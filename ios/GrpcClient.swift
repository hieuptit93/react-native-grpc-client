import Foundation
import GRPC
import NIO
import NIOSSL
import UIKit
import AVFoundation
import React


@objc(GrpcClient)
public class GrpcClient: RCTEventEmitter {
    public var emitter: RCTEventEmitter!
    var callback: BidirectionalStreamingCall<StreamingVoice_VoiceRequest, StreamingVoice_TextReply>!
    public var encoder = JSONEncoder()
    public var isEmitting = true
    override init() {
        super.init()
        emitter = self
    }

    @objc open override func supportedEvents() -> [String]! {
        return ["open", "error", "completed", "message", "data"]
    }

    @objc func onOpen() {
        if(isEmitting) {
           emitter.sendEvent(withName: "open", body: [])
        }
    }

    @objc func onCompeleted() {
     if(isEmitting) {
               emitter.sendEvent(withName: "completed", body: [])
            }
    }

    @objc func onError(message: String?) {
     if(isEmitting) {
          emitter.sendEvent(withName: "error", body: message)
            }
    }

    @objc func onMessage(data: String?) {
        if(isEmitting) {
          emitter.sendEvent(withName: "message", body: data)
        }
    }



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
            self.callback = greeter.sendVoice(callOptions: callOptions) { StreamingVoice_TextReply in
                if StreamingVoice_TextReply.hasResult == false {
                    return
                }
                print("StreamingVoice_TextReply", StreamingVoice_TextReply)
                let resultFinal = StreamingVoice_TextReply.result.final
                let lastResult = StreamingVoice_TextReply.result.hypotheses[0].transcript
                self.encoder.outputFormatting = .prettyPrinted
                do {
                    let data = try self.encoder.encode(StreamingVoice_TextReply)
                    self.onMessage(data : String(data: data, encoding: .utf8)!)
                } catch {
                    self.onError(message: error.localizedDescription)
                }
                print(resultFinal, lastResult)
            }
            self.callback.status.whenComplete { result in
                self.onCompeleted()
            }
            self.callback.status.whenFailure { error in
                self.onError(message: error.localizedDescription)
            }
            onOpen()
        }
        catch {
            //handle error
            print(error)
        }
    }


    @objc
    func close() -> Void {
//         emitter.stopObserving();
       self.callback.sendEnd(promise: nil)
       _ = try! self.callback.status.wait()
    }
  
    @objc
    func cancel() -> Void {
        self.onError(message: "close")
    }

    @objc(send:)
    func send(text: String) -> Void {
        var voice = StreamingVoice_VoiceRequest.with { StreamingVoice_VoiceRequest in}
        let data:Data = Data(base64Encoded: text, options: NSData.Base64DecodingOptions(rawValue: 0))!
        //        let data: Data = Data(base64Encoded: textSample, options: NSData.Base64DecodingOptions(rawValue: 0))!
        voice.byteBuff = data

        let event = self.callback.sendMessage(voice)
        event.whenComplete { result in
            print("complete", result)
//             self.onCompeleted()
        }
        event.whenSuccess { success in
            print("success", success)
        }
        event.whenFailure { error in
            print("v", error)
//             self.onError(message: error.localizedDescription)
        }
    }
}

