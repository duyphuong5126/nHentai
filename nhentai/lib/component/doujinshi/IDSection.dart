import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class IDSection extends StatefulWidget {
  final int id;

  const IDSection({Key? key, required this.id}) : super(key: key);

  @override
  _IDSectionState createState() => _IDSectionState();
}

class _IDSectionState extends State<IDSection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'ID:',
          style: TextStyle(
              fontFamily: Constant.BOLD,
              fontSize: 16,
              color: Colors.white),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            '${widget.id}',
            style: TextStyle(
                fontFamily: Constant.BOLD,
                fontSize: 14,
                color: Colors.white),
          ),
          decoration: BoxDecoration(
              color: Constant.grey4D4D4D,
              borderRadius: BorderRadius.all(Radius.circular(3))),
        )
      ],
    );
  }
}
