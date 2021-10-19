import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/IntegerBloc.dart';

class NumberPageIndex extends StatefulWidget {
  final int pageIndex;
  final int initialSelectedPageIndex;
  final IntegerBloc selectedPageIndexBloc;
  final Function(int) onPagePressed;

  const NumberPageIndex(
      {Key? key,
      required this.pageIndex,
      required this.initialSelectedPageIndex,
      required this.selectedPageIndexBloc,
      required this.onPagePressed})
      : super(key: key);

  @override
  _NumberPageIndexState createState() => _NumberPageIndexState();
}

class _NumberPageIndexState extends State<NumberPageIndex> {
  @override
  Widget build(BuildContext context) {
    int index = widget.pageIndex;
    return StreamBuilder(
        stream: widget.selectedPageIndexBloc.output.distinct(),
        initialData: widget.initialSelectedPageIndex,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          int currentPage = snapshot.data;
          String fontFamily = index == currentPage
              ? Constant.NUNITO_BOLD
              : Constant.NUNITO_LIGHT;
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
