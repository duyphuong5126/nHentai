import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DoujinshiListBloc.dart';
import 'package:nhentai/component/doujinshi/DoujinshiThumbnail.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

class HorizontalDoujinshiList extends StatefulWidget {
  final DoujinshiListBloc doujinshiListBloc;
  final Function(Doujinshi) onDoujinshiSelected;

  const HorizontalDoujinshiList(
      {Key? key,
      required this.doujinshiListBloc,
      required this.onDoujinshiSelected})
      : super(key: key);

  @override
  _HorizontalDoujinshiListState createState() =>
      _HorizontalDoujinshiListState();
}

class _HorizontalDoujinshiListState extends State<HorizontalDoujinshiList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.doujinshiListBloc.output,
        initialData: <Doujinshi>[],
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Doujinshi> doujinshiList = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'More like this',
                style: TextStyle(
                    fontFamily: Constant.NUNITO_EXTRA_BOLD,
                    fontSize: 18,
                    color: Colors.white),
              ),
              SizedBox(
                height: 300,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(
                      doujinshiList.length,
                      (index) => DoujinshiThumbnail(
                          doujinshi: doujinshiList[index],
                          onDoujinshiSelected: widget.onDoujinshiSelected,
                          width: 200,
                          height: 300)),
                ),
              )
            ],
          );
        });
  }
}
