import 'dart:convert';

import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:http/http.dart';
import 'package:nhentai/domain/entity/RecommendDoujinshiList.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';

abstract class DoujinshiRemoteDataSource {
  Future<DoujinshiList> getDoujinshiList(
      int page, String searchTerm, SortOption sortOption);

  Future<RecommendedDoujinshiList> getRecommendedDoujinshiList(int doujinshiId);
}

class DoujinshiRemoteDataSourceImpl extends DoujinshiRemoteDataSource {
  @override
  Future<DoujinshiList> getDoujinshiList(
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
        ? 'https://nhentai.net/api/galleries/all?page=$page' + sortString
        : 'https://nhentai.net/api/galleries/search?query=$searchTerm&page=$page' +
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
  Future<RecommendedDoujinshiList> getRecommendedDoujinshiList(
      int doujinshiId) async {
    String url = 'https://nhentai.net/api/gallery/$doujinshiId/related';
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
}
