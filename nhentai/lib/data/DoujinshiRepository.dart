import 'package:nhentai/data/DoujinshiLocalDataSource.dart';
import 'package:nhentai/data/DoujinshiRemoteDataSource.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/domain/entity/DoujinshiResult.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';

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
}
