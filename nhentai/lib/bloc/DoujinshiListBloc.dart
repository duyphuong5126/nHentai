import 'dart:async';

import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:rxdart/rxdart.dart';

class DoujinshiListBloc {
  List<Doujinshi> _data = [];

  final StreamController<List<Doujinshi>> _dataStreamController = BehaviorSubject();

  StreamSink<List<Doujinshi>> get _input => _dataStreamController.sink;

  Stream<List<Doujinshi>> get output => _dataStreamController.stream;

  void updateData(List<Doujinshi> newData) {
    _data = newData;
    _input.add(_data);
  }

  void dispose() {
    _dataStreamController.close();
  }
}
