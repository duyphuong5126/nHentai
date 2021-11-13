import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

abstract class StoreReadDoujinshiUseCase {
  Future execute(Doujinshi doujinshi, int lastReadPageIndex);
}

class StoreReadDoujinshiUseCaseImpl extends StoreReadDoujinshiUseCase {
  DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future execute(Doujinshi doujinshi, int lastReadPageIndex) {
    return _repository.storeRecentlyReadDoujinshi(doujinshi, lastReadPageIndex);
  }
}
