import Foundation
import GRPC
import NIO
import NIOSSL
import UIKit
import AVFoundation
import React

@objc(GrpcClient)
class GrpcClient: NSObject {
    
    public static var emitter: RCTEventEmitter!
    
    @objc(open:withB:)
    func open(host: String, port: Int) -> Void {
        
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        defer {
          try? group.syncShutdownGracefully()
        }
        do {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

            let keepalive = ClientConnectionKeepalive(
              interval: .seconds(15),
              timeout: .seconds(10)
            )

            let mChannel = try GRPCChannelPool.with(
              target: .hostAndPort(host, port),
              transportSecurity: .plaintext,
              eventLoopGroup: group
            ) {
              // Configure keepalive.
              $0.keepalive = keepalive
            }
           
            let greeter = StreamingVoice_StreamVoiceClient.init(channel: mChannel)
            greeter.defaultCallOptions.customMetadata.add(name: "channels", value: "1")
            greeter.defaultCallOptions.customMetadata.add(name: "rate", value: "16000")
            greeter.defaultCallOptions.customMetadata.add(name: "format", value: "S16LE")
            greeter.defaultCallOptions.customMetadata.add(name: "token", value: "stepupenglish")
            greeter.defaultCallOptions.customMetadata.add(name: "single-sentence", value: "True")
            
    
            print(greeter)
            
        }
        catch {
            //handle error
            print(error)
        }
        
    }

    
    @objc
    func close() {
        print("close")
    }

}

