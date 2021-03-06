//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: asr-online.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import SwiftProtobuf


/// Usage: instantiate `StreamingVoice_StreamVoiceClient`, then call methods of this protocol to make API calls.
internal protocol StreamingVoice_StreamVoiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: StreamingVoice_StreamVoiceClientInterceptorFactoryProtocol? { get }

  func sendVoice(
    callOptions: CallOptions?,
    handler: @escaping (StreamingVoice_TextReply) -> Void
  ) -> BidirectionalStreamingCall<StreamingVoice_VoiceRequest, StreamingVoice_TextReply>

  func getVersion(
    _ request: StreamingVoice_GetVersionRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<StreamingVoice_GetVersionRequest, StreamingVoice_GetVersionReponse>
}

extension StreamingVoice_StreamVoiceClientProtocol {
  internal var serviceName: String {
    return "streaming_voice.StreamVoice"
  }

  /// Bidirectional streaming call to SendVoice
  ///
  /// Callers should use the `send` method on the returned object to send messages
  /// to the server. The caller should send an `.end` after the final message has been sent.
  ///
  /// - Parameters:
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ClientStreamingCall` with futures for the metadata and status.
  internal func sendVoice(
    callOptions: CallOptions? = nil,
    handler: @escaping (StreamingVoice_TextReply) -> Void
  ) -> BidirectionalStreamingCall<StreamingVoice_VoiceRequest, StreamingVoice_TextReply> {
    return self.makeBidirectionalStreamingCall(
      path: "/streaming_voice.StreamVoice/SendVoice",
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeSendVoiceInterceptors() ?? [],
      handler: handler
    )
  }

  /// Unary call to GetVersion
  ///
  /// - Parameters:
  ///   - request: Request to send to GetVersion.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getVersion(
    _ request: StreamingVoice_GetVersionRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<StreamingVoice_GetVersionRequest, StreamingVoice_GetVersionReponse> {
    return self.makeUnaryCall(
      path: "/streaming_voice.StreamVoice/GetVersion",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetVersionInterceptors() ?? []
    )
  }
}

internal protocol StreamingVoice_StreamVoiceClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'sendVoice'.
  func makeSendVoiceInterceptors() -> [ClientInterceptor<StreamingVoice_VoiceRequest, StreamingVoice_TextReply>]

  /// - Returns: Interceptors to use when invoking 'getVersion'.
  func makeGetVersionInterceptors() -> [ClientInterceptor<StreamingVoice_GetVersionRequest, StreamingVoice_GetVersionReponse>]
}

internal final class StreamingVoice_StreamVoiceClient: StreamingVoice_StreamVoiceClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: StreamingVoice_StreamVoiceClientInterceptorFactoryProtocol?

  /// Creates a client for the streaming_voice.StreamVoice service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: StreamingVoice_StreamVoiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol StreamingVoice_StreamVoiceProvider: CallHandlerProvider {
  var interceptors: StreamingVoice_StreamVoiceServerInterceptorFactoryProtocol? { get }

  func sendVoice(context: StreamingResponseCallContext<StreamingVoice_TextReply>) -> EventLoopFuture<(StreamEvent<StreamingVoice_VoiceRequest>) -> Void>

  func getVersion(request: StreamingVoice_GetVersionRequest, context: StatusOnlyCallContext) -> EventLoopFuture<StreamingVoice_GetVersionReponse>
}

extension StreamingVoice_StreamVoiceProvider {
  internal var serviceName: Substring { return "streaming_voice.StreamVoice" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "SendVoice":
      return BidirectionalStreamingServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<StreamingVoice_VoiceRequest>(),
        responseSerializer: ProtobufSerializer<StreamingVoice_TextReply>(),
        interceptors: self.interceptors?.makeSendVoiceInterceptors() ?? [],
        observerFactory: self.sendVoice(context:)
      )

    case "GetVersion":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<StreamingVoice_GetVersionRequest>(),
        responseSerializer: ProtobufSerializer<StreamingVoice_GetVersionReponse>(),
        interceptors: self.interceptors?.makeGetVersionInterceptors() ?? [],
        userFunction: self.getVersion(request:context:)
      )

    default:
      return nil
    }
  }
}

internal protocol StreamingVoice_StreamVoiceServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'sendVoice'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeSendVoiceInterceptors() -> [ServerInterceptor<StreamingVoice_VoiceRequest, StreamingVoice_TextReply>]

  /// - Returns: Interceptors to use when handling 'getVersion'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetVersionInterceptors() -> [ServerInterceptor<StreamingVoice_GetVersionRequest, StreamingVoice_GetVersionReponse>]
}
