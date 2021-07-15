import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification.dart' as custom;

class NotificationManager {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  AndroidInitializationSettings initializationSettingsAndroid;
  IOSInitializationSettings initializationSettingsIOS;
  InitializationSettings initializationSettings;

  Future initNotificationManager() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializationSettingsAndroid =
        AndroidInitializationSettings('flutter_devs');
    initializationSettingsIOS = IOSInitializationSettings();
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  NotificationDetails setChannel(
      channelId, channelName, channelDescription, soundName) {
    var android = new AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription,
      priority: Priority.High,
      importance: Importance.Max,
      sound: RawResourceAndroidNotificationSound(soundName),
      playSound: true,
    );
    var iOS =
        new IOSNotificationDetails(sound: '$soundName.mp3', presentSound: true);
    var platform = new NotificationDetails(android, iOS);
    return platform;
  }

  NotificationDetails salahChannel() {
    var android = new AndroidNotificationDetails(
      '1',
      "Salah Prayer notification",
      'Prayer notification channel',
      priority: Priority.High,
      importance: Importance.Max,
      sound: RawResourceAndroidNotificationSound('hayya_alassallah_azan'),
      playSound: true,
    );
    var iOS = new IOSNotificationDetails(
        sound: 'hayya_alassallah_azan.mp3', presentSound: true);
    var platform = new NotificationDetails(android, iOS);
    return platform;
  }

  NotificationDetails beepChannel() {
    var android = new AndroidNotificationDetails(
      '2',
      "Beep notification",
      'Prayer notification channel',
      priority: Priority.High,
      importance: Importance.Max,
      sound: RawResourceAndroidNotificationSound('beep_once'),
      playSound: true,
    );
    var iOS =
        new IOSNotificationDetails(sound: 'beep_once.mp3', presentSound: true);
    var platform = new NotificationDetails(android, iOS);
    return platform;
  }

  NotificationDetails vibrationChannel() {
    var android = new AndroidNotificationDetails(
      '3',
      "Vibration notification",
      'Prayer notification channel',
      priority: Priority.High,
      importance: Importance.Max,
      playSound: false,
    );
    var iOS = new IOSNotificationDetails(presentSound: false);
    var platform = new NotificationDetails(android, iOS);
    return platform;
  }

  NotificationDetails muteChannel() {
    var android = new AndroidNotificationDetails(
      '4',
      "Mute notification",
      'Prayer notification channel',
      priority: Priority.Low,
      importance: Importance.Low,
      playSound: false,
    );
    var iOS = new IOSNotificationDetails(presentSound: false);
    var platform = new NotificationDetails(android, iOS);
    return platform;
  }

  Future<void> scheduleNotification(custom.Notification notification) async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 5));
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        notification.channel.channelID,
        notification.channel.channelName,
        notification.channel.channelDescription,
        sound:
            RawResourceAndroidNotificationSound(notification.channel.soundName),
        largeIcon: DrawableResourceAndroidBitmap('flutter_devs'),
        // vibrationPattern: vibrationPattern,
        autoCancel: false,
        enableLights: true,
        playSound: notification.channel.hasSound,
        color: Colors.green,
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'hayya_alassallah_azan.aiff');
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        notification.notificationID,
        notification.notificationTitle,
        notification.notificationBody,
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  notifications() async {
    List<PendingNotificationRequest> request =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> showNotification(String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        playSound: true,
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', body, platformChannelSpecifics,
        payload: 'item x');
  }
}
