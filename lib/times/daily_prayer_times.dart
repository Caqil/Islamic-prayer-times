import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:islamic_prayer_times/main.dart';
import 'package:islamic_prayer_times/map.dart';
import 'package:islamic_prayer_times/provider/daily_timings.dart';
import 'package:islamic_prayer_times/provider/settings_provider.dart';
import 'package:islamic_prayer_times/service/Utils.dart';
import 'package:islamic_prayer_times/service/get_prayer_times.dart';
import 'package:islamic_prayer_times/settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyPrayerTimes extends StatefulWidget {
  @override
  _DailyPrayerTimesState createState() => _DailyPrayerTimesState();
}

class _DailyPrayerTimesState extends State<DailyPrayerTimes>
    with AutomaticKeepAliveClientMixin {
  DateTime time = DateTime.now();
  var prayerTimes;
  Position _position;
  List<Placemark> _location;
  String nextPrayer = '';
  String nextTime = '';
  var lat;
  var lon;
  bool loading = false;
  String prayerStatus = "Next";

  getTimes() async {
    setState(() {
      loading = true;
    });
    var settingsState = Provider.of<SettingsProvider>(context, listen: false);
    var state = Provider.of<DailyTimings>(context, listen: false);

    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

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

    getNext(state.getTodays);
    // getNext("11:55");

    setState(() {
      loading = false;
    });

    return prayerTimes;
  }

  getAnotherDay(String time) async {
    var state = Provider.of<DailyTimings>(context, listen: false);
    var settingsState = Provider.of<SettingsProvider>(context, listen: false);

    state.setPrayerTimes = await GetPrayerTimes().getNextPrayer(
        timestamp: time,
        lat: state.getLat.toString(),
        lon: state.getLon.toString(),
        method: settingsState.preferredCalculationMethod.toString(),
        madhab: settingsState.madhab.toString(),
        midnightMode: settingsState.midNightMode.toString(),
        hijriDateAdjustment: Utils()
            .getCalculatedHijriDate(settingsState.hijriDateAdjustment)
            .toString());
    return state.getPrayerTimes;
  }

  getNext(var prayerTimes) {
    final nowDateTime = DateTime.now();

    if (nowDateTime.isBefore(DateTime(
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        int.parse(prayerTimes.fajr.split(":")[0]),
        int.parse(prayerTimes.fajr.split(":")[1])))) {
      prayerStatus = "Next";
      nextTime = prayerTimes.fajr;
      nextPrayer = 'Fajr';
      return;
    }

    if (nowDateTime.isAfter(DateTime(
            nowDateTime.year,
            nowDateTime.month,
            nowDateTime.day,
            int.parse(prayerTimes.fajr.split(":")[0]),
            int.parse(prayerTimes.fajr.split(":")[1]))) &&
        nowDateTime.isBefore(DateTime(
                nowDateTime.year,
                nowDateTime.month,
                nowDateTime.day,
                int.parse(prayerTimes.fajr.split(":")[0]),
                int.parse(prayerTimes.fajr.split(":")[1]))
            .add(Duration(minutes: 15)))) {
      prayerStatus = "Current";
      nextTime = prayerTimes.fajr;
      nextPrayer = 'Fajr';
      return;
    }

    if (nowDateTime.isBefore(DateTime(
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        int.parse(prayerTimes.dhuhr.split(":")[0]),
        int.parse(prayerTimes.dhuhr.split(":")[1])))) {
      nextTime = prayerTimes.dhuhr;
      nextPrayer = 'Dhuhr';
      return;
    }

    if (nowDateTime.isAfter(DateTime(
            nowDateTime.year,
            nowDateTime.month,
            nowDateTime.day,
            int.parse(prayerTimes.dhuhr.split(":")[0]),
            int.parse(prayerTimes.dhuhr.split(":")[1]))) &&
        nowDateTime.isBefore(DateTime(
                nowDateTime.year,
                nowDateTime.month,
                nowDateTime.day,
                int.parse(prayerTimes.dhuhr.split(":")[0]),
                int.parse(prayerTimes.dhuhr.split(":")[1]))
            .add(Duration(minutes: 15)))) {
      prayerStatus = "Current";
      nextTime = prayerTimes.dhuhr;
      nextPrayer = 'Dhuhr';
      return;
    }

    if (nowDateTime.isBefore(DateTime(
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        int.parse(prayerTimes.asr.split(":")[0]),
        int.parse(prayerTimes.asr.split(":")[1])))) {
      nextTime = prayerTimes.asr;
      nextPrayer = 'Asr';
      return;
    }

    if (nowDateTime.isAfter(DateTime(
            nowDateTime.year,
            nowDateTime.month,
            nowDateTime.day,
            int.parse(prayerTimes.asr.split(":")[0]),
            int.parse(prayerTimes.asr.split(":")[1]))) &&
        nowDateTime.isBefore(DateTime(
                nowDateTime.year,
                nowDateTime.month,
                nowDateTime.day,
                int.parse(prayerTimes.asr.split(":")[0]),
                int.parse(prayerTimes.asr.split(":")[1]))
            .add(Duration(minutes: 15)))) {
      prayerStatus = "Current";
      nextTime = prayerTimes.asr;
      nextPrayer = 'Asr';
      return;
    }

    if (nowDateTime.isBefore(DateTime(
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        int.parse(prayerTimes.maghrib.split(":")[0]),
        int.parse(prayerTimes.maghrib.split(":")[1])))) {
      nextTime = prayerTimes.maghrib;
      nextPrayer = 'Maghrib';
      return;
    }

    if (nowDateTime.isAfter(DateTime(
            nowDateTime.year,
            nowDateTime.month,
            nowDateTime.day,
            int.parse(prayerTimes.maghrib.split(":")[0]),
            int.parse(prayerTimes.maghrib.split(":")[1]))) &&
        nowDateTime.isBefore(DateTime(
                nowDateTime.year,
                nowDateTime.month,
                nowDateTime.day,
                int.parse(prayerTimes.maghrib.split(":")[0]),
                int.parse(prayerTimes.maghrib.split(":")[1]))
            .add(Duration(minutes: 15)))) {
      prayerStatus = "Current";
      nextTime = prayerTimes.maghrib;
      nextPrayer = 'Maghrib';
      return;
    }

    if (nowDateTime.isBefore(DateTime(
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        int.parse(prayerTimes.isha.split(":")[0]),
        int.parse(prayerTimes.isha.split(":")[1])))) {
      nextTime = prayerTimes.isha;
      nextPrayer = 'Isha';
      return;
    }

    if (nowDateTime.isAfter(DateTime(
            nowDateTime.year,
            nowDateTime.month,
            nowDateTime.day,
            int.parse(prayerTimes.isha.split(":")[0]),
            int.parse(prayerTimes.isha.split(":")[1]))) &&
        nowDateTime.isBefore(DateTime(
                nowDateTime.year,
                nowDateTime.month,
                nowDateTime.day,
                int.parse(prayerTimes.isha.split(":")[0]),
                int.parse(prayerTimes.isha.split(":")[1]))
            .add(Duration(minutes: 15)))) {
      prayerStatus = "Current";
      nextTime = prayerTimes.isha;
      nextPrayer = 'Isha';
      return;
    }

    if (nowDateTime.isAfter(DateTime(
            nowDateTime.year,
            nowDateTime.month,
            nowDateTime.day,
            int.parse(prayerTimes.isha.split(":")[0]),
            int.parse(prayerTimes.isha.split(":")[1]))
        .add(Duration(minutes: 15)))) {
      prayerStatus = "Next";
      nextTime = prayerTimes.fajr;
      nextPrayer = 'Fajr';
      return;
    }
  }

  SharedPreferences sharedPrefs;

  initSharedPreference() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initSharedPreference();
    getTimes();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var height = MediaQuery.of(context).size.height;
    var state = Provider.of<DailyTimings>(context).getPrayerTimes;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: topSectionBackgroundColor(),
        mini: true,
        child: loading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Icon(Icons.refresh),
        onPressed: () => getTimes(),
      ),
      body: state == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => getTimes(),
              child: Center(
                child: Container(
                  height: height,
                  child: Stack(
                    children: [
                      topWidgets(height),
                      bottomWidgets(height),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SafeArea(
                            child: FloatingActionButton(
                              heroTag: "btn1",
                              backgroundColor: topSectionBackgroundColor(),
                              mini: true,
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) => Settings()))
                                    .then((value) async {
                                  getTimes();
                                  restartBackgroundFetch();
                                });
                              },
                              child: Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Color topSectionBackgroundColor() {
    if (nextPrayer == 'Fajr') return Colors.black45;
    if (nextPrayer == 'Dhuhr') return Colors.orangeAccent;
    if (nextPrayer == 'Asr') return Colors.deepOrangeAccent.shade200;
    if (nextPrayer == 'Maghrib') return Colors.blue;
    if (nextPrayer == 'Isha') return Colors.blueGrey.shade900;
  }

  Align topWidgets(double height) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: height / 2,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mosque.png'),
          ),
          color: topSectionBackgroundColor(),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  location(),
                  nextPrayerTime(height),
                  topRightDateDisplay()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Align location() {
    var settingState = Provider.of<SettingsProvider>(context, listen: false);

    return Align(
      alignment: Alignment.topLeft,
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) => MapScreen(),
        ))
            .then((value) {
          getTimes();
          restartBackgroundFetch();
        }),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.white,
            ),
            Text(
              // state.getLocation[0].locality,
              settingState.address.length > 20
                  ? settingState.address.substring(0, 20) + "..."
                  : settingState.address,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  nextPrayerTime(double height) {
    return Container(
      height: height / 4,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                prayerStatus,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                nextPrayer,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                Utils().getFormattedDate(
                    sharedPrefs.getBool("use24Hour") ?? true, nextTime),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 55.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Align bottomWidgets(double height) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height / 1.5,
          child: Stack(
            children: [
              _dayTimings(height),
              dateSwitchWidget(),
            ],
          ),
        ));
  }

  Align _dayTimings(double height) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: height / 1.6,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0), topLeft: Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
          child: timings(),
        ),
      ),
    );
  }

  timings() {
    var times = Provider.of<DailyTimings>(context).getPrayerTimes;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          prayerTimeTile(prayer: 'Fajr', time: '${times.fajr}'),
          prayerTimeTile(prayer: 'Sunrise', time: '${times.sunrise}'),
          prayerTimeTile(prayer: 'Dhuhr', time: '${times.dhuhr}'),
          prayerTimeTile(prayer: 'Asr', time: '${times.asr}'),
          prayerTimeTile(prayer: 'Maghrib', time: '${times.maghrib}'),
          prayerTimeTile(prayer: 'Isha', time: '${times.isha}')
        ],
      ),
    );
  }

  Padding dateSwitchWidget() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 40.0,
        right: 40.0,
      ),
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      time = time.subtract(new Duration(days: 1));
                      String formatted =
                          DateFormat('dd-MM-yyyy').format(time).toString();
                      getAnotherDay(formatted);
                    },
                    child: Container(child: Icon(Icons.navigate_before))),
                switchDate(),
                GestureDetector(
                    onTap: () {
                      time = time.add(new Duration(days: 1));
                      String formatted =
                          DateFormat('dd-MM-yyyy').format(time).toString();
                      getAnotherDay(formatted);
                    },
                    child: Container(child: Icon(Icons.navigate_next))),
              ],
            )),
      ),
    );
  }

  Padding switchDate() {
    var times = Provider.of<DailyTimings>(context).getPrayerTimes;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              '${times.hijiri_day} ${times.hijiri_month} ${times.hijiri_year} AH',
              style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '${times.en_date}',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Align topRightDateDisplay() {
    var state = Provider.of<DailyTimings>(context, listen: false).getTodays;

    return Align(
      alignment: Alignment.topRight,
      child: Column(
        children: [
          Text(
            '${state.hijiri_day} ${state.hijiri_month} ${state.hijiri_year} AH',
            style: TextStyle(color: Colors.white, fontSize: 10.0),
          ),
          Text(
            '${state.hijiri_weekday}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            '${state.en_weekday}',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          Text(
            '${state.en_date}',
            style: TextStyle(color: Colors.white, fontSize: 10.0),
          ),
        ],
      ),
    );
  }

  prayerTimeTile({String prayer, String time}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey)),
        child: ListTile(
          leading: Text(
            prayer,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          trailing: Container(
            width: 100.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  Utils().getFormattedDate(
                      sharedPrefs.getBool("use24Hour") ?? true, time),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                // Icon(Icons.access_time)
              ],
            ),
          ),
        ),
      ),
    );
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
