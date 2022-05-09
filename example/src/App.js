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
const options = {
  sampleRate: 16000, // default 44100
  channels: 1, // 1 or 2, default 1
  bitsPerSample: 16, // 8 or 16, default 16
  audioSource: 6, // android only (see below)
  wavFile: 'test.wav', // default 'audio.wav'
};
export default function App() {
  const [text, setText] = useState([]);
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
      showAlertMsg('open');
      AudioRecord.init(options);
      AudioRecord.on('data', (data) => {
        SttGrpc.send(data);
      });
      AudioRecord.start();
    });
    SttGrpc.on('error', (mess) => {
      showAlertMsg(mess);
    });

    SttGrpc.on('message', (data) => {
      console.log(data);
      const res = JSON.parse(data);
      console.log(JSON.stringify(res, null, 2));
      setText(data);
    });

    SttGrpc.on('completed', () => {
      showAlertMsg('completed');
    });
  };

  return (
    <View style={styles.container}>
      <Text>{`Result: ${text}`}</Text>

      <TouchableOpacity style={styles.button} onPress={startRecord}>
        <Text>{'Thu âm'}</Text>
      </TouchableOpacity>
    </View>
  );
}

const showAlertMsg = (msg) => {
  Alert.alert(
    'On Event',
    msg?.toString(),
    [
      {
        text: 'OK',
        onPress: () => {},
      },
    ],
    { cancelable: false }
  );
};

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
