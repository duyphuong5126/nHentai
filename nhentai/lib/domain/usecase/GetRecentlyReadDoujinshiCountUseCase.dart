import 'package:nhentai/data/DoujinshiRepository.dart';

abstract class GetRecentlyReadDoujinshiCountUseCase {
  Future<int> execute();
}

class GetRecentlyReadDoujinshiCountUseCaseImpl
    extends GetRecentlyReadDoujinshiCountUseCase {
  DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<int> execute() {
    return _repository.getRecentlyReadDoujinshiCount();
  }
}
