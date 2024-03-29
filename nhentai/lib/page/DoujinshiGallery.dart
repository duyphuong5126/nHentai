import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/analytics/AnalyticsUtils.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/DoujinshiGridGallery.dart';
import 'package:nhentai/component/LoadingMessage.dart';
import 'package:nhentai/component/NumberPageIndicesList.dart';
import 'package:nhentai/component/SortOptionList.dart';
import 'package:nhentai/component/YesNoActionsAlertDialog.dart';
import 'package:nhentai/component/doujinshi/recommendation/RecommendedDoujinshiList.dart';
import 'package:nhentai/data/remote/url_builder.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/domain/entity/RecommendationType.dart';
import 'package:nhentai/domain/entity/SearchHistory.dart';
import 'package:nhentai/domain/entity/SearchHistoryItem.dart';
import 'package:nhentai/domain/entity/Tag.dart';
import 'package:nhentai/page/uimodel/OpenDoujinshiModel.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';
import 'package:nhentai/support/Extensions.dart';
import 'package:nhentai/component/DefaultSectionLabel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DoujinshiGallery extends StatefulWidget {
  @override
  _DoujinshiGalleryState createState() => _DoujinshiGalleryState();
}

class _DoujinshiGalleryState extends State<DoujinshiGallery> {
  static const String HINT = 'nakadashi';
  static const double SUGGESTION_MAX_HEIGHT = 500.0;
  static const double SUGGESTION_WIDTH = 220.0;

  final DataCubit<int> _numOfPagesCubit = DataCubit<int>(-1);
  final DataCubit<List<Doujinshi>> _doujinshiListCubit =
      DataCubit<List<Doujinshi>>([]);
  final DataCubit<String> _pageIndicatorCubit = DataCubit<String>('');
  final DataCubit<String> _searchTermCubit = DataCubit<String>('');
  final DataCubit<SortOption> _sortOptionCubit =
      DataCubit<SortOption>(SortOption.MostRecent);
  final DataCubit<bool> _loadingCubit = DataCubit<bool>(false);
  final DataCubit<bool> _refreshStatusesSignalCubit = DataCubit<bool>(false);
  final DataCubit<int> _clearSearchBox = DataCubit(
    DateTime.now().millisecondsSinceEpoch,
  );
  String _searchTerm = '';
  SortOption _sortOption = SortOption.MostRecent;

  StateHolder<int> selectedPageHolder = StateHolder<int>(data: 0);

  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();

  late SearchHistory _searchHistory;

  int numOfPages = 0;
  int itemCountPerPage = 0;
  int currentPage = -1;
  Map<int, List<Doujinshi>> _doujinshiMap = {};

  WebViewController? _galleryController;

  WebViewController? _searchDoujinController;

  void _changeToPage(int page) async {
    if (_doujinshiMap.containsKey(page)) {
      currentPage = page;
      _doujinshiMap[currentPage] = _doujinshiMap[page]!;

      _doujinshiListCubit.push(_getCurrentPage());
      _pageIndicatorCubit.push(_pageIndicator());
    } else {
      String galleryUrl =
          UrlBuilder.buildGalleryUrl(page + 1, _searchTerm, _sortOption);
      _loadingCubit.push(true);
      currentPage = page;
      _galleryController?.loadUrl(galleryUrl);
      _clearSearchBox.push(DateTime.now().millisecondsSinceEpoch);
    }
    Future.delayed(Duration(seconds: 2))
        .then((value) => _refreshController.refreshCompleted());
  }

  List<Doujinshi> _getCurrentPage() {
    List<Doujinshi>? doujinshiList = _doujinshiMap[currentPage];
    return doujinshiList != null ? doujinshiList : [];
  }

  void _goToPage(int page) {
    if ((page >= 0 && page < numOfPages) || (page == 0 && numOfPages == 0)) {
      _changeToPage(page);
      _scrollController.jumpTo(0);
    }
  }

