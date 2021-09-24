import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';

class FavoriteToggleButton extends StatefulWidget {
  const FavoriteToggleButton({Key? key}) : super(key: key);

  @override
  _FavoriteToggleButtonState createState() => _FavoriteToggleButtonState();
}

class _FavoriteToggleButtonState extends State<FavoriteToggleButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.all(0),
      onPressed: () {
        print('Favorite is toggled');
      },
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
              'Favorite',
              style: TextStyle(
                  fontFamily: Constant.NUNITO_BLACK,
                  fontSize: 18,
                  color: Colors.white),
            )
          ],
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            color: Colors.green[500]),
      ),
    );
  }
}
