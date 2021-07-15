import 'package:intl/intl.dart';

class Utils {
  List<String> list = [
    "Two Days Ago",
    "One Day Ago",
    "None",
    "One Day Ahead",
    "Two Days Ahead"
  ];

  getCalculatedHijriDate(int itemIndex) {
    switch (itemIndex) {
      case 0:
        return -2;
      case 1:
        return -1;
      case 2:
        return 0;
      case 3:
        return 1;
      case 4:
        return 2;
      default:
        return 0;
    }
  }

  getFormattedDate(bool use24Hour, String dateToConvert) {
    return use24Hour
        ? dateToConvert
        : DateFormat("h:mm a")
            .format(DateFormat("HH:mm").parse(dateToConvert))
            .toString();
  }
}
