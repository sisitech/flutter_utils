import 'package:flutter/material.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/constants.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/models.dart';
import 'package:intl/intl.dart';

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

const List<String> monthNames = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

const List<String> monthShortNames = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "June",
  "July",
  "Aug",
  "Sept",
  "Oct",
  "Nov",
  "Dec"
];

Widget getMonthBtns({
  required ThemeData theme,
  required Function(int month) action,
}) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: monthShortNames
          .asMap()
          .entries
          .map(
            (e) => GestureDetector(
              onTap: () => action(e.key),
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Chip(
                  label: Text(
                    e.value,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

/// Widgets

Widget getSelectedDatesWidget({
  SelectedDateRange? dateRange,
  required ThemeData theme,
  required DateFormat dateFormat,
}) {
  final textTheme = theme.textTheme;
  final colorScheme = theme.colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          dateRange?.rangeLabel ?? "Select Date Range",
          style: textTheme.titleLarge!.copyWith(
            color: colorScheme.primary,
          ),
        ),
      ),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "Selected: ",
              style:
                  textTheme.labelSmall!.copyWith(color: colorScheme.secondary),
            ),
            TextSpan(
              text: dateRange?.startDate == null
                  ? "__\\__\\__"
                  : dateFormat.format(dateRange?.startDate ?? now),
              style: textTheme.labelMedium,
            ),
            TextSpan(
              text: " to ",
              style:
                  textTheme.labelSmall!.copyWith(color: colorScheme.secondary),
            ),
            TextSpan(
              text: dateRange?.endDate == null
                  ? "__\\__\\__"
                  : dateFormat.format(
                      dateRange?.endDate?.subtract(const Duration(days: 1)) ??
                          now),
              style: textTheme.labelMedium,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget buildActionChip({
  required ThemeData theme,
  String? title,
  required String label,
  Function()? onDelete,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Chip(
      label: Text.rich(
        TextSpan(
          children: [
            if (title != null) TextSpan(text: title),
            TextSpan(text: label),
          ],
          style: theme.textTheme.bodySmall,
        ),
      ),
      onDeleted: onDelete,
    ),
  );
}

buildDayHeaders(ThemeData theme) {
  List<String> daysOfWeek =
      DateFormat('EEE').dateSymbols.STANDALONESHORTWEEKDAYS;
  daysOfWeek = daysOfWeek.sublist(1)
    ..add(daysOfWeek.first); // make Mon the 1st day
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: daysOfWeek.asMap().entries.map((entry) {
      int idx = entry.key;
      String day = daysOfWeek[idx];
      return Text(day,
          style: theme.textTheme.labelMedium!
              .copyWith(color: theme.colorScheme.primary));
    }).toList(),
  );
}

/// Functions

int getWeekNumberFromDate(DateTime date) {
  DateTime firstDayOfYear = DateTime(date.year, 1, 1);
  int daysDifference = date.difference(firstDayOfYear).inDays;
  int weekNumber = (daysDifference / 7).ceil() + 1;
  return weekNumber;
}

SelectedDateRange? getDateRange(List<DateTime> dates) {
  if (dates.isEmpty) return null;

  final DateTime startDate = dates.first;
  final DateTime endDate = dates.last.add(const Duration(days: 1));
  final DateTime shownEndDate = dates.last;
  final int dayCount = endDate.difference(startDate).inDays;

  final DateRangeTypes rangeType = dayCount < 7
      ? DateRangeTypes.day
      : dayCount < 28
          ? DateRangeTypes.week
          : dayCount <= 31
              ? DateRangeTypes.month
              : dayCount < 365
                  ? DateRangeTypes.monthRange
                  : dayCount == 365 || dayCount == 366
                      ? DateRangeTypes.year
                      : DateRangeTypes.yearRange;

  String? rangeLabel;
  switch (rangeType) {
    case DateRangeTypes.day:
      rangeLabel = dayCount > 1
          ? "${dayFormat.format(startDate)} to ${dayFormat.format(shownEndDate)}"
          : dateToLabelMap[rangeType]?[startDate] ??
              DateFormat('EEE, dd/MMM/yy').format(startDate);
      break;

    case DateRangeTypes.week:
      rangeLabel = dayCount == 7
          ? (dateToLabelMap[rangeType]?[startDate] ??
              "Week ${getWeekNumberFromDate(startDate)}")
          : "Week ${getWeekNumberFromDate(startDate)} to Week ${getWeekNumberFromDate(shownEndDate)}";

      break;

    case DateRangeTypes.month:
      rangeLabel = dateToLabelMap[rangeType]?[startDate] ??
          DateFormat('MMMM').format(startDate);
      break;
    case DateRangeTypes.monthRange:
      rangeLabel =
          "${monthFormat.format(startDate)} to ${monthFormat.format(shownEndDate)}";
      break;

    case DateRangeTypes.year:
      rangeLabel =
          dateToLabelMap[rangeType]?[startDate] ?? yearFormat.format(startDate);
      break;
    case DateRangeTypes.yearRange:
      rangeLabel =
          "${yearFormat.format(startDate)} to ${yearFormat.format(shownEndDate)}";
      break;

    default:
  }

  return SelectedDateRange(
    startDate: startDate,
    endDate: endDate,
    rangeType: rangeType,
    rangeLabel: rangeLabel,
  );
}

Map<int, List<DateTime>> groupDatesByMonth(int year) {
  Map<int, List<DateTime>> groupedDates = {};
  DateTime today = DateTime.now();
  int thisYear = today.year;
  int lastYearMonth = year == thisYear ? today.month : 12;

  for (int month = 1; month <= lastYearMonth; month++) {
    List<DateTime> dates = [];
    DateTime current = DateTime(year, month, 1);

    while (current.month == month) {
      if (current.isAfter(today)) {
        break;
      }

      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    groupedDates[month] = dates;
  }
  return groupedDates;
}
