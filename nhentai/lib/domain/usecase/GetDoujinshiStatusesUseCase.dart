import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/DoujinshiStatuses.dart';

abstract class GetDoujinshiStatusesUseCase {
  Future<DoujinshiStatuses> execute(int doujinshiId);
}

class GetDoujinshiStatusesUseCaseImpl extends GetDoujinshiStatusesUseCase {
  DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<DoujinshiStatuses> execute(int doujinshiId) {
    return _repository.getDoujinshiStatuses(doujinshiId);
  }
}
