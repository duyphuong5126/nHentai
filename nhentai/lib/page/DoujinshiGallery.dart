import 'package:flutter/material.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/bloc/DoujinshiListBloc.dart';
import 'package:nhentai/bloc/IntegerBloc.dart';
import 'package:nhentai/bloc/StringBloc.dart';
import 'package:nhentai/component/DoujinshiGridGallery.dart';
import 'package:nhentai/component/NumberPageIndicesList.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DoujinshiList.dart';
import 'package:nhentai/domain/usecase/GetDoujinshiListUseCase.dart';
import 'package:nhentai/text_widget/DefaultScreenTitle.dart';
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
      DoujinshiList doujinshiList = await _getBookListByPage.execute(page);
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
                selectedPageIndexHolder: StateHolder<int>(data: 0),
                onPagePressed: this._goToPage),
          ),
          height: 40,
        )
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: DefaultScreenTitle('nHentai Gallery'),
        centerTitle: true,
        backgroundColor: Colors.green[500],
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
}
