import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my/object/merchant.dart';
import 'package:my/utils/sharePreference.dart';
import 'dart:io' show Platform;
import 'package:rxdart/subjects.dart';

class NotificationPlugin {
  //
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final BehaviorSubject<ReceivedNotification>
      didReceivedLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();
  var initializationSettings;

  NotificationPlugin._();

  init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    init();
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('testlogo');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
            id: id, title: title, body: body, payload: payload);
        didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
          alert: false,
          badge: true,
          sound: true,
        );
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
    });
  }

  Future<void> showNotification(data) async {
    print('notification data: $data');
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    Merchant merchant =
        Merchant.fromJson(await SharePreferences().read('merchant'));
    if (merchant != null && data['merchant_id'] == Merchant.fromJson(await SharePreferences().read("merchant")).merchantId) {
      print("Merchant id 1 $data['merchant_id']");
      print("Merchant id 2 ${Merchant.fromJson(await SharePreferences().read("merchant")).merchantId}");
      var androidChannelSpecifics = AndroidNotificationDetails(
        data['id'],
        data['name'],
        "CHANNEL_DESCRIPTION",
        importance: Importance.Max,
        priority: Priority.High,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        icon: 'logo',
        styleInformation: DefaultStyleInformation(true, true),
      );
      var iosChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics =
          NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        data['title'],
        data['message'], //null
        platformChannelSpecifics,
        payload: data['name'],
      );
    }
  }

  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

NotificationPlugin notificationPlugin = NotificationPlugin._();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}
