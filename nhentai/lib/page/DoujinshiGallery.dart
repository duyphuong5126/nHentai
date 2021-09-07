import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/bloc/DoujinshiListBloc.dart';
import 'package:nhentai/bloc/IntegerBloc.dart';
import 'package:nhentai/bloc/StringBloc.dart';
import 'package:nhentai/component/DoujinshiGridGallery.dart';
import 'package:nhentai/component/NumberPageIndicesList.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/domain/usecase/GetDoujinshiListUseCase.dart';
import 'package:nhentai/text_widget/DefaultSectionLabel.dart';

class DoujinshiGallery extends StatefulWidget {
  @override
  _DoujinshiGalleryState createState() => _DoujinshiGalleryState();
}

class _DoujinshiGalleryState extends State<DoujinshiGallery> {
  GetDoujinshiListUseCase _getBookListByPage = new GetDoujinshiListUseCase();

  final IntegerBloc _numOfPagesBloc = IntegerBloc();
  final DoujinshiListBloc _doujinshiListBloc = DoujinshiListBloc();
  final StringBloc _pageIndicatorBloc = StringBloc();
  final StringBloc _searchTermBloc = StringBloc();
  String _searchTerm = '';

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

      _doujinshiListBloc.updateData(getCurrentPage());
      _pageIndicatorBloc.updateData(_pageIndicator());
    } else {
      DoujinshiList doujinshiList =
          await _getBookListByPage.execute(page, _searchTerm);
      print('Number of pages: ${doujinshiList.numPages}');
      if (doujinshiList.numPages > 0) {
        currentPage = page;
        numOfPages = doujinshiList.numPages;
        itemCountPerPage = doujinshiList.perPage;
        doujinshiMap[currentPage] = doujinshiList.result;

        _doujinshiListBloc.updateData(getCurrentPage());
        _numOfPagesBloc.updateData(doujinshiList.numPages);
        _pageIndicatorBloc.updateData(_pageIndicator());
      }
    }
  }

  List<Doujinshi> getCurrentPage() {
    List<Doujinshi>? doujinshiList = doujinshiMap[currentPage];
    return doujinshiList != null ? doujinshiList : [];
  }

  void _goToPage(int page) {
    if (page < 0 || page >= numOfPages) {
      print('Page $page does not exist');
    } else {
      print('Go to page $page');
      _changeToPage(page);
      _scrollController.jumpTo(0);
    }
  }

  String _pageIndicator() {
    String pageIndicator;
    int currentPageSize = getCurrentPage().length;
    if (currentPageSize <= 0) {
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
    print('newTerm=$newTerm');
    if (newTerm != _searchTerm) {
      doujinshiMap.clear();
      _searchTerm = newTerm;
      _searchTermBloc.updateData(newTerm);
      selectedPageHolder.data = 0;
      _goToPage(0);
    }
  }

  @override
  void initState() {
    super.initState();
    _changeToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = ListView(
      controller: _scrollController,
      children: [
        StreamBuilder(
            stream: _searchTermBloc.output,
            initialData: '',
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              String searchTerm = snapshot.data;
              return Visibility(
                child: Center(
                  child: Container(
                    child: SectionLabel(
                        'Result for $searchTerm', Colors.blueGrey[500]!),
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  ),
                ),
                visible: searchTerm.isNotEmpty,
              );
            }),
        DoujinshiGridGallery(
          doujinshiListBloc: _doujinshiListBloc,
        ),
        Center(
          child: Container(
            child: StreamBuilder(
                stream: _pageIndicatorBloc.output,
                initialData: '',
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return SectionLabel(snapshot.data, Colors.blueGrey[500]!);
                }),
            margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10, 20, 10, 40),
          child: Center(
            child: NumberPageIndicesList(
                numOfPagesBloc: _numOfPagesBloc,
                selectedPageIndexHolder: selectedPageHolder,
                onPagePressed: this._goToPage),
          ),
          height: 40,
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: _getTitle(),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: Container(
        child: bodyWidget,
        color: Colors.black,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _doujinshiListBloc.dispose();
    _numOfPagesBloc.dispose();
    _pageIndicatorBloc.dispose();
  }

  Widget _getTitle() {
    TextEditingController editingController = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              SvgPicture.asset(
                Constant.IMAGE_LOGO,
                width: 40,
                height: 20,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 0, 20, 0),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: editingController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Milf',
                              contentPadding: EdgeInsets.only(bottom: 6)),
                          style: TextStyle(
                              fontFamily: 'NunitoRegular',
                              fontSize: 18,
                              color: Colors.green[500]),
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
                            color: Colors.green[500],
                          ),
                        ),
                      ),
                      Container(
                        child: IconButton(
                          onPressed: () =>
                              _onSearchTermChanged(editingController.text),
                          icon: Icon(Icons.search),
                          padding: EdgeInsets.all(0),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[500],
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
}
