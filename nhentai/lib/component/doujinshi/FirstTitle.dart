import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class FirstTitle extends StatefulWidget {
  final String text;

  const FirstTitle({Key? key, required this.text}) : super(key: key);

  @override
  _FirstTitleState createState() => _FirstTitleState();
}

class _FirstTitleState extends State<FirstTitle> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: TextStyle(
          fontFamily: Constant.BOLD,
          fontSize: 20,
          color: Colors.white),
    );
  }
}
