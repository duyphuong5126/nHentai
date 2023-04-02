import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';

class NumberPageIndex extends StatefulWidget {
  final int pageIndex;
  final int initialSelectedPageIndex;
  final DataCubit<int> selectedPageIndexCubit;
  final Function(int) onPagePressed;

  const NumberPageIndex(
      {Key? key,
      required this.pageIndex,
      required this.initialSelectedPageIndex,
      required this.selectedPageIndexCubit,
      required this.onPagePressed})
      : super(key: key);

  @override
  _NumberPageIndexState createState() => _NumberPageIndexState();
}

class _NumberPageIndexState extends State<NumberPageIndex> {
  @override
  Widget build(BuildContext context) {
    int index = widget.pageIndex;
    widget.selectedPageIndexCubit.push(widget.initialSelectedPageIndex);
    return BlocBuilder(
        bloc: widget.selectedPageIndexCubit,
        buildWhen: (int previousIndex, int currentIndex) {
          return previousIndex != currentIndex;
        },
        builder: (BuildContext context, int currentPage) {
          String fontFamily = index == currentPage
              ? Constant.BOLD
              : Constant.REGULAR;
          Color textColor =
              index == currentPage ? Constant.mainColor : Colors.white;
          return Container(
            child: TextButton(
              onPressed: () {
                widget.onPagePressed(index);
              },
              child: Text(
                "${index + 1}",
                style: TextStyle(
                    fontFamily: fontFamily, fontSize: 16, color: textColor),
              ),
            ),
          );
        });
  }
}
