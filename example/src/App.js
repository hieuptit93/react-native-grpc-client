import * as React from 'react';

import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  Alert,
  Platform,
} from 'react-native';
import SttGrpc from 'react-native-grpc-client';
import Permissions, { openSettings } from 'react-native-permissions';
import { useState, useEffect } from 'react';
import AudioRecord from 'react-native-audio-record';
import { Buffer } from 'buffer';

const MOCK_DATA = "Lv5f/0T/gf+Z/3//HwBT/xMAagAPAIcAu//fAJL/jQBdAI0ABQFtAK4BSQCWAfkAsQGHAY4BewFlARgBVQEKAS4BjQAaAR8BPwFsAVQAwACaANIARgAmALT/TgBm/yP/Kf8i/xT/nP+D/mH/gv7n/nX/Tv/n/3D/9/9G/+z/u//S/5X/BADQ/1cAxf/m/8n/TgC5//f/PQCx//3/iv8nADMAWAErAPAAvQAjAXUBpwAFAaAAZgHKAPcAagDyAD4BCQFGATAA0AAmAOEA+P/1/6kAUQASAGT/l/+v/jv/ev6G/X39Df30/ZL9Mf6Q/hT+vf7k/hoAqf8PABIAJQAr/4n/CwCb/wH/3P4LAJL/IgDO/7r/PAChAEkAegC6ArQAcQF9AE0AFP+i/9MAnP2OAX7+UAFt/yMBvP9DADQA2P6EAdn++gG4/4sBRQBcAuL/eQAJAc4AlADsAK8AsP9nAUsAkgHMADkB0f8FAKL/Tv9U/5H+N/+X/u/+LgAHAJf/6v6IAC//FwCbADcADAA8APH/i/9RAJ7/qv/N/37/vf6G/8H+cv8o/3H+TQBr/i0AaACi/oMB+P6wAG0AtABCAPcA/AHN/3oB4P9QAagAeAEgASkAcAEgAIkBgQAcAKEAif/g/xgAwP7P/0j/T/8G/wj+M//c/ZX/Ev7Y/9b/Mv+AAPL/Ev/n/57/wv7a/wH//v+N/vX/tf7J/5f/CwAL/7n/w//O/kr/t/62/yb/af+J/uD/Zf+nAKv/zf/p/wcAZADDAKkA9wDnAAQBywC2Ab8BZAF2AcsAzAB7AH0BVQBzATgBCAHRAaQBqQGnADsBZwCEAOf/BgDm/yD/uv+1/WD/Xf6U/7D+g/+G/0gAdgBDAFAA1v8oAPz/cQC+/9z/Pv9RABv/kf8u/8P/1f43/0X+Tv9p/33/DgBaAPYARgHkADcByQC4AEIBqADXAb8A/QFmASMCTgFEAeMAjgCGALgAzv+H/wMAU/9r/yb/XP+l/v3/vf7h/rz+7/7n/gn+Sv/8/W7/hP5F/zn/7/46AHv/n/9n/t//JP+p/2v/VP9VAJH/OADd/7UA8QAAAagAsQA6AVgAFAFGALMAjQAJADEAlgAFAEwAUADl/78AbwCqACEAqwA9AJMA6f+LAKQAmgBdAJsAvgB9ABcBeQA1AHkApQC+AHoAFgAHARQAtwAzAHP/hwD//zQAgP/M//7/sf/l/2f/9P/R/0sAHv86AEn/ZP8fADL/FQBx/3YAEf/K/5H/Iv8X/0f++f5p/iH/qf5t/0n/7/8sAN///f9j/5v/MP9MAMH+Z/+n/4L/ggAmADoAHQBFABwAIAHjAIgA6AATAJoAuAB+AIoAggDzAIQAtwAXAH0ATgCgAP4ALQDVAMP/DwB3ANX/xP/u/zoARAC//4X/dQD2/5z/bf/6/h3/hf+p/3P/nf8Q/xT/c/7b/xgAFP8wAH7/+v92/y8AvwB+AI0A7P9HAOz/QgAPAMkAyQCQAMsAiwCBAIcARwCcAGgACwABAPv/FgFmAJ8AmgCgAGIAZgCYABoASADf/07/kv9a/7v////z/73/vv/0/2H/u/8Y/3//N/8Y/4T/uf++/+D/vv9t/2z/lP/+/pL/1/9k//L/wf8iAD8A2QDCAO0AmAECAXEBlwERAacB8QCfAKv/IADz/yYAt//P/7z/yf9OAHr/JgD8/5oAEgA="

const options = {
  sampleRate: 16000, // default 44100
  channels: 1, // 1 or 2, default 1
  bitsPerSample: 16, // 8 or 16, default 16
  audioSource: 6, // android only (see below)
  wavFile: 'test.wav', // default 'audio.wav'
};

export default function App() {
  const [text, setText] = useState([]);
  const [textEvent, setTextEvent] = useState([]);
  const [isPermission, setPermission] = useState(false);

  useEffect(() => {
    // checkPermission();
  }, []);

  const checkPermission = async () => {
    const p = await Permissions.check(
      Platform.OS === 'android'
        ? Permissions.PERMISSIONS.ANDROID.RECORD_AUDIO
        : Permissions.PERMISSIONS.IOS.MICROPHONE
    );
    if (p === 'granted') {
      setPermission(true);
      return true;
    }
    if (p === 'blocked') {
      setPermission(false);
      return openSettings();
    }
    return requestPermission();
  };

  const requestPermission = async () => {
    const p = await Permissions.request(
      Platform.OS === 'android'
        ? Permissions.PERMISSIONS.ANDROID.RECORD_AUDIO
        : Permissions.PERMISSIONS.IOS.MICROPHONE
    );
  };

  const startRecord = () => {
    SttGrpc.close();
    SttGrpc.open('103.141.141.13', 9001);
    SttGrpc.on('open', () => {
      showAlertMsg(`onOpen`);
      setText("")
      AudioRecord.init(options);
      AudioRecord.on('data', (data) => {
        // SttGrpc.send(data);
        // console.log(data)
        SttGrpc.send(MOCK_DATA)
      });
      AudioRecord.start();
    });
    SttGrpc.on('error', (mess) => {
      showAlertMsg(`onError ${mess}`);
      AudioRecord.stop();
    });

    SttGrpc.on('message', (data) => {
      showAlertMsg(`onMessage`);
      console.log(data);
      const res = JSON.parse(data);
      console.log(JSON.stringify(res, null, 2));
      setText(data);
    });

    SttGrpc.on('completed', () => {
      showAlertMsg(`onCompleted`);
      AudioRecord.stop();
    });
  };

  const stopRecord = ()=>{
    AudioRecord.stop();
    SttGrpc.close()
  }

  const cancelRecord = ()=>{
    AudioRecord.stop();
    SttGrpc.cancel()
  }

  const showAlertMsg = (msg) => {
    // Alert.alert(
    //   'On Event',
    //   msg?.toString(),
    //   [
    //     {
    //       text: 'OK',
    //       onPress: () => {},
    //     },
    //   ],
    //   { cancelable: false }
    // );
    setTextEvent(msg)
  };

  return (
    <View style={styles.container}>
      <Text>{`Event: ${textEvent}`}</Text>
      <Text>{`Result: ${text}`}</Text>

      <TouchableOpacity style={styles.button} onPress={startRecord}>
        <Text>{'Thu âm'}</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.button} onPress={stopRecord}>
        <Text>{'Stop'}</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.button} onPress={cancelRecord}>
        <Text>{'Cancel'}</Text>
      </TouchableOpacity>
    </View>
  );
}


const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'white',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
  button: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'green',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