  String _pageIndicator() {
    String pageIndicator;
    int currentPageSize = _getCurrentPage().length;
    NumberFormat numberFormat = NumberFormat.decimalPattern();
    if (numOfPages <= 0) {
      pageIndicator = _searchTerm.isNotEmpty
          ? 'No result for \"$_searchTerm\"'
          : 'No result';
    } else if (currentPageSize <= 0) {
      pageIndicator =
          'Page ${currentPage + 1}/${numberFormat.format(numOfPages)}';
    } else if (currentPageSize <= 1) {
      pageIndicator =
          'Page ${currentPage + 1}/${numberFormat.format(numOfPages)} - Loaded 1 doujinshi';
    } else {
      pageIndicator =
          'Page ${currentPage + 1}/${numberFormat.format(numOfPages)} - Loaded $currentPageSize doujinshis';
    }
    return pageIndicator;
  }

  void _saveSearchHistory(String searchTerm) async {
    if (_searchHistory.history
        .any((historyItem) => historyItem.match(searchTerm))) {
      _searchHistory.history.forEach((historyItem) {
        if (historyItem.match(searchTerm)) {
          historyItem.increaseSearchTimes();
          return;
        }
      });
    } else {
      _searchHistory.prependSearchTerm(searchTerm);
      await _preferenceManager.saveSearchHistory(_searchHistory);
    }
  }

  void _deleteSearchHistory(String searchTerm) {
    showDialog(
        context: context,
        builder: (context) {
          return YesNoActionsAlertDialog(
              title: 'Delete this suggestion',
              content: 'Do you want to remove the suggestion "$searchTerm"?',
              yesLabel: 'Yes',
              noLabel: 'No',
              yesAction: () async {
                _searchHistory.history.removeWhere(
                    (historyItem) => historyItem.match(searchTerm));
                await _preferenceManager.saveSearchHistory(_searchHistory);
              },
              noAction: () {});
        });
  }

  void _searchDoujinshi(int doujinshiId) async {
    _loadingCubit.push(true);
    _searchDoujinController?.loadUrl(UrlBuilder.buildDetailUrl(doujinshiId));
    _clearSearchBox.push(DateTime.now().millisecondsSinceEpoch);
  }

  void _onSearchTermChanged(String newTerm) {
    print('Test>> newTerm=$newTerm, _searchTerm=$_searchTerm');
    context.closeSoftKeyBoard();
    int? doujinshiId = int.tryParse(newTerm);
    if (doujinshiId != null) {
      _searchDoujinshi(doujinshiId);
      _saveSearchHistory(newTerm);
    } else if (newTerm != _searchTerm) {
      _doujinshiMap.clear();
      _sortOption = SortOption.MostRecent;
      _sortOptionCubit.push(_sortOption);
      _searchTerm = newTerm;
      _searchTermCubit.push(newTerm);
      selectedPageHolder.data = 0;
      _goToPage(0);
      if (newTerm.isNotEmpty) {
        _saveSearchHistory(newTerm);
        AnalyticsUtils.search(newTerm);
      }
    }
  }

  void _onRefreshGallery() async {
    _doujinshiMap.clear();
    _sortOption = SortOption.MostRecent;
    _sortOptionCubit.push(_sortOption);
    _searchTermCubit.push(_searchTerm);
    selectedPageHolder.data = 0;
    _goToPage(0);
  }

  void _onSortOptionSelected(SortOption newSortOption) {
    if (newSortOption != _sortOption && _searchTerm.isNotEmpty) {
      _doujinshiMap.clear();
      _sortOption = newSortOption;
      selectedPageHolder.data = 0;
      _goToPage(0);
    }
  }

