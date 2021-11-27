import 'dart:convert';
import 'dart:io';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:http/http.dart';
import 'package:nhentai/domain/entity/DoujinshiResult.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

abstract class DoujinshiRemoteDataSource {
  Future<DoujinshiList> fetchDoujinshiList(
      int page, String searchTerm, SortOption sortOption);

  Future<RecommendedDoujinshiList> fetchRecommendedDoujinshiList(
      int doujinshiId);

  Future<DoujinshiResult> fetchDoujinshi(int doujinshiId);

  Stream<String> downloadPageAndReturnLocalPath(
      int doujinshiId, String pageUrl, String fileName);
}

class DoujinshiRemoteDataSourceImpl extends DoujinshiRemoteDataSource {
  static const int _REQUEST_TIME_OUT = 30;
  static const int _FILE_FETCHING_TIME_OUT = 90;

  @override
  Future<DoujinshiList> fetchDoujinshiList(
      int page, String searchTerm, SortOption sortOption) async {
    String sortString = '';
    if (sortOption == SortOption.PopularToday) {
      sortString = '&sort=popular-today';
    } else if (sortOption == SortOption.PopularThisWeek) {
      sortString = '&sort=popular-week';
    } else if (sortOption == SortOption.PopularAllTime) {
      sortString = '&sort=popular';
    }
    String url = searchTerm.isEmpty
        ? '${Constant.NHENTAI_HOME}/api/galleries/all?page=$page' + sortString
        : '${Constant.NHENTAI_HOME}/api/galleries/search?query=$searchTerm&page=$page' +
            sortString;
    Future<DoujinshiList> result;
    try {
      Response response = await get(Uri.parse(url))
          .timeout(Duration(seconds: _REQUEST_TIME_OUT));
      DoujinshiList doujinshiList =
          DoujinshiList.fromJson(jsonDecode(response.body));
      print(
          '-------------------\nGET $url\nResult: ${response.statusCode} - ${doujinshiList.result.map((e) => e.id)}\n-------------------');
      result = Future.value(doujinshiList);
    } catch (e) {
      print('-------------------\nGET $url\nError: $e\n-------------------');
      result = Future.value(DoujinshiList(result: [], numPages: 0, perPage: 0));
    }
    return result;
  }

  @override
  Future<RecommendedDoujinshiList> fetchRecommendedDoujinshiList(
      int doujinshiId) async {
    String url = '${Constant.NHENTAI_HOME}/api/gallery/$doujinshiId/related';
    Future<RecommendedDoujinshiList> result;
    try {
      Response response = await get(Uri.parse(url))
          .timeout(Duration(seconds: _REQUEST_TIME_OUT));
      RecommendedDoujinshiList doujinshiList =
          RecommendedDoujinshiList.fromJson(jsonDecode(response.body));
      print(
          '----------------------------------------------------------------------------');
      print(
          '\nGET $url\nResult: ${response.statusCode} - ${doujinshiList.result.map((e) => e.id)}\n');
      print(
          '----------------------------------------------------------------------------');
      result = Future.value(doujinshiList);
    } catch (e) {
      print(
          '----------------------------------------------------------------------------');
      print('\nGET $url\nError: $e');
      print(
          '----------------------------------------------------------------------------');
      result = Future.value(RecommendedDoujinshiList(result: []));
    }
    return result;
  }

  @override
  Future<DoujinshiResult> fetchDoujinshi(int doujinshiId) async {
    String url = '${Constant.NHENTAI_HOME}/api/gallery/$doujinshiId';
    Future<DoujinshiResult> result;
    try {
      Response response = await get(Uri.parse(url))
          .timeout(Duration(seconds: _REQUEST_TIME_OUT));
      Doujinshi doujinshi = Doujinshi.fromJson(jsonDecode(response.body));
      print(
          '-------------------\nGET $url\nResult: ${response.statusCode} - ${doujinshi.id}\n-------------------');
      result = Future.value(DoujinshiResult.success(doujinshi));
    } on Exception catch (exception) {
      print(
          '-------------------\nGET $url\nError: $exception\n-------------------');
      result = Future.value(DoujinshiResult.error(exception));
    } catch (e) {
      print('-------------------\nGET $url\nError: $e\n-------------------');
      result = Future.value(DoujinshiResult.error(null));
    }
    return result;
  }

  @override
  Stream<String> downloadPageAndReturnLocalPath(
      int doujinshiId, String pageUrl, String fileName) {
    return Rx.fromCallable(() => getApplicationDocumentsDirectory())
        .flatMap((Directory appDir) {
      String doujinshiFolderPath = appDir.path + '/download/$doujinshiId';
      String filePath = doujinshiFolderPath + '/$fileName';
      Directory(doujinshiFolderPath).createSync(recursive: true);
      File localFile = File(filePath);

      return Rx.fromCallable(() => get(Uri.parse(pageUrl))
          .timeout(Duration(seconds: _FILE_FETCHING_TIME_OUT))).flatMap((remoteFile) {
        print(
            'DoujinshiRemoteDataSource: pageUrl=$pageUrl - file size=${remoteFile.bodyBytes.length}');
        return Rx.fromCallable(
            () => localFile.writeAsBytes(remoteFile.bodyBytes));
      }).map((File file) => file.path);
    }).doOnError((error, stacktrace) {
      if (error is Exception) {
        print(
            '-------------------\nGET $pageUrl\nError: $error\n-------------------');
        print('$stacktrace');
      } else {
        print(
            '-------------------\nGET $pageUrl\nError: $error\n-------------------');
        print('$stacktrace');
      }
    });
  }
}
