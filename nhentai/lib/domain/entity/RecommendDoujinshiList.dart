import 'package:nhentai/domain/entity/Doujinshi.dart';

class RecommendedDoujinshiList {
  late List<Doujinshi> result;

  RecommendedDoujinshiList({required this.result});

  RecommendedDoujinshiList.fromJson(Map<String, dynamic> json) {
    result = [];
    json['result'].forEach((v) {
      result.add(new Doujinshi.fromJson(v));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result.map((v) => v.toJson()).toList();
    return data;
  }
}
