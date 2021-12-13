import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/NumberPageIndex.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  final ItemScrollController _listScrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();
  final GlobalKey _indexItemKey = GlobalKey();
  bool isIndexItemKeySet = false;

  VoidCallback? _visibleRangeObserver;
  final DataCubit<bool> _backwardButtonsVisibility = DataCubit(false);
  final DataCubit<bool> _forwardButtonsVisibility = DataCubit(false);

  void _doInitialScroll() async {
    Future.delayed(Duration(microseconds: 500), () {
      final RenderObject? renderObject =
          _indexItemKey.currentContext?.findRenderObject();
      int scrollToPosition = widget.selectedPageIndexHolder.data;
      if (scrollToPosition - 1 >= 0) {
        scrollToPosition--;
      }
      if (renderObject is RenderBox) {
        _listScrollController.jumpTo(index: scrollToPosition);
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
          if (_visibleRangeObserver != null) {
            _positionsListener.itemPositions
                .removeListener(_visibleRangeObserver!);
            _visibleRangeObserver = null;
          }
          _visibleRangeObserver = () {
            Iterable<int> indices = _positionsListener.itemPositions.value
                .map((itemPosition) => itemPosition.index);
            _backwardButtonsVisibility
                .emit(!indices.contains(0) && numOfPages > 0);
            _forwardButtonsVisibility
                .emit(!indices.contains(numOfPages - 1) && numOfPages > 0);
          };
          _positionsListener.itemPositions.addListener(_visibleRangeObserver!);
          return Visibility(
            child: Row(
              children: [
                BlocBuilder(
                    bloc: _backwardButtonsVisibility,
                    builder: (context, bool isVisible) {
                      return Visibility(
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                child: Icon(
                                  Icons.first_page,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () => _gotoPage(0),
                            ),
                          ),
                        ),
                        visible: isVisible,
                      );
                    }),
                BlocBuilder(
                    bloc: _backwardButtonsVisibility,
                    builder: (context, bool isVisible) {
                      return Visibility(
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                child: Icon(
                                  Icons.navigate_before,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                int selectedPage =
                                    _selectedPageIndexCubit.state;
                                if (selectedPage > 0) {
                                  _gotoPage(selectedPage - 1);
                                }
                              },
                            ),
                          ),
                        ),
                        visible: isVisible,
                      );
                    }),
                Expanded(
                    child: Center(
                  child: ScrollablePositionedList.builder(
                    shrinkWrap: true,
                    itemScrollController: _listScrollController,
                    itemPositionsListener: _positionsListener,
                    scrollDirection: Axis.horizontal,
                    itemCount: numOfPages >= 0 ? numOfPages : 0,
                    itemBuilder: (context, index) {
                      Key? key;
                      if (!isIndexItemKeySet) {
                        isIndexItemKeySet = true;
                        key = _indexItemKey;
                        _doInitialScroll();
                      }
                      return NumberPageIndex(
                        key: key,
                        pageIndex: index,
                        initialSelectedPageIndex:
                            widget.selectedPageIndexHolder.data,
                        selectedPageIndexCubit: _selectedPageIndexCubit,
                        onPagePressed: (selectedPage) {
                          widget.selectedPageIndexHolder.data = selectedPage;
                          _selectedPageIndexCubit.emit(selectedPage);
                          widget.onPageSelected(selectedPage);
                        },
                      );
                    },
                  ),
                )),
                BlocBuilder(
                    bloc: _forwardButtonsVisibility,
                    builder: (context, bool isVisible) {
                      return Visibility(
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                child: Icon(
                                  Icons.navigate_next,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                int selectedPage =
                                    _selectedPageIndexCubit.state;
                                if (selectedPage >= 0 &&
                                    selectedPage < numOfPages - 1) {
                                  _gotoPage(selectedPage + 1);
                                }
                              },
                            ),
                          ),
                        ),
                        visible: isVisible,
                      );
                    }),
                BlocBuilder(
                    bloc: _forwardButtonsVisibility,
                    builder: (context, bool isVisible) {
                      return Visibility(
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                child: Icon(
                                  Icons.last_page,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () => _gotoPage(numOfPages - 1),
                            ),
                          ),
                        ),
                        visible: isVisible,
                      );
                    })
              ],
            ),
            visible: numOfPages > 0,
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _selectedPageIndexCubit.dispose();
  }

  void _gotoPage(int pageIndex) {
    print('Test>>> go to page $pageIndex');
    if (pageIndex >= 0) {
      widget.selectedPageIndexHolder.data = pageIndex;
      _listScrollController.jumpTo(index: pageIndex);
      _selectedPageIndexCubit.emit(pageIndex);
      widget.onPageSelected(pageIndex);
    }
  }
}
