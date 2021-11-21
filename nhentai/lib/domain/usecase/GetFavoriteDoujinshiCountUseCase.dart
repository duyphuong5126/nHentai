import 'package:nhentai/data/DoujinshiRepository.dart';

abstract class GetFavoriteDoujinshiCountUseCase {
  Future<int> execute();
}

class GetFavoriteDoujinshiCountUseCaseImpl
    extends GetFavoriteDoujinshiCountUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<int> execute() {
    return _repository.getFavoriteDoujinshiCount();
  }
}
