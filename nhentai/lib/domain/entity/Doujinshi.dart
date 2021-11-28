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

  late String thumbnailImage;
  late String coverImage;
  List<String> previewThumbnailList = [];
  List<String> fullSizePageUrlList = [];
  String backUpCoverImage = '';
  String languageIcon = '';
  String shareUrl = '';

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
    String thumbnailType = images.thumbnail.t == 'p' ? '.png' : '.jpg';
    thumbnailImage =
        '${Constant.NHENTAI_T}/galleries/$mediaId/thumb$thumbnailType';
    coverImage = '${Constant.NHENTAI_T}/galleries/$mediaId/cover.jpg';
    if (images.pages.isNotEmpty) {
      String backUpCoverType = images.pages.first.t == 'p' ? '.png' : '.jpg';
      backUpCoverImage =
          '${Constant.NHENTAI_I}/galleries/$mediaId/1$backUpCoverType';
      for (int index = 0; index < images.pages.length; index++) {
        String thumbnailType = images.pages[index].t == 'p' ? '.png' : '.jpg';
        previewThumbnailList.add(
            '${Constant.NHENTAI_T}/galleries/$mediaId/${index + 1}t$thumbnailType');
        String imageType = images.pages[index].t == 'p' ? '.png' : '.jpg';
        fullSizePageUrlList.add(
            '${Constant.NHENTAI_I}/galleries/$mediaId/${index + 1}$imageType');
      }
    }

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
    shareUrl = '${Constant.NHENTAI_HOME}/g/$id/';
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
