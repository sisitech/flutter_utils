import 'package:flutter/material.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/constants.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/models.dart';
import 'package:flutter_utils/date_widgets/date_range_picker/utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Widget Functions ==============================================

Widget getDayWeekView({
  required DateRangeTypes rangeType,
  required DateTime currentPickerDt,
  required Function(DateTime day) onDaySelected,
  required Function(DateTime startWeekDay) onWeekSelected,
  required List<DateTime> selectedDays,
}) {
  List<DateTime> calendarDayDates = getCalendarViewDays(
      DateTime(currentPickerDt.year, currentPickerDt.month, 1));
  List<DateTime> calendarWeekDates = getCalendarViewWeeks(calendarDayDates);

  return Column(
    children: [
      _buildDayHeaders(rangeType == DateRangeTypes.week),
      GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rangeType == DateRangeTypes.week ? 8 : 7,
        ),
        itemCount: (rangeType == DateRangeTypes.week
                ? calendarWeekDates
                : calendarDayDates)
            .length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          DateTime date = rangeType == DateRangeTypes.week
              ? calendarWeekDates[index]
              : calendarDayDates[index];
          return Obx(
            () => _buildDayItem(
              date: date,
              dateIdx: index,
              currentPickers: currentPickerDt,
              isWeekView: rangeType == DateRangeTypes.week,
              isSelected: selectedDays.contains(date),
              onDateSelected: rangeType == DateRangeTypes.week
                  ? onWeekSelected
                  : onDaySelected,
            ),
          );
        },
      ),
    ],
  );
}

Widget _buildDayHeaders(bool isWeekView) {
  List<String> daysOfWeek =
      DateFormat('EEE').dateSymbols.STANDALONESHORTWEEKDAYS;
  daysOfWeek = daysOfWeek.sublist(1)
    ..add(daysOfWeek.first); // make Mon the 1st day

  if (isWeekView) {
    daysOfWeek = ["WK", ...daysOfWeek];
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: daysOfWeek.asMap().entries.map((entry) {
      int idx = entry.key;
      String day = daysOfWeek[idx];
      return Text(day,
          style: Get.theme.textTheme.labelMedium!.copyWith(
              color: isWeekView && idx > 0
                  ? Get.theme.colorScheme.onBackground
                  : Get.theme.colorScheme.primary));
    }).toList(),
  );
}

Widget _buildDayItem({
  required DateTime currentPickers,
  required DateTime date,
  required Function(DateTime val) onDateSelected,
  required bool? isSelected,
  required bool isWeekView,
  required int dateIdx,
}) {
  final theme = Get.theme;
  List<int> weekIndices = [0, 8, 16, 24, 32, 40]; // startWeekDates Indices
  bool isNotInCurrentPickerDate = date.isBefore(currentPickers) ||
      date.isAfter(
          DateTime(currentPickers.year, currentPickers.month + 1, 0)) ||
      date.isAfter(now);
  bool isSelectedDate = isSelected == true && !date.isAfter(now);
  return GestureDetector(
    onTap: () {
      if (date.isAfter(now)) return;
      if (isWeekView && !weekIndices.contains(dateIdx)) {
        onDateSelected(getFirstDayOfCurrentWeek(date));
        return;
      }
      onDateSelected(date);
    },
    child: Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelectedDate
              ? theme.colorScheme.secondaryContainer
              : Colors.transparent,
        ),
        color: isSelectedDate
            ? isWeekView && weekIndices.contains(dateIdx)
                ? theme.colorScheme.secondaryContainer
                : Colors.transparent
            : null,
      ),
      child: Center(
        child: Text(
          isWeekView && weekIndices.contains(dateIdx)
              ? getWeekNumberFromDate(date).toString()
              : "${date.day}",
          style: theme.textTheme.labelSmall!.copyWith(
            color: isSelectedDate
                ? theme.colorScheme.onSecondaryContainer
                : isWeekView && weekIndices.contains(dateIdx)
                    ? theme.colorScheme.secondary
                    : isNotInCurrentPickerDate
                        ? theme.colorScheme.outline
                        : theme.colorScheme.onBackground,
            fontWeight: isSelectedDate ? FontWeight.bold : null,
          ),
        ),
      ),
    ),
  );
}

