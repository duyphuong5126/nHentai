import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class DoujinshiPage extends StatefulWidget {
  const DoujinshiPage({Key? key}) : super(key: key);

  @override
  _DoujinshiPageState createState() => _DoujinshiPageState();
}

class _DoujinshiPageState extends State<DoujinshiPage> {
  Map initialData = {};

  @override
  Widget build(BuildContext context) {
    if (initialData.isEmpty) {
      var arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map) {
        initialData = arguments;
      }
    }
    print('Book ID ${initialData[Constant.BOOK_ID]}');
    return Scaffold(
      body: SafeArea(
        child: Expanded(
          child: Image.network(initialData[Constant.BOOK_COVER_URL]),
        ),
      ),
    );
  }
}
