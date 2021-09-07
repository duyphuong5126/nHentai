import 'package:flutter/material.dart';
import 'package:nhentai/text_widget/DefaultScreenTitle.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DefaultScreenTitle('More'),
        centerTitle: true,
        backgroundColor: Colors.green[500],
      ),
      body: Container(
        color: Colors.white,
      ),
    );
  }
}
