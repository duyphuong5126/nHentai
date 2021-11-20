import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/component/doujinshi/PreviewThumbnail.dart';
import 'package:nhentai/component/doujinshi/PreviewThumbnailSeeMore.dart';

class PreviewSection extends StatefulWidget {
  final List<String> pages;
  final Function(int) onPageSelected;

  const PreviewSection(
      {Key? key, required this.pages, required this.onPageSelected})
      : super(key: key);

  @override
  _PreviewSectionState createState() => _PreviewSectionState();
}

class _PreviewSectionState extends State<PreviewSection> {
  static const int MAX_ITEM = 30;

  @override
  Widget build(BuildContext context) {
    List<String> pages = widget.pages;
    int total = pages.length;
    int numOfRows = 2;
    int maxGridItemCount = total >= MAX_ITEM ? MAX_ITEM : total;
    int remainItemCount = total - maxGridItemCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: TextStyle(
              fontFamily: Constant.BOLD,
              fontSize: 18,
              color: Colors.white),
        ),
        SizedBox(
            height: 400,
            child: GridView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: maxGridItemCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numOfRows,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 4 / 3),
                itemBuilder: (BuildContext context, int index) {
                  return total > MAX_ITEM && index == MAX_ITEM - 1
                      ? PreviewThumbnailSeeMore(
                          thumbnailUrl: pages.elementAt(index),
                          imagePosition: index,
                          remainsCount: remainItemCount,
                          onThumbnailSelected: widget.onPageSelected)
                      : PreviewThumbnail(
                          thumbnailUrl: pages.elementAt(index),
                          imagePosition: index,
                          onThumbnailSelected: widget.onPageSelected);
                }))
      ],
    );
  }
}
