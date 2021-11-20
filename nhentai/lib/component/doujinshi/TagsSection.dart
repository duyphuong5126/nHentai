import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/domain/entity/Tag.dart';
import 'package:nhentai/support/Extensions.dart';

class TagsSection extends StatefulWidget {
  final String tagName;
  final List<Tag> tagList;
  final Function(Tag tag) onTagSelected;

  const TagsSection(
      {Key? key,
      required this.tagName,
      required this.tagList,
      required this.onTagSelected})
      : super(key: key);

  @override
  _TagsSectionState createState() => _TagsSectionState();
}

class _TagsSectionState extends State<TagsSection> {
  @override
  Widget build(BuildContext context) {
    List<Tag> tagList = widget.tagList;
    NumberFormat decimalFormat = NumberFormat.decimalPattern();
    NumberFormat compactFormat = NumberFormat.compact();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${widget.tagName.capitalize()}:',
          style: TextStyle(
              fontFamily: Constant.BOLD,
              fontSize: 16,
              color: Colors.white),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
            child: Wrap(
          runSpacing: 5,
          spacing: 5,
          direction: Axis.horizontal,
          children: List.generate(tagList.length, (index) {
            Tag tag = tagList[index];
            return InkWell(
              onTap: () {
                widget.onTagSelected(tag);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '${tag.name.capitalize()}',
                      style: TextStyle(
                          fontFamily: Constant.BOLD,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                    WidgetSpan(
                        child: SizedBox(
                      width: 3,
                    )),
                    TextSpan(
                      text:
                          '(${tag.count >= 100000 ? compactFormat.format(tag.count) : decimalFormat.format(tag.count)})',
                      style: TextStyle(
                          fontFamily: Constant.BOLD,
                          fontSize: 14,
                          color: Constant.grey767676),
                    ),
                  ]),
                ),
                decoration: BoxDecoration(
                    color: Constant.grey4D4D4D,
                    borderRadius: BorderRadius.all(Radius.circular(3))),
              ),
            );
          }),
        ))
      ],
    );
  }
}
