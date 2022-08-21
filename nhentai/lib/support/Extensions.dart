import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/data/remote/web_network_service.dart';
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

  void showErrorSnackBar(String message,
      {String? actionLabel, Function? action}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red[900],
        duration: Duration(seconds: 5),
        action: SnackBarAction(
            label: actionLabel ?? '', onPressed: () => action?.call()),
        content: Text(message,
            style: TextStyle(
                color: Colors.white,
                fontFamily: Constant.BOLD,
                fontSize: 15))));
  }
}

extension WebViewControllerExtension on WebViewController {
  Future<String> get bodyJson async => (await runJavascriptReturningResult(
          "(function() { return ('<html>'+document.getElementsByTagName('body')[0].innerText+'</html>'); })();")
      .then((json) => json
          .replaceAll("\"\\u003Chtml>", "")
          .replaceAll("\\u003C/html>\"", ""))
      .then((webBodyString) =>
          WebNetworkService.unescapeBodyString(webBodyString)));
}
