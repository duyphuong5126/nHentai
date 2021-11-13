import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';

abstract class GetDoujinshiListUseCase {
  Future<DoujinshiList> execute(
      int page, String searchTerm, SortOption sortOption);
}

class GetDoujinshiListUseCaseImpl extends GetDoujinshiListUseCase {
  DoujinshiRepository _repository = new DoujinshiRepositoryImpl();

  @override
  Future<DoujinshiList> execute(
      int page, String searchTerm, SortOption sortOption) {
    return _repository.getDoujinshiList(page, searchTerm, sortOption);
  }
}
