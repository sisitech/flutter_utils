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
  required Function(DateTime startMonth, DateTime lastMonth) onRangeSelected,
  required List<DateTime> startEndDates,
  required int selectedRangeCount,
}) {
  List<DateTime> calendarDayDates = getCalendarViewDays(
      DateTime(currentPickerDt.year, currentPickerDt.month, 1));
  List<DateTime> calendarWeekDates = getCalendarViewWeeks(calendarDayDates);
  List<DateTime> selectedDates = startEndDates.isNotEmpty
      ? [
          startEndDates.first,
          startEndDates.last.subtract(const Duration(days: 1))
        ]
      : [];

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
          return _buildDayItem(
            date: date,
            dateIdx: index,
            currentPickers: currentPickerDt,
            isWeekView: rangeType == DateRangeTypes.week,
            isSelected: selectedDates.contains(date) ||
                (selectedDates.isNotEmpty &&
                    date.isAfter(selectedDates.first) &&
                    date.isBefore(selectedDates.last)),
            onRangeSelected: onRangeSelected,
            selectedRangeCount: selectedRangeCount,
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
  required bool? isSelected,
  required bool isWeekView,
  required int dateIdx,
  required int selectedRangeCount,
  required Function(DateTime startMonth, DateTime lastMonth) onRangeSelected,
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

      if (isWeekView) {
        DateTime startDate = getFirstDayOfCurrentWeek(date);
        onRangeSelected(
            startDate,
            getLastPeriodRangeDate(
                selectedRangeCount, startDate, DateRangeTypes.week));
        return;
      }

      onRangeSelected(date,
          getLastPeriodRangeDate(selectedRangeCount, date, DateRangeTypes.day));
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
Widget getMonthYearView({
  required DateRangeTypes rangeType,
  required int selectedRangeCount,
  required List<DateTime> startEndDates,
  required Function(DateTime startMonth, DateTime lastMonth) onRangeSelected,
  int? currentPickerYear, // for months
  int? currentPickerDecade, // for years
}) {
  bool isMonthView = currentPickerDecade == null && currentPickerYear != null;
  List<int> yearList = currentPickerDecade == null
      ? []
      : List.generate(10, (index) => currentPickerDecade + index);
  List<DateTime> calendarDates = [];

  if (isMonthView) {
    calendarDates = getCalendarViewMonths(currentPickerYear);
  } else {
    calendarDates =
        List.generate(yearList.length, (i) => DateTime(yearList[i], 1, 1));
  }

  return GridView.builder(
    gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
    itemCount: isMonthView ? monthsList.length : yearList.length,
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemBuilder: (context, index) {
      DateTime date = calendarDates[index];
      return Obx(
        () => _buildMonthYearItem(
          date: date,
          isStartOfRange:
              startEndDates.isEmpty ? false : startEndDates.first == date,
          isSelected: startEndDates.isEmpty
              ? false
              : date == startEndDates.first ||
                  (date.isAfter(startEndDates.first) &&
                      date.isBefore(startEndDates.last)),
          onRangeSelected: onRangeSelected,
          selectedRangeCount: selectedRangeCount,
          isMonthView: isMonthView,
        ),
      );
    },
  );
}

Widget _buildMonthYearItem({
  required bool isStartOfRange,
  required bool isSelected,
  required DateTime date,
  required int selectedRangeCount,
  required Function(DateTime startMonth, DateTime lastMonth) onRangeSelected,
  required bool isMonthView,
}) {
  final theme = Get.theme;
  bool isNotInCurrentPickerDate = date.isAfter(today);

  return GestureDetector(
    onTap: () {
      if (isNotInCurrentPickerDate) return;
      onRangeSelected(
        date,
        getLastPeriodRangeDate(
          selectedRangeCount,
          date,
          isMonthView ? DateRangeTypes.month : DateRangeTypes.year,
        ),
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
            ? isStartOfRange
                ? theme.colorScheme.secondaryContainer
                : Colors.transparent
            : null,
      ),
      child: Center(
        child: Text(
          isMonthView ? monthFormat.format(date) : yearFormat.format(date),
          style: theme.textTheme.labelSmall!.copyWith(
            color: isSelected == true
                ? theme.colorScheme.onSecondaryContainer
                : isStartOfRange
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
