#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(GrpcClient, NSObject)

RCT_EXTERN_METHOD(startStream:(int)host withB:(int)port
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

@end
