import 'package:nhentai/Constant.dart';

class CommentPoster {
  late int id;
  late String userName;
  late String slug;
  late String avatarUrl;
  late bool isSuperUser;
  late bool isStaff;

  CommentPoster(
      {required this.id,
      required this.userName,
      required this.slug,
      required this.avatarUrl,
      required this.isStaff,
      required this.isSuperUser});

  CommentPoster.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['username'];
    slug = json['slug'];
    avatarUrl = '${Constant.NHENTAI_I}/${json['avatar_url']}';
    isSuperUser = json['is_superuser'];
    isStaff = json['is_staff'];
  }
}
