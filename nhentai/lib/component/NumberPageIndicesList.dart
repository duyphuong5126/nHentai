import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/NumberPageIndex.dart';

class NumberPageIndicesList<T extends StateHolder<int>> extends StatefulWidget {
  final DataCubit<int> numOfPagesCubit;
  final Function(int) onPageSelected;
  final T selectedPageIndexHolder;

  const NumberPageIndicesList({
    Key? key,
    required this.numOfPagesCubit,
    required this.selectedPageIndexHolder,
    required this.onPageSelected,
  }) : super(key: key);

  @override
  _NumberPageIndicesListState createState() => _NumberPageIndicesListState();
}

class _NumberPageIndicesListState extends State<NumberPageIndicesList> {
  final DataCubit<int> _selectedPageIndexCubit = DataCubit<int>(-1);
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
    return BlocBuilder(
        bloc: widget.numOfPagesCubit,
        buildWhen: (int previousNumOfPages, int currentNumOfPages) {
          return currentNumOfPages >= 0;
        },
        builder: (BuildContext context, int numOfPages) {
          return ListView(
            shrinkWrap: true,
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            children: List.generate(
              numOfPages >= 0 ? numOfPages : 0,
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
                  selectedPageIndexCubit: _selectedPageIndexCubit,
                  onPagePressed: (selectedPage) {
                    widget.selectedPageIndexHolder.data = selectedPage;
                    _selectedPageIndexCubit.emit(selectedPage);
                    widget.onPageSelected(selectedPage);
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
    _selectedPageIndexCubit.dispose();
  }
}
