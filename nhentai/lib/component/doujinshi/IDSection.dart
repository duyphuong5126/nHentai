import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              fontFamily: Constant.BOLD, fontSize: 16, color: Colors.white),
        ),
        SizedBox(
          width: 10,
        ),
        Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
                color: Constant.grey4D4D4D,
                borderRadius: BorderRadius.all(Radius.circular(3))),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              overlayColor: MaterialStateProperty.resolveWith(
                  (states) => _getBackgroundColor(states)),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  '${widget.id}',
                  style: TextStyle(
                      fontFamily: Constant.BOLD,
                      fontSize: 14,
                      color: Colors.white),
                ),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.id.toString()))
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Constant.mainColor,
                      duration: Duration(seconds: 5),
                      content: Text('Doujinshi ID was copied to clipboard',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: Constant.BOLD,
                              fontSize: 15))));
                });
              },
            ),
          ),
        )
      ],
    );
  }

  Color _getBackgroundColor(Set<MaterialState> states) {
    Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.selected
    };

    return states.any(interactiveStates.contains)
        ? Constant.mainDarkColor
        : Constant.grey4D4D4D;
  }
}
