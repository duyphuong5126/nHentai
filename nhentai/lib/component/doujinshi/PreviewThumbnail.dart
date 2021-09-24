import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class PreviewThumbnail extends StatefulWidget {
  final String thumbnailUrl;
  final int imagePosition;
  final Function(int) onThumbnailSelected;

  const PreviewThumbnail(
      {Key? key,
      required this.thumbnailUrl,
      required this.imagePosition,
      required this.onThumbnailSelected})
      : super(key: key);

  @override
  _PreviewThumbnailState createState() => _PreviewThumbnailState();
}

class _PreviewThumbnailState extends State<PreviewThumbnail> {
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
                      child: Text(
                        '${widget.imagePosition + 1}',
                        style: TextStyle(
                            fontFamily: Constant.NUNITO_REGULAR,
                            fontSize: 14,
                            color: Colors.white),
                      ),
                    ),
                    constraints: BoxConstraints.expand(height: 30),
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
