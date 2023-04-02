import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../Constant.dart';

class Thumbnail extends StatefulWidget {
  const Thumbnail({
    Key? key,
    required this.thumbnailUrl,
  }) : super(key: key);

  final String thumbnailUrl;

  @override
  State<Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<Thumbnail> {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: CachedNetworkImageProvider(
        widget.thumbnailUrl,
        errorListener: () {
          if (mounted) {
            setState(() {});
          }
        },
      ),
      height: double.infinity,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
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
  }
}
