#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(GrpcClient, NSObject)

RCT_EXTERN_METHOD(open:(NSString)host withB:(int)port)

RCT_EXTERN_METHOD(close:)

@end
