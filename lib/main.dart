import 'dart:async';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:islamic_prayer_times/Extras/notification/notification_manager.dart';
import 'package:islamic_prayer_times/provider/daily_timings.dart';
import 'package:islamic_prayer_times/provider/settings_provider.dart';
import 'package:islamic_prayer_times/service/Utils.dart';
import 'package:islamic_prayer_times/service/get_prayer_times.dart';
import 'package:islamic_prayer_times/times/MonthlyPrayerTimes.dart';
import 'package:islamic_prayer_times/times/daily_prayer_times.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as permissionHandler;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/prayer_times.dart';

const EVENTS_KEY = "fetch_events";
int increment = 0;

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print("[BackgroundFetch] Headless event received: $taskId");

  NotificationManager manager = NotificationManager();
  await manager.initNotificationManager();

  setScheduledNotifications();

  BackgroundFetch.finish(taskId);
}

Future<void> restartBackgroundFetch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("enableNotifications") ?? true) {
    BackgroundFetch.stop().then((value) {
      BackgroundFetch.start().then((value) {
        setScheduledNotifications();
      });
    });
  }
}

Future<void> setScheduledNotifications() async {
  DateTime time = DateTime.now();
  String unixTime = (time.microsecondsSinceEpoch / 1000).toString();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  double latitude = prefs.getDouble("latitude") ?? 0.0;
  double longitude = prefs.getDouble("longitude") ?? 0.0;
  int preferredCalculationMethod = prefs.getInt("preferredCalculationMethod") ?? 2;
  int madhab = prefs.getInt("madhab") ?? 0;
  int midNightMode = prefs.getInt("midNightMode") ?? 0;
  int hijriDateAdjustment = prefs.getInt("hijri") ?? 2;

  PrayerTimesModel prayerTimes = await GetPrayerTimes().getPrayerTimes(
      timestamp: unixTime.toString(),
      lat: latitude.toString(),
      lon: longitude.toString(),
      method: preferredCalculationMethod.toString(),
      madhab: madhab.toString(),
      midnightMode: midNightMode.toString(),
      hijriDateAdjustment: Utils().getCalculatedHijriDate(hijriDateAdjustment).toString());

  calculateNextTime(prayerTimes.fajr, "Fajr", 0);
  calculateNextTime(prayerTimes.dhuhr, "Dhuhr", 1);
  calculateNextTime(prayerTimes.asr, "Asr", 2);
  calculateNextTime(prayerTimes.maghrib, "Maghrib", 3);
  calculateNextTime(prayerTimes.isha, "Isha", 4);
}

