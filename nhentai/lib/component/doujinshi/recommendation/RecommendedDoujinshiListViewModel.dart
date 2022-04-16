import 'dart:async';

import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/domain/entity/RecommendationType.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/usecase/GetRecommendedDoujinshisUseCase.dart';

abstract class RecommendedDoujinshiListViewModel {
  DataCubit<List<Doujinshi>> recommendedDoujinshisCubit();

  void init();

  void refreshCurrentList();

  void destroy();
}

class RecommendedDoujinshiListViewModelImpl
    extends RecommendedDoujinshiListViewModel {
  static const int RECOMMENDATION_LIMIT = 5;

  final String name;
  final RecommendationType recommendationType;

  RecommendedDoujinshiListViewModelImpl(
      {required this.name, required this.recommendationType});

  static Map<String, List<Doujinshi>> _namedLists = {};

  DataCubit<List<Doujinshi>> _recommendedListCubit = DataCubit([]);

  GetRecommendedDoujinshisUseCase _getRecommendedDoujinshisUseCase =
      GetRecommendedDoujinshisUseCaseImpl();

  List<StreamSubscription> _streamSubscriptions = [];

  @override
  DataCubit<List<Doujinshi>> recommendedDoujinshisCubit() {
    return _recommendedListCubit;
  }

  @override
  void init() {
    if (_recommendedListCubit.isClosed) {
      _recommendedListCubit = DataCubit([]);
    }

    List<Doujinshi>? namedList = _namedLists[name];
    print('Recommendation of $name>>> cached list $namedList');
    if (namedList != null && namedList.isNotEmpty) {
      _recommendedListCubit.emit(namedList);
    } else {
      refreshCurrentList();
    }
  }

  @override
  void refreshCurrentList() {
    _streamSubscriptions.add(_getRecommendedDoujinshisUseCase
        .execute(recommendationType, RECOMMENDATION_LIMIT)
        .listen((Future<List<Doujinshi>> futureDoujinshiList) async {
      List<Doujinshi> doujinshiList = await futureDoujinshiList;
      print('Recommendation of $name>>> doujinshiList=${doujinshiList.length}');
      if (doujinshiList.isNotEmpty) {
        _recommendedListCubit.emit(doujinshiList);
        _namedLists[name] = doujinshiList;
      }
    }, onError: (error, stackTrace) {
      print(
          'Recommendation of $name>>> Could not get recommended doujinshis with error $error');
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
