import 'dart:convert';

import 'package:nhentai/Constant.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:http/http.dart';
import 'package:nhentai/domain/entity/DoujinshiResult.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';

abstract class DoujinshiRemoteDataSource {
  Future<DoujinshiList> fetchDoujinshiList(
      int page, String searchTerm, SortOption sortOption);

  Future<RecommendedDoujinshiList> fetchRecommendedDoujinshiList(
      int doujinshiId);

  Future<DoujinshiResult> fetchDoujinshi(int doujinshiId);
}

class DoujinshiRemoteDataSourceImpl extends DoujinshiRemoteDataSource {
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
      Response response = await get(Uri.parse(url));
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
      Response response = await get(Uri.parse(url));
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
      Response response = await get(Uri.parse(url));
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
}
