import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/analytics/AnalyticsUtils.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/DoujinshiGridGallery.dart';
import 'package:nhentai/component/LoadingMessage.dart';
import 'package:nhentai/component/NumberPageIndicesList.dart';
import 'package:nhentai/component/doujinshi/recommendation/RecommendedDoujinshiList.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/domain/entity/RecommendationType.dart';
import 'package:nhentai/domain/usecase/GetFavoriteDoujinshiCountUseCase.dart';
import 'package:nhentai/domain/usecase/GetFavoriteDoujinshiListUseCase.dart';
import 'package:nhentai/domain/usecase/GetRecentlyReadDoujinshiCountUseCase.dart';
import 'package:nhentai/domain/usecase/GetRecentlyReadDoujinshiListUseCase.dart';
import 'package:nhentai/page/uimodel/DoujinshiCollectionType.dart';
import 'package:nhentai/component/DefaultScreenTitle.dart';
import 'package:nhentai/component/DefaultSectionLabel.dart';
import 'package:nhentai/page/uimodel/OpenDoujinshiModel.dart';
import 'package:nhentai/support/Extensions.dart';

class DoujinshiCollectionPage extends StatefulWidget {
  const DoujinshiCollectionPage({Key? key}) : super(key: key);

  @override
  _DoujinshiCollectionPageState createState() =>
      _DoujinshiCollectionPageState();
}

class _DoujinshiCollectionPageState extends State<DoujinshiCollectionPage> {
  static const _PER_PAGE = 25;

  final GetRecentlyReadDoujinshiListUseCase
      _getRecentlyReadDoujinshiListUseCase =
      GetRecentlyReadDoujinshiListUseCaseImpl();
  final GetRecentlyReadDoujinshiCountUseCase
      _getRecentlyReadDoujinshiCountUseCase =
      GetRecentlyReadDoujinshiCountUseCaseImpl();
  final GetFavoriteDoujinshiCountUseCase _getFavoriteDoujinshiCountUseCase =
      GetFavoriteDoujinshiCountUseCaseImpl();
  final GetFavoriteDoujinshiListUseCase _getFavoriteDoujinshiListUseCase =
      GetFavoriteDoujinshiListUseCaseImpl();
  final DataCubit<int> _numOfPagesCubit = DataCubit(0);
  final DataCubit<List<Doujinshi>> _doujinshiListCubit = DataCubit([]);
  final DataCubit<String> _pageIndicatorCubit = DataCubit('');
  final DataCubit<DoujinshiCollectionType> _collectionTypeCubit =
      DataCubit(DoujinshiCollectionType.Recent);
  final DataCubit<bool> _loadingCubit = DataCubit(false);
  final DataCubit<bool> refreshStatusesSignalCubit = DataCubit(false);

  final ScrollController _scrollController = ScrollController();

  int _recentlyReadCount = 0;
  int _favoriteCount = 0;
  int _numOfPages = 0;
  int _currentPage = -1;
  Map<int, List<Doujinshi>> doujinshiMap = {};

  StateHolder<int> selectedPageHolder = StateHolder<int>(data: 0);

