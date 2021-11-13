import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/component/DefaultScreenTitle.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 1)).then((value) =>
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Constant.mainDarkColor,
            systemStatusBarContrastEnforced: true)));
    return Scaffold(
      appBar: AppBar(
        title: DefaultScreenTitle('More'),
        centerTitle: true,
        backgroundColor: Constant.mainColor,
      ),
      body: Container(
        color: Colors.white,
      ),
    );
  }
}
