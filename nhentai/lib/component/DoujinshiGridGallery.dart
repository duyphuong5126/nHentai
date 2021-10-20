import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nhentai/bloc/DoujinshiListBloc.dart';
import 'package:nhentai/component/doujinshi/DoujinshiThumbnail.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

class DoujinshiGridGallery extends StatefulWidget {
  final DoujinshiListBloc doujinshiListBloc;
  final Function(Doujinshi) onDoujinshiSelected;

  const DoujinshiGridGallery(
      {Key? key,
      required this.doujinshiListBloc,
      required this.onDoujinshiSelected})
      : super(key: key);

  @override
  _DoujinshiGridGalleryState createState() => _DoujinshiGridGalleryState();
}

class _DoujinshiGridGalleryState extends State<DoujinshiGridGallery> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.doujinshiListBloc.output,
        initialData: <Doujinshi>[],
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Doujinshi> doujinshiList = snapshot.data;
          return buildDoujinList(doujinshiList);
        });
  }

  Widget buildDoujinList(List<Doujinshi> _doujinshiList) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _doujinshiList.length,
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
      itemBuilder: (BuildContext context, int index) {
        return DoujinshiThumbnail(
          doujinshi: _doujinshiList[index],
          onDoujinshiSelected: widget.onDoujinshiSelected,
        );
      },
    );
  }
}
