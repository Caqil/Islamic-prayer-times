import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class DailyTimings with ChangeNotifier {
  //location settings
  Position _position;
  List<Placemark> _location;
  var _lat;
  var _lon;

  Position get getPosition => _position;
  set setPosition(Position value) {
    _position = value;
  }

  List<Placemark> get getLocation => _location;

  set setLocation(List<Placemark> value) {
    _location = value;
  }

  get getLat => _lat;

  set setLat(value) {
    _lat = value;
  }

  get getLon => _lon;

  set setLon(value) {
    _lon = value;
  }

  // daily
  var _prayerTimes;
  var _todays;

  get getTodays => _todays;

  set setTodays(value) {
    _todays = value;
  }

  get getPrayerTimes => _prayerTimes;

  set setPrayerTimes(value) {
    _prayerTimes = value;
    notifyListeners();
  }

  //monthly
  var _monthlyPrayerTimes;

  get getMonthlyPrayerTimes => _monthlyPrayerTimes;

  set setMonthlyPrayerTimes(value) {
    _monthlyPrayerTimes = value;
    notifyListeners();
  }
}
