import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/page/DoujinshiGallery.dart';
import 'package:nhentai/page/DownloadPage.dart';
import 'package:nhentai/page/DoujinshiCollectionPage.dart';
import 'package:nhentai/page/MorePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: [
          DoujinshiGallery(),
          DoujinshiCollectionPage(),
          DownloadPage(),
          MorePage()
        ],
        index: _selectedIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.search),
              label: 'Gallery',
              tooltip: 'Gallery'),
          BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.favorite),
              label: 'Favorite',
              tooltip: 'Favorite'),
          BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.download_done_sharp),
              label: 'Download',
              tooltip: 'Download'),
          BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.more_vert),
              label: 'More',
              tooltip: 'More'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Constant.mainColor,
        unselectedItemColor: Colors.grey[900],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedLabelStyle:
            TextStyle(fontFamily: Constant.NUNITO_BLACK, fontSize: 18),
        unselectedLabelStyle:
            TextStyle(fontFamily: Constant.NUNITO_REGULAR, fontSize: 16),
        onTap: _onTabSelected,
      ),
    );
  }
}
