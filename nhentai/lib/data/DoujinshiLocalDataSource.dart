import 'dart:io';
import 'package:nhentai/data/db/DoujinshiDatabase.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshi.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<int> getDownloadedDoujinshiCount();

  Future<List<DownloadedDoujinshi>> getDownloadedDoujinshis(int skip, int take);
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

  @override
  Future<int> getDownloadedDoujinshiCount() {
    return _database.getDownloadedDoujinshiCount();
  }

  @override
  Future<List<DownloadedDoujinshi>> getDownloadedDoujinshis(
      int skip, int take) async {
    List<Doujinshi> localList =
        await _database.getDownloadedDoujinshis(skip, take);
    Directory appDir = await getApplicationDocumentsDirectory();
    return localList.map((doujinshi) {
      String doujinshiFolderPath = appDir.path + '/download/${doujinshi.id}';
      return DownloadedDoujinshi(
          doujinshi: doujinshi,
          downloadedPathList: doujinshi.fullSizePageUrlList
              .map((pageUrl) =>
                  doujinshiFolderPath + '/${pageUrl.split('/').last}')
              .toList(),
          downloadedThumbnail: doujinshiFolderPath +
              '/${doujinshi.thumbnailImage.split('/').last}',
          downloadedCover:
              doujinshiFolderPath + '/${doujinshi.coverImage.split('/').last}',
          downloadedBackupCover: doujinshiFolderPath +
              '/${doujinshi.backUpCoverImage.split('/').last}');
    }).toList();
  }
}
