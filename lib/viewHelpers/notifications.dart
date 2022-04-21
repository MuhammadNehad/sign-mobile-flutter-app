// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:rxdart/subjects.dart';

class NotificationPlugin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  // final BehaviorSubject<ReceivedNotificaiton> didReceivelNS =
  //     BehaviorSubject<ReceivedNotificaiton>();
  var initializeSettings;
  NotificationPlugin._() {
    init();
  }
  init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          ReceivedNotificaiton rn =
              ReceivedNotificaiton(id, title, body, payload);
          // didReceivelNS.add(rn);
        });
    initializeSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
          alert: false,
          badge: false,
        );
  }

  // setListenerToLowerVersions(Function ONTLV) {
  //   didReceivelNS.listen((value) {
  //     ONTLV(value);
  //   });
  // }

  setOnNotificationClick(Function ONC) async {
    flutterLocalNotificationsPlugin.initialize(initializeSettings,
        onSelectNotification: (String payload) async {
      ONC(payload);
    });
  }

  Future<void> showNotification(String body) async {
    var acs = AndroidNotificationDetails('channelId', 'Name',
        channelDescription: 'channelDescription');
    var ics = IOSNotificationDetails();
    var pcs = NotificationDetails(android: acs, iOS: ics);
    await flutterLocalNotificationsPlugin.show(0, "app", body, pcs,
        payload: 'Test background location');
  }
}

NotificationPlugin np = NotificationPlugin._();

class ReceivedNotificaiton {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotificaiton(this.id, this.title, this.body, this.payload);
}
