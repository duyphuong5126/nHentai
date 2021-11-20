import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class YesNoActionsAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String yesLabel;
  final String noLabel;
  final Function yesAction;
  final Function noAction;

  const YesNoActionsAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.yesLabel,
    required this.noLabel,
    required this.yesAction,
    required this.noAction,
  }) : super(key: key);

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
          Text(
            title,
            style: TextStyle(
                fontFamily: Constant.BOLD,
                fontSize: 20,
                color: Constant.mainColor),
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
        text: TextSpan(
            text: content,
            style: TextStyle(
                fontFamily: Constant.REGULAR,
                fontSize: 15,
                color: Colors.black)),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 5,
            ),
            Expanded(
                child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                yesAction();
              },
              child: Text(
                yesLabel,
                style: TextStyle(
                    fontFamily: Constant.BOLD,
                    fontSize: 15,
                    color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith(_getBackgroundColor),
                  shape: MaterialStateProperty.resolveWith((states) =>
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3))))),
            )),
            Expanded(
                child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      noAction();
                    },
                    child: Text(
                      noLabel,
                      style: TextStyle(
                          fontFamily: Constant.BOLD,
                          fontSize: 15,
                          color: Constant.mainColor),
                    ))),
            SizedBox(
              width: 5,
            )
          ],
        )
      ],
    );
  }
}
