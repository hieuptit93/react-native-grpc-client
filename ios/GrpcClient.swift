import Foundation
import GRPC
import NIO
import NIOSSL

@objc(GrpcClient)
class GrpcClient: NSObject {

    @objc(startStream:withB:withResolver:withRejecter:)
    func startStream(host: String, port: Int, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        defer {
          try? group.syncShutdownGracefully()
        }

        do {
            let mChannel = try GRPCChannelPool.with(
              target: .host(host, port: port),
              transportSecurity: .plaintext,
              eventLoopGroup: group)
            let stub = StreamingVoice_StreamVoiceClient.init(channel: mChannel)
            print(stub.serviceName)
        } catch {
            //handle error
//            print(error)
        }
        
        
        
        

        
        resolve(host)
    }

    

}

