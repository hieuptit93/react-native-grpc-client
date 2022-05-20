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

    @objc func onMessage(data: Any?) {
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
                self.onMessage(data:StreamingVoice_TextReply.result)
                print(resultFinal, lastResult)

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
//        self.callback.sendEnd()
    }

    @objc(send:)
    func send(data: String) -> Void {
        var voice = StreamingVoice_VoiceRequest.with { StreamingVoice_VoiceRequest in
            print("Test")
        }
        let data:Data = Data(base64Encoded: data, options: NSData.Base64DecodingOptions(rawValue: 0))!
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
            self.onError(message: error.localizedDescription)
        }
    }
}
