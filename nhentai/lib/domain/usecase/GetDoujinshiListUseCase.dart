import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';

class GetDoujinshiListUseCase {
  DoujinshiRepository _repository = new DoujinshiRepository();

  Future<DoujinshiList> execute(int page) async {
    return _repository.getDoujinshiList(page);
  }
}
