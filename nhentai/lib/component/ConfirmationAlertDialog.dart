import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class ConfirmationAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final Function confirmAction;

  const ConfirmationAlertDialog(
      {Key? key,
      required this.title,
      required this.content,
      required this.confirmLabel,
      required this.confirmAction})
      : super(key: key);

  Color _getBackgroundColor(Set<MaterialState> states) {
    Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.selected
    };

    return states.any(interactiveStates.contains)
        ? Constant.mainDarkColor
        : Constant.mainColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            maxLines: 10,
            textAlign: TextAlign.center,
            text: TextSpan(
                text: title,
                style: TextStyle(
                    fontFamily: Constant.BOLD,
                    fontSize: 20,
                    color: Constant.mainColor)),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(20))),
      content: RichText(
        maxLines: 10,
        textAlign: TextAlign.center,
        text: TextSpan(
            text: content,
            style: TextStyle(
                fontFamily: Constant.REGULAR,
                fontSize: 15,
                color: Colors.black)),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              confirmAction();
            },
            child: Text(
              confirmLabel,
              style: TextStyle(
                  fontFamily: Constant.BOLD, fontSize: 15, color: Colors.white),
            ),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.resolveWith(_getBackgroundColor),
                shape: MaterialStateProperty.resolveWith((states) =>
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3))))),
          ),
          constraints: BoxConstraints.expand(height: 40),
        )
      ],
    );
  }
}
