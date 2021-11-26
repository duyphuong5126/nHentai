import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

abstract class DownloadDoujinshiUseCase {
  Stream<String> execute(Doujinshi doujinshi);
}

class DownloadDoujinshiUseCaseImpl extends DownloadDoujinshiUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Stream<String> execute(Doujinshi doujinshi) {
    return _repository.downloadDoujinshi(doujinshi);
  }
}
