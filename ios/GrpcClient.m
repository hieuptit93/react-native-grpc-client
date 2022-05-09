#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(GrpcClient, RCTEventEmitter)

RCT_EXTERN_METHOD(open:(NSString)host withB:(int)port)

RCT_EXTERN_METHOD(close)

@end
