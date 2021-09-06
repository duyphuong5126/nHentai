import 'dart:convert';

import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:http/http.dart';

class DoujinshiRemoteDataSource {
  Future<DoujinshiList> getDoujinshiList(int page) async {
    Response response = await get(
        Uri.parse('https://nhentai.net/api/galleries/all?page=$page'));
    Future<DoujinshiList> result;
    try {
      result = Future.value(DoujinshiList.fromJson(jsonDecode(response.body)));
    } catch (e) {
      result = Future.value(DoujinshiList(result: [], numPages: 0, perPage: 0));
    }
    return result;
  }
}
