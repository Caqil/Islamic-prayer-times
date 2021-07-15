class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String en_day;
  final String en_weekday;
  final String en_month;
  final String en_date;
  final String en_year;
  final String hijiri_day;
  final String hijiri_year;
  final String hijiri_weekday;
  final String hijiri_month;
  final String hijiri_date;

  PrayerTimesModel({
    this.fajr,
    this.sunrise,
    this.dhuhr,
    this.asr,
    this.maghrib,
    this.isha,
    this.en_day,
    this.en_weekday,
    this.en_month,
    this.en_date,
    this.en_year,
    this.hijiri_day,
    this.hijiri_year,
    this.hijiri_weekday,
    this.hijiri_month,
    this.hijiri_date,
  });

  // ignore: non_constant_identifier_names
  PrayerTimesModelFromJson(Map<String, dynamic> json) => PrayerTimesModel(
        fajr: json['timings']['Fajr'],
        sunrise: json['timings']['Sunrise'],
        dhuhr: json['timings']['Dhuhr'],
        asr: json['timings']['Asr'],
        maghrib: json['timings']['Maghrib'],
        isha: json['timings']['Isha'],
        en_date: json['date']['readable'],
        en_day: json['date']['gregorian']['day'],
        en_month: json['date']['gregorian']['month']['en'],
        en_weekday: json['date']['gregorian']['weekday']['en'],
        en_year: json['date']['gregorian']['year'],
        hijiri_date: json['date']['hijri']['date'],
        hijiri_day: json['date']['hijri']['day'],
        hijiri_month: json['date']['hijri']['month']['en'],
        hijiri_weekday: json['date']['hijri']['weekday']['en'],
        hijiri_year: json['date']['hijri']['year'],
      );
}
