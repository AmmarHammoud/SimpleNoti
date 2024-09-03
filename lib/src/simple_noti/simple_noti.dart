import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:simple_noti/src/constants/constants.dart';
import 'package:simple_noti/src/dio_helper/dio_helper.dart';
import 'package:universal_html/html.dart' as html;

import '../notifications_helper/notifications_helper.dart';

abstract class SimpleNotifications {
  ///The pusher cridentials
  static late final String _appKey;
  static late final String _appSecret;
  static late final String _appId;
  static late final String _cluster;

  ///The pusher object that is used to communicate with Pusher
  static late PusherChannelsFlutter _pusher;

  ///Initialize flutter local notification plugin
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ///A bool to choose whether to include debug output or not
  static late bool _enableLogging;

  ///A timer to make sure a single notification is not shown more than once
  ///as in web it may arrive several times
  static Timer? _debounceTimer;

  ///A bool to decide whether the notifications have been allowed on web or not
  static bool _permissionGrantedOnWeb = false;

  ///A function to decode the received event.
  ///The [event.data]'s run time type may vary in term of mobile and web
  static Map _decodedEvent(event) {
    if (event.runtimeType == String) {
      return jsonDecode(event);
    }
    Map json = {};
    for (var kv in event.entries) {
      json[kv.key] = kv.value.toString();
    }
    return json;
  }

