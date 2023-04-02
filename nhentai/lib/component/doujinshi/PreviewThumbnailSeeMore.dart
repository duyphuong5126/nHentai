import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';

import 'Thumbnal.dart';

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
    _isCensoredCubit.push(await _preferenceManager.isCensored());
  }

  @override
  Widget build(BuildContext context) {
    _initCensoredStatus();
    return ClipRRect(
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
                      : Thumbnail(
                          thumbnailUrl: widget.thumbnailUrl,
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
            ),
            Positioned.fill(
                child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                highlightColor: Colors.white,
                splashColor: Colors.white,
                onTap: () => widget.onThumbnailSelected(widget.imagePosition),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
