import {NativeModules, Platform, NativeEventEmitter} from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-grpc-client' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ios: "- You have run 'pod install'\n", default: ''}) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const GrpcClient = NativeModules.GrpcClient
  ? NativeModules.GrpcClient
  : new Proxy(
    {},
    {
      get() {
        throw new Error(LINKING_ERROR);
      },
    }
  );

export function multiply(a: number, b: number): Promise<number> {
  return GrpcClient.multiply(a, b);
}

export function startStream(a: string, b: number, c: string): Promise<any> {
  return GrpcClient.startStream(a, b, c);
}

const EventEmitter = new NativeEventEmitter(GrpcClient);

const eventsMap = {
  data: 'data',
  open: 'open',
  error: 'error',
  completed: 'completed',
  message: 'message',
};

const SttGrpc = {
  open: (host: string, post: number) => GrpcClient.open(host, post),
  close: () => GrpcClient.close(),
  on: (event: "data", callback: (data: string) => void) => {
    const nativeEvent = eventsMap[event];
    if (!nativeEvent) {
      throw new Error('Invalid event');
    }
    EventEmitter.removeAllListeners(nativeEvent);
    return EventEmitter.addListener(nativeEvent, callback);
  },
  send: (data: string) => GrpcClient.send(data)
}

export default SttGrpc
