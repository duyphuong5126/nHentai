import 'dart:convert';

import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:http/http.dart';

class DoujinshiRemoteDataSource {
  Future<DoujinshiList> getDoujinshiList(int page, String searchTerm) async {
    String url = searchTerm.isEmpty
        ? 'https://nhentai.net/api/galleries/all?page=$page'
        : 'https://nhentai.net/api/galleries/search?query=$searchTerm&page=$page';
    Response response = await get(Uri.parse(url));
    Future<DoujinshiList> result;
    try {
      result = Future.value(DoujinshiList.fromJson(jsonDecode(response.body)));
    } catch (e) {
      result = Future.value(DoujinshiList(result: [], numPages: 0, perPage: 0));
    }
    return result;
  }
}
