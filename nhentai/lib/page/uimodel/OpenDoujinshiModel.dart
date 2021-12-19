import 'package:nhentai/domain/entity/Doujinshi.dart';

class OpenDoujinshiModel {
  final Doujinshi doujinshi;
  final bool isSearchable;

  const OpenDoujinshiModel(
      {required this.doujinshi, required this.isSearchable});
}
