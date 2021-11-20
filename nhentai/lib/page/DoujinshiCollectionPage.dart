import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/DoujinshiGridGallery.dart';
import 'package:nhentai/component/LoadingMessage.dart';
import 'package:nhentai/component/NumberPageIndicesList.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/domain/usecase/GetRecentlyReadDoujinshiCountUseCase.dart';
import 'package:nhentai/domain/usecase/GetRecentlyReadDoujinshiListUseCase.dart';
import 'package:nhentai/page/uimodel/DoujinshiCollectionType.dart';
import 'package:nhentai/component/DefaultScreenTitle.dart';
import 'package:nhentai/component/DefaultSectionLabel.dart';

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
  final DataCubit<int> _numOfPagesCubit = DataCubit(-1);
  final DataCubit<List<Doujinshi>> _doujinshiListCubit = DataCubit([]);
  final DataCubit<String> _pageIndicatorCubit = DataCubit('');
  final DataCubit<DoujinshiCollectionType> _collectionTypeCubit =
      DataCubit(DoujinshiCollectionType.Recent);
  final DataCubit<bool> _loadingCubit = DataCubit(false);

  final ScrollController _scrollController = ScrollController();

  int collectionSize = 0;
  int numOfPages = 0;
  int currentPage = -1;
  Map<int, List<Doujinshi>> doujinshiMap = {};

  StateHolder<int> selectedPageHolder = StateHolder<int>(data: 0);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 1)).then((value) =>
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Constant.mainDarkColor,
            systemStatusBarContrastEnforced: true)));
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
                return IconButton(onPressed: () {}, icon: icon);
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
    return ListView(
      controller: _scrollController,
      children: [
        DoujinshiGridGallery(
          doujinshiListCubit: _doujinshiListCubit,
          onDoujinshiSelected: this._openDoujinshi,
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
            margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
          ),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 20, 10, 40),
            child: NumberPageIndicesList(
                numOfPagesCubit: _numOfPagesCubit,
                selectedPageIndexHolder: selectedPageHolder,
                onPagePressed: this._goToPage),
            height: 40,
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
    if (recentlyReadCount != collectionSize) {
      collectionSize = recentlyReadCount;
      _resetCollection();
      _changeToPage(0);
    }
  }

  void _openDoujinshi(Doujinshi doujinshi) async {
    await Navigator.of(context)
        .pushNamed(MainNavigator.DOUJINSHI_PAGE, arguments: doujinshi);
    _initDoujinshiCollection();
  }

  void _goToPage(int page) {
    if (page < 0 || (page > 0 && page >= numOfPages)) {
    } else {
      _changeToPage(page);
      _scrollController.jumpTo(0);
    }
  }

  void _changeToPage(int page) async {
    if (doujinshiMap.containsKey(page)) {
      currentPage = page;
      doujinshiMap[currentPage] = doujinshiMap[page]!;

      _doujinshiListCubit.emit(_getCurrentPage());
      _pageIndicatorCubit.emit(_pageIndicator());
    } else {
      _loadingCubit.emit(true);
      DoujinshiList doujinshiList =
          await _getRecentlyReadDoujinshiListUseCase.execute(page, _PER_PAGE);
      currentPage = page;
      numOfPages = doujinshiList.numPages;
      doujinshiMap[currentPage] = doujinshiList.result;

      _doujinshiListCubit.emit(_getCurrentPage());
      _numOfPagesCubit.emit(doujinshiList.numPages);
      _pageIndicatorCubit.emit(_pageIndicator());
      _loadingCubit.emit(false);
    }
  }

  List<Doujinshi> _getCurrentPage() {
    List<Doujinshi>? doujinshiList = doujinshiMap[currentPage];
    return doujinshiList != null ? doujinshiList : [];
  }

  String _pageIndicator() {
    String pageIndicator;
    int currentPageSize = _getCurrentPage().length;
    String collectionLabel =
        _collectionTypeCubit.state == DoujinshiCollectionType.Recent
            ? 'recently read'
            : 'favorite';
    if (numOfPages <= 0) {
      pageIndicator = 'No $collectionLabel doujinshi';
    } else if (currentPageSize <= 0) {
      pageIndicator = 'Page ${currentPage + 1}/$numOfPages';
    } else if (currentPageSize <= 1) {
      pageIndicator =
          'Page ${currentPage + 1}/$numOfPages - One $collectionLabel doujinshi';
    } else {
      pageIndicator =
          'Page ${currentPage + 1}/$numOfPages - $currentPageSize $collectionLabel doujinshis';
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
    numOfPages = 0;
    currentPage = -1;
    doujinshiMap.clear();
    _scrollController.jumpTo(0);
    _numOfPagesCubit.emit(0);
    _doujinshiListCubit.emit([]);
    _pageIndicatorCubit.emit('');
    _loadingCubit.emit(false);
  }
}
