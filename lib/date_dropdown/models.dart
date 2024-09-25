import 'package:flutter/material.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:flutter_utils/extensions/date_extensions.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';

// enum DateRangeType { day, week, month, quarterYr, halfYr, year }

enum DateRangeTypes { day, week, month, monthRange, year }

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
  late final DateRangeTypes? type;
  TimePeriod({
    this.displayName = "This Month @start_date# ",
    this.value = 0,
    this.type = DateRangeTypes.month,
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
      return 'time_of_day';
    } else if (durationInDays <= 9) {
      return 'daily';
    } else if (durationInDays <= 35) {
      return 'week_year';
    } else if (durationInDays <= 140) {
      return 'month_year';
    } else if (durationInDays <= 370) {
      return 'quarter_year';
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
    return DateTime.now();
  }

  DateTime getDefaultEndDate() {
    return DateTime.now();
  }
}

DateTime getFirstDayOfCurrentWeek(DateTime date) {
  int daysToSubtract = date.weekday - DateTime.monday;
  // If today is Sunday, we subtract 6 days to get to the previous Monday
  if (daysToSubtract < 0) {
    daysToSubtract += 7;
  }
  DateTime firstDayOfWeek = date.subtract(Duration(days: daysToSubtract));
  return firstDayOfWeek;
}
