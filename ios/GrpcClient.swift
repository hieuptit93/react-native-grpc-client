import Foundation
import GRPC
import NIO
import NIOSSL
import UIKit
import AVFoundation
import React

@objc(GrpcClient)
class GrpcClient: NSObject {
    
    public var emitter: RCTEventEmitter!
    
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
            
            let callOptions = CallOptions(customMetadata: [
                "channels": "1",
                "rate": "16000",
                "format": "S16LE",
                "token": "stepupenglish",
                "single-sentence": "True"
            ])
            let greeter = StreamingVoice_StreamVoiceClient.init(channel: mChannel, defaultCallOptions: callOptions)
            
            let callback = greeter.sendVoice(callOptions: callOptions) { StreamingVoice_TextReply in
                       if StreamingVoice_TextReply.hasResult == false {
                           return
                       }
                       print(StreamingVoice_TextReply)
                       let resultFinal = StreamingVoice_TextReply.result.final
                       let lastResult = StreamingVoice_TextReply.result.hypotheses[0].transcript
                       print(resultFinal, lastResult)
                       
                   }
            
            let request = self.send(dataString: "")

                let event = callback.sendMessage(request!)
                    event.whenComplete { result in
                        print("v221", result)
                    }
                    event.whenSuccess { success in
                        print("v1", success)
                    }
                    event.whenFailure { error in
                        print("v", error)
                    }
        
            
        }
        catch {
            //handle error
            print(error)
        }
        
    }

    
    @objc
    func close() -> Void {
        print("close")
    }
    
    func send(dataString: String) -> StreamingVoice_VoiceRequest? {
        let textSample = "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"
        var voice = StreamingVoice_VoiceRequest.with { StreamingVoice_VoiceRequest in
            print("Test")
        }
        let data: Data = Data(base64Encoded: textSample, options: NSData.Base64DecodingOptions(rawValue: 0))!
        voice.byteBuff = data
            return voice
        }

}

