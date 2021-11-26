import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/page/DoujinshiPage.dart';
import 'package:nhentai/page/HomePage.dart';
import 'package:nhentai/page/ReaderPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  StateHolder<String> homeTabNameHolder =
      StateHolder(data: HomePage.DEFAULT_TAB_NAME);
  runApp(MaterialApp(
    routes: {
      '/': (context) => HomePage(
            homeTabNameHolder: homeTabNameHolder,
          ),
      MainNavigator.DOUJINSHI_PAGE: (context) => DoujinshiPage(),
      MainNavigator.DOUJINSHI_READER_PAGE: (context) => ReaderPage()
    },
    navigatorObservers: [
      FirebaseAnalyticsObserver(
          analytics: FirebaseAnalytics(),
          nameExtractor: (RouteSettings settings) {
            String? routeName = settings.name;
            switch (settings.name) {
              case MainNavigator.DOUJINSHI_PAGE:
                routeName = 'DoujinshiPage';
                break;

              case MainNavigator.DOUJINSHI_READER_PAGE:
                routeName = 'ReaderPage';
                break;

              case '/':
                routeName = homeTabNameHolder.data;
                break;
            }
            print(
                'FirebaseAnalyticsObserver: settings name=${settings.name}, route name=$routeName');
            return routeName;
          }),
    ],
    debugShowCheckedModeBanner: false,
  ));
}
