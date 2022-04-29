import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-grpc-client' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
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

export function startStream(a: string, b: number) {
  return GrpcClient.startStream(a, b);
}

export function sendVoice(a: string) {
  return GrpcClient.sendVoice(a);
}
