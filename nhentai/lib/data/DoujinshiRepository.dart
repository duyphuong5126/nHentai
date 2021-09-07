import 'package:nhentai/data/DoujinshiRemoteDataSource.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';

class DoujinshiRepository {
  DoujinshiRemoteDataSource _remoteDataSource = new DoujinshiRemoteDataSource();

  Future<DoujinshiList> getDoujinshiList(int page, String searchTerm) async {
    return _remoteDataSource.getDoujinshiList(page + 1, searchTerm);
  }
}
