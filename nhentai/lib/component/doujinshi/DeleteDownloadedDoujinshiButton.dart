import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class DeleteDownloadedDoujinshiButton extends StatelessWidget {
  final Function onPressed;

  const DeleteDownloadedDoujinshiButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Constant.grey4D4D4D,
      highlightColor: Constant.grey1f1f1f,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(3))),
      padding: EdgeInsets.all(0),
      onPressed: () => onPressed(),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Delete This Doujinshi',
                style: TextStyle(
                    fontFamily: Constant.BOLD,
                    fontSize: 18,
                    color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
