import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/local_notifications.dart';
import 'package:flutter_time/src/notifications_data.dart';
import 'package:logging/logging.dart';

class FirebaseCloudMessaging {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final Logger log = Logger('FirebaseCloudMessaging');

  final LocalNotifications _localNotifications;

  FirebaseCloudMessaging()
      : _localNotifications = getIt<LocalNotifications>(),
        assert(getIt<LocalNotifications>() != null);

  void initialize() {
    if (Platform.isIOS) requestIosPermission();

    _firebaseMessaging.getToken().then((token) {
      log.info(token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        log.info('Message received: $message');

        _localNotifications.notifyCloudMessage(CloudMessageNotification(
            message['notification']['title'],
            message['notification']['body'],
            json.encode(message['data'])));
      },
      onResume: (Map<String, dynamic> message) async {
        log.info('Message received on resume: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        log.info('Message received on launch: $message');
      },
    );
  }

  void requestIosPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      log.info('Settings registered: $settings');
    });
  }

  void subscribeForProductsChanges(String owner) {
    _firebaseMessaging.subscribeToTopic(owner.replaceAll('@', '_at_'));
  }

  void unsubscribeForProductsChange(String owner) {
    _firebaseMessaging.unsubscribeFromTopic(owner.replaceAll('@', '_at_'));
  }
}
