import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/domain/entity/Doujinshi.dart';

class DoujinshiThumbnail extends StatefulWidget {
  final Doujinshi doujinshi;
  final Function(Doujinshi) onDoujinshiSelected;
  final double width;
  final double height;

  const DoujinshiThumbnail(
      {Key? key,
      required this.doujinshi,
      required this.onDoujinshiSelected,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  _DoujinshiThumbnailState createState() => _DoujinshiThumbnailState();
}

class _DoujinshiThumbnailState extends State<DoujinshiThumbnail> {
  @override
  Widget build(BuildContext context) {
    Doujinshi doujinshi = widget.doujinshi;
    List<InlineSpan> spans = [];
    if (doujinshi.languageIcon.isNotEmpty) {
      spans.add(WidgetSpan(
          child: SizedBox(
        child: Container(
          child: Image.asset(doujinshi.languageIcon),
          margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
        ),
        width: 30,
        height: 15,
      )));
    }
    spans.add(TextSpan(text: doujinshi.title.english));
    return GestureDetector(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Card(
            child: Padding(
              padding: EdgeInsets.all(3),
              child: Container(
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Image.network(
                      doujinshi.thumbnailImage,
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
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          height: 70,
                          color: Constant.black96000000,
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          child: RichText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                style: TextStyle(
                                    fontFamily: Constant.NUNITO_SEMI_BOLD,
                                    fontSize: 14,
                                    color: Colors.white),
                                children: spans),
                          ),
                        ))
                      ],
                    )
                  ],
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            )),
      ),
      onTap: () => widget.onDoujinshiSelected(doujinshi),
    );
  }
}
