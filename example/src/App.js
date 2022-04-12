import * as React from 'react';

import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { startStream } from 'react-native-grpc-client';
import Permissions, {openSettings} from "react-native-permissions";
import { useState, useEffect } from 'react';
import AudioRecord from 'react-native-audio-record';
import { Buffer } from 'buffer';
const options = {
  sampleRate: 16000,  // default 44100
  channels: 1,        // 1 or 2, default 1
  bitsPerSample: 16,  // 8 or 16, default 16
  audioSource: 6,     // android only (see below)
  wavFile: "test.wav", // default 'audio.wav'
};
export default function App() {
  const [text, setText] = useState([]);
  const [isPermission, setPermission] = useState(false);

  useEffect(() => {
    checkPermission();
  }, [])


  const checkPermission = async () => {
    const p = await Permissions.check(
      Platform.OS === 'android'
        ? Permissions.PERMISSIONS.ANDROID.RECORD_AUDIO
        : Permissions.PERMISSIONS.IOS.MICROPHONE,
    );
    if (p === 'granted') {
      setPermission(true)
      return true;
    }
    if (p === 'blocked') {
      setPermission(false)
      return openSettings();
    }
    return requestPermission();
  };

  const requestPermission = async () => {
    const p = await Permissions.request(
      Platform.OS === 'android'
        ? Permissions.PERMISSIONS.ANDROID.RECORD_AUDIO
        : Permissions.PERMISSIONS.IOS.MICROPHONE,
    );
  };

  const startRecord = () => {
    AudioRecord.init(options);
    AudioRecord.on("data", data => {
      const buf = Buffer.from(data, "base64");
      const destination = new Uint16Array(buf.buffer, buf.byteOffset, buf.length / Uint16Array.BYTES_PER_ELEMENT);
      console.log('data', data)
      console.log('buf', buf)
      startStream('103.141.140.189', 9100, data).then((t) => {
        setText(t)
      });
    });
     AudioRecord.start();
//    startStream('103.141.140.189', 9100, "null").then((t) => {
//      setText(t)
//    });
  }

  return (
    <View style={styles.container}>
      <Text>{`Result: ${text}`}</Text>

      <TouchableOpacity style={styles.button} onPress={startRecord}>
        <Text>{'Thu âm'}</Text>
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
    backgroundColor: 'red',
    alignItems: 'center',
    justifyContent: 'center'
  }
});
