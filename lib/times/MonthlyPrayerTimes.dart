import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamic_prayer_times/model/prayer_times.dart';
import 'package:islamic_prayer_times/provider/daily_timings.dart';
import 'package:islamic_prayer_times/provider/settings_provider.dart';
import 'package:islamic_prayer_times/service/Utils.dart';
import 'package:islamic_prayer_times/service/get_prayer_times.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonthlyPrayerTimes extends StatefulWidget {
  @override
  _MonthlyPrayerTimesState createState() => _MonthlyPrayerTimesState();
}

class _MonthlyPrayerTimesState extends State<MonthlyPrayerTimes>
    with AutomaticKeepAliveClientMixin {
  bool loading = false;
  String hijiriMonth;
  String hijiriYear;

//38.9906657
//-77.026088

  getTimes() async {
    var state = Provider.of<DailyTimings>(context, listen: false);
    var settingsState = Provider.of<SettingsProvider>(context, listen: false);

    hijiriMonth = state.getPrayerTimes.hijiri_month;
    hijiriYear = state.getPrayerTimes.hijiri_year;

    state.setMonthlyPrayerTimes = await GetPrayerTimes().getMonthTimings(
      lat: state.getLat.toString(),
      lon: state.getLon.toString(),
      method: settingsState.preferredCalculationMethod.toString(),
      madhab: settingsState.madhab.toString(),
      midnightMode: settingsState.midNightMode.toString(),
      hijriDateAdjustment: Utils()
          .getCalculatedHijriDate(settingsState.hijriDateAdjustment)
          .toString(),
      month: hijiriMonth,
      year: hijiriYear,
    );

    return state.getMonthlyPrayerTimes;
  }

  getAnotherDay(String month, String year) async {
    var state = Provider.of<DailyTimings>(context, listen: false);
    var settingsState = Provider.of<SettingsProvider>(context, listen: false);

    state.setMonthlyPrayerTimes = await GetPrayerTimes().getMonthTimings(
      lat: state.getLat.toString(),
      lon: state.getLon.toString(),
      method: settingsState.preferredCalculationMethod.toString(),
      madhab: settingsState.madhab.toString(),
      midnightMode: settingsState.midNightMode.toString(),
      hijriDateAdjustment: Utils()
          .getCalculatedHijriDate(settingsState.hijriDateAdjustment)
          .toString(),
      month: month,
      year: year,
    );

    return state.getMonthlyPrayerTimes;
  }

  SharedPreferences sharedPrefs;

  initSharedPreference() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    getTimes();
    initSharedPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<DailyTimings>(context, listen: false);
    super.build(context);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
              children: [_month(state), _monthTimings()],
            ),
          ),
        ),
      ),
    );
  }

  Center _month(DailyTimings state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '${state.getTodays.hijiri_month} ${state.getTodays.hijiri_year}',
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  Expanded _monthTimings() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
            future: getTimes(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              List<dynamic> times = snapshot.data;
              return _daysInMonth(times);
            }),
      ),
    );
  }

  ListView _daysInMonth(List times) {
    return ListView.separated(
        separatorBuilder: (context, i) {
          return Divider(
            height: 5.0,
            thickness: 1,
            color: Colors.white,
          );
        },
        itemCount: times.length,
        itemBuilder: (context, i) {
          var timing = PrayerTimesModel().PrayerTimesModelFromJson(times[i]);
          return _day(timing);
        });
  }

  Container _day(timing) {
    return Container(
      height: 80.0,
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _dailyDate(timing),
            SizedBox(
              height: 10.0,
            ),
            _dailyTimes(timing)
          ],
        ),
      ),
    );
  }

  Row _dailyDate(timing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 20.0,
          width: 20.0,
          child: Center(
              child: Text(
            timing.hijiri_day,
            style: TextStyle(fontSize: 10),
          )),
          decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.circular(10)),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
          ),
          child: Text(timing.en_date),
        ),
      ],
    );
  }

  Row _dailyTimes(timing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        prayer('Fajr', timing.fajr),
        prayer('Sunrise', timing.sunrise),
        prayer('Dhuhr', timing.dhuhr),
        prayer('Asr', timing.asr),
        prayer('Maghrib', timing.maghrib),
        prayer('Isha', timing.isha)
      ],
    );
  }

  Column prayer(String name, String timing) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(fontSize: 10),
        ),
        Text(
          Utils().getFormattedDate(
              sharedPrefs.getBool("use24Hour") ?? true, timing.substring(0, 6)),
          style: TextStyle(fontSize: 10),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
