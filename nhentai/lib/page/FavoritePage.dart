import 'package:flutter/material.dart';
import 'package:nhentai/text_widget/DefaultScreenTitle.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DefaultScreenTitle('Favorite'),
        centerTitle: true,
        backgroundColor: Colors.green[500],
      ),
      body: Container(
        color: Colors.white,
      ),
    );
  }
}
