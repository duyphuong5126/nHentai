import 'package:nhentai/data/DoujinshiRepository.dart';

abstract class GetDownloadedDoujinshiCountUseCase {
  Future<int> execute();
}

class GetDownloadedDoujinshiCountUseCaseImpl
    extends GetDownloadedDoujinshiCountUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<int> execute() {
    return _repository.getDownloadedDoujinshiCount();
  }
}