calculateNextTime(var nextTime, String prayerName, int Id) async {
  var val = nextTime.split(":");

  final nowDateTime = DateTime.now();
  DateTime prayerDateTime =
      new DateTime(nowDateTime.year, nowDateTime.month, nowDateTime.day, int.parse(val[0]), int.parse(val[1]));

  var difference;

  if (prayerDateTime.isBefore(nowDateTime)) {
    prayerDateTime = prayerDateTime.add(Duration(days: 1));
    difference = prayerDateTime.difference(nowDateTime).inMinutes;
  } else {
    difference = prayerDateTime.difference(nowDateTime).inMinutes;
  }

  NotificationManager manager = NotificationManager();
  await manager.initNotificationManager();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int notificationMode = prefs.getInt("notificationMode") ?? 0;

  NotificationDetails notificationDetails;

  switch (notificationMode) {
    case 0:
      // notificationDetails = manager.salahChannel();
      notificationDetails =
          manager.setChannel("1", "Salah Prayer notification", "Prayer notification channel", "hayya_alassallah_azan");
      break;
    case 1:
      // notificationDetails = manager.beepChannel();
      notificationDetails = manager.setChannel("2", "Beep notification", "Prayer notification channel", "beep_once");
      break;
    case 2:
      notificationDetails = manager.vibrationChannel();
      break;
    case 3:
      notificationDetails = manager.muteChannel();
      break;
    case 4:
      notificationDetails =
          manager.setChannel("5", "Salah Prayer notification", "Prayer notification channel", "ahmad_al_nafees");
      break;
    case 5:
      notificationDetails = manager.setChannel(
          "6", "Salah Prayer notification", "Prayer notification channel", "another_mishary_rashid_alafasy_adhan");
      break;
    case 6:
      notificationDetails = manager.setChannel(
          "7", "Salah Prayer notification", "Prayer notification channel", "dubai_s_one_tv_by_mishary_rashid_alafasy");
      break;
    case 7:
      notificationDetails =
          manager.setChannel("8", "Salah Prayer notification", "Prayer notification channel", "hafiz_mustafa_ozcan_from_turkey");
      break;
    case 8:
      notificationDetails = manager.setChannel(
          "9", "Salah Prayer notification", "Prayer notification channel", "karl_jenkins_the_armed_man_mass_for_peace");
      break;
    case 9:
      notificationDetails =
          manager.setChannel("10", "Salah Prayer notification", "Prayer notification channel", "masjid_al_haram_in_mecca");
      break;
    case 10:
      notificationDetails =
          manager.setChannel("11", "Salah Prayer notification", "Prayer notification channel", "mishary_rashid_alafasy");
      break;
    case 11:
      notificationDetails =
          manager.setChannel("12", "Salah Prayer notification", "Prayer notification channel", "qari_abdul_kareem");
      break;
    case 12:
      notificationDetails =
          manager.setChannel("13", "Salah Prayer notification", "Prayer notification channel", "salah_mansoor_az_ahrani");
      break;
    case 13:
      notificationDetails =
          manager.setChannel("14", "Salah Prayer notification", "Prayer notification channel", "sheikh_jamac_hareed");
      break;
    default:
      notificationDetails = manager.salahChannel();
      break;
  }

  /*var android = new AndroidNotificationDetails(
    'id',
    "Prayer notification",
    'Prayer notification channel',
    priority: Priority.High,
    importance: Importance.Max,
    sound: RawResourceAndroidNotificationSound('hayya_alassallah_azan'),
    playSound: true,
  );
  var iOS = new IOSNotificationDetails(
      sound: 'hayya_alassallah_azan.aiff', presentSound: true);
  var platform = new NotificationDetails(android, iOS);*/

  await flutterLocalNotificationsPlugin.schedule(
    Id,
    'Prayer notification',
    '$prayerName Prayer Time',
    DateTime.now().add(Duration(minutes: difference)),
    // platform,
    notificationDetails,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DailyTimings>(create: (context) => DailyTimings()),
        ChangeNotifierProvider<SettingsProvider>(create: (context) => SettingsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Montserrat Alternates',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

// home page
class Pages extends StatefulWidget {
  @override
  _PagesState createState() => _PagesState();
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class _PagesState extends State<Pages> {
  PageController _controller;
  int index = 0;

  Future<void> initPlatformState() async {
    BackgroundFetch.configure(
            BackgroundFetchConfig(
              minimumFetchInterval: 1440,
              //for 24 hour in minutes
              forceAlarmManager: true,
              stopOnTerminate: false,
              startOnBoot: true,
              enableHeadless: true,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresStorageNotLow: false,
              requiresDeviceIdle: false,
              requiredNetworkType: NetworkType.NONE,
            ),
            _onBackgroundFetch)
        .then((int status) async {
      print('[BackgroundFetch] configure success: $status');
      NotificationManager manager = NotificationManager();
      await manager.initNotificationManager();

      setScheduledNotifications();
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) async {
    print("[BackgroundFetch] Event received: $taskId");

    NotificationManager manager = NotificationManager();
    await manager.initNotificationManager();

    setScheduledNotifications();

    BackgroundFetch.finish(taskId);
  }

  Future<void> initSharedAndBatteryPermission() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    var add = sharedPrefs.getString("address") ?? "";
    print("112233, add: " + add);

    if (sharedPrefs.getBool("enableNotifications") ?? true) {
      initPlatformState();
    }

    // background fetch service will stop after some time on some devices due to OS reasons.
    // this will allow background fetch to run forever
    await permissionHandler.Permission.ignoreBatteryOptimizations.request();
  }

  @override
  void initState() {
    _controller = PageController(initialPage: index);
    super.initState();

    initSharedAndBatteryPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _controller,
          onPageChanged: (i) {
            setState(() {
              index = i;
            });
          },
          children: [DailyPrayerTimes(), MonthlyPrayerTimes()],
        ),
        _pageDots()
      ],
    );
  }

  SafeArea _pageDots() {
    return SafeArea(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 40.0,
        width: 40.0,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: index == 0 ? Colors.blue : Colors.grey,
              radius: 5.0,
            ),
            SizedBox(
              width: 5.0,
            ),
            CircleAvatar(
              backgroundColor: index == 1 ? Colors.blue : Colors.grey,
              radius: 5.0,
            ),
          ],
        ),
      ),
    ));
  }
}

// splash
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () async {
      if (!await permissionHandler.Permission.location.isGranted) {
        showAlertDialog(context);
      }else{
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Pages()));
      }
    });
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("ALLOW"),
      onPressed: () async {
        permissionHandler.PermissionStatus permissionStatus = await permissionHandler.Permission.location.request();
        if (permissionStatus.isGranted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Pages()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permission no granted. Please grant the permission to use the app."),));
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Permissions"),
      content: Text("This app collects location data to fetch 'Prayer Times' even when the app is closed or not in use. "
          "App gets location once after every 24 hours to get 'Prayer Times'."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Hero(
            tag: "logo",
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/logo.png'),
                  height: 250,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Prayer Times",
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Getting files ready. Please wait",
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
