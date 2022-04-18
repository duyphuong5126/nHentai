import 'dart:convert';
import 'package:nhentai/domain/entity/SearchHistory.dart';
import 'package:nhentai/page/uimodel/ReaderType.dart';
import 'package:nhentai/page/uimodel/reader_screen_coverage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceManager {
  static const String _READER_TYPE = 'reader_type';
  static const String _READER_TRANSPARENCY = 'reader_transparency';
  static const String _READER_SCREEN_COVERAGE = 'reader_screen_coverage';
  static const String _CENSORED = 'censored';
  static const String _SEARCH_HISTORY = 'search_history';

  Future<ReaderScreenCoverage> getReaderScreenCoverage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int typePosition = sharedPreferences.getInt(_READER_SCREEN_COVERAGE) ?? 0;
    return ReaderScreenCoverage.values[typePosition];
  }

  Future saveReaderScreenCoverage(ReaderScreenCoverage coverage) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(_READER_SCREEN_COVERAGE, coverage.index);
  }

  Future<ReaderType> getReaderType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int typePosition = sharedPreferences.getInt(_READER_TYPE) ?? 0;
    return ReaderType.values[typePosition];
  }

  Future saveReaderType(ReaderType type) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(_READER_TYPE, type.index);
  }

  Future<double> getReaderTransparency() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getDouble(_READER_TRANSPARENCY) ?? 0;
  }

  Future saveReaderTransparency(double readerTransparency) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setDouble(_READER_TRANSPARENCY, readerTransparency);
  }

  Future<bool> isCensored() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_CENSORED) ?? false;
  }

  Future<bool> saveCensored(bool isCensored) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setBool(_CENSORED, isCensored);
  }

  Future<SearchHistory> getSearchHistory() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String rawHistory = sharedPreferences.getString(_SEARCH_HISTORY) ?? '';
    return rawHistory.isNotEmpty
        ? SearchHistory.fromJson(jsonDecode(rawHistory))
        : SearchHistory(history: []);
  }

  Future<bool> saveSearchHistory(SearchHistory history) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(
        _SEARCH_HISTORY, jsonEncode(history.toJson()));
  }
}