  @override
  void initState() {
    super.initState();
    _collectionTypeCubit.stream.listen((collectionType) {
      _resetCollection();
      _changeToPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    _initDoujinshiCollection();
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder(
          bloc: _collectionTypeCubit,
          builder: (context, collectionType) {
            return DefaultScreenTitle(
                collectionType == DoujinshiCollectionType.Recent
                    ? 'Recently read'
                    : 'Favorite');
          },
        ),
        centerTitle: true,
        backgroundColor: Constant.mainColor,
        actions: [
          BlocBuilder(
              bloc: _collectionTypeCubit,
              builder: (context, collectionType) {
                Icon icon = collectionType == DoujinshiCollectionType.Recent
                    ? Icon(Icons.favorite)
                    : Icon(Icons.history);
                return IconButton(
                    onPressed: () {
                      _collectionTypeCubit.push(
                          collectionType == DoujinshiCollectionType.Recent
                              ? DoujinshiCollectionType.Favorite
                              : DoujinshiCollectionType.Recent);
                    },
                    icon: icon);
              })
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: _getBodyWidget(),
              color: Colors.black,
            ),
          )),
          Positioned.fill(
              child: Align(
            alignment: Alignment.topLeft,
            child: BlocBuilder(
                bloc: _numOfPagesCubit,
                builder: (BuildContext context, int numOfPages) {
                  return Visibility(
                    child: Container(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Image.asset(
                            'images/ic_nothing_here_grey.png',
                            height: 450,
                          )
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      color: Constant.getNothingColor(),
                      constraints: BoxConstraints.expand(),
                    ),
                    visible: numOfPages == 0,
                  );
                }),
          )),
          Positioned.fill(
              child: Align(
            alignment: Alignment.bottomLeft,
            child: BlocBuilder(
              bloc: _loadingCubit,
              builder: (BuildContext context, bool isLoading) {
                return Visibility(
                  child: LoadingMessage(loadingMessage: 'Loading, please wait'),
                  visible: isLoading,
                );
              },
            ),
          ))
        ],
      ),
    );
  }

  Widget _getBodyWidget() {
    RecommendationType recommendationType =
        _collectionTypeCubit.state == DoujinshiCollectionType.Recent
            ? RecommendationType.RecentlyRead
            : RecommendationType.Favorite;
    return ListView(
      controller: _scrollController,
      children: [
        DoujinshiGridGallery(
          doujinshiListCubit: _doujinshiListCubit,
          onDoujinshiSelected: this._openDoujinshi,
          refreshStatusesSignalCubit: refreshStatusesSignalCubit,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10, 15, 10, 5),
          child: RecommendedDoujinshiList(
            listName: 'DoujinshiCollectionPage',
            recommendationType: recommendationType,
          ),
        ),
        Center(
          child: Container(
            child: BlocBuilder(
                bloc: _pageIndicatorCubit,
                builder: (BuildContext c, String label) {
                  return Visibility(
                    child: SectionLabel(label, Colors.blueGrey[500]!),
                    visible: label.isNotEmpty,
                  );
                }),
            margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
          ),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 20),
            child: NumberPageIndicesList(
                numOfPagesCubit: _numOfPagesCubit,
                selectedPageIndexHolder: selectedPageHolder,
                onPageSelected: this._goToPage),
          ),
        ),
        BlocBuilder(
            bloc: _loadingCubit,
            builder: (BuildContext context, bool isLoading) {
              return Visibility(
                child: SizedBox(
                  height: 100,
                ),
                visible: isLoading,
              );
            })
      ],
    );
  }

  void _initDoujinshiCollection() async {
    int recentlyReadCount =
        await _getRecentlyReadDoujinshiCountUseCase.execute();
    int favoriteCount = await _getFavoriteDoujinshiCountUseCase.execute();
    switch (_collectionTypeCubit.state) {
      case DoujinshiCollectionType.Favorite:
        {
          if (favoriteCount != _favoriteCount) {
            _favoriteCount = favoriteCount;
            _resetCollection();
            _changeToPage(0);
          }
          break;
        }

      case DoujinshiCollectionType.Recent:
        {
          if (recentlyReadCount != _recentlyReadCount) {
            _recentlyReadCount = recentlyReadCount;
            _resetCollection();
            _changeToPage(0);
          } else if (favoriteCount != _favoriteCount) {
            _favoriteCount = favoriteCount;
            refreshStatusesSignalCubit.push(true);
          }
          break;
        }
    }
  }

  void _openDoujinshi(Doujinshi doujinshi) async {
    context.closeSoftKeyBoard();
    DoujinshiCollectionType collectionType = _collectionTypeCubit.state;
    if (collectionType == DoujinshiCollectionType.Recent) {
      AnalyticsUtils.openReadDoujinshi(doujinshi.id);
    } else {
      AnalyticsUtils.openFavoriteDoujinshi(doujinshi.id);
    }
    await Navigator.of(context).pushNamed(MainNavigator.DOUJINSHI_PAGE,
        arguments:
            OpenDoujinshiModel(doujinshi: doujinshi, isSearchable: false));
    _initDoujinshiCollection();
    Future.delayed(Duration(milliseconds: 1)).then((value) =>
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Constant.mainDarkColor,
            systemStatusBarContrastEnforced: true)));
  }

  void _goToPage(int page) {
    if (page < 0 || (page > 0 && page >= _numOfPages)) {
    } else {
      _changeToPage(page);
      _scrollController.jumpTo(0);
    }
  }

  void _changeToPage(int page) async {
    if (doujinshiMap.containsKey(page)) {
      _currentPage = page;
      doujinshiMap[_currentPage] = doujinshiMap[page]!;

      _doujinshiListCubit.push(_getCurrentPage());
      _pageIndicatorCubit.push(_pageIndicator());
    } else {
      _loadingCubit.push(true);
      DoujinshiList doujinshiList = _collectionTypeCubit.state ==
              DoujinshiCollectionType.Recent
          ? await _getRecentlyReadDoujinshiListUseCase.execute(page, _PER_PAGE)
          : await _getFavoriteDoujinshiListUseCase.execute(page, _PER_PAGE);
      _currentPage = page;
      _numOfPages = doujinshiList.numPages;
      doujinshiMap[_currentPage] = doujinshiList.result;

      _doujinshiListCubit.push(_getCurrentPage());
      _numOfPagesCubit.push(doujinshiList.numPages);
      _pageIndicatorCubit.push(_pageIndicator());
      _loadingCubit.push(false);
    }
  }

  List<Doujinshi> _getCurrentPage() {
    List<Doujinshi>? doujinshiList = doujinshiMap[_currentPage];
    return doujinshiList != null ? doujinshiList : [];
  }

  String _pageIndicator() {
    String pageIndicator;
    int currentPageSize = _getCurrentPage().length;
    String collectionLabel =
        _collectionTypeCubit.state == DoujinshiCollectionType.Recent
            ? 'recently read'
            : 'favorite';
    if (_numOfPages <= 0) {
      pageIndicator = 'No $collectionLabel doujinshi';
    } else if (currentPageSize <= 0) {
      pageIndicator = 'Page ${_currentPage + 1}/$_numOfPages';
    } else if (currentPageSize <= 1) {
      pageIndicator =
          'Page ${_currentPage + 1}/$_numOfPages - One $collectionLabel doujinshi';
    } else {
      pageIndicator =
          'Page ${_currentPage + 1}/$_numOfPages - $currentPageSize $collectionLabel doujinshis';
    }
    return pageIndicator;
  }

  @override
  void dispose() {
    super.dispose();
    _numOfPagesCubit.close();
    _doujinshiListCubit.close();
    _pageIndicatorCubit.close();
    _collectionTypeCubit.close();
    _loadingCubit.close();
  }

  void _resetCollection() {
    _numOfPages = 0;
    _currentPage = -1;
    doujinshiMap.clear();
    _scrollController.jumpTo(0);
    _numOfPagesCubit.push(0);
    _doujinshiListCubit.push([]);
    _pageIndicatorCubit.push('');
    _loadingCubit.push(false);
  }
}
