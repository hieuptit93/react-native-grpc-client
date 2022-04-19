package com.reactnativegrpcclient

import android.content.res.AssetManager
import android.util.Log
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.google.protobuf.ByteString
import io.grpc.ManagedChannelBuilder
import io.grpc.Metadata
import io.grpc.stub.MetadataUtils
import io.grpc.stub.StreamObserver
import service.StreamVoiceGrpc
import service.TextReply
import service.VoiceRequest
import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.util.concurrent.TimeUnit
import android.util.Base64;
import com.facebook.react.bridge.ReadableArray;


class GrpcClientModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
        return "GrpcClient"
    }

    @ReactMethod
    fun startStream(host: String, port: Int, data: String?, promise: Promise) {
      val asyncStubSingle: StreamVoiceGrpc.StreamVoiceStub;
      val mChannel = ManagedChannelBuilder
        .forAddress(host, port)
        .usePlaintext()
        .keepAliveTime(30, TimeUnit.SECONDS)
        .keepAliveWithoutCalls(true)
        .build()

      val header1 = Metadata()
      header1.put(Metadata.Key.of("channels", Metadata.ASCII_STRING_MARSHALLER), "1")
      header1.put(Metadata.Key.of("rate", Metadata.ASCII_STRING_MARSHALLER), "16000")
      header1.put(Metadata.Key.of("format", Metadata.ASCII_STRING_MARSHALLER), "S16LE")
      header1.put(Metadata.Key.of("token", Metadata.ASCII_STRING_MARSHALLER), "stepupenglish")
      header1.put(Metadata.Key.of("single-sentence", Metadata.ASCII_STRING_MARSHALLER), "True")
      asyncStubSingle = MetadataUtils.attachHeaders<StreamVoiceGrpc.StreamVoiceStub>(StreamVoiceGrpc.newStub(mChannel), header1)
      val responseObserver = object : StreamObserver<TextReply> {
        //Định nghĩa sẽ làm gì với TextReply asr_response trả về:
        override fun onNext(textReply: TextReply) {
//          if (!textReply.hasResult()) return
          val resultFinal = textReply.result.final
          val lastResult = textReply.result.getHypotheses(0).transcript
          Log.d("startStream Final result:", lastResult)
//          Log.d("startStream Final resultFinal:", resultFinal)
          if(resultFinal) {
            promise.resolve(lastResult)
            return
          }

        }

        //Định nghĩa các việc sẽ làm nếu server trả về lỗi nào đó
        override fun onError(throwable: Throwable) {
          // Already stopAsr
          Log.d("startStream error", throwable.message);
        }

        //Định nghĩa những việc sẽ làm khi server kết thúc stream
        override fun onCompleted() {
          // Already stopAsr
          Log.d("startStream Done", "");
        }
      }
      try {
        val request: StreamObserver<VoiceRequest> = asyncStubSingle.sendVoice(responseObserver)
//        val bi = BufferedInputStream(FileInputStream(  (reactApplicationContext.getExternalFilesDir("test.wav"))))
//        val byte_buff = ByteArray(8000)
//        //dùng để khởi tạo 1 phiên ASR ở server  kèm mã xác thực và 1 mảng byte để tiết kiệm tài nguyên
//        //gửi audio đến server
//        while (bi.read(byte_buff, 0, byte_buff.size) !== -1) {
//          request.onNext(
//            VoiceRequest.newBuilder().setByteBuff(ByteString.copyFrom(byte_buff)).build()
//          )
//        }
//        bi.close()
        //gửi thông báo hết audio cho server
        val decodeStringBytesAudio: ByteArray = Base64.decode(data, Base64.NO_WRAP)
        val originStr = String(decodeStringBytesAudio)
        request.onNext(
            VoiceRequest.newBuilder().setByteBuff(ByteString.copyFrom(decodeStringBytesAudio)).build()
          )
        request.onCompleted()
      } catch (e: Exception) {
        Log.d("startStream errrr", e.toString())
      }
//      val request = asyncStubSingle.sendVoice(responseObserver)
//      Log.d("hieu", asyncStubSingle.toString())
//      request.onNext(VoiceRequest.newBuilder().setByteBuff(ByteString.copyFrom(ByteArray(1280))).build())

    }


}
