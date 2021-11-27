import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshi.dart';

abstract class DeleteDownloadedDoujinshiUseCase {
  Stream<bool> execute(DownloadedDoujinshi downloadedDoujinshi);
}

class DeleteDownloadedDoujinshiUseCaseImpl
    extends DeleteDownloadedDoujinshiUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Stream<bool> execute(DownloadedDoujinshi downloadedDoujinshi) {
    return _repository.deleteDownloadedDoujinshi(downloadedDoujinshi);
  }
}
