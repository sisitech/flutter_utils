import 'package:flutter_utils/date_dropdown/models.dart';

var now = DateTime.now();

var dateRanges = [
  TimePeriod(
    displayName: 'Today',
    value: 1,
    startDate: () {
      var now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    },
    endDate: () {
      var now = DateTime.now();
      return DateTime(now.year, now.month, now.day + 1);
    },
  ),
  TimePeriod(
    displayName: 'Yesterday',
    value: 2,
    startDate: () {
      var now = DateTime.now();
      return DateTime(now.year, now.month, now.day - 1);
    },
    endDate: () {
      var now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    },
  ),
  TimePeriod(
    displayName: 'Last 7 Days',
    value: 3,
    // displayName: "Week of @start_date_display#",
    startDate: () {
      var now = DateTime.now();
      return DateTime(now.year, now.month, now.day - 7);
    },
    endDate: () {
      var now = DateTime.now();
      return DateTime(now.year, now.month, now.day + 1);
    },
  ),
  TimePeriod(
    // displayName: "This Month",
    displayName: "@start_date_display#",
    dateFormat: "MMMM y",
    value: 4,
    startDate: () {
      var now = DateTime.now();
      return DateTime(now.year, now.month, 1);
    },
    endDate: () {
      var now = DateTime.now();
      return DateTime(now.year, now.month + 1, 1);
    },
  ),
  TimePeriod(
    // displayName: 'Last Month',
    displayName: "@start_date_display#",
    dateFormat: "MMMM y",
    value: 5,
    startDate: () {
      var now = DateTime.now();
      return DateTime(now.year, now.month - 1, 1);
    },
    endDate: () {
      var now = DateTime.now();
      return DateTime(now.year, now.month);
    },
  ),
  TimePeriod(
    // displayName: 'Last Month But 2 :)',
    displayName: "@start_date_display#",
    dateFormat: "MMMM y",
    value: 11,
    startDate: () {
      return DateTime(now.year, now.month - 2, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month - 1);
    },
  ),
  TimePeriod(
    // displayName: 'Last Month But 3 :)',
    displayName: "@start_date_display#",
    dateFormat: "MMMM y",
    value: 10,
    startDate: () {
      return DateTime(now.year, now.month - 3, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month - 2);
    },
  ),
  TimePeriod(
    displayName: 'Last 3 months ',
    value: 6,
    startDate: () {
      return DateTime(now.year, now.month, 1 - 90);
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day);
    },
  ),
  TimePeriod(
    displayName: 'Last 6 months ',
    value: 7,
    dateFormat: "E, dd MMM,y",
    startDate: () {
      return DateTime(now.year, now.month, 1 - 180);
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day);
    },
  ),
  TimePeriod(
    // displayName: 'This Year',
    // displayName: "@start_date_display#",
    displayName: "@start_date_display# - Today",

    dateFormat: "MMM y",
    value: 8,

    startDate: () {
      return DateTime(now.year, 1, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day + 1);
    },
  ),
  TimePeriod(
    // displayName: 'Last 1 Year',
    displayName: "@start_date_display# - @end_date_display#",
    dateFormat: "MMM y",
    value: 9,
    startDate: () {
      return DateTime(now.year - 1, 1, 1);
    },
    endDate: () {
      return DateTime(now.year, 1, 1);
    },
  ),
];
