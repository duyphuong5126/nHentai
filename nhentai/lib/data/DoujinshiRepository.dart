import 'dart:math';

import 'package:nhentai/data/DoujinshiLocalDataSource.dart';
import 'package:nhentai/data/DoujinshiRemoteDataSource.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/domain/entity/DoujinshiResult.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshi.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshiList.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';
import 'package:nhentai/domain/entity/RecommendationType.dart';
import 'package:nhentai/domain/entity/comment/Comment.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';
import 'package:rxdart/rxdart.dart';

abstract class DoujinshiRepository {
  Future<DoujinshiList> getDoujinshiList(
      int page, String searchTerm, SortOption sortOption);

  Future<RecommendedDoujinshiList> getRecommendedDoujinshiList(int doujinshiId);

  Future storeRecentlyReadDoujinshi(Doujinshi doujinshi, int lastReadPageIndex);

  Future<DoujinshiStatuses> getDoujinshiStatuses(int doujinshiId);

  Future<DoujinshiList> getRecentlyReadDoujinshiList(int page, int perPage);

  Future<int> getRecentlyReadDoujinshiCount();

  Future<bool> clearLastReadPage(int doujinshiId);

  Future<bool> updateDoujinshiDetails(int doujinshiId);

  Future<bool> updateFavoriteDoujinshi(Doujinshi doujinshi, bool isFavorite);

  Future<int> getFavoriteDoujinshiCount();

  Future<DoujinshiList> getFavoriteDoujinshiList(int page, int perPage);

  Stream<String> downloadDoujinshi(Doujinshi doujinshi);

  Future<int> getDownloadedDoujinshiCount();

  Future<DownloadedDoujinshiList> getDownloadedDoujinshis(
      int page, int perPage);

  Stream<bool> deleteDownloadedDoujinshi(
      DownloadedDoujinshi downloadedDoujinshi);

  Stream<Doujinshi> getDoujinshi(int doujinshiId);

  Stream<List<Comment>> getCommentList(int doujinshiId);

  Stream<Future<List<Doujinshi>>> getRecommendedDoujinshis(
      RecommendationType recommendationType, int limit);
}

class DoujinshiRepositoryImpl extends DoujinshiRepository {
  DoujinshiRemoteDataSource _remote = new DoujinshiRemoteDataSourceImpl();
  DoujinshiLocalDataSource _local = new DoujinshiLocalDataSourceImpl();

  @override
  Future<DoujinshiList> getDoujinshiList(
      int page, String searchTerm, SortOption sortOption) {
    return _remote.fetchDoujinshiList(page + 1, searchTerm, sortOption);
  }

  @override
  Future<RecommendedDoujinshiList> getRecommendedDoujinshiList(
      int doujinshiId) {
    return _remote.fetchRecommendedDoujinshiList(doujinshiId);
  }

  @override
  Future storeRecentlyReadDoujinshi(
      Doujinshi doujinshi, int lastReadPageIndex) {
    return _local.saveRecentlyReadDoujinshi(doujinshi, lastReadPageIndex);
  }

  @override
  Future<DoujinshiStatuses> getDoujinshiStatuses(int doujinshiId) {
    return _local.getDoujinshiStatuses(doujinshiId);
  }

  @override
  Future<DoujinshiList> getRecentlyReadDoujinshiList(
      int page, int perPage) async {
    List<Doujinshi> doujinshiList =
        await _local.getRecentlyReadDoujinshis(page * perPage, perPage);
    int recentlyReadDoujinshiCount =
        await _local.getRecentlyReadDoujinshiCount();
    int pageSize = recentlyReadDoujinshiCount > perPage
        ? perPage
        : recentlyReadDoujinshiCount;
    int numPages = recentlyReadDoujinshiCount ~/ perPage;
    if (recentlyReadDoujinshiCount % perPage > 0) {
      numPages++;
    }
    return DoujinshiList(
        result: doujinshiList, numPages: numPages, perPage: pageSize);
  }

  @override
  Future<int> getRecentlyReadDoujinshiCount() {
    return _local.getRecentlyReadDoujinshiCount();
  }

  @override
  Future<bool> clearLastReadPage(int doujinshiId) {
    return _local.clearLastReadPage(doujinshiId);
  }

  @override
  Future<bool> updateDoujinshiDetails(int doujinshiId) async {
    DoujinshiResult remoteResult = await _remote.fetchDoujinshi(doujinshiId);
    return remoteResult is Success
        ? await _local.updateDoujinshiDetails(remoteResult.doujinshi)
        : false;
  }

  @override
  Future<bool> updateFavoriteDoujinshi(Doujinshi doujinshi, bool isFavorite) {
    return _local.updateFavoriteDoujinshi(doujinshi, isFavorite);
  }

  @override
  Future<int> getFavoriteDoujinshiCount() {
    return _local.getFavoriteDoujinshiCount();
  }

  @override
  Future<DoujinshiList> getFavoriteDoujinshiList(int page, int perPage) async {
    List<Doujinshi> doujinshiList =
        await _local.getFavoriteDoujinshis(page * perPage, perPage);
    int favoriteDoujinshiCount = await _local.getFavoriteDoujinshiCount();
    int pageSize =
        favoriteDoujinshiCount > perPage ? perPage : favoriteDoujinshiCount;
    int numPages = favoriteDoujinshiCount ~/ perPage;
    if (favoriteDoujinshiCount % perPage > 0) {
      numPages++;
    }
    return DoujinshiList(
        result: doujinshiList, numPages: numPages, perPage: pageSize);
  }

