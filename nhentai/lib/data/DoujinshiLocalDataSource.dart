import 'package:nhentai/data/db/DoujinshiDatabase.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';

abstract class DoujinshiLocalDataSource {
  Future saveRecentlyReadDoujinshi(Doujinshi doujinshi, int lastReadPageIndex);

  Future<DoujinshiStatuses> getDoujinshiStatuses(int doujinshiId);

  Future<List<Doujinshi>> getRecentlyReadDoujinshis(int skip, int take);

  Future<int> getRecentlyReadDoujinshiCount();
}

class DoujinshiLocalDataSourceImpl extends DoujinshiLocalDataSource {
  DoujinshiDatabase _database = DoujinshiDatabase();

  @override
  Future saveRecentlyReadDoujinshi(Doujinshi doujinshi, int lastReadPageIndex) {
    return _database.addRecentlyReadDoujinshi(doujinshi, lastReadPageIndex);
  }

  @override
  Future<DoujinshiStatuses> getDoujinshiStatuses(int doujinshiId) {
    return _database.getDoujinshiStatuses(doujinshiId);
  }

  @override
  Future<List<Doujinshi>> getRecentlyReadDoujinshis(int skip, int take) {
    return _database.getRecentlyReadDoujinshis(skip, take);
  }

  Future<int> getRecentlyReadDoujinshiCount() {
    return _database.getRecentlyReadDoujinshiCount();
  }
}
