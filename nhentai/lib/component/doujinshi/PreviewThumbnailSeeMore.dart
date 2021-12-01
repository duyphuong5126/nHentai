import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';

class PreviewThumbnailSeeMore extends StatefulWidget {
  final String thumbnailUrl;
  final int imagePosition;
  final int remainsCount;
  final Function(int) onThumbnailSelected;

  const PreviewThumbnailSeeMore(
      {Key? key,
      required this.thumbnailUrl,
      required this.imagePosition,
      required this.onThumbnailSelected,
      required this.remainsCount})
      : super(key: key);

  @override
  _PreviewThumbnailSeeMoreState createState() =>
      _PreviewThumbnailSeeMoreState();
}

class _PreviewThumbnailSeeMoreState extends State<PreviewThumbnailSeeMore> {
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final DataCubit<bool> _isCensoredCubit = DataCubit(false);

  void _initCensoredStatus() async {
    _isCensoredCubit.emit(await _preferenceManager.isCensored());
  }

  @override
  Widget build(BuildContext context) {
    _initCensoredStatus();
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          color: Constant.grey767676,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              BlocBuilder(
                  bloc: _isCensoredCubit,
                  builder: (BuildContext context, bool isCensored) {
                    return isCensored
                        ? Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Constant.grey4D4D4D,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.thumbnailUrl,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return Container(
                                color: Constant.getNothingColor(),
                                padding: EdgeInsets.all(5),
                                child: Image.asset(
                                  Constant.IMAGE_NOTHING,
                                  height: double.infinity,
                                  width: double.infinity,
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
                        bottomRight: Radius.circular(5),
                        bottomLeft: Radius.circular(5))),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Center(
                  child: Text(
                    '+${widget.remainsCount}',
                    style: TextStyle(
                        fontFamily: Constant.BOLD,
                        fontSize: 25,
                        color: Colors.white),
                  ),
                ),
                constraints: BoxConstraints.expand(),
              )
            ],
          ),
        ),
      ),
      onTap: () => widget.onThumbnailSelected(widget.imagePosition),
    );
  }
}
