import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/page/uimodel/ReaderType.dart';

class ReaderTypeBloc extends Cubit<ReaderType> {
  ReaderTypeBloc(ReaderType initialState) : super(initialState);

  void updateType(ReaderType newType) {
    emit(newType);
  }

  void dispose() async {
    close();
  }
}