///
Widget getMonthView({
  required DateRangeTypes rangeType,
  required int currentPickerYr,
  required int selectedMonthRange,
  required List<DateTime> startEndMonthDates,
  required Function(DateTime startMonth, DateTime lastMonth) onMonthsSelected,
}) {
  List<DateTime> calendarMonthDates = getCalendarViewMonths(currentPickerYr);

  return GridView.builder(
    gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
    itemCount: monthsList.length,
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemBuilder: (context, index) {
      DateTime month = calendarMonthDates[index];
      return Obx(
        () => _buildMonthItem(
          date: month,
          isStartMonth: startEndMonthDates.isEmpty
              ? false
              : startEndMonthDates.first == month,
          isSelected: startEndMonthDates.isEmpty
              ? false
              : month == startEndMonthDates.first ||
                  (month.isAfter(startEndMonthDates.first) &&
                      month.isBefore(startEndMonthDates.last)),
          onMonthsSelected: onMonthsSelected,
          selectedMonthRange: selectedMonthRange,
          currentPickerYr: currentPickerYr,
          startEndMonthDates: startEndMonthDates,
        ),
      );
    },
  );
}

Widget _buildMonthItem({
  required bool isStartMonth,
  required int currentPickerYr,
  required bool isSelected,
  required DateTime date,
  required int selectedMonthRange,
  required List<DateTime> startEndMonthDates,
  required Function(DateTime startMonth, DateTime lastMonth) onMonthsSelected,
}) {
  final theme = Get.theme;
  bool isNotInCurrentPickerDate = date.isAfter(today);

  return GestureDetector(
    onTap: () {
      if (isNotInCurrentPickerDate) return;
      onMonthsSelected(
        date,
        getLastMonthRangeDate(selectedMonthRange, date),
      );
    },
    child: Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected == true
              ? theme.colorScheme.secondaryContainer
              : Colors.transparent,
        ),
        color: isSelected == true
            ? isStartMonth
                ? theme.colorScheme.secondaryContainer
                : Colors.transparent
            : null,
      ),
      child: Center(
        child: Text(
          monthFormat.format(date),
          style: theme.textTheme.labelSmall!.copyWith(
            color: isSelected == true
                ? theme.colorScheme.onSecondaryContainer
                : isStartMonth
                    ? theme.colorScheme.secondary
                    : isNotInCurrentPickerDate
                        ? theme.colorScheme.outline
                        : theme.colorScheme.onBackground,
            fontWeight: isSelected == true ? FontWeight.bold : null,
          ),
        ),
      ),
    ),
  );
}

///
Widget getYearView({
  required int selectedDecade,
  required List<int> selectedYear,
  required Function(int year) onYearSelected,
}) {
  List<int> yearList = List.generate(10, (index) => selectedDecade + index);
  List<int> validYearList = yearList.contains(now.year)
      ? yearList.sublist(0, yearList.indexOf(now.year) + 1)
      : yearList;

  return GridView.builder(
    gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
    itemCount: yearList.length,
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemBuilder: (context, index) {
      int year = yearList[index];
      return Obx(
        () => _buildYearItem(
          year: year,
          isSelected: selectedYear.isEmpty ? false : selectedYear.first == year,
          onYearSelected: onYearSelected,
          isNotInCurrentPickerDate: !validYearList.contains(year),
        ),
      );
    },
  );
}

Widget _buildYearItem({
  required bool isSelected,
  required int year,
  required bool isNotInCurrentPickerDate,
  required Function(int val) onYearSelected,
}) {
  final theme = Get.theme;
  return GestureDetector(
    onTap: () {
      if (isNotInCurrentPickerDate) return;
      onYearSelected(year);
    },
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected == true
              ? theme.colorScheme.secondaryContainer
              : Colors.transparent,
        ),
        color: isSelected == true ? theme.colorScheme.secondaryContainer : null,
      ),
      child: Center(
        child: Text(
          year.toString(),
          style: theme.textTheme.labelSmall!.copyWith(
            color: isSelected == true
                ? theme.colorScheme.onSecondaryContainer
                : isNotInCurrentPickerDate
                    ? theme.colorScheme.outline
                    : theme.colorScheme.onBackground,
            fontWeight: isSelected == true ? FontWeight.bold : null,
          ),
        ),
      ),
    ),
  );
}

///
Widget getSelectedDatesWidget({
  SelectedDateRange? dateRange,
  required DateFormat dateFormat,
}) {
  final textTheme = Get.theme.textTheme;
  final colorScheme = Get.theme.colorScheme;
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
                  : dateFormat.format(dateRange?.endDate ?? now),
              style: textTheme.labelMedium,
            ),
          ],
        ),
      ),
    ],
  );
}
