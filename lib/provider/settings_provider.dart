import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  int hijriDateAdjustment = 2;
  int preferredCalculationMethod = 2;
  int midNightMode = 0;
  bool use24Hour = true;
  bool enableNotifications = true;
  int madhab = 0;
  int notificationMode = 0;

  double latitude = 0.0;
  double longitude = 0.0;
  String address = "";

  SettingsProvider() {
    print("112233, settingprovider called");
    setInitialValueFromStorage();
  }

  Future<void> setInitialValueFromStorage() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    hijriDateAdjustment = sharedPrefs.getInt("hijri") ?? 2;
    preferredCalculationMethod =
        sharedPrefs.getInt("preferredCalculationMethod") ?? 2;
    midNightMode = sharedPrefs.getInt("midNightMode") ?? 0;
    use24Hour = sharedPrefs.getBool("use24Hour") ?? true;
    enableNotifications = sharedPrefs.getBool("enableNotifications") ?? true;
    madhab = sharedPrefs.getInt("madhab") ?? 0;
    notificationMode = sharedPrefs.getInt("notificationMode") ?? 0;

    latitude = sharedPrefs.getDouble("latitude") ?? 0.0;
    longitude = sharedPrefs.getDouble("longitude") ?? 0.0;
    address = sharedPrefs.getString("address") ?? "";

    // var add = sharedPrefs.getString("address") ?? "";
    print("112233, add: "+address);

    notifyListeners();
  }

  Future<bool> shouldUse24Hour() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    bool use24Hour = sharedPrefs.getBool("use24Hour") ?? true;
    return use24Hour;
  }

  Future<void> setHijriDate(int difference) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt("hijri", difference);
    hijriDateAdjustment = difference;
    notifyListeners();
  }

  Future<void> setPreferredCalculationMethod(int methodNo) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt("preferredCalculationMethod", methodNo);
    preferredCalculationMethod = methodNo;
    notifyListeners();
  }

  Future<void> setMidNightMode(int mode) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt("midNightMode", mode);
    midNightMode = mode;
    notifyListeners();
  }

  Future<void> setUse24Hour(bool value) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool("use24Hour", value);
    use24Hour = value;
    notifyListeners();
  }

  Future<void> setEnableNotifications(bool value) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool("enableNotifications", value);
    enableNotifications = value;
    notifyListeners();
  }

  Future<void> setLatitude(double latitude) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setDouble("latitude", latitude);
    this.latitude = latitude;
    notifyListeners();
  }

  Future<void> setLongitude(double longitude) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setDouble("longitude", longitude);
    this.longitude = longitude;
    notifyListeners();
  }

  Future<void> setAddress(String address) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("address", address);
    this.address = address;
    notifyListeners();
  }

  Future<void> setMadhab(int madhab) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt("madhab", madhab);
    this.madhab = madhab;
    notifyListeners();
  }

  Future<void> setNotificationMode(int notificationMode) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt("notificationMode", notificationMode);
    this.notificationMode = notificationMode;
    notifyListeners();
  }
}
