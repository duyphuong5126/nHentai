import 'package:flutter/material.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/bloc/IntegerBloc.dart';
import 'package:nhentai/component/NumberPageIndex.dart';

class NumberPageIndicesList<T extends StateHolder<int>> extends StatefulWidget {
  final IntegerBloc numOfPagesBloc;
  final Function(int) onPagePressed;
  final T selectedPageIndexHolder;

  const NumberPageIndicesList({
    Key? key,
    required this.numOfPagesBloc,
    required this.selectedPageIndexHolder,
    required this.onPagePressed,
  }) : super(key: key);

  @override
  _NumberPageIndicesListState createState() => _NumberPageIndicesListState();
}

class _NumberPageIndicesListState extends State<NumberPageIndicesList> {
  final IntegerBloc _selectedPageIndexBloc = IntegerBloc();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _indexItemKey = GlobalKey();
  bool isIndexItemKeySet = false;

  void _doInitialScroll() async {
    Future.delayed(Duration(microseconds: 500), () {
      final RenderObject? renderObject =
          _indexItemKey.currentContext?.findRenderObject();
      int scrollToPosition = widget.selectedPageIndexHolder.data;
      if (scrollToPosition - 1 >= 0) {
        scrollToPosition--;
      }
      if (renderObject is RenderBox) {
        _scrollController.jumpTo(scrollToPosition * renderObject.size.width);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.numOfPagesBloc.output,
        initialData: 0,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          int numOfPages = snapshot.data;
          return ListView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            children: List.generate(
              numOfPages,
              (index) {
                Key? key;
                if (!isIndexItemKeySet) {
                  isIndexItemKeySet = true;
                  key = _indexItemKey;
                  _doInitialScroll();
                }
                return NumberPageIndex(
                  key: key,
                  pageIndex: index,
                  initialSelectedPageIndex: widget.selectedPageIndexHolder.data,
                  selectedPageIndexBloc: _selectedPageIndexBloc,
                  onPagePressed: (selectedPage) {
                    widget.selectedPageIndexHolder.data = selectedPage;
                    _selectedPageIndexBloc.updateData(selectedPage);
                    widget.onPagePressed(selectedPage);
                  },
                );
              },
            ),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _selectedPageIndexBloc.dispose();
  }
}
