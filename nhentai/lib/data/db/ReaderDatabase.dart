import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ReaderDatabase {
  Database? _database;

  static const String _DB_NAME = 'reader.db';
  static const String _READER_TYPE_TABLE = 'reader_type';
  static const String _TYPE = 'type';

  Future _openDataBase() async {
    _database = await openDatabase(join(await getDatabasesPath(), _DB_NAME),
        onCreate: (db, version) {
      db.execute('create table $_READER_TYPE_TABLE($_TYPE integer)');
    });
  }
}
