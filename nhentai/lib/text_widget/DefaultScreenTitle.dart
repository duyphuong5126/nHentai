import 'package:flutter/material.dart';

class DefaultScreenTitle extends StatelessWidget {
  final String title;

  DefaultScreenTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 20.0,
          fontFamily: 'NunitoBlack',
          letterSpacing: 1.5,
          color: Colors.white),
    );
  }
}
