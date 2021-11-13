import 'package:flutter_bloc/flutter_bloc.dart';

class DataCubit<Data> extends Cubit<Data> {
  DataCubit(Data initialState) : super(initialState);

  void dispose() async {
    close();
  }
}
