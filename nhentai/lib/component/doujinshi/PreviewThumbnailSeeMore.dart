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
      child: Card(
          child: Padding(
            padding: EdgeInsets.all(3),
            child: Container(
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
                    color: Constant.black96000000,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 40,
                            color: Colors.white,
                          ),
                          Text(
                            '${widget.remainsCount}',
                            style: TextStyle(
                                fontFamily: Constant.NUNITO_BLACK,
                                fontSize: 16,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    constraints: BoxConstraints.expand(),
                  )
                ],
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          )),
      onTap: () => widget.onThumbnailSelected(widget.imagePosition),
    );
  }
}
