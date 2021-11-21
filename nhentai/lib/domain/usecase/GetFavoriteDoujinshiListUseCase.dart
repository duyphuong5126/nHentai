import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';

abstract class GetFavoriteDoujinshiListUseCase {
  Future<DoujinshiList> execute(int page, int perPage);
}

class GetFavoriteDoujinshiListUseCaseImpl
    extends GetFavoriteDoujinshiListUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<DoujinshiList> execute(int page, int perPage) {
    return _repository.getFavoriteDoujinshiList(page, perPage);
  }
}
