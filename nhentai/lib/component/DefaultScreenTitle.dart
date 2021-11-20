import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class DefaultScreenTitle extends StatelessWidget {
  final String title;

  DefaultScreenTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 20.0,
          fontFamily: Constant.BOLD,
          letterSpacing: 1.5,
          color: Colors.white),
    );
  }
}
