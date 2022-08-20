import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension ContextExtension on BuildContext {
  void closeSoftKeyBoard() {
    FocusScope.of(this).requestFocus(FocusNode());
  }
}

extension WebViewControllerExtension on WebViewController {
  Future<String> get body async => (await runJavascriptReturningResult(
          "(function() { return ('<html>'+document.getElementsByTagName('body')[0].innerText+'</html>'); })();"))
      .replaceAll("\"\\u003Chtml>", "")
      .replaceAll("\\u003C/html>\"", "");
}
