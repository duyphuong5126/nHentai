import 'dart:ui';

import 'package:flutter/material.dart';

class Constant {
  static const String NHENTAI_I = 'https://i.nhentai.net';
  static const String NHENTAI_T = 'https://t.nhentai.net';

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

  static const String NUNITO_BLACK = 'NunitoBlack';
  static const String NUNITO_REGULAR = 'NunitoRegular';
  static const String NUNITO_BOLD = 'NunitoBold';
  static const String NUNITO_EXTRA_BOLD = 'NunitoExtraBold';
  static const String NUNITO_SEMI_BOLD = 'NunitoSemiBold';
  static const String NUNITO_LIGHT = 'NunitoLight';

  static Color grey4D4D4D = Color.fromARGB(255, 77, 77, 77);
  static Color grey767676 = Color.fromARGB(255, 118, 118, 118);
  static Color grey1f1f1f = Color.fromARGB(255, 31, 31, 31);
  static Color black96000000 = Color.fromARGB(150, 0, 0, 0);
  static Color mainColor = Colors.green[500]!;

  static Color getNothingColor() {
    return Color.fromARGB(255, 24, 24, 24);
  }
}
