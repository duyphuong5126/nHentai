import 'package:flutter/services.dart';

class WebNetworkService {
  static const jsonParsingPlatform =
      MethodChannel('com.nonoka.nhentai/jsonParsing');

  static Future<String> unescapeBodyString(String webBodyString) async {
    String json = await jsonParsingPlatform.invokeMethod(
        'parseJson', webBodyString) as String;
    return json;
  }
}
