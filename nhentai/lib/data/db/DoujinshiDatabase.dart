import 'dart:convert';

import 'package:nhentai/Constant.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DoujinshiDatabase {
  Database? _database;

  static const _VERSION = 1;

  static const String _DB_NAME = 'doujinshi.db';
  static const String _DOUJINSHI_TABLE = 'doujinshi';
  static const String _DOUJINSHI_ID = Constant.DB_ID;
  static const String _DOUJINSHI_JSON = 'doujinshi_json';
  static const String _IS_FAVORITE_DOUJINSHI = 'is_favorite';
  static const String _LAST_READ_PAGE = 'last_read_page';
  static const String _IS_DOWNLOADED_DOUJINSHI = 'is_downloaded';
  static const String _UPDATED_TIME = 'updated_time';

  Future _openDataBase() async {
    if (_database != null && _database?.isOpen == true) {
      return;
    }
    await _database?.close();
    _database = await openDatabase(join(await getDatabasesPath(), _DB_NAME),
        version: _VERSION, onCreate: (db, version) {
      db.execute('create table $_DOUJINSHI_TABLE('
          '$_DOUJINSHI_ID integer primary key,'
          '$_DOUJINSHI_JSON string,'
          '$_LAST_READ_PAGE int,'
          '$_IS_FAVORITE_DOUJINSHI int,'
          '$_IS_DOWNLOADED_DOUJINSHI int,'
          '$_UPDATED_TIME int'
          ')');
    });
  }

  Future<DoujinshiStatuses> getDoujinshiStatuses(int doujinshiId) async {
    List<Map> doujinshiStatuses;
    await _openDataBase();
    doujinshiStatuses = await _database!.query(_DOUJINSHI_TABLE,
        columns: [
          _LAST_READ_PAGE,
          _IS_FAVORITE_DOUJINSHI,
          _IS_DOWNLOADED_DOUJINSHI
        ],
        where: '$_DOUJINSHI_ID = ?',
        whereArgs: [doujinshiId]);
    return doujinshiStatuses.isNotEmpty
        ? DoujinshiStatuses(
            lastReadPageIndex: doujinshiStatuses[0][_LAST_READ_PAGE],
            isFavorite: doujinshiStatuses[0][_IS_FAVORITE_DOUJINSHI] == 1,
            isDownloaded: doujinshiStatuses[0][_IS_DOWNLOADED_DOUJINSHI] == 1)
        : DoujinshiStatuses();
  }

  Future<List<Doujinshi>> getRecentlyReadDoujinshis(int skip, int take) async {
    List<Doujinshi> resultList = [];
    await _openDataBase();
    List<Map> recentlyReadDoujinshisList = await _database!.query(
        _DOUJINSHI_TABLE,
        columns: [_DOUJINSHI_JSON],
        where: '$_LAST_READ_PAGE > 0',
        orderBy: '$_UPDATED_TIME desc',
        offset: skip,
        limit: take);
    recentlyReadDoujinshisList.forEach((doujinshiMap) {
      String doujinshiJson = doujinshiMap[_DOUJINSHI_JSON];
      resultList.add(Doujinshi.fromJson(jsonDecode(doujinshiJson)));
    });
    return resultList;
  }

  Future<int> getRecentlyReadDoujinshiCount() async {
    int result = 0;
    await _openDataBase();
    result = Sqflite.firstIntValue(await _database!.rawQuery(
            'select count($_DOUJINSHI_ID) from $_DOUJINSHI_TABLE where $_LAST_READ_PAGE > 0')) ??
        0;
    return result;
  }

  Future addRecentlyReadDoujinshi(
      Doujinshi doujinshi, int lastReadPageIndex) async {
    await _openDataBase();
    List<Map> recentlyReadDoujinshisList = await _database!.query(
        _DOUJINSHI_TABLE,
        columns: [_LAST_READ_PAGE],
        where: '$_DOUJINSHI_ID = ?',
        whereArgs: [doujinshi.id]);
    int currentTimeMillis = DateTime.now().microsecondsSinceEpoch;
    if (recentlyReadDoujinshisList.isNotEmpty) {
      await _database!.update(
          _DOUJINSHI_TABLE,
          {
            _LAST_READ_PAGE: lastReadPageIndex,
            _UPDATED_TIME: currentTimeMillis
          },
          where: '$_DOUJINSHI_ID = ?',
          whereArgs: [doujinshi.id]);
    } else {
      await _insertDoujinshi(doujinshi,
          lastReadPageIndex: lastReadPageIndex,
          currentTimeMillis: currentTimeMillis);
    }
  }

  Future updateDoujinshiDetails(Doujinshi doujinshi) async {
    await _openDataBase();
    int currentTimeMillis = DateTime.now().microsecondsSinceEpoch;
    _database!.update(
        _DOUJINSHI_TABLE,
        {
          _DOUJINSHI_JSON: jsonEncode(doujinshi),
          _UPDATED_TIME: currentTimeMillis
        },
        where: '$_DOUJINSHI_ID = ?',
        whereArgs: [doujinshi.id]);
  }

  Future clearLastReadPage(int doujinshiId) async {
    await _openDataBase();
    int currentTimeMillis = DateTime.now().microsecondsSinceEpoch;
    _database!.update(_DOUJINSHI_TABLE,
        {_LAST_READ_PAGE: -1, _UPDATED_TIME: currentTimeMillis},
        where: '$_DOUJINSHI_ID = ?', whereArgs: [doujinshiId]);
  }

  Future _insertDoujinshi(Doujinshi doujinshi,
      {int lastReadPageIndex = -1,
      bool isFavorite = false,
      bool isDownloaded = false,
      int currentTimeMillis = -1}) async {
    await _database!.insert(_DOUJINSHI_TABLE, {
      _DOUJINSHI_ID: doujinshi.id,
      _DOUJINSHI_JSON: jsonEncode(doujinshi),
      _LAST_READ_PAGE: lastReadPageIndex,
      _IS_FAVORITE_DOUJINSHI: isFavorite ? 1 : 0,
      _IS_DOWNLOADED_DOUJINSHI: isDownloaded ? 1 : 0,
      _UPDATED_TIME: currentTimeMillis
    });
  }
}
