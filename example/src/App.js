import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { startStream } from 'react-native-grpc-client';
import { useState } from 'react';

export default function App() {
  const [text, setText] = useState([]);

  React.useEffect(() => {
    startStream('103.141.140.189', 9100).then((t) => {
     setText(t)
    });
  }, []);

  return (
    <View style={styles.container}>
      <Text>{`Result: ${text}`}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'red',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
