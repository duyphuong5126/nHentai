import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nhentai/notification/notification_helper.dart';

class NotificationHelperFactory {
  static NotificationHelper get doujinshiNotificationHelper =>
      NotificationHelper(
          channelId: 'd0ujinshi',
          channelName: 'Doujinshi',
          channelDescription: 'For notifications about updates of a doujinshi',
          importance: Importance.high,
          priority: Priority.high);
}