  @override
  Stream<String> downloadDoujinshi(Doujinshi doujinshi) {
    return Rx.fromCallable(() => Future.value(doujinshi.fullSizePageUrlList))
        .map((fullSizePageUrlList) {
          List<String> pageUrlList = [];
          pageUrlList.add(doujinshi.coverImage);
          pageUrlList.add(doujinshi.backUpCoverImage);
          pageUrlList.add(doujinshi.thumbnailImage);
          pageUrlList.addAll(fullSizePageUrlList);
          return pageUrlList;
        })
        .flatMap((pageUrlList) => Stream.fromIterable(pageUrlList))
        .interval(Duration(milliseconds: 500))
        .flatMap((pageUrl) {
          print('DoujinshiRepository: try to download page $pageUrl');
          return _downloadPage(doujinshi.id, pageUrl);
        })
        .map((pageLocalPath) {
          print('DoujinshiRepository: downloaded file $pageLocalPath');
          return pageLocalPath;
        })
        .doOnDone(() async {
          bool localUpdateSuccess =
              await _local.updateDownloadedDoujinshi(doujinshi, true);
          print(
              'DoujinshiRepository: is doujinshi ${doujinshi.id} downloaded: $localUpdateSuccess');
        })
        .doOnError((error, stackTrace) {
          print(
              'DoujinshiRepository: could not download doujinshi ${doujinshi.id}, error: $error');
        });
  }

  @override
  Future<int> getDownloadedDoujinshiCount() {
    return _local.getDownloadedDoujinshiCount();
  }

  @override
  Future<DownloadedDoujinshiList> getDownloadedDoujinshis(
      int page, int perPage) async {
    List<DownloadedDoujinshi> downloadedList =
        await _local.getDownloadedDoujinshis(page * perPage, perPage);
    int downloadedDoujinshiCount = await _local.getDownloadedDoujinshiCount();
    int pageSize =
        downloadedDoujinshiCount > perPage ? perPage : downloadedDoujinshiCount;
    int numPages = downloadedDoujinshiCount ~/ perPage;
    if (downloadedDoujinshiCount % perPage > 0) {
      numPages++;
    }
    return DownloadedDoujinshiList(
        result: downloadedList, numPages: numPages, perPage: pageSize);
  }

  @override
  Stream<bool> deleteDownloadedDoujinshi(
      DownloadedDoujinshi downloadedDoujinshi) {
    return _local.deleteDownloadedDoujinshi(downloadedDoujinshi);
  }

  @override
  Stream<Doujinshi> getDoujinshi(int doujinshiId) {
    return Rx.fromCallable(() => _remote.fetchDoujinshi(doujinshiId))
        .flatMap((doujinshiResult) {
      if (doujinshiResult is Success) {
        return Stream.value(doujinshiResult.doujinshi);
      }
      if (doujinshiResult is Error) {
        Exception? exception = doujinshiResult.exception;
        return exception != null
            ? Stream.error(exception)
            : Stream.error(NullThrownError());
      }
      return Stream.empty();
    });
  }

  @override
  Stream<List<Comment>> getCommentList(int doujinshiId) {
    return _remote.getCommentList(doujinshiId);
  }

  Stream<String> _downloadPage(int doujinshiId, String pageUrl) {
    return Rx.fromCallable(() => Future.value(pageUrl.split('/').last))
        .flatMap((pageName) {
      print(
          'DoujinshiRepository: try to download page image $pageName - $pageUrl');
      return _remote.downloadPageAndReturnLocalPath(
          doujinshiId, pageUrl, pageName);
    }).doOnError((error, stackTrace) {
      print(
          'DoujinshiRepository: could not download page $pageUrl with error $error');
    });
  }

  @override
  Stream<Future<List<Doujinshi>>> getRecommendedDoujinshis(
      recommendationType, int limit) {
    return _local
        .getRecommendedSearchTerm(recommendationType)
        .flatMap((searchTerm) {
      SortOption sortOption =
          SortOption.values[Random().nextInt(SortOption.values.length)];
      return Rx.fromCallable(
              () => _remote.fetchDoujinshiList(1, searchTerm, sortOption))
          .flatMap((remoteDoujinshiList) {
        return _local.getLocalDoujinshiIds().map((localIds) async {
          List<Doujinshi> doujinshiList = remoteDoujinshiList.result
              .where((doujinshi) => !localIds.contains(doujinshi.id))
              .toList();

          int pageIndex = 2;
          while (doujinshiList.length < limit &&
              pageIndex < remoteDoujinshiList.numPages) {
            DoujinshiList doujinshiListResult = await _remote
                .fetchDoujinshiList(pageIndex++, searchTerm, sortOption);
            doujinshiList.addAll(doujinshiListResult.result);
          }

          return doujinshiList;
        });
      });
    }).map((doujinshiListFuture) async {
      List<Doujinshi> doujinshiList = await doujinshiListFuture;
      doujinshiList.sort((Doujinshi a, Doujinshi b) =>
          -a.numFavorites.compareTo(b.numFavorites));
      return doujinshiList.take(limit).toList();
    });
  }
}
