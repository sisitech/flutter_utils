import 'package:flutter/material.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:flutter_utils/extensions/date_extensions.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:intl/intl.dart';

enum DateRangeType { day, week, month, quarterYr, halfYr, year }

///[TimePeriod]
/// Extra Classes:
///- The timeIntervals concept: Returns a list of endDateTime in millisecondsSinceEpoch
/// - Hour … List of ed for each 2 hours
/// - Week … List of ed for each day
/// - Month … List of ed for each week
/// - Year … List of ed for each month
class TimePeriod {
  late DateTime Function()? startDateFunc;
  late DateTime Function()? endDateFunc;
  late final String displayName;
  late final String dateFormat;
  late final int value;
  late final DateRangeType? type;
  DateTime? prevStartDate;
  List<int>?
      timeIntervals; // list of timeInterval endDates in millisecondsSinceEpoch
  List<String>? intervalLabels;
  TimePeriod({
    this.displayName = "This Month @start_date# ",
    this.value = 0,
    this.type = DateRangeType.month,
    DateTime Function()? startDate,
    DateTime Function()? endDate,
    this.dateFormat = "E, dd MMM",
    bool allowAll = false,
  }) {
    if (allowAll) {
    } else if (startDate != null) {
      startDateFunc = startDate;
    } else {
      startDateFunc = getDefaultStartDate;
    }
    if (allowAll) {
    } else if (endDate != null) {
      endDateFunc = endDate;
    } else {
      endDateFunc = getDefaultEndDate;
    }
    prevStartDate = getPrevStartDate(startDateFunc!(), type!);
    timeIntervals = getTimePeriodIntervals(startDateFunc!(), type!);
    intervalLabels = getIntervalLabels(timeIntervals!, type!);
  }

  String getGroupingType() {
    if (startDateFunc == null && endDateFunc == null) {
      return "id";
    }
    DateTime startDate = startDateFunc!();
    DateTime endDate = endDateFunc!();
    return _getDurationCategory(startDate, endDate);
  }

  String _getDurationCategory(DateTime startDate, DateTime endDate) {
    // Calculate the duration between the two dates
    Duration duration = endDate.difference(startDate);
    int durationInDays = duration.inDays;

    // Apply the rules in order
    if (durationInDays <= 1) {
      return 'hourly_8';
    } else if (durationInDays <= 9) {
      return 'daily';
    } else if (durationInDays <= 35) {
      return 'week_year';
    } else if (durationInDays <= 370) {
      return 'month_year';
    } else {
      return 'year';
    }
  }

  DropdownMenuItem<int> get dropDownItem {
    return DropdownMenuItem(
      value: value,
      child: Text(displayName.ctr.interpolate(toJson() ?? {})),
    );
  }

