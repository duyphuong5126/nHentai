import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';

class ReaderThumbnail extends StatefulWidget {
  final String thumbnailUrl;
  final double width;
  final double height;
  final int thumbnailIndex;
  final Function(int) onThumbnailSelected;
  final DataCubit<int> selectedIndexBloc;

  const ReaderThumbnail(
      {Key? key,
      required this.thumbnailUrl,
      required this.width,
      required this.height,
      required this.thumbnailIndex,
      required this.onThumbnailSelected,
      required this.selectedIndexBloc})
      : super(key: key);

  @override
  _ReaderThumbnailState createState() => _ReaderThumbnailState();
}

class _ReaderThumbnailState extends State<ReaderThumbnail> {
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final DataCubit<bool> _isCensoredCubit = DataCubit(false);

  void _initCensoredStatus() async {
    _isCensoredCubit.emit(await _preferenceManager.isCensored());
  }

  @override
  Widget build(BuildContext context) {
    _initCensoredStatus();
    return GestureDetector(
      child: BlocBuilder(
        bloc: widget.selectedIndexBloc,
        builder: (BuildContext context, int selectedIndex) {
          Widget thumbnail = Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              BlocBuilder(
                  bloc: _isCensoredCubit,
                  builder: (BuildContext context, bool isCensored) {
                    return isCensored
                        ? Container(
                            width: widget.width,
                            height: widget.height,
                            color: Constant.grey4D4D4D,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.block,
                              size: 20,
                              color: Constant.mainColor,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.thumbnailUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return Container(
                                color: Constant.getNothingColor(),
                                padding: EdgeInsets.all(5),
                                child: Image.asset(
                                  Constant.IMAGE_NOTHING,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.fitWidth,
                                ),
                              );
                            },
                          );
                  }),
              Container(
                decoration: BoxDecoration(
                    color: Constant.black96000000,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(3),
                        bottomLeft: Radius.circular(3))),
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                child: Center(
                  child: Text(
                    '${widget.thumbnailIndex + 1}',
                    style: TextStyle(
                        fontFamily: Constant.REGULAR,
                        fontSize: 10,
                        color: Colors.white),
                  ),
                ),
                width: double.infinity,
                height: 20,
              )
            ],
          );
          return (widget.thumbnailIndex == selectedIndex)
              ? _buildSelectedThumbnail(thumbnail)
              : _buildNormalThumbnail(thumbnail);
        },
      ),
      onTap: () {
        widget.onThumbnailSelected(widget.thumbnailIndex);
      },
    );
  }

  Widget _buildNormalThumbnail(Widget thumbnail) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(3)),
      child: Container(
        color: Colors.white,
        width: widget.width,
        height: widget.height,
        child: thumbnail,
      ),
    );
  }

  Widget _buildSelectedThumbnail(Widget thumbnail) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(3)),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Constant.mainColor, width: 2)),
        width: widget.width,
        height: widget.height,
        child: thumbnail,
      ),
    );
  }
}
