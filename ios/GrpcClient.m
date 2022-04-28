#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(GrpcClient, NSObject)

RCT_EXTERN_METHOD(startStream:(NSString)host withB:(int)port
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

@end
