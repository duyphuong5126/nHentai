import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/RecommendationType.dart';
import 'package:nhentai/domain/entity/recommendation_info.dart';

abstract class GetRecommendationUseCase {
  Future<RecommendationInfo> execute(RecommendationType recommendationType);
}

class GetRecommendationUseCaseImpl extends GetRecommendationUseCase {
  late final DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<RecommendationInfo> execute(RecommendationType recommendationType) =>
      _repository.getRecommendationInfo(recommendationType);
}
