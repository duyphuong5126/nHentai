import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/page/uimodel/ReaderType.dart';

class ReaderTypeCubit extends Cubit<ReaderType> {
  ReaderTypeCubit(ReaderType initialState) : super(initialState);

  void updateType(ReaderType newType) {
    emit(newType);
  }

  void dispose() async {
    close();
  }
}
