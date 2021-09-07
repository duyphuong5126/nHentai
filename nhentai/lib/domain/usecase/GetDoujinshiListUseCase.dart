import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';

class GetDoujinshiListUseCase {
  DoujinshiRepository _repository = new DoujinshiRepository();

  Future<DoujinshiList> execute(int page, String searchTerm) async {
    return _repository.getDoujinshiList(page, searchTerm);
  }
}
