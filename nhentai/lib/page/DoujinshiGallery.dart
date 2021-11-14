import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/DoujinshiGridGallery.dart';
import 'package:nhentai/component/LoadingMessage.dart';
import 'package:nhentai/component/NumberPageIndicesList.dart';
import 'package:nhentai/component/SortOptionList.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/domain/entity/Tag.dart';
import 'package:nhentai/domain/usecase/GetDoujinshiListUseCase.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';
import 'package:nhentai/support/Extensions.dart';
import 'package:nhentai/component/DefaultSectionLabel.dart';

class DoujinshiGallery extends StatefulWidget {
  @override
  _DoujinshiGalleryState createState() => _DoujinshiGalleryState();
}

class _DoujinshiGalleryState extends State<DoujinshiGallery> {
  GetDoujinshiListUseCase _getBookListByPage =
      new GetDoujinshiListUseCaseImpl();

  final DataCubit<int> _numOfPagesCubit = DataCubit<int>(-1);
  final DataCubit<List<Doujinshi>> _doujinshiListCubit =
      DataCubit<List<Doujinshi>>([]);
  final DataCubit<String> _pageIndicatorCubit = DataCubit<String>('');
  final DataCubit<String> _searchTermCubit = DataCubit<String>('');
  final DataCubit<SortOption> _sortOptionCubit =
      DataCubit<SortOption>(SortOption.MostRecent);
  final DataCubit<bool> _loadingCubit = DataCubit<bool>(false);
  String _searchTerm = '';
  SortOption _sortOption = SortOption.MostRecent;

  StateHolder<int> selectedPageHolder = StateHolder<int>(data: 0);

  final ScrollController _scrollController = ScrollController();

  int numOfPages = 0;
  int itemCountPerPage = 0;
  int currentPage = -1;
  Map<int, List<Doujinshi>> doujinshiMap = {};

  void _changeToPage(int page) async {
    if (doujinshiMap.containsKey(page)) {
      currentPage = page;
      doujinshiMap[currentPage] = doujinshiMap[page]!;

      _doujinshiListCubit.emit(_getCurrentPage());
      _pageIndicatorCubit.emit(_pageIndicator());
    } else {
      _loadingCubit.emit(true);
      DoujinshiList doujinshiList =
          await _getBookListByPage.execute(page, _searchTerm, _sortOption);
      currentPage = page;
      numOfPages = doujinshiList.numPages;
      itemCountPerPage = doujinshiList.perPage;
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

  void _goToPage(int page) {
    if (page >= 0 && page < numOfPages) {
      _changeToPage(page);
      _scrollController.jumpTo(0);
    }
  }

  String _pageIndicator() {
    String pageIndicator;
    int currentPageSize = _getCurrentPage().length;
    if (numOfPages <= 0) {
      pageIndicator = _searchTerm.isNotEmpty
          ? 'No result for \"$_searchTerm\"'
          : 'No result';
    } else if (currentPageSize <= 0) {
      pageIndicator = 'Page ${currentPage + 1}/$numOfPages';
    } else if (currentPageSize <= 1) {
      pageIndicator =
          'Page ${currentPage + 1}/$numOfPages - Loaded 1 doujinshi';
    } else {
      pageIndicator =
          'Page ${currentPage + 1}/$numOfPages - Loaded $currentPageSize doujinshis';
    }
    return pageIndicator;
  }

  void _onSearchTermChanged(String newTerm) {
    if (newTerm != _searchTerm) {
      _scrollController.jumpTo(0);
      doujinshiMap.clear();
      _sortOption = SortOption.MostRecent;
      _sortOptionCubit.emit(_sortOption);
      _searchTerm = newTerm;
      _searchTermCubit.emit(newTerm);
      selectedPageHolder.data = 0;
      _goToPage(0);
    }
  }

  void _onSortOptionSelected(SortOption newSortOption) {
    if (newSortOption != _sortOption && _searchTerm.isNotEmpty) {
      doujinshiMap.clear();
      _sortOption = newSortOption;
      selectedPageHolder.data = 0;
      _goToPage(0);
    }
  }

  void _openDoujinshi(Doujinshi doujinshi) async {
    final openDoujinshiResult = await Navigator.of(context)
        .pushNamed(MainNavigator.DOUJINSHI_PAGE, arguments: doujinshi);
    if (openDoujinshiResult is Tag) {
      _onSearchTermChanged(openDoujinshiResult.name);
    }
  }

  @override
  void initState() {
    super.initState();
    _changeToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 1)).then((value) =>
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Constant.mainDarkColor,
            systemStatusBarContrastEnforced: true)));
    return Scaffold(
      appBar: AppBar(
        title: _getTitle(),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
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

  @override
  void dispose() {
    super.dispose();
    _doujinshiListCubit.dispose();
    _numOfPagesCubit.dispose();
    _pageIndicatorCubit.dispose();
    _searchTermCubit.dispose();
    _sortOptionCubit.dispose();
    _loadingCubit.dispose();
  }

  Widget _getTitle() {
    TextEditingController editingController = TextEditingController();
    TextStyle searchTextStyle = TextStyle(
        fontFamily: Constant.NUNITO_REGULAR,
        fontSize: 16,
        color: Constant.mainColor);
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              SvgPicture.asset(
                Constant.IMAGE_LOGO,
                width: 30,
                height: 15,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 0, 20, 0),
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Container(
                        height: 35,
                        margin: EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: editingController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'e.g. tag: "big breast"',
                              hintStyle: searchTextStyle,
                              contentPadding: EdgeInsets.only(bottom: 10)),
                          style: searchTextStyle,
                          maxLines: 1,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _onSearchTermChanged,
                        ),
                      )),
                      Container(
                        child: IconButton(
                          onPressed: () {
                            editingController.clear();
                            _onSearchTermChanged('');
                          },
                          padding: EdgeInsets.all(0),
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: Constant.mainColor,
                          ),
                        ),
                      ),
                      Container(
                        child: IconButton(
                          onPressed: () {
                            _onSearchTermChanged(editingController.text);
                            context.closeSoftKeyBoard();
                          },
                          icon: Icon(Icons.search),
                          padding: EdgeInsets.all(0),
                        ),
                        decoration: BoxDecoration(
                          color: Constant.mainColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _getBodyWidget() {
    return ListView(
      controller: _scrollController,
      children: [
        BlocBuilder(
            bloc: _searchTermCubit,
            builder: (BuildContext context, String searchTerm) {
              return Visibility(
                child: Center(
                  child: Container(
                    child: SectionLabel(
                        'Result for $searchTerm', Colors.blueGrey[500]!),
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  ),
                ),
                visible: searchTerm.isNotEmpty,
              );
            }),
        BlocBuilder(
            bloc: _searchTermCubit,
            builder: (BuildContext c, String searchTerm) {
              return Visibility(
                child: Container(
                  child: SortOptionList(
                    sortOptionCubit: _sortOptionCubit,
                    onSortOptionSelected: this._onSortOptionSelected,
                  ),
                  margin: EdgeInsets.only(top: 20, bottom: 10),
                  height: 40,
                ),
                visible: searchTerm.isNotEmpty,
              );
            }),
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
        Container(
          margin: EdgeInsets.fromLTRB(10, 20, 10, 40),
          child: Center(
            child: NumberPageIndicesList(
                numOfPagesCubit: _numOfPagesCubit,
                selectedPageIndexHolder: selectedPageHolder,
                onPagePressed: this._goToPage),
          ),
          height: 40,
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
}
