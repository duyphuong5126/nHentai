import 'package:nhentai/domain/entity/Doujinshi.dart';

class DoujinshiResult {
  DoujinshiResult._();

  factory DoujinshiResult.success(Doujinshi doujinshi) = Success;

  factory DoujinshiResult.error(Exception? exception) = Error;
}

class Success extends DoujinshiResult {
  final Doujinshi doujinshi;

  Success(this.doujinshi) : super._();
}

class Error extends DoujinshiResult {
  Exception? exception;

  Error(this.exception) : super._();
}
