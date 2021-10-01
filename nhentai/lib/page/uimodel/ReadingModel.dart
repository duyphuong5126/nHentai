import 'package:nhentai/domain/entity/Doujinshi.dart';

class ReadingModel {
  final Doujinshi doujinshi;
  final int startPageIndex;

  const ReadingModel({required this.doujinshi, required this.startPageIndex});
}
