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
import 'package:permission_handler/permission_handler.dart';
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
  int preferredCalculationMethod =
      prefs.getInt("preferredCalculationMethod") ?? 2;
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
      hijriDateAdjustment:
          Utils().getCalculatedHijriDate(hijriDateAdjustment).toString());

  calculateNextTime(prayerTimes.fajr, "Fajr", 0);
  calculateNextTime(prayerTimes.dhuhr, "Dhuhr", 1);
  calculateNextTime(prayerTimes.asr, "Asr", 2);
  calculateNextTime(prayerTimes.maghrib, "Maghrib", 3);
  calculateNextTime(prayerTimes.isha, "Isha", 4);
}

calculateNextTime(var nextTime, String prayerName, int Id) async {
  var val = nextTime.split(":");

  final nowDateTime = DateTime.now();
  DateTime prayerDateTime = new DateTime(nowDateTime.year, nowDateTime.month,
      nowDateTime.day, int.parse(val[0]), int.parse(val[1]));

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
      notificationDetails = manager.setChannel("1", "Salah Prayer notification",
          "Prayer notification channel", "hayya_alassallah_azan");
      break;
    case 1:
      // notificationDetails = manager.beepChannel();
      notificationDetails = manager.setChannel(
          "2", "Beep notification", "Prayer notification channel", "beep_once");
      break;
    case 2:
      notificationDetails = manager.vibrationChannel();
      break;
    case 3:
      notificationDetails = manager.muteChannel();
      break;
    case 4:
      notificationDetails = manager.setChannel("5", "Salah Prayer notification",
          "Prayer notification channel", "ahmad_al_nafees");
      break;
    case 5:
      notificationDetails = manager.setChannel(
          "6",
          "Salah Prayer notification",
          "Prayer notification channel",
          "another_mishary_rashid_alafasy_adhan");
      break;
    case 6:
      notificationDetails = manager.setChannel(
          "7",
          "Salah Prayer notification",
          "Prayer notification channel",
          "dubai_s_one_tv_by_mishary_rashid_alafasy");
      break;
    case 7:
      notificationDetails = manager.setChannel("8", "Salah Prayer notification",
          "Prayer notification channel", "hafiz_mustafa_ozcan_from_turkey");
      break;
    case 8:
      notificationDetails = manager.setChannel(
          "9",
          "Salah Prayer notification",
          "Prayer notification channel",
          "karl_jenkins_the_armed_man_mass_for_peace");
      break;
    case 9:
      notificationDetails = manager.setChannel(
          "10",
          "Salah Prayer notification",
          "Prayer notification channel",
          "masjid_al_haram_in_mecca");
      break;
    case 10:
      notificationDetails = manager.setChannel(
          "11",
          "Salah Prayer notification",
          "Prayer notification channel",
          "mishary_rashid_alafasy");
      break;
    case 11:
      notificationDetails = manager.setChannel(
          "12",
          "Salah Prayer notification",
          "Prayer notification channel",
          "qari_abdul_kareem");
      break;
    case 12:
      notificationDetails = manager.setChannel(
          "13",
          "Salah Prayer notification",
          "Prayer notification channel",
          "salah_mansoor_az_ahrani");
      break;
    case 13:
      notificationDetails = manager.setChannel(
          "14",
          "Salah Prayer notification",
          "Prayer notification channel",
          "sheikh_jamac_hareed");
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
        ChangeNotifierProvider<DailyTimings>(
            create: (context) => DailyTimings()),
        ChangeNotifierProvider<SettingsProvider>(
            create: (context) => SettingsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Montserrat Alternates',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Pages(),
      ),
    );
  }
}

// home page
class Pages extends StatefulWidget {
  @override
  _PagesState createState() => _PagesState();
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
    await Permission.ignoreBatteryOptimizations.request();
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
  bool fileLoading = false;

