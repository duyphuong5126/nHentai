import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/preference/SharedPreferenceManager.dart';

class DownloadedPreviewThumbnail extends StatefulWidget {
  final String thumbnailLocalPath;
  final int imagePosition;
  final Function(int) onThumbnailSelected;

  const DownloadedPreviewThumbnail(
      {Key? key,
      required this.thumbnailLocalPath,
      required this.imagePosition,
      required this.onThumbnailSelected})
      : super(key: key);

  @override
  _DownloadedPreviewThumbnailState createState() =>
      _DownloadedPreviewThumbnailState();
}

class _DownloadedPreviewThumbnailState
    extends State<DownloadedPreviewThumbnail> {
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
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.block,
                            size: 20,
                            color: Constant.mainColor,
                          ),
                        )
                      : Image.file(
                          File(widget.thumbnailLocalPath),
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
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
                  '${widget.imagePosition + 1}',
                  style: TextStyle(
                      fontFamily: Constant.REGULAR,
                      fontSize: 14,
                      color: Colors.white),
                ),
              ),
              constraints: BoxConstraints.expand(height: 30),
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
