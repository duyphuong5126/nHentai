import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsUtils {
  static late FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static const String EVENT_OPEN_DOUJINSHI = 'open_doujinshi';
  static const String EVENT_OPEN_READ_DOUJINSHI = 'open_read_doujinshi';
  static const String EVENT_OPEN_FAVORITE_DOUJINSHI = 'open_favorite_doujinshi';
  static const String EVENT_OPEN_DOWNLOADED_DOUJINSHI =
      'open_downloaded_doujinshi';
  static const String EVENT_OPEN_RECOMMENDED_DOUJINSHI =
      'open_recommended_doujinshi';
  static const String EVENT_READ_DOUJINSHI = 'read_doujinshi';
  static const String EVENT_ADD_FAVORITE = 'add_favorite';
  static const String EVENT_REMOVE_FAVORITE = 'remove_favorite';
  static const String EVENT_CHANGE_GALLERY_PAGE = 'change_gallery_page';

  static const String PARAM_DOUJINSHI_ID = 'doujinshi_id';

  static void setScreen(String screenName) async {
    print('AnalyticsUtils: setScreen - $screenName');
    FirebaseAnalytics.instance.setCurrentScreen(screenName: screenName);
  }

  static void search(String searchTerm) async {
    print('AnalyticsUtils: search - $searchTerm');
    _analytics.logSearch(searchTerm: searchTerm);
  }

  static void openDoujinshi(int doujinshiId) {
    print('AnalyticsUtils: openDoujinshi - $doujinshiId');
    _analytics.logEvent(
        name: EVENT_OPEN_DOUJINSHI,
        parameters: {PARAM_DOUJINSHI_ID: doujinshiId});
  }

  static void openReadDoujinshi(int doujinshiId) {
    print('AnalyticsUtils: openReadDoujinshi - $doujinshiId');
    _analytics.logEvent(
        name: EVENT_OPEN_READ_DOUJINSHI,
        parameters: {PARAM_DOUJINSHI_ID: doujinshiId});
  }

  static void openFavoriteDoujinshi(int doujinshiId) {
    print('AnalyticsUtils: openFavoriteDoujinshi - $doujinshiId');
    _analytics.logEvent(
        name: EVENT_OPEN_FAVORITE_DOUJINSHI,
        parameters: {PARAM_DOUJINSHI_ID: doujinshiId});
  }

  static void openDownloadedDoujinshi(int doujinshiId) {
    print('AnalyticsUtils: openDownloadedDoujinshi - $doujinshiId');
    _analytics.logEvent(
        name: EVENT_OPEN_DOWNLOADED_DOUJINSHI,
        parameters: {PARAM_DOUJINSHI_ID: doujinshiId});
  }

  static void openRecommendedDoujinshi(int doujinshiId) {
    print('AnalyticsUtils: openRecommendedDoujinshi - $doujinshiId');
    _analytics.logEvent(
        name: EVENT_OPEN_RECOMMENDED_DOUJINSHI,
        parameters: {PARAM_DOUJINSHI_ID: doujinshiId});
  }

  static void readDoujinshi(int doujinshiId) {
    print('AnalyticsUtils: readDoujinshi - $doujinshiId');
    _analytics.logEvent(
        name: EVENT_READ_DOUJINSHI,
        parameters: {PARAM_DOUJINSHI_ID: doujinshiId});
  }

  static void addFavorite(int doujinshiId) {
    print('AnalyticsUtils: addFavorite - $doujinshiId');
    _analytics.logEvent(
        name: EVENT_ADD_FAVORITE,
        parameters: {PARAM_DOUJINSHI_ID: doujinshiId});
  }

  static void removeFavorite(int doujinshiId) {
    print('AnalyticsUtils: removeFavorite - $doujinshiId');
    _analytics.logEvent(
        name: EVENT_REMOVE_FAVORITE,
        parameters: {PARAM_DOUJINSHI_ID: doujinshiId});
  }
}
