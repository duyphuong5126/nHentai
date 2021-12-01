import 'package:nhentai/data/MasterDataRepository.dart';
import 'package:nhentai/domain/entity/masterdata/Version.dart';

abstract class GetActiveVersionUseCase {
  Stream<Version> execute();
}

class GetActiveVersionUseCaseImpl extends GetActiveVersionUseCase {
  late MasterDataRepository _repository = MasterDataRepositoryImpl();

  @override
  Stream<Version> execute() {
    return _repository.getActiveVersion();
  }
}
