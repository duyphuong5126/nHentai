import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nhentai/page/uimodel/ReaderType.dart';
import 'package:nhentai/page/uimodel/reader_screen_coverage.dart';

class Constant {
  static const String NHENTAI_HOME = 'https://nhentai.net';
  static const String NHENTAI_I = 'https://i.nhentai.net';
  static const String NHENTAI_T = 'https://t.nhentai.net';
  static const String MASTER_DATA_HOME =
      'https://raw.githubusercontent.com/duyphuong5126/NHentaiDB/master/nhentai';

  static const String BOOK = 'book';

  static const String CHINESE_LANG = 'chinese';
  static const String JAPANESE_LANG = 'japanese';
  static const String ENGLISH_LANG = 'english';
  static const String TRANSLATED_LANG = 'translated';
  static const String REWROTE_LANG = 'rewrite';
  static const String SPEECHLESS_LANG = 'speechless';
  static const String TEXT_CLEANED_LANG = 'text cleaned';

  static const String IMAGE_LANG_GB = 'images/ic_lang_gb.png';
  static const String IMAGE_LANG_JP = 'images/ic_lang_jp.png';
  static const String IMAGE_LANG_CN = 'images/ic_lang_cn.png';
  static const String IMAGE_LOGO = 'images/ic_nhentai_logo.svg';
  static const String IMAGE_NOTHING = 'images/ic_nothing_here_grey.png';
  static const String LOADING_GIF = 'images/ic_loading_cat_transparent.gif';
  static const String ICON_UN_SEEN = 'images/ic_un_seen.svg';

  static const String REGULAR = 'NotoSans_Regular';
  static const String BOLD = 'NotoSans_Bold';
  static const String ITALIC = 'NotoSans_Italic';
  static const String BOLD_ITALIC = 'NotoSans_BoldItalic';

  static const String DB_ID = '_id';

  static const Map<ReaderType, String> READER_TYPES = {
    ReaderType.LeftToRight: 'Left to right',
    ReaderType.TopDown: 'Top down',
    ReaderType.RightToLeft: 'Right to left',
  };

  static const Map<ReaderScreenCoverage, String> READER_SCREEN_COVERAGE_LEVELS =
      {
    ReaderScreenCoverage.Basic: 'Basic',
    ReaderScreenCoverage.TransparentStatusBar: 'Under status bar',
    ReaderScreenCoverage.FullScreen: 'Full screen',
  };

  static Color grey4D4D4D = Color.fromARGB(255, 77, 77, 77);
  static Color grey767676 = Color.fromARGB(255, 118, 118, 118);
  static Color grey1f1f1f = Color.fromARGB(255, 31, 31, 31);
  static Color black96000000 = Color.fromARGB(150, 0, 0, 0);
  static Color mainColorTransparent = Color.fromARGB(150, 237, 37, 83);
  static Color mainColor = Color.fromARGB(255, 237, 37, 83);
  static Color mainDarkColor = Color.fromARGB(255, 109, 0, 25);
  static Color blue0673B7 = Color.fromARGB(255, 6, 115, 183);

  static Color green53A105 = Color.fromARGB(255, 83, 161, 5);
  static Color yellowECC031 = Color.fromARGB(255, 236, 192, 49);

  static Color getNothingColor() {
    return Color.fromARGB(255, 24, 24, 24);
  }
}