  Map<String, dynamic>? toJson() {
    try {
      var startDate = startDateFunc!();
      var endDate = endDateFunc!();
      return {
        "start_date": startDate,
        "end_date": endDate,
        "start_date_display": startDate.toDateTimeFormat(dateFormat),
        "end_date_display":
            DateTime(endDate.year, endDate.month, endDate.day - 1)
                .toDateTimeFormat(dateFormat)
      };
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }

  get displayText {
    return displayName.ctr.interpolate(toJson() ?? {});
  }

  get queryFilters {
    var filters = [];
    DateTime? endDate;
    DateTime? startDate;
    if (startDateFunc != null) {
      startDate = startDateFunc!();
      filters.add("date > ${startDate.toAPIDate}");
    }
    if (endDateFunc != null) {
      endDate = endDateFunc!();
      filters.add("date < ${endDate.toAPIDate}");
    }
    if (filters.length == 1) {
      return filters.join(" AND ");
    }
    return "date BETWEEN ${startDate?.toAPIDate} AND ${endDate?.toAPIDate}";
  }

  DateTime getDefaultStartDate() {
    return getTheFirstDayOfMonth(DateTime.now());
  }

  DateTime getDefaultEndDate() {
    return getTheLastDayOfMonth(DateTime.now());
  }
}

DateTime getTheLastDayOfMonth(DateTime date) {
  DateTime now = DateTime.now();
  DateTime firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
  debugPrint('$firstDayOfNextMonth');
  return DateTime(firstDayOfNextMonth.year, firstDayOfNextMonth.month,
      firstDayOfNextMonth.day);
}

DateTime getTheFirstDayOfMonth(DateTime date) {
  DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
  return firstDayOfMonth;
}

/// Range Functions
DateTime getPrevStartDate(DateTime startDate, DateRangeType type) {
  switch (type) {
    case DateRangeType.day:
      return DateTime(startDate.year, startDate.month, startDate.day - 1);
    case DateRangeType.week:
      return DateTime(startDate.year, startDate.month, startDate.day - 7);
    case DateRangeType.month:
      return DateTime(startDate.year, startDate.month - 1, 1);

    case DateRangeType.quarterYr:
      return DateTime(startDate.year, startDate.month - 3, 1);

    case DateRangeType.halfYr:
      return DateTime(startDate.year, startDate.month - 6, 1);

    case DateRangeType.year:
      return DateTime(startDate.year - 1, 1, 1);
    default:
      return startDate;
  }
}

List<int> getTimePeriodIntervals(DateTime startDate, DateRangeType type) {
  int yearRangeIdx = 4;
  switch (type) {
    case DateRangeType.day:
      return List.generate(13,
          (i) => startDate.add(Duration(hours: i * 2)).millisecondsSinceEpoch);
    case DateRangeType.week:
      return List.generate(
          8, (i) => startDate.add(Duration(days: i)).millisecondsSinceEpoch);
    case DateRangeType.month:
      return List.generate(5,
          (i) => startDate.add(Duration(days: i * 7)).millisecondsSinceEpoch);
    case DateRangeType.quarterYr:
      yearRangeIdx = 4;
      break;
    case DateRangeType.halfYr:
      yearRangeIdx = 7;
      break;
    case DateRangeType.year:
      yearRangeIdx = 13;
      break;
  }
  return List.generate(
      yearRangeIdx,
      (i) => DateTime(startDate.year, startDate.month + i, startDate.day)
          .millisecondsSinceEpoch);
}

List<String> getIntervalLabels(
    List<int> timeIntervals, DateRangeType rangeType) {
  switch (rangeType) {
    case DateRangeType.day:
      return dayTitles;
    case DateRangeType.week:
      return weekDayTitles;
    case DateRangeType.month:
      return timeIntervals
          .map((e) =>
              "Week ${getWeekNumber(DateTime.fromMillisecondsSinceEpoch(e))}")
          .toList()
          .sublist(0, timeIntervals.length - 1);
    case DateRangeType.year:
      return yearMonthTitles;
    case DateRangeType.quarterYr:
      break;
    case DateRangeType.halfYr:
      break;
  }
  return timeIntervals
      .map((e) =>
          DateFormat("MMMM").format(DateTime.fromMillisecondsSinceEpoch(e)))
      .toList()
      .sublist(0, timeIntervals.length - 1);
}

DateTime getFirstDayOfCurrentWeek() {
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int daysToSubtract = today.weekday - DateTime.monday;
  // If today is Sunday, we subtract 6 days to get to the previous Monday
  if (daysToSubtract < 0) {
    daysToSubtract += 7;
  }
  DateTime firstDayOfWeek = today.subtract(Duration(days: daysToSubtract));
  return firstDayOfWeek;
}

int getWeekNumber(DateTime date) {
  DateTime firstDayOfYear = DateTime(date.year, 1, 1);
  int daysDifference = date.difference(firstDayOfYear).inDays;
  int weekNumber = (daysDifference / 7).ceil() + 1;
  return weekNumber;
}

List<String> dayTitles = [
  '0h',
  '2h',
  '4h',
  '6h',
  '8h',
  '10h',
  '12h',
  '14h',
  '16h',
  '18h',
  '20h',
  '22h',
  '24h'
];
List<String> weekDayTitles = ['Mn', 'Te', 'Wd', 'Th', 'Fr', 'St', 'Su'];
List<String> monthWeekTitles = ['Week'];
List<String> yearMonthTitles = [
  'Jn',
  'Fb',
  'Mr',
  'Ap',
  'My',
  'Jun',
  'Jl',
  'Ag',
  'Sp',
  'Oc',
  'Nv',
  'Dc'
];
