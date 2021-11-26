import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/component/doujinshi/DoujinshiThumbnail.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

class HorizontalDoujinshiList extends StatefulWidget {
  final DataCubit<List<Doujinshi>> doujinshiListCubit;
  final Function(Doujinshi) onDoujinshiSelected;

  const HorizontalDoujinshiList(
      {Key? key,
      required this.doujinshiListCubit,
      required this.onDoujinshiSelected})
      : super(key: key);

  @override
  _HorizontalDoujinshiListState createState() =>
      _HorizontalDoujinshiListState();
}

class _HorizontalDoujinshiListState extends State<HorizontalDoujinshiList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: widget.doujinshiListCubit,
        builder: (BuildContext context, List<Doujinshi> doujinshiList) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'More like this',
                style: TextStyle(
                    fontFamily: Constant.BOLD,
                    fontSize: 18,
                    color: Colors.white),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: doujinshiList.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 5,
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return DoujinshiThumbnail(
                        doujinshi: doujinshiList[index],
                        onDoujinshiSelected: widget.onDoujinshiSelected,
                        width: 200,
                        height: 300);
                  },
                ),
              )
            ],
          );
        });
  }
}
