import 'dart:async';

import 'package:flutter/material.dart';

class CoverImage extends StatefulWidget {
  final String coverImageUrl;
  final String backUpCoverImageUrl;

  const CoverImage(
      {Key? key,
      required this.coverImageUrl,
      required this.backUpCoverImageUrl})
      : super(key: key);

  @override
  _CoverImageState createState() => _CoverImageState();
}

class _CoverImageState extends State<CoverImage> {
  bool isUp = false;
  Timer? _eternalScrollTimer;
  ScrollController? _scrollController;

  void _startEternalScroll() {
    if (_scrollController == null) {
      _scrollController = ScrollController();
    }
    _eternalScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      double offset = isUp
          ? _scrollController?.position.maxScrollExtent ?? -1
          : _scrollController?.position.minScrollExtent ?? -1;
      if (offset >= 0) {
        isUp = !isUp;
        _scrollController!.animateTo(offset,
            duration: Duration(seconds: 2), curve: Curves.ease);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _startEternalScroll();
    return Container(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        controller: _scrollController,
        child: Column(
          children: [
            Image.network(
              widget.coverImageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return Image.network(
                  widget.backUpCoverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'images/ic_nothing_here_grey.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
      constraints: BoxConstraints.loose(Size(double.infinity, 400)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _eternalScrollTimer?.cancel();
    _eternalScrollTimer = null;
    _scrollController?.dispose();
    _scrollController = null;
  }
}
