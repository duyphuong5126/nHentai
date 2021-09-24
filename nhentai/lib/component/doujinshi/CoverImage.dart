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
  final ScrollController _scrollController = ScrollController();

  bool isUp = false;
  late Timer _eternalScrollTimer;

  void _startEternalScroll() {
    _eternalScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      double offset = isUp
          ? _scrollController.position.maxScrollExtent
          : _scrollController.position.minScrollExtent;
      isUp = !isUp;
      _scrollController.animateTo(offset,
          duration: Duration(seconds: 2), curve: Curves.ease);
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
                return Image.network(widget.backUpCoverImageUrl);
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
    _eternalScrollTimer.cancel();
    _scrollController.dispose();
  }
}
