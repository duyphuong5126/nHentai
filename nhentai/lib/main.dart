import 'package:flutter/material.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/page/DoujinshiPage.dart';
import 'package:nhentai/page/DoujinshiGallery.dart';
import 'package:nhentai/page/HomePage.dart';

void main() {
  runApp(MaterialApp(
    routes: {
      '/': (context) => HomePage(),
      MainNavigator.DOUJINSHI_GALLERY: (context) => DoujinshiGallery(),
      MainNavigator.DOUJINSHI_PAGE: (context) => DoujinshiPage()
    },
    debugShowCheckedModeBanner: false,
  ));
}
