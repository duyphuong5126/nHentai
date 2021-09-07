import 'package:flutter/material.dart';
import 'package:nhentai/text_widget/DefaultScreenTitle.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DefaultScreenTitle('Download'),
        centerTitle: true,
        backgroundColor: Colors.green[500],
      ),
      body: Container(
        color: Colors.white,
      ),
    );
  }
}
