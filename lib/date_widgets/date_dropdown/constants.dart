import 'package:flutter_utils/date_widgets/date_dropdown/models.dart';
import 'package:intl/intl.dart';

var now = DateTime.now();
DateTime today = DateTime(now.year, now.month, now.day);
DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
DateTime yesterday = today.subtract(const Duration(days: 1));
DateTime thisWeek = getFirstDayOfCurrentWeek(today);
DateTime lastWeek =
    getFirstDayOfCurrentWeek(today).subtract(const Duration(days: 7));
DateTime thisMonth = DateTime(now.year, now.month, 1);
DateTime lastMonth = DateTime(now.year, now.month - 1, 1);
DateTime thisYear = DateTime(now.year, 1, 1);
DateTime lastYear = DateTime(now.year - 1, 1, 1);

DateFormat monthFormat = DateFormat('MMM');
DateFormat yearFormat = DateFormat('yyyy');
List<String> monthsList = monthFormat.dateSymbols.STANDALONESHORTMONTHS;
List<String> allMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sept',
  'Oct',
  'Nov',
  'Dec'
];

const String kCustomTPKeyword = "Custom";

var defaultDateRanges = [
  TimePeriod(
    displayName: 'Today',
    type: DateRangeTypes.day,
    value: 1,
    startDate: () {
      return today;
    },
    endDate: () {
      return tomorrow;
    },
  ),
  TimePeriod(
    displayName: 'Yesterday',
    value: 2,
    type: DateRangeTypes.day,
    startDate: () {
      return yesterday;
    },
    endDate: () {
      return today;
    },
  ),
  TimePeriod(
    displayName: 'This Week',
    value: 3,
    type: DateRangeTypes.week,
    startDate: () {
      return thisWeek;
    },
    endDate: () {
      return tomorrow;
    },
  ),
  TimePeriod(
    displayName: 'Last Week',
    value: 4,
    type: DateRangeTypes.week,
    startDate: () {
      return lastWeek;
    },
    endDate: () {
      return getFirstDayOfCurrentWeek(today);
    },
  ),
  TimePeriod(
    // This Month
    displayName: "This Month",
    value: 5,
    type: DateRangeTypes.month,
    startDate: () {
      return thisMonth;
    },
    endDate: () {
      return DateTime(now.year, now.month + 1, 1);
    },
  ),
  TimePeriod(
    displayName: 'Last Month',
    value: 6,
    type: DateRangeTypes.month,
    startDate: () {
      return lastMonth;
    },
    endDate: () {
      return thisMonth;
    },
  ),
  TimePeriod(
    // displayName: 'Last Month But 2 :)',
    displayName: "@start_date_display#",
    dateFormat: "MMMM y",
    type: DateRangeTypes.month,
    value: 7,
    startDate: () {
      return DateTime(now.year, now.month - 2, 1);
    },
    endDate: () {
      return lastMonth;
    },
  ),
  TimePeriod(
    // displayName: 'Last Month But 3 :)',
    displayName: "@start_date_display#",
    dateFormat: "MMMM y",
    type: DateRangeTypes.month,
    value: 8,
    startDate: () {
      return DateTime(now.year, now.month - 3, 1);
    },
    endDate: () {
      return DateTime(now.year, now.month - 2);
    },
  ),
  TimePeriod(
    displayName: 'Last 3 months ',
    value: 9,
    type: DateRangeTypes.monthRange,
    startDate: () {
      return DateTime(now.year, now.month, 1 - 90);
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day);
    },
  ),
  TimePeriod(
    displayName: 'Last 6 months ',
    value: 10,
    type: DateRangeTypes.monthRange,
    startDate: () {
      return DateTime(now.year, now.month, 1 - 180);
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day);
    },
  ),
  TimePeriod(
    displayName: "This Year",
    type: DateRangeTypes.year,
    value: 11,
    startDate: () {
      return thisYear;
    },
    endDate: () {
      return DateTime(now.year, now.month, now.day + 1);
    },
  ),
  TimePeriod(
    displayName: "Last Year",
    type: DateRangeTypes.year,
    value: 12,
    startDate: () {
      return lastYear;
    },
    endDate: () {
      return thisYear;
    },
  ),
  TimePeriod(
    displayName: "All Time",
    type: DateRangeTypes.yearRange,
    value: 13,
    startDate: () {
      return DateTime(2015, 1, 1);
    },
    endDate: () {
      return today;
    },
  ),
  TimePeriod(
    displayName: kCustomTPKeyword,
    type: DateRangeTypes.year,
    value: 14,
    startDate: () {
      return today;
    },
    endDate: () {
      return today;
    },
  ),
];
