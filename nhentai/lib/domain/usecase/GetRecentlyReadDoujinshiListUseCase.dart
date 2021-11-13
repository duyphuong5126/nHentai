import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';

abstract class GetRecentlyReadDoujinshiListUseCase {
  Future<DoujinshiList> execute(int page, int perPage);
}

class GetRecentlyReadDoujinshiListUseCaseImpl
    extends GetRecentlyReadDoujinshiListUseCase {
  DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<DoujinshiList> execute(int page, int perPage) {
    return _repository.getRecentlyReadDoujinshiList(page, perPage);
  }
}
