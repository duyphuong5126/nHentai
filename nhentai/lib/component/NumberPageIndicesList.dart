import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/NumberPageIndex.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class NumberPageIndicesList<T extends StateHolder<int>> extends StatefulWidget {
  final DataCubit<int> numOfPagesCubit;
  final Function(int) onPageSelected;
  final T selectedPageIndexHolder;
  final bool showPageNumberInput;

  const NumberPageIndicesList(
      {Key? key,
      required this.numOfPagesCubit,
      required this.selectedPageIndexHolder,
      required this.onPageSelected,
      this.showPageNumberInput = true})
      : super(key: key);

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
  final DataCubit<bool> _pageNumberTextFieldVisibility = DataCubit(false);
  final TextEditingController _pageNumberInputController =
      TextEditingController();

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
            bool isFirstIndexVisible = indices.contains(0);
            bool isLastIndexVisible = indices.contains(numOfPages - 1);
            _backwardButtonsVisibility
                .push(!isFirstIndexVisible && numOfPages > 0);
            _forwardButtonsVisibility
                .push(!isLastIndexVisible && numOfPages > 0);
            _pageNumberTextFieldVisibility.push(numOfPages > 0 &&
                (!isFirstIndexVisible || !isLastIndexVisible));
          };
          _positionsListener.itemPositions.addListener(_visibleRangeObserver!);
          return Container(
            child: Visibility(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
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
                                  widget.selectedPageIndexHolder.data =
                                      selectedPage;
                                  _selectedPageIndexCubit.push(selectedPage);
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
                  ),
                  !widget.showPageNumberInput
                      ? Visibility(
                          child: Container(),
                          visible: false,
                        )
                      : BlocBuilder(
                          bloc: _pageNumberTextFieldVisibility,
                          builder: (context, bool isVisible) {
                            return Visibility(
                              child: Center(
                                child: Container(
                                  margin: EdgeInsets.only(top: 10.0),
                                  width: 220,
                                  height: 40,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: TextField(
                                            controller:
                                                _pageNumberInputController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    color: Constant.grey1f1f1f,
                                                    fontFamily:
                                                        Constant.REGULAR,
                                                    fontSize: 15),
                                                border: InputBorder.none,
                                                hintText: 'Page number'),
                                            style: TextStyle(
                                                color: Constant.grey1f1f1f,
                                                fontFamily: Constant.REGULAR,
                                                fontSize: 15),
                                            onSubmitted: (text) {
                                              _submitPageIndex(
                                                  text, numOfPages);
                                            },
                                          ),
                                          width: 150,
                                          height: 60,
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: Ink(
                                            child: InkWell(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Icon(
                                                  Icons.arrow_forward,
                                                  size: 20,
                                                  color: Constant.grey1f1f1f,
                                                ),
                                              ),
                                              onTap: () => _submitPageIndex(
                                                  _pageNumberInputController
                                                      .text,
                                                  numOfPages),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              visible: isVisible,
                            );
                          })
                ],
              ),
              visible: numOfPages > 0,
            ),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _selectedPageIndexCubit.dispose();
  }

  void _submitPageIndex(String pageIndexText, int numOfPages) {
    int? pageNumberData = int.tryParse(pageIndexText);
    if (pageNumberData != null &&
        pageNumberData > 0 &&
        pageNumberData <= numOfPages) {
      _gotoPage(pageNumberData - 1);
    }
  }

  void _gotoPage(int pageIndex) {
    if (pageIndex >= 0) {
      widget.selectedPageIndexHolder.data = pageIndex;
      _listScrollController.jumpTo(index: pageIndex);
      _selectedPageIndexCubit.push(pageIndex);
      widget.onPageSelected(pageIndex);
    }
  }
}
