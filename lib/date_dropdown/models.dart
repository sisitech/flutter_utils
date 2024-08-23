import 'package:flutter/material.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:flutter_utils/extensions/date_extensions.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';

class TimePeriod {
  late DateTime Function()? startDateFunc;
  late DateTime Function()? endDateFunc;
  late final String displayName;
  late final String dateFormat;
  late final int value;

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

  TimePeriod({
    this.displayName = "This Month @start_date# ",
    this.value = 0,
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
