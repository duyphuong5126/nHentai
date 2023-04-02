import 'package:flutter_bloc/flutter_bloc.dart';

class DataCubit<Data> extends Cubit<Data> {
  DataCubit(Data initialState) : super(initialState);

  push(Data state) {
    if (!isClosed) {
      emit(state);
    }
  }

  void dispose() async {
    close();
  }
}
