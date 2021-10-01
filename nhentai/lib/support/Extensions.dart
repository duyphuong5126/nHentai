import 'package:flutter/cupertino.dart';

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
