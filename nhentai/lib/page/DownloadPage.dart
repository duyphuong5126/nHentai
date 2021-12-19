import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/analytics/AnalyticsUtils.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/DefaultScreenTitle.dart';
import 'package:nhentai/component/DefaultSectionLabel.dart';
import 'package:nhentai/component/DoujinshiGridGallery.dart';
import 'package:nhentai/component/LoadingMessage.dart';
import 'package:nhentai/component/NumberPageIndicesList.dart';
import 'package:nhentai/component/doujinshi/recommendation/RecommendedDoujinshiList.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshi.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshiList.dart';
import 'package:nhentai/domain/entity/RecommendationType.dart';
import 'package:nhentai/domain/usecase/GetDownloadedDoujinshiCountUseCase.dart';
import 'package:nhentai/domain/usecase/GetDownloadedDoujinshisUseCase.dart';
import 'package:nhentai/domain/usecase/GetFavoriteDoujinshiCountUseCase.dart';
import 'package:nhentai/domain/usecase/GetRecentlyReadDoujinshiCountUseCase.dart';
import 'package:nhentai/page/uimodel/OpenDoujinshiModel.dart';
import 'package:nhentai/support/Extensions.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  static const _PER_PAGE = 25;
  final GetDownloadedDoujinshiCountUseCase _getDownloadedDoujinshiCountUseCase =
      GetDownloadedDoujinshiCountUseCaseImpl();
  final GetDownloadedDoujinshisUseCase _getDownloadedDoujinshisUseCase =
      GetDownloadedDoujinshisUseCaseImpl();
  final GetRecentlyReadDoujinshiCountUseCase
      _getRecentlyReadDoujinshiCountUseCase =
      GetRecentlyReadDoujinshiCountUseCaseImpl();
  final GetFavoriteDoujinshiCountUseCase _getFavoriteDoujinshiCountUseCase =
      GetFavoriteDoujinshiCountUseCaseImpl();
  final DataCubit<int> _numOfPagesCubit = DataCubit(0);
  final DataCubit<List<DownloadedDoujinshi>> _doujinshiListCubit =
      DataCubit([]);
  final DataCubit<String> _pageIndicatorCubit = DataCubit('');
  final DataCubit<bool> _loadingCubit = DataCubit(false);
  final DataCubit<bool> refreshStatusesSignalCubit = DataCubit(false);

  final ScrollController _scrollController = ScrollController();

  int _downloadedCount = 0;
  int _numOfPages = 0;
  int _currentPage = -1;
  int _recentlyReadCount = 0;
  int _favoriteCount = 0;

  Map<int, List<DownloadedDoujinshi>> doujinshiMap = {};

  StateHolder<int> selectedPageHolder = StateHolder<int>(data: 0);

  @override
  Widget build(BuildContext context) {
    _initDoujinshiCollection();
    return Scaffold(
      appBar: AppBar(
        title: DefaultScreenTitle('Download'),
        centerTitle: true,
        backgroundColor: Constant.mainColor,
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
            recommendationType: RecommendationType.Downloaded,
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
    int downloadedCount = await _getDownloadedDoujinshiCountUseCase.execute();
    if (downloadedCount != _downloadedCount) {
      _downloadedCount = downloadedCount;
      _resetCollection();
      _changeToPage(0);
      _recentlyReadCount =
          await _getRecentlyReadDoujinshiCountUseCase.execute();
      _favoriteCount = await _getFavoriteDoujinshiCountUseCase.execute();
    } else {
      int recentlyReadCount =
          await _getRecentlyReadDoujinshiCountUseCase.execute();
      int favoriteCount = await _getFavoriteDoujinshiCountUseCase.execute();
      if (_recentlyReadCount != recentlyReadCount ||
          _favoriteCount != favoriteCount) {
        refreshStatusesSignalCubit.emit(true);
      }
    }
  }

  void _openDoujinshi(Doujinshi doujinshi) async {
    context.closeSoftKeyBoard();
    AnalyticsUtils.openDownloadedDoujinshi(doujinshi.id);
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

      _doujinshiListCubit.emit(_getCurrentPage());
      _pageIndicatorCubit.emit(_pageIndicator());
    } else {
      _loadingCubit.emit(true);
      DownloadedDoujinshiList doujinshiList =
          await _getDownloadedDoujinshisUseCase.execute(page, _PER_PAGE);
      _currentPage = page;
      _numOfPages = doujinshiList.numPages;
      doujinshiMap[_currentPage] = doujinshiList.result;

      _doujinshiListCubit.emit(_getCurrentPage());
      _numOfPagesCubit.emit(doujinshiList.numPages);
      _pageIndicatorCubit.emit(_pageIndicator());
      _loadingCubit.emit(false);
    }
  }

  List<DownloadedDoujinshi> _getCurrentPage() {
    List<DownloadedDoujinshi>? doujinshiList = doujinshiMap[_currentPage];
    return doujinshiList != null ? doujinshiList : [];
  }

  String _pageIndicator() {
    String pageIndicator;
    int currentPageSize = _getCurrentPage().length;
    String collectionLabel = 'downloaded';
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

  void _resetCollection() {
    _numOfPages = 0;
    _currentPage = -1;
    doujinshiMap.clear();
    _scrollController.jumpTo(0);
    _numOfPagesCubit.emit(0);
    _doujinshiListCubit.emit([]);
    _pageIndicatorCubit.emit('');
    _loadingCubit.emit(false);
  }
}
