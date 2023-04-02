import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';
import 'package:nhentai/domain/entity/DownloadedDoujinshi.dart';

class CoverImage extends StatefulWidget {
  final Doujinshi doujinshi;

  const CoverImage({Key? key, required this.doujinshi}) : super(key: key);

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
    Doujinshi doujinshi = widget.doujinshi;
    return Container(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        controller: _scrollController,
        child: Column(
          children: [
            doujinshi is DownloadedDoujinshi
                ? Image.file(File(doujinshi.downloadedCover),
                    width: double.infinity, fit: BoxFit.cover, errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) {
                    return Image.file(File(doujinshi.downloadedBackupCover),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'images/ic_nothing_here_grey.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    });
                  })
                : _Cover(
                    coverUrl: doujinshi.coverImage,
                    backUpUrl: doujinshi.backUpCoverImage,
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

class _Cover extends StatefulWidget {
  const _Cover({
    Key? key,
    required this.coverUrl,
    required this.backUpUrl,
  }) : super(key: key);
  final String coverUrl;
  final String backUpUrl;

  @override
  State<_Cover> createState() => _CoverState();
}

class _CoverState extends State<_Cover> {
  String coverUrl = '';

  @override
  void initState() {
    super.initState();
    coverUrl = widget.coverUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: CachedNetworkImageProvider(
        coverUrl,
        errorListener: () {
          if (mounted) {
            setState(() {
              coverUrl = widget.backUpUrl;
            });
          }
        },
      ),
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'images/ic_nothing_here_grey.png',
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
