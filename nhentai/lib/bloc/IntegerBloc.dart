import 'dart:async';

import 'package:rxdart/rxdart.dart';

class IntegerBloc {
  int _data = -1;

  final StreamController<int> _dataStreamController = BehaviorSubject();

  StreamSink<int> get _input => _dataStreamController.sink;

  Stream<int> get output => _dataStreamController.stream;

  int getCurrentData() {
    return _data;
  }

  void updateData(int newData) {
    if (newData != _data) {
      _data = newData;
      _input.add(_data);
    }
  }

  void dispose() {
    _dataStreamController.close();
  }
}
