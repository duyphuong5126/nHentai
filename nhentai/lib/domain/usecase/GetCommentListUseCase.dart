import 'package:nhentai/data/DoujinshiRepository.dart';
import 'package:nhentai/domain/entity/comment/Comment.dart';

abstract class GetCommentListUseCase {
  Stream<List<Comment>> execute(int doujinshiId);
}

class GetCommentListUseCaseImpl extends GetCommentListUseCase {
  late DoujinshiRepository _repository = DoujinshiRepositoryImpl();

  @override
  Stream<List<Comment>> execute(int doujinshiId) {
    return _repository.getCommentList(doujinshiId);
  }
}
