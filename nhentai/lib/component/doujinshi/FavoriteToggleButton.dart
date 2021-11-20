import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhentai/Constant.dart';

class FavoriteToggleButton extends StatefulWidget {
  final int favoriteCount;

  const FavoriteToggleButton({Key? key, required this.favoriteCount})
      : super(key: key);

  @override
  _FavoriteToggleButtonState createState() => _FavoriteToggleButtonState();
}

class _FavoriteToggleButtonState extends State<FavoriteToggleButton> {
  @override
  Widget build(BuildContext context) {
    NumberFormat decimalFormat = NumberFormat.decimalPattern();
    NumberFormat compactFormat = NumberFormat.compact();
    String favoriteCountLabel = widget.favoriteCount <= 0
        ? ''
        : widget.favoriteCount >= 100000
            ? ' (${compactFormat.format(widget.favoriteCount)})'
            : ' (${decimalFormat.format(widget.favoriteCount)})';
    return MaterialButton(
      padding: EdgeInsets.all(0),
      onPressed: () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'Favorite$favoriteCountLabel',
              style: TextStyle(
                  fontFamily: Constant.BOLD, fontSize: 18, color: Colors.white),
            )
          ],
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            color: Constant.mainColor),
      ),
    );
  }
}
