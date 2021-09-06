import 'package:nhentai/domain/entity/Page.dart';

class Images {
  late List<Page> pages;
  late Page cover;
  late Page thumbnail;

  Images({required this.pages, required this.cover, required this.thumbnail});

  Images.fromJson(Map<String, dynamic> json) {
    pages = [];
    json['pages'].forEach((v) {
      pages.add(new Page.fromJson(v));
    });
    cover = new Page.fromJson(json['cover']);
    thumbnail = new Page.fromJson(json['thumbnail']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pages'] = this.pages.map((v) => v.toJson()).toList();
    data['cover'] = this.cover.toJson();
    data['thumbnail'] = this.thumbnail.toJson();
    return data;
  }
}
