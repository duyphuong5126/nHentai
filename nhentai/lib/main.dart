import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/page/DoujinshiPage.dart';
import 'package:nhentai/page/HomePage.dart';
import 'package:nhentai/page/ReaderPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(MaterialApp(
    routes: {
      '/': (context) => HomePage(),
      MainNavigator.DOUJINSHI_PAGE: (context) => DoujinshiPage(),
      MainNavigator.DOUJINSHI_READER_PAGE: (context) => ReaderPage()
    },
    debugShowCheckedModeBanner: false,
  ));
}
