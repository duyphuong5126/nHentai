import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class SecondTitle extends StatefulWidget {
  final String text;

  const SecondTitle({Key? key, required this.text}) : super(key: key);

  @override
  _SecondTitleState createState() => _SecondTitleState();
}

class _SecondTitleState extends State<SecondTitle> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: TextStyle(
          fontFamily: Constant.BOLD, fontSize: 18, color: Colors.white),
    );
  }
}
