import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';

class GetRecommendedDoujinshiListUseCase {
  DoujinshiRepository _repository = new DoujinshiRepository();

  Future<RecommendedDoujinshiList> execute(int doujinshiId) async {
    return _repository.getRecommendedDoujinshiList(doujinshiId);
  }
}
