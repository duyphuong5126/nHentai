import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class LoadingMessage extends StatelessWidget {
  final String loadingMessage;

  const LoadingMessage({Key? key, required this.loadingMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Image.asset(
                Constant.LOADING_GIF,
                width: 80,
                height: 80,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                loadingMessage,
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: Constant.BOLD,
                    color: Colors.black),
              )
            ],
          )
        ],
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      constraints: BoxConstraints.expand(height: 100),
    );
  }
}
