import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String get toWeekDayDate {
    return DateFormat("E, dd MMM hh:mm aaa").format(this);
  }

  String get toAPIDate {
    return DateFormat("yyyy-MM-dd").format(this);
  }

  String get toAPIDateTime {
    return DateFormat("yyyy-MM-ddTHH:mm").format(this);
  }

  String toDateTimeFormat(String format) {
    return DateFormat(format).format(this);
  }
}

extension StringDateExt on String {
  DateTime? get toDate {
    try {
      if (this.toLowerCase() == "today" || this.toLowerCase() == "now") {
        return DateTime.now();
      }

      var format = DateFormat("yyyy-MM-dd");
      return format.parse(this);
    } catch (e) {
      return null;
    }
  }
}
