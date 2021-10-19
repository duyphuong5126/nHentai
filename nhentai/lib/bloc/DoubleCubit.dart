import 'package:flutter_bloc/flutter_bloc.dart';

class DoubleCubit extends Cubit<double> {
  DoubleCubit(double initialState) : super(initialState);

  void dispose() async {
    close();
  }
}
