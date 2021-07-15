import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:islamic_prayer_times/model/prayer_times.dart';

class GetPrayerTimes {
  getPrayerTimes(
      {String timestamp,
      String lat,
      String lon,
      String method,
      String madhab,
      String midnightMode,
      String hijriDateAdjustment}) async {
    var url =
        'http://api.aladhan.com/v1/timings/$timestamp?latitude=$lat&longitude=$lon&method=$method&school=$madhab&midnightMode=$midnightMode'
        '&adjustment=$hijriDateAdjustment';
    print("url: " + url.toString());
    var response = await http.get(url);
    // var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var timings = jsonResponse['data']['timings'];
      var date = jsonResponse['data']['date'];
      return PrayerTimesModel(
        fajr: timings['Fajr'],
        sunrise: timings['Sunrise'],
        dhuhr: timings['Dhuhr'],
        asr: timings['Asr'],
        maghrib: timings['Maghrib'],
        isha: timings['Isha'],
        en_date: date['readable'],
        en_day: date['gregorian']['day'],
        en_month: date['gregorian']['month']['en'],
        en_weekday: date['gregorian']['weekday']['en'],
        en_year: date['gregorian']['year'],
        hijiri_date: date['hijri']['date'],
        hijiri_day: date['hijri']['day'],
        hijiri_month: date['hijri']['month']['en'],
        hijiri_weekday: date['hijri']['weekday']['en'],
        hijiri_year: date['hijri']['year'],
      );
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  getNextPrayer(
      {String timestamp,
      String lat,
      String lon,
      String method,
      String madhab,
      String midnightMode,
      String hijriDateAdjustment}) async {
    var url =
        'http://api.aladhan.com/v1/timings/$timestamp?latitude=$lat&longitude=$lon&method=$method&school=$madhab&midnightMode=$midnightMode'
        '&adjustment=$hijriDateAdjustment';
    var response = await http.get(url);
    // var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var timings = jsonResponse['data']['timings'];
      var date = jsonResponse['data']['date'];
      return PrayerTimesModel(
        fajr: timings['Fajr'],
        sunrise: timings['Sunrise'],
        dhuhr: timings['Dhuhr'],
        asr: timings['Asr'],
        maghrib: timings['Maghrib'],
        isha: timings['Isha'],
        en_date: date['readable'],
        en_day: date['gregorian']['day'],
        en_month: date['gregorian']['month']['en'],
        en_weekday: date['gregorian']['weekday']['en'],
        en_year: date['gregorian']['year'],
        hijiri_date: date['hijri']['date'],
        hijiri_day: date['hijri']['day'],
        hijiri_month: date['hijri']['month']['en'],
        hijiri_weekday: date['hijri']['weekday']['en'],
        hijiri_year: date['hijri']['year'],
      );
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  getMonthTimings(
      {String lat,
      String lon,
      String method,
      String madhab,
      String midnightMode,
      String hijriDateAdjustment,
      var month,
      var year}) async {
    var url =
        'http://api.aladhan.com/v1/hijriCalendar?latitude=$lat&longitude=$lon&method=$method&school=$madhab&midnightMode=$midnightMode'
        '&adjustment=$hijriDateAdjustment&month=$month&year=$year';
    print("monthlyURl: $url");
    var response = await http.get(url);
    // var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var timings = jsonResponse['data'];
      return timings;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}
