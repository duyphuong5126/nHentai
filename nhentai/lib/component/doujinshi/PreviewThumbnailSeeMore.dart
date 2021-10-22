import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          color: Constant.grey767676,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Image.network(
                widget.thumbnailUrl,
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
              ),
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
                        fontFamily: Constant.NUNITO_BLACK,
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
