import 'package:nhentai/data/remote/MasterDataRemoteDataSource.dart';
import 'package:nhentai/domain/entity/masterdata/Version.dart';

abstract class MasterDataRepository {
  Stream<Version> getActiveVersion();
}

class MasterDataRepositoryImpl extends MasterDataRepository {
  late MasterDataRemoteDataSource _masterDataRemoteDataSource =
      MasterDataRemoteDataSourceImpl();

  @override
  Stream<Version> getActiveVersion() {
    return _masterDataRemoteDataSource
        .fetchVersionHistory()
        .map((versionHistory) => versionHistory.activeVersion);
  }
}
