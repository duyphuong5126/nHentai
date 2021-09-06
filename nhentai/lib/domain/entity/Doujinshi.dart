import 'package:nhentai/Constant.dart';
import 'package:nhentai/domain/entity/Images.dart';
import 'package:nhentai/domain/entity/Tag.dart';
import 'package:nhentai/domain/entity/Title.dart';

class Doujinshi {
  late int id;
  late String mediaId;
  late Title title;
  late Images images;
  late String scanlator;
  late int uploadDate;
  late List<Tag> tags;
  late int numPages;
  late int numFavorites;

  static String _thumbnailBaseUrl = 'https://t.nhentai.net';

  late String bookThumbnail;
  String languageIcon = '';

  Doujinshi(
      {required this.id,
      required this.mediaId,
      required this.title,
      required this.images,
      required this.scanlator,
      required this.uploadDate,
      required this.tags,
      required this.numPages,
      required this.numFavorites}) {
    _initData();
  }

  Doujinshi.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    mediaId = json['media_id'];
    title = new Title.fromJson(json['title']);
    images = new Images.fromJson(json['images']);
    scanlator = json['scanlator'];
    uploadDate = json['upload_date'];
    tags = [];
    json['tags'].forEach((v) {
      tags.add(new Tag.fromJson(v));
    });
    numPages = json['num_pages'];
    numFavorites = json['num_favorites'];

    _initData();
  }

  void _initData() {
    String imageType = images.thumbnail.t == 'p' ? '.png' : '.jpg';
    bookThumbnail = '$_thumbnailBaseUrl/galleries/$mediaId/thumb$imageType';
    if (tags.any((element) {
      String lang = element.name.toLowerCase();
      return lang == Constant.ENGLISH_LANG || lang == Constant.TRANSLATED_LANG;
    })) {
      languageIcon = Constant.IMAGE_LANG_GB;
    }
    if (tags.any(
            (element) => element.name.toLowerCase() == Constant.JAPANESE_LANG)) {
      languageIcon = Constant.IMAGE_LANG_JP;
    }
    if (tags.any(
            (element) => element.name.toLowerCase() == Constant.CHINESE_LANG)) {
      languageIcon = Constant.IMAGE_LANG_CN;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['media_id'] = this.mediaId;
    data['title'] = this.title.toJson();
    data['images'] = this.images.toJson();
    data['scanlator'] = this.scanlator;
    data['upload_date'] = this.uploadDate;
    data['tags'] = this.tags.map((v) => v.toJson()).toList();
    data['num_pages'] = this.numPages;
    data['num_favorites'] = this.numFavorites;
    return data;
  }
}
