@objc(GrpcClient)
class GrpcClient: NSObject {

    @objc(startStream:withB:withResolver:withRejecter:)
    func startStream(host: String, port: Int, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        resolve(host)
    }
}
