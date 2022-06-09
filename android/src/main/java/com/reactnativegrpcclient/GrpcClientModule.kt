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
import com.facebook.react.bridge.Callback;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.FieldNamingPolicy
import com.google.gson.FieldNamingStrategy


class GrpcClientModule(private val reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  lateinit var request: StreamObserver<VoiceRequest>
  var eventEmitter: DeviceEventManagerModule.RCTDeviceEventEmitter? = null
  val gson = GsonBuilder().setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES)
    .setFieldNamingStrategy { it ->
      when (it.name) {
        "id_" -> "id"
        "msg_" -> "msg"
        "result_" -> "result"
        "hypotheses_" -> "hypotheses"
        "confidence_" -> "confidence"
        "likelihood_" -> "likelihood"
        "transcriptNormedUrlencoded_" -> "transcript_normed_urlencoded"
        "transcriptNormed_" -> "transcript_normed"
        "transcriptUrlencoded_" -> "transcript_urlencoded"
        "transcript_" -> "transcript"
        "final_" -> "final"
        "segmentStart_" -> "segment_start"
        "segmentLength_" -> "segment_length"
        "totalLength_" -> "total_length"
        "audioUrl_" -> "audio_url"
        else -> {
          it.name
        }
      }
    }.create()

  override fun getName(): String {
    return "GrpcClient"
  }

  @ReactMethod
  fun open(host: String, port: Int) {
    eventEmitter = reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
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
    asyncStubSingle = MetadataUtils.attachHeaders<StreamVoiceGrpc.StreamVoiceStub>(
      StreamVoiceGrpc.newStub(mChannel),
      header1
    )

    try {
      val responseObserver = object : StreamObserver<TextReply> {
        //Định nghĩa sẽ làm gì với TextReply asr_response trả về:
        override fun onNext(textReply: TextReply) {
//          if (!textReply.hasResult()) return
          val jsonString = gson.toJson(textReply)
          Log.d("startStream Final result:", jsonString)
//          Log.d("startStream Final resultFinal:", resultFinal)
          onMessage(jsonString)
        }

        //Định nghĩa các việc sẽ làm nếu server trả về lỗi nào đó
        override fun onError(throwable: Throwable) {
          // Already stopAsr
          Log.d("startStream error", throwable.message?:"")
          onError(throwable.message)
        }

        //Định nghĩa những việc sẽ làm khi server kết thúc stream
        override fun onCompleted() {
          // Already stopAsr
          Log.d("startStream Done", "")
          onCompeleted()
        }
      }
      request = asyncStubSingle.sendVoice(responseObserver)
      onOpen()
    } catch (e: Exception) {
      Log.d("startStream errrr", e.toString())
      onError(e.message)
    }
  }

  fun onOpen() {
    eventEmitter?.emit("open", null);
  }

  fun onCompeleted() {
    eventEmitter?.emit("completed", null);
  }

  fun onError(message: String?) {
    eventEmitter?.emit("error", message);
  }

  fun onMessage(data: String?) {
    eventEmitter?.emit("message", data);
  }

  @ReactMethod
  fun send(data: String?) {
    try {
      val decodeStringBytesAudio: ByteArray = Base64.decode(data, Base64.NO_WRAP)
      request.onNext(
        VoiceRequest.newBuilder().setByteBuff(ByteString.copyFrom(decodeStringBytesAudio)).build()
      )
    } catch (e: Exception) {
      Log.d("startStream errrr", e.toString())
      onError(e.message)
    }
  }

  @ReactMethod
  fun close() {
    try {
      //gửi thông báo hết audio cho server
      request.onCompleted()
    } catch (e: Exception) {
      Log.d("startStream errrr", e.toString())
      onError(e.message)
    }
  }

  @ReactMethod
  fun cancel() {
    try {
      //gửi thông báo ngắt kết nối cho server
      request.onError(null)
    } catch (e: Exception) {
      Log.d("startStream errrr", e.toString())
      onError(e.message)
    }
  }

}
