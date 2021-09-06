import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final Color textColor;

  SectionLabel(this.label, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style:
          TextStyle(fontSize: 16.0, fontFamily: 'NunitoBold', color: textColor),
    );
  }
}