  void _openDoujinshi(Doujinshi doujinshi) async {
    context.closeSoftKeyBoard();
    AnalyticsUtils.openDoujinshi(doujinshi.id);
    final openDoujinshiResult = await Navigator.of(context).pushNamed(
        MainNavigator.DOUJINSHI_PAGE,
        arguments:
            OpenDoujinshiModel(doujinshi: doujinshi, isSearchable: true));
    if (openDoujinshiResult is Tag) {
      _onSearchTermChanged(openDoujinshiResult.name);
    }
    _refreshStatusesSignalCubit.push(true);
  }

  void _initSearchHistory() async {
    _searchHistory = await _preferenceManager.getSearchHistory();
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
    _initSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _getTitle(),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    child: WebView(
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (controller) {
                        _galleryController = controller;
                        _changeToPage(0);
                      },
                      onPageFinished: (url) async {
                        try {
                          String? body = await _galleryController?.bodyJson;
                          log('Test>>> Gallery url=$url, body=$body');
                          if (body != null) {
                            DoujinshiList doujinshiList =
                                DoujinshiList.fromJson(jsonDecode(body));
                            numOfPages = doujinshiList.numPages;
                            itemCountPerPage = doujinshiList.perPage;
                            _doujinshiMap[currentPage] = doujinshiList.result;

                            _doujinshiListCubit.push(_getCurrentPage());
                            _numOfPagesCubit.push(doujinshiList.numPages);
                            _pageIndicatorCubit.push(_pageIndicator());
                            _loadingCubit.push(false);
                          }
                        } catch (error) {
                          print('Gallery WebView error=$error');
                          _loadingCubit.push(false);
                          context.showErrorSnackBar(_searchTerm.isNotEmpty
                              ? 'Could not search for $_searchTerm doujinshis'
                              : 'Could not load gallery');
                        }
                      },
                      onWebResourceError: (error) {
                        print('Gallery WebView resource error=$error');
                        _loadingCubit.push(false);
                        context.showErrorSnackBar(_searchTerm.isNotEmpty
                            ? 'Could not search for $_searchTerm doujinshis'
                            : 'Could not load gallery');
                      },
                    ),
                    width: 1,
                    height: 1,
                  ))),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    child: WebView(
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (controller) {
                        _searchDoujinController = controller;
                      },
                      onPageFinished: (url) async {
                        try {
                          String? body =
                              await _searchDoujinController?.bodyJson;
                          log('Test>>> Search url=$url, body=$body');
                          if (body != null) {
                            _openDoujinshi(
                                Doujinshi.fromJson(jsonDecode(body)));
                            _loadingCubit.push(false);
                          }
                        } catch (error) {
                          print('Search Doujinshi WebView error=$error');
                          _loadingCubit.push(false);
                          context.showErrorSnackBar(
                              'Could not find any matched doujinshi');
                        }
                      },
                    ),
                    width: 1,
                    height: 1,
                  ))),
          Positioned.fill(
              child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: SmartRefresher(
                enablePullDown: true,
                controller: _refreshController,
                child: _getBodyWidget(),
                onRefresh: this._onRefreshGallery,
              ),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              child: Image.asset(
                            'images/ic_nothing_here_grey.png',
                            fit: BoxFit.scaleDown,
                          )),
                          Container(
                            margin: EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            constraints: BoxConstraints.expand(height: 40),
                            child: MaterialButton(
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                    fontFamily: Constant.BOLD,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                              color: Constant.mainColor,
                              onPressed: this._onRefreshGallery,
                            ),
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
          )),
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
    _refreshStatusesSignalCubit.dispose();
    _scrollController.dispose();
  }

  Widget _getTitle() {
    TextEditingController? editingController;
    TextStyle searchTextStyle = TextStyle(
        fontFamily: Constant.REGULAR, fontSize: 14, color: Constant.mainColor);
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              InkResponse(
                highlightColor: Colors.transparent,
                onTap: () {
                  editingController?.clear();
                  _onSearchTermChanged('');
                  context.closeSoftKeyBoard();
                },
                child: SvgPicture.asset(
                  Constant.IMAGE_LOGO,
                  width: 30,
                  height: 15,
                ),
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
                        child: RawAutocomplete<SearchHistoryItem>(
                          displayStringForOption: (historyItem) =>
                              historyItem.toString(),
                          optionsBuilder: (TextEditingValue text) {
                            String searchTerm = text.text;
                            if (searchTerm.isEmpty) {
                              return const [];
                            }
                            return _searchHistory.history.where((historyItem) {
                              return historyItem.match(searchTerm);
                            });
                          },
                          onSelected: (historyItem) {
                            _onSearchTermChanged(historyItem.searchTerm);
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                    maxHeight: SUGGESTION_MAX_HEIGHT),
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                color: Colors.white,
                                width: SUGGESTION_WIDTH,
                                child: ListView.separated(
                                    shrinkWrap: true,
                                    separatorBuilder: (context, int index) =>
                                        Divider(
                                          color: Constant.grey4D4D4D,
                                        ),
                                    padding: EdgeInsets.zero,
                                    itemCount: options.length,
                                    itemBuilder: (context, int index) {
                                      SearchHistoryItem option =
                                          options.elementAt(index);
                                      return Container(
                                        color: Colors.white,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                child: GestureDetector(
                                              child: RichText(
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                    style: TextStyle(
                                                        fontFamily:
                                                            Constant.REGULAR,
                                                        fontSize: 14,
                                                        color: Constant
                                                            .grey4D4D4D),
                                                    children: [
                                                      TextSpan(
                                                          text:
                                                              option.toString())
                                                    ]),
                                              ),
                                              onTap: () => onSelected(option),
                                            )),
                                            GestureDetector(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20,
                                                    horizontal: 10),
                                                child: Icon(Icons.close,
                                                    size: 14,
                                                    color: Constant.grey4D4D4D),
                                              ),
                                              onTap: () {
                                                _deleteSearchHistory(
                                                    option.searchTerm);
                                                onSelected(SearchHistoryItem(
                                                    searchTerm: '',
                                                    searchTimes: 0));
                                              },
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                            );
                          },
                          fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            editingController = textEditingController;
                            return BlocListener(
                              listener: (context, state) {
                                textEditingController.clear();
                              },
                              bloc: _clearSearchBox,
                              child: TextField(
                                focusNode: focusNode,
                                controller: textEditingController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'e.g. tag: "$HINT"',
                                    hintStyle: searchTextStyle,
                                    contentPadding:
                                        EdgeInsets.only(bottom: 10)),
                                style: searchTextStyle,
                                maxLines: 1,
                                textInputAction: TextInputAction.search,
                                onSubmitted: (searchText) {
                                  String searchTerm =
                                      searchText.isNotEmpty ? searchText : HINT;
                                  _onSearchTermChanged(searchTerm);
                                },
                              ),
                            );
                          },
                        ),
                      )),
                      Container(
                        child: IconButton(
                          onPressed: () {
                            editingController?.clear();
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
                            String searchTerm = '';
                            String? editingSearchTerm = editingController?.text;
                            if (editingSearchTerm != null) {
                              searchTerm = editingSearchTerm.isNotEmpty
                                  ? editingSearchTerm
                                  : HINT;
                            }
                            _onSearchTermChanged(searchTerm);
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
        Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Center(
            child: NumberPageIndicesList(
              numOfPagesCubit: _numOfPagesCubit,
              selectedPageIndexHolder: selectedPageHolder,
              onPageSelected: this._goToPage,
              showPageNumberInput: false,
            ),
          ),
        ),
        DoujinshiGridGallery(
          doujinshiListCubit: _doujinshiListCubit,
          onDoujinshiSelected: this._openDoujinshi,
          refreshStatusesSignalCubit: _refreshStatusesSignalCubit,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10, 15, 10, 5),
          child: RecommendedDoujinshiList(
            listName: 'DoujinshiGallery',
            recommendationType: RecommendationType.Gallery,
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
        Container(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 20),
          child: Center(
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
}
