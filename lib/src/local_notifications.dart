import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/blocs/product/live_product_editor.dart';
import 'package:flutter_time/src/global_keys.dart';
import 'package:flutter_time/src/model/product.dart';
import 'package:flutter_time/src/notifications_data.dart';
import 'package:flutter_time/src/shared_preferences_repository.dart';
import 'package:logging/logging.dart';

class LocalNotifications {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  final Logger log = Logger('LocalNotifications');

  void initialize() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    _localNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);
  }

  Future<void> _onSelectNotification(String payloadString) async {
    log.info('On notification selection: $payloadString');

    var decoded = json.decode(payloadString);
    log.info('Decoded json $decoded');
    var payload = Payload.fromJson(decoded);

    if (payload.type == PayloadType.viewProduct) {
      _handleViewProductNotification(payload);
    }
  }

  Future<void> _onDidReceiveLocalNotification(
      int id, String title, String body, String payloadString) async {
    var payload = Payload.fromJson(json.decode(payloadString));

    if (payload.type == PayloadType.viewProduct) {
      _handleViewProductNotification(payload);
    }
  }

  void _handleViewProductNotification(Payload payload) {
    BuildContext context = productsGlobalKey.currentContext;

    var sharedPreferencesRepository = getIt<SharedPreferencesRepository>();

    Product product = payload.data;
    if (product.owner == sharedPreferencesRepository.getLastEmailAddress()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return LiveProductEditor(
            owner: product.owner,
            productId: product.id,
          );
        }),
      );
    }
  }

  Future<void> notifyPriceChanged(
      PriceChangedNotification priceChangedNotification) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'fluttertime', 'fluttertime', 'fluttertime',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(0, priceChangedNotification.title,
        priceChangedNotification.description, platformChannelSpecifics,
        payload: json.encode(priceChangedNotification.payload.toJson()));
  }

  Future<void> notifyCloudMessage(
      CloudMessageNotification cloudMessageNotification) async {
    log.info(
        'Cloud message received, showing notification: $cloudMessageNotification');

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'fluttertime', 'fluttertime', 'fluttertime',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    log.info('Notifying with payload ${cloudMessageNotification.data}');
    await _localNotificationsPlugin.show(0, cloudMessageNotification.title,
        cloudMessageNotification.description, platformChannelSpecifics,
        payload: cloudMessageNotification.data);
  }

  void dispose() {}
}
