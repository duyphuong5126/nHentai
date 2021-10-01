import 'package:flutter/material.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/bloc/DoujinshiBloc.dart';
import 'package:nhentai/page/DoujinshiDetailPage.dart';
import 'package:nhentai/page/DoujinshiGallery.dart';
import 'package:nhentai/page/HomePage.dart';
import 'package:nhentai/page/ReaderPage.dart';

void main() {
  runApp(MaterialApp(
    routes: {
      '/': (context) => HomePage(),
      MainNavigator.DOUJINSHI_GALLERY: (context) => DoujinshiGallery(),
      MainNavigator.DOUJINSHI_PAGE: (context) => DoujinshiPage(
            doujinshiBloc: DoujinshiBloc(),
          ),
      MainNavigator.DOUJINSHI_READER_PAGE: (context) => ReaderPage()
    },
    debugShowCheckedModeBanner: false,
  ));
}
