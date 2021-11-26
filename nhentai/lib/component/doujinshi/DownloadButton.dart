import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class DownloadButton extends StatelessWidget {
  final Function onPressed;

  const DownloadButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Constant.grey4D4D4D,
      highlightColor: Constant.grey1f1f1f,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(3))),
      padding: EdgeInsets.all(0),
      onPressed: () => onPressed(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            Icon(
              Icons.download_sharp,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'Download',
              style: TextStyle(
                  fontFamily: Constant.BOLD, fontSize: 18, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
