import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhentai/Constant.dart';

class FavoriteToggleButton extends StatefulWidget {
  final int favoriteCount;
  final bool isFavorite;
  final Function onPressed;

  const FavoriteToggleButton(
      {Key? key,
      required this.favoriteCount,
      required this.isFavorite,
      required this.onPressed})
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
    bool isFavorite = widget.isFavorite;
    return MaterialButton(
      color: isFavorite ? Colors.white : Constant.mainColor,
      highlightColor: isFavorite ? Colors.white : Constant.grey767676,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(3))),
      padding: EdgeInsets.all(0),
      onPressed: () {
        widget.onPressed();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            Icon(
              Icons.favorite,
              color: isFavorite ? Constant.mainColor : Colors.white,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'Favorite$favoriteCountLabel',
              style: TextStyle(
                  fontFamily: Constant.BOLD,
                  fontSize: 18,
                  color: isFavorite ? Constant.mainColor : Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
