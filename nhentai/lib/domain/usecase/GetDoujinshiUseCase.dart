import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

abstract class GetDoujinshiUseCase {
  Stream<Doujinshi> execute(int doujinshiId);
}

class GetDoujinshiUseCaseImpl extends GetDoujinshiUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Stream<Doujinshi> execute(int doujinshiId) {
    return _repository.getDoujinshi(doujinshiId);
  }
}
