import 'package:nhentai/domain/entity/DoujinshiPage.dart';

class Images {
  late List<DoujinshiPage> pages;
  late DoujinshiPage cover;
  late DoujinshiPage thumbnail;

  Images({required this.pages, required this.cover, required this.thumbnail});

  Images.fromJson(Map<String, dynamic> json) {
    pages = [];
    json['pages'].forEach((v) {
      pages.add(new DoujinshiPage.fromJson(v));
    });
    cover = new DoujinshiPage.fromJson(json['cover']);
    thumbnail = new DoujinshiPage.fromJson(json['thumbnail']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pages'] = this.pages.map((v) => v.toJson()).toList();
    data['cover'] = this.cover.toJson();
    data['thumbnail'] = this.thumbnail.toJson();
    return data;
  }
}
