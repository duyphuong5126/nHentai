import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';

class GetDoujinshiListUseCase {
  DoujinshiRepository _repository = new DoujinshiRepository();

  Future<DoujinshiList> execute(
      int page, String searchTerm, SortOption sortOption) async {
    return _repository.getDoujinshiList(page, searchTerm, sortOption);
  }
}
