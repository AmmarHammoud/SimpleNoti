import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_noti/src/constants/constants.dart';

class Noti {
  ///A flag for choosing whether enable logging or not
  static late bool _enableLogging;

  static _onTap(NotificationResponse notificationResponse) {
    if (!_enableLogging) return;
    log('LOCAL NOTIFICATION: ${notificationResponse.payload.toString()}');
  }

  ///Initialize the helper
  static Future init(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, {
    bool enableLogging = true,
    Function(NotificationResponse notificationsResponsee)? onTap,
  }) async {
    try {
      _enableLogging = enableLogging;

      var androidInit =
          const AndroidInitializationSettings('@mipmap/ic_launcher');
      var init = InitializationSettings(android: androidInit);
      await flutterLocalNotificationsPlugin.initialize(
        init,
        onDidReceiveNotificationResponse: onTap ?? _onTap,
        onDidReceiveBackgroundNotificationResponse: onTap ?? _onTap,
      );
      if (!_enableLogging) return;
      logGreen('local notification has been initializing successfully');
    } catch (e) {
      logRed('error initializing local notification: ${e.toString()}');
    }
  }

  ///A method to display a notification
  static Future showNotification({
    int id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin fln,
  }) async {
    AndroidNotificationDetails androidPlatformSpecific =
        AndroidNotificationDetails(
      title,
      body,
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      // actions: [
      //   AndroidNotificationAction('id_1', 'Action 1'),
      //   AndroidNotificationAction('id_2', 'Action 2'),
      //   AndroidNotificationAction('id_3', 'Action 3'),
      // ],
    );
    var noti = NotificationDetails(android: androidPlatformSpecific);
    await fln.show(id, title, body, noti, payload: payload);
  }
}
