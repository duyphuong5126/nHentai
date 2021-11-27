import 'package:nhentai/domain/entity/Doujinshi.dart';

class DownloadedDoujinshi extends Doujinshi {
  final List<String> downloadedPathList;

  DownloadedDoujinshi(
      {required Doujinshi doujinshi, required this.downloadedPathList})
      : super(
            id: doujinshi.id,
            mediaId: doujinshi.mediaId,
            title: doujinshi.title,
            images: doujinshi.images,
            scanlator: doujinshi.scanlator,
            uploadDate: doujinshi.uploadDate,
            tags: doujinshi.tags,
            numFavorites: doujinshi.numFavorites,
            numPages: doujinshi.numPages);
}
