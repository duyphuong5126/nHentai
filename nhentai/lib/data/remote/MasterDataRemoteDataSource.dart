import 'dart:convert';
import 'package:http/http.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/domain/entity/masterdata/VersionHistory.dart';
import 'package:rxdart/rxdart.dart';

abstract class MasterDataRemoteDataSource {
  Stream<VersionHistory> fetchVersionHistory();
}

class MasterDataRemoteDataSourceImpl extends MasterDataRemoteDataSource {
  @override
  Stream<VersionHistory> fetchVersionHistory() {
    String url = '${Constant.MASTER_DATA_HOME}/VersionHistory.json';
    return Rx.fromCallable(() => get(Uri.parse(url)))
        .map((versionHistoryResponse) =>
            VersionHistory.fromJson(jsonDecode(versionHistoryResponse.body)))
        .doOnError((error, stackTrace) {
      print(
          '-------------------\nGET $url\nError: $error\n-------------------');
    });
  }
}
