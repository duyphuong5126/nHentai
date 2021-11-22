import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/analytics/AnalyticsUtils.dart';
import 'package:nhentai/page/DoujinshiGallery.dart';
import 'package:nhentai/page/DownloadPage.dart';
import 'package:nhentai/page/DoujinshiCollectionPage.dart';
import 'package:nhentai/page/MorePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() {
    AnalyticsUtils.setScreen('DoujinshiGallery');
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          {
            AnalyticsUtils.setScreen('DoujinshiGallery');
            break;
          }
        case 1:
          {
            AnalyticsUtils.setScreen('DoujinshiCollectionPage');
            break;
          }
        case 2:
          {
            AnalyticsUtils.setScreen('DownloadPage');
            break;
          }
        case 3:
          {
            AnalyticsUtils.setScreen('MorePage');
            break;
          }
      }
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
              icon: Icon(Icons.collections),
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
        selectedLabelStyle: TextStyle(fontFamily: Constant.BOLD, fontSize: 18),
        unselectedLabelStyle:
            TextStyle(fontFamily: Constant.REGULAR, fontSize: 16),
        onTap: _onTabSelected,
      ),
    );
  }
}
