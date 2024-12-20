import 'package:flutter/material.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/constants.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/models.dart';

/// Models
class SelectedDateRange {
  DateTime? startDate;
  DateTime? endDate;
  String? rangeLabel;
  DateRangeTypes? rangeType;

  SelectedDateRange({
    this.startDate,
    this.endDate,
    this.rangeLabel,
    this.rangeType,
  });
}

/// Constants
enum DateRangeDefaults { thisWeek, thisMonth, thisYear }

Map<DateRangeDefaults, SelectedDateRange> defaultRanges = {
  DateRangeDefaults.thisWeek: SelectedDateRange(
    startDate: thisWeek,
    endDate: tomorrow,
    rangeLabel: "This Week",
    rangeType: DateRangeTypes.week,
  ),
  DateRangeDefaults.thisMonth: SelectedDateRange(
    startDate: thisMonth,
    endDate: tomorrow,
    rangeLabel: "This Month",
    rangeType: DateRangeTypes.month,
  ),
  DateRangeDefaults.thisYear: SelectedDateRange(
    startDate: thisYear,
    endDate: tomorrow,
    rangeLabel: "This Year",
    rangeType: DateRangeTypes.year,
  ),
};

/// Util Functions ==============================================

List<DropdownMenuItem<int>> getPickerYears(int firstYearPicker) {
  List<DropdownMenuItem<int>> yearDates = [];
  for (int year = now.year; year >= firstYearPicker; year--) {
    DateTime yearDate = DateTime(year, 1, 1);
    yearDates.add(DropdownMenuItem(
      value: yearDate.year,
      child: Text(yearFormat.format(yearDate)),
    ));
  }
  return yearDates;
}

List<DropdownMenuItem<int>> getPickerMonths(int selectedYear) {
  int monthCount = (selectedYear == now.year) ? now.month : allMonths.length;

  return List.generate(
    monthCount,
    (i) => DropdownMenuItem(
      value: i + 1,
      child: Text(allMonths[i]),
    ),
  );
}

List<DropdownMenuItem<int>> getPickerPeriodCounts(
    int maxMonthRange, String rangeLabel) {
  List<DropdownMenuItem<int>> monthRanges = [];
  for (int i = 1; i <= maxMonthRange; i++) {
    monthRanges.add(DropdownMenuItem(
      value: i,
      child: Text('$i $rangeLabel${i == 1 ? '' : 's'}'),
    ));
  }
  return monthRanges;
}

List<DropdownMenuItem<int>> getPickerDecades(int firstYearPicker) {
  List<DropdownMenuItem<int>> decades = [];
  int currentDecade = (now.year ~/ 10) * 10;
  int startDecade = (firstYearPicker ~/ 10) * 10;

  for (int decade = startDecade; decade <= currentDecade; decade += 10) {
    decades.add(DropdownMenuItem(
      value: decade,
      child: Text('${decade}s'),
    ));
  }

  return decades;
}

int getWeekNumberFromDate(DateTime date) {
  DateTime firstDayOfYear = DateTime(date.year, 1, 1);
  int daysDifference = date.difference(firstDayOfYear).inDays;
  int weekNumber = (daysDifference / 7).ceil() + 1;
  return weekNumber;
}

List<DateTime> getCalendarViewDays(DateTime date) {
  List<DateTime> dates = [];

  // 1. Add previous month days
  DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
  int startWeekday = firstDayOfMonth.weekday; // Monday = 1, Sunday = 7
  for (int i = 1; i < startWeekday; i++) {
    dates.add(firstDayOfMonth.subtract(Duration(days: startWeekday - i)));
  }
  // 2. Add the dates for the current month
  int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
  for (int day = 1; day <= daysInMonth; day++) {
    dates.add(DateTime(date.year, date.month, day));
  }
  // 3. Add post days
  DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
  int endWeekday = lastDayOfMonth.weekday;
  for (int i = 1; i <= (7 - endWeekday); i++) {
    dates.add(lastDayOfMonth.add(Duration(days: i)));
  }
  return dates;
}

List<DateTime> getCalendarViewWeeks(List<DateTime> monthDays) {
  List<DateTime> weekDates = [];
  for (int i = 0; i < monthDays.length; i += 7) {
    DateTime firstDayOfWeek = monthDays[i];
    weekDates.add(firstDayOfWeek);
    List<DateTime> weekChunk = monthDays.sublist(
        i, i + 7 > monthDays.length ? monthDays.length : i + 7);
    weekDates.addAll(weekChunk);
  }
  return weekDates;
}

List<DateTime> getCalendarViewMonths(int startYear) {
  return List.generate(12, (month) => DateTime(startYear, month + 1, 1));
}

DateTime getLastPeriodRangeDate(
    int range, DateTime startDate, DateRangeTypes rangeType) {
  DateTime lastRangeDate = now;

  switch (rangeType) {
    case DateRangeTypes.year:
      lastRangeDate = DateTime(startDate.year + range, 1, 1);
      break;
    case DateRangeTypes.month:
      lastRangeDate = DateTime(startDate.year, startDate.month + range, 1);
      break;
    case DateRangeTypes.week:
      lastRangeDate = DateTime(
          startDate.year, startDate.month, startDate.day + (range * 7));
      break;
    case DateRangeTypes.day:
      lastRangeDate =
          DateTime(startDate.year, startDate.month, startDate.day + range);
      break;
    default:
      lastRangeDate = now;
  }

  return lastRangeDate.isAfter(today) ? now : lastRangeDate;
}
