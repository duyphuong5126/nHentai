import 'package:flutter/material.dart';
import 'package:nhentai/Constant.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/analytics/AnalyticsUtils.dart';
import 'package:nhentai/page/DoujinshiGallery.dart';
import 'package:nhentai/page/DownloadPage.dart';
import 'package:nhentai/page/DoujinshiCollectionPage.dart';
import 'package:nhentai/page/MorePage.dart';

class HomePage extends StatefulWidget {
  static const String DEFAULT_TAB_NAME = 'DoujinshiGallery';
  static const int DEFAULT_TAB_INDEX = 0;

  final StateHolder<String> homeTabNameHolder;

  const HomePage({Key? key, required this.homeTabNameHolder}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = HomePage.DEFAULT_TAB_INDEX;

  @override
  void initState() {
    super.initState();
    widget.homeTabNameHolder.data = 'DoujinshiGallery';
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          {
            widget.homeTabNameHolder.data = 'DoujinshiGallery';
            AnalyticsUtils.setScreen('DoujinshiGallery');
            break;
          }
        case 1:
          {
            widget.homeTabNameHolder.data = 'DoujinshiCollectionPage';
            AnalyticsUtils.setScreen('DoujinshiCollectionPage');
            break;
          }
        case 2:
          {
            widget.homeTabNameHolder.data = 'DownloadPage';
            AnalyticsUtils.setScreen('DownloadPage');
            break;
          }
        case 3:
          {
            widget.homeTabNameHolder.data = 'MorePage';
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
