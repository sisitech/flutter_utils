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
}
