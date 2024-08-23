import 'package:flutter_utils/date_dropdown/models.dart';

var now = DateTime.now();

var dateRanges = [
  TimePeriod(
    displayName: 'Today',
    value: 1,
    startDate: () {
      return DateTime(now.year, now.month, now.day);
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day + 1);
    },
    type: DateRangeType.day,
  ),
  TimePeriod(
    displayName: 'Yesterday',
    value: 2,
    startDate: () {
      return DateTime(now.year, now.month, now.day - 1);
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day);
    },
    type: DateRangeType.day,
  ),
  TimePeriod(
    displayName: 'This Week',
    value: 3,
    // displayName: "Week of @start_date_display#",
    startDate: () {
      return getFirstDayOfCurrentWeek();
    },
    endDate: () {
      DateTime firstWeekDay = getFirstDayOfCurrentWeek();
      return firstWeekDay.add(const Duration(days: 7));
    },
    type: DateRangeType.week,
  ),
  TimePeriod(
    displayName: 'Last Week',
    value: 4,
    // displayName: "Week of @start_date_display#",
    startDate: () {
      DateTime firstWeekDay = getFirstDayOfCurrentWeek();
      return firstWeekDay.subtract(const Duration(days: 7));
    },
    endDate: () {
      return getFirstDayOfCurrentWeek();
    },
    type: DateRangeType.week,
  ),
  TimePeriod(
    displayName: "This Month",
    // displayName: "@start_date_display#",
    dateFormat: "MMMM y",
    value: 5,
    startDate: () {
      return DateTime(now.year, now.month, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month + 1, 1);
    },
    type: DateRangeType.month,
  ),
  TimePeriod(
    displayName: 'Last Month',
    // displayName: "@start_date_display#",
    dateFormat: "MMMM y",
    value: 6,
    startDate: () {
      return DateTime(now.year, now.month - 1, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month);
    },
    type: DateRangeType.month,
  ),
  TimePeriod(
    // displayName: 'Last Month But 2 :)',
    displayName: "@start_date_display#",
    dateFormat: "MMMM y",
    value: 7,
    startDate: () {
      return DateTime(now.year, now.month - 2, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month - 1);
    },
    type: DateRangeType.month,
  ),
  TimePeriod(
    // displayName: 'Last Month But 3 :)',
    displayName: "@start_date_display#",
    dateFormat: "MMMM y",
    value: 8,
    startDate: () {
      return DateTime(now.year, now.month - 3, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month - 2);
    },
    type: DateRangeType.month,
  ),
  TimePeriod(
    displayName: 'Last 3 months ',
    value: 9,
    startDate: () {
      return DateTime(now.year, now.month - 3, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day);
    },
    type: DateRangeType.quarterYr,
  ),
  TimePeriod(
    displayName: 'Last 6 months ',
    value: 10,
    dateFormat: "E, dd MMM,y",
    startDate: () {
      return DateTime(now.year, now.month - 6, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day);
    },
    type: DateRangeType.halfYr,
  ),
  TimePeriod(
    displayName: 'This Year',
    // displayName: "@start_date_display# - Today",
    dateFormat: "MMM y",
    value: 11,
    startDate: () {
      return DateTime(now.year, 1, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day + 1);
    },
    type: DateRangeType.year,
  ),
  TimePeriod(
    displayName: 'Last Year',
    // displayName: "@start_date_display# - @end_date_display#",
    dateFormat: "MMM y",
    value: 12,
    startDate: () {
      return DateTime(now.year - 1, 1, 1);
    },
    endDate: () {
      return DateTime(now.year, 1, 1);
    },
    type: DateRangeType.year,
  ),
];
