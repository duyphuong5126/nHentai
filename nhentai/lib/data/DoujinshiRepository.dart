import 'package:nhentai/data/DoujinshiRemoteDataSource.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';

class DoujinshiRepository {
  DoujinshiRemoteDataSource _remoteDataSource = new DoujinshiRemoteDataSource();

  Future<DoujinshiList> getDoujinshiList(
      int page, String searchTerm, SortOption sortOption) async {
    return _remoteDataSource.getDoujinshiList(page + 1, searchTerm, sortOption);
  }

  Future<RecommendedDoujinshiList> getRecommendedDoujinshiList(
      int doujinshiId) async {
    return _remoteDataSource.getRecommendedDoujinshiList(doujinshiId);
  }
}
