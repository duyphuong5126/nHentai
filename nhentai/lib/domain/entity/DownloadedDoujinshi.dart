import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/image.dart';

class DownloadedDoujinshi extends Doujinshi {
  final List<DoujinshiImage> downloadedPathList;
  final String downloadedCover;
  final String downloadedBackupCover;
  final String downloadedThumbnail;

  DownloadedDoujinshi(
      {required Doujinshi doujinshi,
      required this.downloadedPathList,
      required this.downloadedCover,
      required this.downloadedBackupCover,
      required this.downloadedThumbnail})
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
