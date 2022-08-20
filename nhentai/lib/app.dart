import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nhentai/MainNavigator.dart';
import 'package:nhentai/StateHolder.dart';
import 'package:nhentai/bloc/DataCubit.dart';
import 'package:nhentai/domain/entity/masterdata/Version.dart';
import 'package:nhentai/domain/usecase/GetActiveVersionUseCase.dart';
import 'package:nhentai/page/DoujinshiPage.dart';
import 'package:nhentai/page/HomePage.dart';
import 'package:nhentai/page/ReaderPage.dart';
import 'package:package_info/package_info.dart';

class NHentaiApp extends StatefulWidget {
  const NHentaiApp({Key? key}) : super(key: key);

  @override
  State<NHentaiApp> createState() => _NHentaiAppState();
}

class _NHentaiAppState extends State<NHentaiApp> {
  final StateHolder<String> homeTabNameHolder =
      StateHolder(data: HomePage.DEFAULT_TAB_NAME);
  final DataCubit<Version?> newVersionCubit = DataCubit(null);

  @override
  void initState() {
    super.initState();
    _initActiveVersion(newVersionCubit);
    _initNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => HomePage(
              homeTabNameHolder: homeTabNameHolder,
              newVersionCubit: newVersionCubit,
            ),
        MainNavigator.DOUJINSHI_PAGE: (context) => DoujinshiPage(),
        MainNavigator.DOUJINSHI_READER_PAGE: (context) => ReaderPage()
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(
            analytics: FirebaseAnalytics.instance,
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
    );
  }

  void _initActiveVersion(DataCubit<Version?> newVersionCubit) async {
    final GetActiveVersionUseCase _getActiveVersionUseCase =
        GetActiveVersionUseCaseImpl();

    _getActiveVersionUseCase.execute().listen((activeVersion) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      print(
          'Active version=${activeVersion.appVersionCode}, installed version=${packageInfo.version}');
      if (packageInfo.version != activeVersion.appVersionCode) {
        newVersionCubit.emit(activeVersion);
      }
    }, onError: (error, s) {
      print(
          'Failed to check active version error=$error');
    });
  }

  void _initNotificationSettings() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_app_notification');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _selectNotification);
  }

  Future<dynamic> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? ''),
        content: Text(body ?? ''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.pushNamed(context, '/');
            },
          )
        ],
      ),
    );
  }

  Future _selectNotification(String? payload) async {
    //Handle notification tapped logic here
  }
}
