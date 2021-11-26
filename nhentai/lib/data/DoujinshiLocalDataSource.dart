import 'package:nhentai/data/db/DoujinshiDatabase.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';

abstract class DoujinshiLocalDataSource {
  Future saveRecentlyReadDoujinshi(Doujinshi doujinshi, int lastReadPageIndex);

  Future<DoujinshiStatuses> getDoujinshiStatuses(int doujinshiId);

  Future<List<Doujinshi>> getRecentlyReadDoujinshis(int skip, int take);

  Future<int> getRecentlyReadDoujinshiCount();

  Future<bool> clearLastReadPage(int doujinshiId);

  Future<bool> updateDoujinshiDetails(Doujinshi doujinshi);

  Future<bool> updateFavoriteDoujinshi(Doujinshi doujinshi, bool isFavorite);

  Future<int> getFavoriteDoujinshiCount();

  Future<List<Doujinshi>> getFavoriteDoujinshis(int skip, int take);

  Future<bool> updateDownloadedDoujinshi(
      Doujinshi doujinshi, bool isDownloaded);
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

  @override
  Future<bool> clearLastReadPage(int doujinshiId) {
    return _database.clearLastReadPage(doujinshiId);
  }

  @override
  Future<bool> updateDoujinshiDetails(Doujinshi doujinshi) {
    return _database.updateDoujinshiDetails(doujinshi);
  }

  @override
  Future<bool> updateFavoriteDoujinshi(Doujinshi doujinshi, bool isFavorite) {
    return _database.updateFavoriteDoujinshi(doujinshi, isFavorite);
  }

  @override
  Future<int> getFavoriteDoujinshiCount() {
    return _database.getFavoriteDoujinshiCount();
  }

  @override
  Future<List<Doujinshi>> getFavoriteDoujinshis(int skip, int take) {
    return _database.getFavoriteDoujinshis(skip, take);
  }

  @override
  Future<bool> updateDownloadedDoujinshi(
      Doujinshi doujinshi, bool isDownloaded) {
    return _database.updateDownloadedDoujinshi(doujinshi, isDownloaded);
  }
}
