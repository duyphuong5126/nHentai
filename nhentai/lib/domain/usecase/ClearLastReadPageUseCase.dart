import 'package:nhentai/data/DoujinshiRepository.dart';

abstract class ClearLastReadPageUseCase {
  Future<bool> execute(int doujinshiId);
}

class ClearLastReadPageUseCaseImpl extends ClearLastReadPageUseCase {
  DoujinshiRepository _repository = new DoujinshiRepositoryImpl();

  @override
  Future<bool> execute(int doujinshiId) {
    return _repository.clearLastReadPage(doujinshiId);
  }
}
