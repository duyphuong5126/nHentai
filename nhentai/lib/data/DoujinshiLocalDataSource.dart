import 'dart:io';
import 'package:nhentai/data/db/DoujinshiDatabase.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshi.dart';
import 'package:nhentai/domain/entity/RecommendationType.dart';
import 'package:nhentai/domain/entity/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

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

  Stream<bool> deleteDownloadedDoujinshi(
      DownloadedDoujinshi downloadedDoujinshi);

  Stream<String> getRecommendedSearchTerm(
      RecommendationType recommendationType);

  Stream<List<int>> getLocalDoujinshiIds();
}

class DoujinshiLocalDataSourceImpl extends DoujinshiLocalDataSource {
  DoujinshiDatabase _database = DoujinshiDatabase();

  @override
  Stream<List<int>> getLocalDoujinshiIds() {
    return _database.getLocalDoujinshiIds();
  }

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
              .map((page) => DoujinshiImage(
                  path: doujinshiFolderPath + '/${page.path.split('/').last}',
                  width: page.width,
                  height: page.height))
              .toList(),
          downloadedThumbnail: doujinshiFolderPath +
              '/${doujinshi.thumbnailImage.split('/').last}',
          downloadedCover:
              doujinshiFolderPath + '/${doujinshi.coverImage.split('/').last}',
          downloadedBackupCover: doujinshiFolderPath +
              '/${doujinshi.backUpCoverImage.split('/').last}');
    }).toList();
  }

  @override
  Stream<bool> deleteDownloadedDoujinshi(
      DownloadedDoujinshi downloadedDoujinshi) {
    return Rx.fromCallable(() => Future.value(downloadedDoujinshi)).flatMap(
        (downloadedDoujinshi) {
      List<String> downloadedPaths = [];
      downloadedPaths.addAll(
          downloadedDoujinshi.downloadedPathList.map((image) => image.path));
      downloadedPaths.add(downloadedDoujinshi.downloadedCover);
      downloadedPaths.add(downloadedDoujinshi.downloadedBackupCover);
      downloadedPaths.add(downloadedDoujinshi.downloadedThumbnail);
      return Stream.value(downloadedPaths);
    }).doOnData((downloadedPaths) {
      String existedPath = downloadedPaths.firstWhere((filePath) {
        File file = File(filePath);
        return file.existsSync() && file.parent.existsSync();
      }, orElse: () => '');
      if (existedPath.isNotEmpty) {
        File(existedPath).parent.delete(recursive: true);
      }
    }).flatMap((downloadedPaths) => Rx.fromCallable(() =>
        _database.deleteDownloadedDoujinshi(downloadedDoujinshi.id, false)));
  }

  @override
  Stream<String> getRecommendedSearchTerm(
      RecommendationType recommendationType) {
    return _database.getRecommendedSearchTerm(recommendationType);
  }
}
