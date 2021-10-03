import 'dart:async';

import 'package:rxdart/subjects.dart';

class BoolBloc {
  bool _data = false;

  final StreamController<bool> _dataStreamController = BehaviorSubject();

  StreamSink<bool> get _input => _dataStreamController.sink;

  Stream<bool> get output => _dataStreamController.stream;

  void updateData(bool newData) {
    if (newData != _data) {
      _data = newData;
      _input.add(_data);
    }
  }

  void dispose() {
    _dataStreamController.close();
  }
}
