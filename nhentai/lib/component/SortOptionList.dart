import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/SortOptionBloc.dart';
import 'package:nhentai/page/uimodel/SortOption.dart';

class SortOptionList extends StatefulWidget {
  final SortOptionBloc sortOptionBloc;
  final Function(SortOption) onSortOptionSelected;

  const SortOptionList(
      {Key? key,
      required this.sortOptionBloc,
      required this.onSortOptionSelected})
      : super(key: key);

  @override
  _SortOptionListState createState() => _SortOptionListState();
}

class _SortOptionListState extends State<SortOptionList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.sortOptionBloc.output,
        initialData: SortOption.MostRecent,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          SortOption sortOption = snapshot.data;
          bool isRecent = sortOption == SortOption.MostRecent;
          bool isPopularToday = sortOption == SortOption.PopularToday;
          bool isPopularThisWeek = sortOption == SortOption.PopularThisWeek;
          bool isPopularAllTime = sortOption == SortOption.PopularAllTime;
          return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  if (!isRecent) {
                    widget.sortOptionBloc.updateData(SortOption.MostRecent);
                    widget.onSortOptionSelected(SortOption.MostRecent);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(
                      'Recent',
                      style: TextStyle(
                          fontFamily: Constant.NUNITO_BLACK,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color:
                          isRecent ? Constant.grey4D4D4D : Constant.grey1f1f1f,
                      borderRadius: BorderRadius.all(Radius.circular(3))),
                  margin: EdgeInsets.only(right: 10),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Text(
                    'Popular:',
                    style: TextStyle(
                        fontFamily: Constant.NUNITO_BLACK,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Constant.grey1f1f1f,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3),
                        bottomLeft: Radius.circular(3))),
                margin: EdgeInsets.only(right: 1),
              ),
              GestureDetector(
                onTap: () {
                  if (!isPopularToday) {
                    widget.sortOptionBloc.updateData(SortOption.PopularToday);
                    widget.onSortOptionSelected(SortOption.PopularToday);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(
                      'Today',
                      style: TextStyle(
                          fontFamily: Constant.NUNITO_BLACK,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                  color: isPopularToday
                      ? Constant.grey4D4D4D
                      : Constant.grey1f1f1f,
                  margin: EdgeInsets.only(right: 1),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (!isPopularThisWeek) {
                    widget.sortOptionBloc
                        .updateData(SortOption.PopularThisWeek);
                    widget.onSortOptionSelected(SortOption.PopularThisWeek);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(
                      'This week',
                      style: TextStyle(
                          fontFamily: Constant.NUNITO_BLACK,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                  color: isPopularThisWeek
                      ? Constant.grey4D4D4D
                      : Constant.grey1f1f1f,
                  margin: EdgeInsets.only(right: 1),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (!isPopularAllTime) {
                    widget.sortOptionBloc.updateData(SortOption.PopularAllTime);
                    widget.onSortOptionSelected(SortOption.PopularAllTime);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(
                      'All time',
                      style: TextStyle(
                          fontFamily: Constant.NUNITO_BLACK,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: isPopularAllTime
                          ? Constant.grey4D4D4D
                          : Constant.grey1f1f1f,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(3),
                          bottomRight: Radius.circular(3))),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          );
        });
  }
}
