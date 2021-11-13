import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';

abstract class GetRecommendedDoujinshiListUseCase {
  Future<RecommendedDoujinshiList> execute(int doujinshiId);
}

class GetRecommendedDoujinshiListUseCaseImpl
    extends GetRecommendedDoujinshiListUseCase {
  DoujinshiRepository _repository = new DoujinshiRepositoryImpl();

  @override
  Future<RecommendedDoujinshiList> execute(int doujinshiId) {
    return _repository.getRecommendedDoujinshiList(doujinshiId);
  }
}
