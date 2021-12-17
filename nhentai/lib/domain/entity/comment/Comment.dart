import 'package:nhentai/domain/entity/comment/CommentPoster.dart';

class Comment {
  late int id;
  late int galleryId;
  late CommentPoster poster;
  late int postDate;
  late String body;

  Comment(
      {required this.id,
      required this.galleryId,
      required this.poster,
      required this.postDate,
      required this.body});

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    galleryId = json['gallery_id'];
    poster = CommentPoster.fromJson(json['poster']);
    postDate = json['post_date'] * 1000;
    body = json['body'];
  }
}
