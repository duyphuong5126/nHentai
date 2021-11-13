import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/component/DefaultScreenTitle.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 1)).then((value) =>
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Constant.mainDarkColor,
            systemStatusBarContrastEnforced: true)));
    return Scaffold(
      appBar: AppBar(
        title: DefaultScreenTitle('Download'),
        centerTitle: true,
        backgroundColor: Constant.mainColor,
      ),
      body: Container(
        color: Colors.white,
      ),
    );
  }
}
