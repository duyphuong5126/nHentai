import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class PageCountSection extends StatefulWidget {
  final int pageCount;

  const PageCountSection({Key? key, required this.pageCount}) : super(key: key);

  @override
  _PageCountSectionState createState() => _PageCountSectionState();
}

class _PageCountSectionState extends State<PageCountSection> {
  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.pageCount} pages',
      style: TextStyle(
          fontFamily: Constant.REGULAR,
          fontSize: 16,
          color: Colors.white),
    );
  }
}
