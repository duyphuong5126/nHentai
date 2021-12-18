import 'dart:async';

import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/domain/entity/RecommendationType.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/usecase/GetRecommendedDoujinshisUseCase.dart';

abstract class RecommendedDoujinshiListViewModel {
  DataCubit<List<Doujinshi>> recommendedDoujinshisCubit();

  void init(RecommendationType recommendationType);

  void destroy();
}

class RecommendedDoujinshiListViewModelImpl
    extends RecommendedDoujinshiListViewModel {
  static const int RECOMMENDATION_LIMIT = 5;

  DataCubit<List<Doujinshi>> _recommendedListCubit = DataCubit([]);

  GetRecommendedDoujinshisUseCase _getRecommendedDoujinshisUseCase =
      GetRecommendedDoujinshisUseCaseImpl();

  List<StreamSubscription> _streamSubscriptions = [];

  @override
  DataCubit<List<Doujinshi>> recommendedDoujinshisCubit() {
    return _recommendedListCubit;
  }

  @override
  void init(RecommendationType recommendationType) {
    _streamSubscriptions.add(_getRecommendedDoujinshisUseCase
        .execute(recommendationType, RECOMMENDATION_LIMIT)
        .listen((Future<List<Doujinshi>> doujinshiListFuture) async {
      List<Doujinshi> doujinshiList = await doujinshiListFuture;
      print('Test>>> doujinshiList=${doujinshiList.length}');
      _recommendedListCubit.emit(doujinshiList);
    }, onError: (error, stackTrace) {
      print('Test>>> Could not get recommended doujinshis with error $error');
    }));
  }

  @override
  void destroy() {
    _recommendedListCubit.close();
    _streamSubscriptions
        .forEach((streamSubscription) => streamSubscription.cancel());
    _streamSubscriptions.clear();
  }
}
