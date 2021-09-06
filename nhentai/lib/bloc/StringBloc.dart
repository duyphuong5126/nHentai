import 'dart:async';

import 'package:rxdart/rxdart.dart';

class StringBloc {
  String _data = '';

  final StreamController<String> _dataStreamController = BehaviorSubject();

  StreamSink<String> get _input => _dataStreamController.sink;

  Stream<String> get output => _dataStreamController.stream;

  void updateData(String newData) {
    if (newData != _data) {
      _data = newData;
      _input.add(_data);
    }
  }

  void dispose() {
    _dataStreamController.close();
  }
}
