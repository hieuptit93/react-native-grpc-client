#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(GrpcClient, NSObject)

RCT_EXTERN_METHOD(startStream:(float)a withB:(float)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

@end
