import 'dart:async';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:rxdart/rxdart.dart';

class DoujinshiBloc {
  final StreamController<Doujinshi> _dataStreamController = BehaviorSubject();

  StreamSink<Doujinshi> get _input => _dataStreamController.sink;

  Stream<Doujinshi> get output => _dataStreamController.stream;

  void updateData(Doujinshi newData) {
    _input.add(newData);
  }

  void dispose() {
    _dataStreamController.close();
  }
}