  @override
  void initState() {
    super.initState();

    _waitFunction();
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
                  image: AssetImage('assets/quran.png'),
                  height: 300,
                ),
                Text(
                  "Al-Qur-an",
                  style: TextStyle(fontSize: 24),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
                Visibility(
                  visible: fileLoading,
                  child: Text(
                    "Getting files ready. Please wait",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _waitFunction() async {
    await downloadTranslation("prayer_time");
    await downloadTranslation("this");
    openHomeScreen();
  }

  Future _fileAlreadyDownloaded(String identifier) async {
    final Directory directory = Platform.isIOS
        ? await getLibraryDirectory()
        : await getExternalStorageDirectory();
    final File file = File('${directory.path}/$identifier.json');
    print("file exist: ${file.exists()}, ${file.path}");
    return await file.exists();
  }

  Future<File> downloadTranslation(String identifier) async {
    if (!await _fileAlreadyDownloaded(identifier)) {
      setState(() {
        fileLoading = true;
      });
      var response;
      print("112233 here");
      try {
        response =
            await http.get("http://api.alquran.cloud/v1/quran/$identifier");
        // response = await http.get(Uri.parse("http://api.alquran.cloud/v1/quran/$identifier"));
      } catch (e) {
        print("Error: $e");
      }
      if (response.statusCode == 200) {
        final Directory directory = Platform.isIOS
            ? await getLibraryDirectory()
            : await getExternalStorageDirectory();
        final File file = File('${directory.path}/$identifier.json');
        return await file.writeAsString(response.body);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
  }

  Position _position;
  DateTime time = DateTime.now();
  var prayerTimes;

  getTimes() async {
    var state = Provider.of<DailyTimings>(context, listen: false);
    var settingsState = Provider.of<SettingsProvider>(context, listen: false);
    print("valllll: " + settingsState.address);
    if (settingsState.address.isEmpty) {
      _position = await _determinePosition();
      state.setLat = _position.latitude;
      state.setLon = _position.longitude;
      settingsState.setLatitude(_position.latitude);
      settingsState.setLongitude(_position.longitude);
      state.setLocation =
          await placemarkFromCoordinates(state.getLat, state.getLon);
      print("called" +
          state.getLocation.first.subLocality +
          " " +
          state.getLocation.first.subAdministrativeArea);
      settingsState.setAddress(state.getLocation.first.subLocality +
          " " +
          state.getLocation.first.subAdministrativeArea);

      restartBackgroundFetch();
    } else {
      print("else working");
      state.setLat = settingsState.latitude;
      state.setLon = settingsState.longitude;
    }
    time = DateTime.now();
    String unixTime = (time.microsecondsSinceEpoch / 1000).toString();
    prayerTimes = await GetPrayerTimes().getPrayerTimes(
        timestamp: unixTime.toString(),
        lat: state.getLat.toString(),
        lon: state.getLon.toString(),
        method: settingsState.preferredCalculationMethod.toString(),
        madhab: settingsState.madhab.toString(),
        midnightMode: settingsState.midNightMode.toString(),
        hijriDateAdjustment: Utils()
            .getCalculatedHijriDate(settingsState.hijriDateAdjustment)
            .toString());
    state.setPrayerTimes = prayerTimes;
    state.setTodays = prayerTimes;

    /*getNext(state.getTodays);
    // getNext("11:55");

    setState(() {
      loading = false;
    });*/

    return prayerTimes;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    PermissionStatus permissionStatus = await Permission.location.request();
    print("112233 Error: $permissionStatus");

    if (permissionStatus.isGranted) {
      return await Geolocator.getCurrentPosition();
    } else {
      return Position(latitude: 0, longitude: 0);
    }
  }

  getPrayerTimes(
      {String timestamp,
      String lat,
      String lon,
      String method,
      String madhab,
      String midnightMode,
      String hijriDateAdjustment,
      String identifier}) async {
    if (!await _fileAlreadyDownloaded(identifier)) {
      setState(() {
        fileLoading = true;
      });

      var url =
          'http://api.aladhan.com/v1/timings/$timestamp?latitude=$lat&longitude=$lon&method=$method&school=$madhab&midnightMode=$midnightMode'
          '&adjustment=$hijriDateAdjustment';
      print("url: " + url.toString());
      var response = await http.get(url);
      // var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Directory directory = Platform.isIOS
            ? await getLibraryDirectory()
            : await getExternalStorageDirectory();
        final File file = File('${directory.path}/$identifier.json');
        return await file.writeAsString(response.body);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
  }

  openHomeScreen() {
    setState(() {
      fileLoading = false;
    });
    Timer(
        Duration(seconds: 2),
        () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => Pages())));
  }
}
