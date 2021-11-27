import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshiList.dart';

abstract class GetDownloadedDoujinshisUseCase {
  Future<DownloadedDoujinshiList> execute(int page, int perPage);
}

class GetDownloadedDoujinshisUseCaseImpl
    extends GetDownloadedDoujinshisUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<DownloadedDoujinshiList> execute(int page, int perPage) {
    return _repository.getDownloadedDoujinshis(page, perPage);
  }
}
