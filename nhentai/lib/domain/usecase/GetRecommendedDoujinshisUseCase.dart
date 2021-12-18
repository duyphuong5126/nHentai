import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

abstract class GetRecommendedDoujinshisUseCase {
  Stream<Future<List<Doujinshi>>> execute(recommendationType, int limit);
}

class GetRecommendedDoujinshisUseCaseImpl
    extends GetRecommendedDoujinshisUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Stream<Future<List<Doujinshi>>> execute(recommendationType, int limit) {
    return _repository.getRecommendedDoujinshis(recommendationType, limit);
  }
}
