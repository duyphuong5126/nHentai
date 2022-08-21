import 'dart:async';
import 'dart:convert';

import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/data/remote/url_builder.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/domain/entity/RecommendationType.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/recommendation_info.dart';
import 'package:nhentai/domain/usecase/get_recommendation_info_use_case.dart';

abstract class RecommendedDoujinshiListViewModel {
  DataCubit<List<Doujinshi>> recommendedDoujinshisCubit();

  DataCubit<String> recommendedUrl();

  void init();

  void refreshCurrentList();

  void onDataLoaded(String rawJson);

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

  DataCubit<String> _recommendedUrl = DataCubit('');

  GetRecommendationUseCase _getRecommendationUseCase =
      GetRecommendationUseCaseImpl();

  List<StreamSubscription> _streamSubscriptions = [];

  @override
  DataCubit<List<Doujinshi>> recommendedDoujinshisCubit() {
    return _recommendedListCubit;
  }

  @override
  DataCubit<String> recommendedUrl() {
    return _recommendedUrl;
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
  void refreshCurrentList() async {
    _streamSubscriptions.add(_getRecommendationUseCase
        .execute(recommendationType)
        .asStream()
        .listen((RecommendationInfo recommendationInfo) {
      String finalUrl = UrlBuilder.buildGalleryUrl(
          1, recommendationInfo.searchTerm, recommendationInfo.sortOption);
      _recommendedUrl.emit(finalUrl);
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
    _recommendedUrl.dispose();
  }

  @override
  void onDataLoaded(String rawJson) async {
    List<Doujinshi> doujinshiList = DoujinshiList.fromJson(jsonDecode(rawJson))
        .result
        .sublist(0, RECOMMENDATION_LIMIT);
    if (doujinshiList.isNotEmpty) {
      _recommendedListCubit.emit(doujinshiList);
      _namedLists[name] = doujinshiList;
    }
  }
}
