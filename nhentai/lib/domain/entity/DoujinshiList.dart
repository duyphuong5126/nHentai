import 'package:nhentai/domain/entity/Doujinshi.dart';

class DoujinshiList {
  late List<Doujinshi> result;
  late int numPages;
  late int perPage;

  DoujinshiList(
      {required this.result, required this.numPages, required this.perPage});

  DoujinshiList.fromJson(Map<String, dynamic> json) {
    result = [];
    json['result'].forEach((v) {
      result.add(new Doujinshi.fromJson(v));
    });
    numPages = json['num_pages'];
    perPage = json['per_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result.map((v) => v.toJson()).toList();
    data['num_pages'] = this.numPages;
    data['per_page'] = this.perPage;
    return data;
  }
}
