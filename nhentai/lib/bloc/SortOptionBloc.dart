import 'dart:async';

import 'package:nhentai/page/uimodel/SortOption.dart';
import 'package:rxdart/rxdart.dart';

class SortOptionBloc {
  SortOption _data = SortOption.MostRecent;

  final StreamController<SortOption> _dataStreamController = BehaviorSubject();

  StreamSink<SortOption> get _input => _dataStreamController.sink;

  Stream<SortOption> get output => _dataStreamController.stream;

  SortOption getCurrentData() {
    return _data;
  }

  void updateData(SortOption newData) {
    if (newData != _data) {
      _data = newData;
      _input.add(_data);
    }
  }

  void dispose() {
    _dataStreamController.close();
  }
}
