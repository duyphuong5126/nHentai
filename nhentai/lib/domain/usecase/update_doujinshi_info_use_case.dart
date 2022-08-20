import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

abstract class UpdateDoujinshiInfoUseCase {
  Future<bool> execute(Doujinshi doujinshi);
}

class UpdateDoujinshiInfoUseCaseImpl extends UpdateDoujinshiInfoUseCase {
  late final DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<bool> execute(Doujinshi doujinshi) =>
      _repository.updateDoujinshiInfo(doujinshi);
}
