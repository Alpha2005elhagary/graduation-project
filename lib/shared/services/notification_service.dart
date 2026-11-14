import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _local.initialize(initSettings);
  }

  static Future<void> showLocalNudge({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'breakbot_nudges',
      'التحذيرات اللطيفة',
      channelDescription: 'تذكيرات وعادات بريك بوت',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(id, title, body, const NotificationDetails(android: androidDetails));
  }
}
