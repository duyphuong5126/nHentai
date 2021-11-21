import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

abstract class UpdateFavoriteDoujinshiUseCase {
  Future<bool> execute(Doujinshi doujinshi, bool isFavorite);
}

class UpdateFavoriteDoujinshiUseCaseImpl
    extends UpdateFavoriteDoujinshiUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Future<bool> execute(Doujinshi doujinshi, bool isFavorite) {
    return _repository.updateFavoriteDoujinshi(doujinshi, isFavorite);
  }
}