  ///The default callback that is going to be fired whenever an event has been received
  static Future<void> _onMyEvent(PusherEvent event) async {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (event.data == null || event.data.isEmpty) return;

      late Map json;
      try {
        json = _decodedEvent(event.data);
      } catch (e) {
        logRed('error decoding json: ${e.toString()}');
      }
      var title = json['title'];
      var body = json['message'];
      if (_enableLogging) {
        logGreen('Event has been received on channel: {${event.channelName}}');
        logMagenta(
            'details: ${event.data.toString()}, run time type: ${event.data.runtimeType}');
      }

      if (kIsWeb) {
        _showNotificationOnWeb(title: title, message: body);
        return;
      }

      await Noti.showNotification(
        title: title,
        body: body,
        payload: json.toString(),
        fln: _flutterLocalNotificationsPlugin,
      );
    });
  }

  ///Initialize the [SimpleNotifications]
  ///if no callback is passed, the default callback [_onMyEvent] will be fired whenever an event has been received
  static Future<void> init({
    required String appKey,
    required String cluster,
    required String appSecret,
    required String appId,
    Function(NotificationResponse notificationResponse)? onTap,
    bool enableLogging = true,
  }) async {
    try {
      _appKey = appKey;
      _cluster = cluster;
      _appSecret = appSecret;
      _appId = appId;

      _enableLogging = enableLogging;

      await Noti.init(_flutterLocalNotificationsPlugin,
          enableLogging: _enableLogging, onTap: onTap);

      DioHelper.init();

      _pusher = PusherChannelsFlutter.getInstance();
      await _pusher.init(
          apiKey: _appKey,
          cluster: _cluster,
          onSubscriptionError: _onSubscriptionError,
          onConnectionStateChange: _onConnectionStateChange,
          onSubscriptionSucceeded: _onSubscriptionSucceeded,
          onError: _onError,
          onDecryptionFailure: _onDecryptionFailure,
          onMemberAdded: _onMemberAdded,
          onMemberRemoved: _onMemberRemoved,
          onSubscriptionCount: _onSubscriptionCount);
    } catch (e) {
      logRed('Error initializing Pusher: ${e.toString()}');
    }
  }

  ///A method to subscribe to a channel with name [channelName] and nullable id [roomId]
  static Future<void> subscribe({
    required String channelName,
    int? roomId,
    Function(PusherEvent event)? onEvent,
  }) async {
    try {
      await _pusher.subscribe(
        channelName:
            '$channelName${roomId == null ? '' : '.${roomId.toString()}'}',
        onEvent: onEvent ?? (e) => _onMyEvent(e),
      );
      await _pusher.connect();
    } catch (e) {
      logRed('error subscribing to: {$channelName}: ${e.toString()}');
    }
  }

  static void _onSubscriptionError(String message, dynamic e) {
    logRed("Error in channel subscription: $message Exception: $e");
  }

  static void _onSubscriptionSucceeded(String channelName, dynamic data) {
    logGreen("Subscription in: {$channelName} succeeded");
    if (data == null || data.isEmpty) return;
    logCyan('data: $data');
  }

  static void _onConnectionStateChange(from, to) {
    logYellow('Connection state changed from: $from to: $to');
  }

  static void _onError(String message, int? code, dynamic e) {
    logRed("Error: $message, Code: $code, Exception: ${e.toString()}");
  }

  static void _onDecryptionFailure(String event, String reason) {
    logRed("onDecryptionFailure: $event reason: $reason");
  }

  static void _onMemberAdded(String channelName, PusherMember member) {
    logMagenta("onMemberAdded: $channelName user: $member");
  }

  static void _onMemberRemoved(String channelName, PusherMember member) {
    logMagenta("onMemberRemoved: $channelName user: $member");
  }

  static void _onSubscriptionCount(String channelName, int subscriptionCount) {
    logYellow(
        "onSubscriptionCount: $channelName subscriptionCount: $subscriptionCount");
  }

  ///A method to unsubscribe from a channel with name [channelName] and nullable [roomId]
  ///and close the connection
  static Future<void> unsubscribeAndClose({
    required String channelName,
    int? roomId,
  }) async {
    try {
      await _pusher.unsubscribe(
          channelName:
              '$channelName${roomId == null ? '' : '.${roomId.toString()}'}');
      await _pusher.disconnect();
      if (!_enableLogging) return;
      logGreen('Unsubscribing succeeded');
    } catch (e) {
      logRed('Error unsubscribing channel {$channelName}: ${e.toString()}');
    }
  }

  ///A method to send notification through making a request to backend
  static Future<void> sendNotifications({
    required String channelName,
    required String title,
    required String message,
    int? roomId,
    dynamic payload,
  }) async {
    try {
      var response = await DioHelper.sendNotificationWithKeys(
        appId: _appId,
        appKey: _appKey,
        appSecret: _appSecret,
        cluster: _cluster,
        channelName: channelName,
        message: message,
        title: title,
        roomId: roomId?.toString(),
        payload: jsonEncode(payload),
      );
      logYellow('response: ${response.data}');
    } catch (e) {
      logRed('error sending notifications: ${e.toString()}');
    }
  }

  ///A method to display a notification locally without making a request.
  ///with a purpose of testing and debugging
  static Future<void> showNotification({
    required String title,
    required String message,
    var payload,
    bool isWeb = false,
  }) async {
    if (isWeb) {
      _showNotificationOnWeb(title: title, message: message);
      return;
    }
    Noti.showNotification(
        title: title,
        body: message,
        payload: payload,
        fln: _flutterLocalNotificationsPlugin);
  }

  ///A method to request notifications permission on web
  static Future<void> _requestNotificationPermission() async {
    html.Notification.requestPermission().then((permission) {
      if (permission == 'granted') {
        _permissionGrantedOnWeb = true;
        if (!_enableLogging) return;
        logGreen('Notification permission granted!');
      } else {
        logRed('Notification permission denied!');
      }
    });
  }

  ///A method to display a notification on web
  static void _showNotificationOnWeb({
    required String title,
    required String message,
  }) async {
    if (!_permissionGrantedOnWeb) await _requestNotificationPermission();
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: message);
    } else {
      logRed('Notification permission not granted.');
    }
  }

  static Future<void> test({dynamic payload}) async {
    try {
      var response = await DioHelper.test(payload: jsonEncode(payload));
      logMagenta('test response ${response.data.toString()}');
    } catch (e) {
      logRed(e.toString());
    }
  }
}
