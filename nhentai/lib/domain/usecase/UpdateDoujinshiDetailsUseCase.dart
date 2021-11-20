import 'package:nhentai/data/DoujinshiRepository.dart';

abstract class UpdateDoujinshiDetailsUseCase {
  Future<bool> execute(int doujinshiId);
}

class UpdateDoujinshiDetailsUseCaseImpl extends UpdateDoujinshiDetailsUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<bool> execute(int doujinshiId) {
    return _repository.updateDoujinshiDetails(doujinshiId);
  }
}
