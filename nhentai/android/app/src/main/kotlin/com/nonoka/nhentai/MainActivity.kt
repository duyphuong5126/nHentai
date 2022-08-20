package com.nonoka.nhentai

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.apache.commons.text.StringEscapeUtils

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "parseJson") {
                val rawJson = (call.arguments as? String).orEmpty()
                val finalJson =
                    StringEscapeUtils.unescapeJava(rawJson)
                result.success(finalJson)
            } else {
                result.notImplemented()
            }
        }
    }

    companion object {
        private const val CHANNEL = "com.nonoka.nhentai/jsonParsing"
    }
}
