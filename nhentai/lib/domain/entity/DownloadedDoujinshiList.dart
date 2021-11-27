import 'package:nhentai/domain/entity/DownloadedDoujinshi.dart';

class DownloadedDoujinshiList {
  late List<DownloadedDoujinshi> result;
  late int numPages;
  late int perPage;

  DownloadedDoujinshiList(
      {required this.result, required this.numPages, required this.perPage});
}
