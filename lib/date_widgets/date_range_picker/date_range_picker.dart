import 'package:flutter/material.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/constants.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/models.dart';
import 'package:flutter_utils/date_widgets/date_range_picker/utils.dart';
import 'package:flutter_utils/date_widgets/date_range_picker/widgets.dart';
import 'package:flutter_utils/layout_widgets/custom_tab_bar.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SistchDateRangePicker extends StatelessWidget {
  final DateFormat? dateFormat;
  final int lastYrPicker;
  final int lastMnPicker;
  final DateRangeDefaults defaultPicker;
  final Function(SelectedDateRange dates) onDatesSelected;
  final Function(TimePeriod timePeriod)? onTimePeriodChange;
  final bool hideSuggestions;
  final SelectedDateRange selectedRange;
  final String btnLabel;

  const SistchDateRangePicker({
    super.key,
    this.dateFormat,
    this.lastYrPicker = 2015,
    this.lastMnPicker = 6,
    this.defaultPicker = DateRangeDefaults.thisMonth,
    required this.onDatesSelected,
    this.onTimePeriodChange,
    required this.selectedRange,
    this.hideSuggestions = true,
    this.btnLabel = "Show Me The Data",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    DateFormat chosenFormat = dateFormat ?? DateFormat("dd/MM/yyy");

    onOpenDatePickerBottomSheet() async {
      SelectedDateRange? val = await Get.bottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0),
          ),
        ),
        DatePickerScaffold(
          chosenFormat: chosenFormat,
          lastMnPicker: lastMnPicker,
          lastYrPicker: lastYrPicker,
          hideSuggestions: hideSuggestions,
          btnLabel: btnLabel,
        ),
      );
      if (val != null) {
        if (onTimePeriodChange != null) {
          onTimePeriodChange!(TimePeriod(
              startDate: () => val.startDate!, endDate: () => val.endDate!));
          return;
        }
        onDatesSelected(val);
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: getSelectedDatesWidget(
              dateFormat: chosenFormat,
              dateRange: selectedRange,
            ),
          ),
          const SizedBox(width: 10),
          getIconBtn(
            bgColor: colorScheme.primary,
            fgColor: colorScheme.onPrimary,
            action: onOpenDatePickerBottomSheet,
            iconPath: Icons.calendar_month,
          ),
        ],
      ),
    );
  }
}

class DatePickerScaffold extends StatelessWidget {
  final DateFormat chosenFormat;
  final int lastYrPicker;
  final int lastMnPicker;
  final bool hideSuggestions;
  final String btnLabel;
  const DatePickerScaffold({
    super.key,
    required this.chosenFormat,
    required this.lastYrPicker,
    required this.lastMnPicker,
    this.hideSuggestions = true,
    required this.btnLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Rx<SelectedDateRange?> selectedDateRange = Rx(null);
    RxBool showFullPicker = RxBool(false);

    /// Date Handlers logic ==============================================

    onRangeSelected(SelectedDateRange val) => selectedDateRange.value = val;

    onDatePickerClose() => Get.back(result: selectedDateRange.value);

    onSwitchPickers() => showFullPicker.value = !showFullPicker.value;

    return getBottomSheetScaffold(
      height: Get.height * (hideSuggestions ? 0.7 : 0.85),
      widgetList: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => getSelectedDatesWidget(
                  dateRange: selectedDateRange.value,
                  dateFormat: chosenFormat,
                ),
              ),
            ),
            const SizedBox(width: 5),
            getIconBtn(
              fgColor: colorScheme.primary,
              action: onSwitchPickers,
              iconPath: Icons.switch_access_shortcut,
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 10),
        Obx(
          () => showFullPicker.value
              ? DateRangePickerWidget(
                  chosenFormat: chosenFormat,
                  lastMnPicker: lastMnPicker,
                  lastYrPicker: lastYrPicker,
                  onRangeSelected: onRangeSelected,
                )
              : DateOptionsPickerWidget(onRangeSelected: onRangeSelected),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onDatePickerClose,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_alt),
                const SizedBox(width: 5),
                Text(btnLabel),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DateOptionsPickerWidget extends StatelessWidget {
  final Function(SelectedDateRange val) onRangeSelected;
  const DateOptionsPickerWidget({
    super.key,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    RxString selectedOption = ''.obs;
    final scrollCtrl = ScrollController();
    return SizedBox(
      height: Get.height * 0.5,
      child: Scrollbar(
        controller: scrollCtrl,
        thumbVisibility: true,
        child: ListView.builder(
          shrinkWrap: true,
          controller: scrollCtrl,
          itemBuilder: (context, index) {
            String dateTxt = defaultDateRanges[index].displayText;
            return Obx(
              () => RadioListTile(
                activeColor: Get.theme.primaryColor,
                value: dateTxt,
                groupValue: selectedOption.value,
                onChanged: (String? val) {
                  if (val != null) {
                    TimePeriod? tp = defaultDateRanges
                        .firstWhereOrNull((e) => e.displayText == val);
                    if (tp != null &&
                        tp.startDateFunc != null &&
                        tp.endDateFunc != null) {
                      selectedOption.value = tp.displayText;
                      onRangeSelected(SelectedDateRange(
                        rangeLabel: tp.displayText,
                        rangeType: tp.type,
                        startDate: tp.startDateFunc!(),
                        endDate: tp.endDateFunc!(),
                      ));
                    }
                  }
                },
                title: Text(dateTxt),
              ),
            );
          },
          itemCount: defaultDateRanges.length,
        ),
      ),
    );
  }
}

class DateRangePickerWidget extends StatelessWidget {
  final DateFormat chosenFormat;
  final int lastYrPicker;
  final int lastMnPicker;
  final bool hideSuggestions;
  final Function(SelectedDateRange val) onRangeSelected;

  const DateRangePickerWidget({
    super.key,
    required this.chosenFormat,
    required this.lastYrPicker,
    required this.lastMnPicker,
    this.hideSuggestions = true,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    RxList<DateTime> selectedDays = RxList([]);
    RxList<DateTime> startEndMonthDates = RxList([]);
    RxList<int> selectedYear = RxList([]);

    /// Pickers Logic ==============================================

    onDaySelected(DateTime val) {
      selectedDays.value = [val];
      onRangeSelected(SelectedDateRange(
        startDate: val,
        endDate: val.add(const Duration(days: 1)),
        rangeType: DateRangeTypes.day,
        rangeLabel: val == today
            ? "Today"
            : val == yesterday
                ? "Yesterday"
                : DateFormat('EEE, dd/MMM/yy').format(val),
      ));
    }

    onWeekSelected(DateTime val) {
      selectedDays.value = List.generate(7, (i) => val.add(Duration(days: i)))
          .where((date) => date.isBefore(today.add(const Duration(days: 1))))
          .toList();
      onRangeSelected(SelectedDateRange(
          startDate: val,
          endDate: selectedDays.last.add(const Duration(days: 1)),
          rangeType: DateRangeTypes.week,
          rangeLabel: val == thisWeek
              ? "This Week"
              : val == lastWeek
                  ? "Last Week"
                  : "Week ${getWeekNumberFromDate(val)}"));
    }

    onMonthsSelected(DateTime startDate, DateTime endDate) {
      startEndMonthDates.value = [startDate, endDate];
      bool isMonthRange = startDate != endDate;

      onRangeSelected(SelectedDateRange(
        startDate: startDate,
        endDate: isMonthRange
            ? endDate
            : DateTime(startDate.year, startDate.month + 1, 1),
        rangeType:
            isMonthRange ? DateRangeTypes.monthRange : DateRangeTypes.month,
        rangeLabel: isMonthRange
            ? "${monthFormat.format(startDate)} to ${monthFormat.format(endDate.subtract(const Duration(days: 1)))}"
            : startDate == thisMonth
                ? "This Month"
                : startDate == lastMonth
                    ? "Last Month"
                    : DateFormat('MMMM').format(startDate),
      ));
    }

    onYearSelected(int year) {
      selectedYear.value = [year];
      DateTime startDate = DateTime(year, 1, 1);
      onRangeSelected(SelectedDateRange(
        startDate: startDate,
        endDate: DateTime(year + 1, 1, 1),
        rangeType: DateRangeTypes.year,
        rangeLabel: startDate == thisYear
            ? "This Year"
            : startDate == lastYear
                ? "Last Year"
                : DateFormat('yyyy').format(startDate),
      ));
    }

    onSuggestionChipSelected(String? val) {
      if (val != null) {
        TimePeriod? selectedPeriod =
            defaultDateRanges.where((e) => e.displayName == val).firstOrNull;
        if (selectedPeriod != null) {
          onRangeSelected(SelectedDateRange(
              startDate: selectedPeriod.startDateFunc!(),
              endDate: selectedPeriod.endDateFunc!(),
              rangeType: selectedPeriod.type,
              rangeLabel: selectedPeriod.displayName));
          // reset picker values
          selectedDays.clear();
        }
      }
    }

    return SistchTabBarScaffold(
      tabLabels: const ["Day", "Week", "Month", "Year"],
      showUnViewedIndicator: false,
      height: Get.height * (hideSuggestions ? 0.5 : 0.6),
      isScrollable: false,
      tabWidgets: [
        DateRangeTypes.day,
        DateRangeTypes.week,
        DateRangeTypes.month,
        DateRangeTypes.year
      ]
          .map((e) => getRangePickerScaffold(
                rangeType: e,
                firstYearPicker: lastYrPicker,
                maxMonthRange: lastMnPicker,
                selectedDays: selectedDays,
                onDaySelected: onDaySelected,
                onWeekSelected: onWeekSelected,
                startEndMonthDates: startEndMonthDates,
                onMonthSelected: onMonthsSelected,
                selectedYear: selectedYear,
                onYearSelected: onYearSelected,
                onRangeSelected: onRangeSelected,
                onSuggestionSelected: onSuggestionChipSelected,
                hideSuggestions: hideSuggestions,
              ))
          .toList(),
    );
  }
}

Widget getRangePickerScaffold({
  required DateRangeTypes rangeType,
  required int firstYearPicker,
  required int maxMonthRange,
  required Function(SelectedDateRange selection) onRangeSelected,
  required Function(String suggestion) onSuggestionSelected,
  required Function(DateTime day) onDaySelected,
  required Function(DateTime startWeekDate) onWeekSelected,
  required List<DateTime> selectedDays,
  required List<DateTime> startEndMonthDates,
  required Function(DateTime startMonth, DateTime lastMonth) onMonthSelected,
  required List<int> selectedYear,
  required Function(int year) onYearSelected,
  required bool hideSuggestions,
}) {
  final width = Get.size.width;

  /// Chip Suggestions Logic ==============================================
  List<String> dateSuggestions = defaultDateRanges
      .where((element) => element.type == rangeType)
      .map((e) => e.displayName)
      .toList();
  Rx<int?> selectedSuggestion = Rx<int?>(null);
  onSuggestionChipSelected(int? val) {
    if (val != null) {
      selectedSuggestion.value = val;
      onSuggestionSelected(dateSuggestions[selectedSuggestion.value!]);
    }
  }

  /// Dropdown logic ==============================================
  Rx<int> selectedDrpMonth = Rx<int>(now.month);
  onMonthDrpSelected(int? val) {
    if (val != null) {
      selectedDrpMonth.value = val;
    }
  }

  Rx<int> selectedMonthRange = Rx<int>(1);
  onMonthRangeSelected(int? val) {
    if (val != null) {
      selectedMonthRange.value = val;
      if (startEndMonthDates.isNotEmpty) {
        onMonthSelected(startEndMonthDates.first,
            getLastMonthRangeDate(val, startEndMonthDates.first));
      }
    }
  }

  Rx<int> selectedDrpYear = Rx<int>(now.year);
  onYearDrpSelected(int? val) {
    if (val != null) selectedDrpYear.value = val;
  }

  Rx<int> selectedDecade = Rx<int>((now.year ~/ 10) * 10);
  onDecadeSelected(int? val) {
    if (val != null) {
      selectedDecade.value = val;
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// the suggestions
      if (!hideSuggestions)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Obx(
            () => getChipsWidget(
              title: "Suggested",
              chipLabels: dateSuggestions,
              selectedIdx: selectedSuggestion.value,
              onChipSelected: onSuggestionChipSelected,
              width: width,
              bgColor: Get.theme.colorScheme.tertiaryContainer,
            ),
          ),
        ),

      /// the range dropdowns
      Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: rangeType == DateRangeTypes.year
                ? [
                    Obx(
                      () => getDropDownFormField(
                        width: width * 0.26,
                        selectedValue: selectedDecade.value,
                        items: getPickerDecades(firstYearPicker),
                        onChanged: (val) => onDecadeSelected(val),
                      ),
                    )
                  ]
                : [
                    Obx(
                      () => [DateRangeTypes.month, DateRangeTypes.monthRange]
                              .contains(rangeType)
                          ? getDropDownFormField(
                              width: width * 0.28,
                              selectedValue: selectedMonthRange.value,
                              items: getPickerMonthRanges(maxMonthRange),
                              onChanged: (val) => onMonthRangeSelected(val),
                            )
                          : getDropDownFormField(
                              width: width * 0.25,
                              selectedValue: selectedDrpMonth.value,
                              items: getPickerMonths(selectedDrpYear.value),
                              onChanged: (int? val) => onMonthDrpSelected(val),
                            ),
                    ),
                    const SizedBox(width: 7),
                    Obx(
                      () => getDropDownFormField(
                        width: width * 0.25,
                        selectedValue: selectedDrpYear.value,
                        items: getPickerYears(firstYearPicker),
                        onChanged: (val) => onYearDrpSelected(val),
                      ),
                    ),
                  ]),
      ),
      const Divider(),
      const SizedBox(height: 10),

      /// the calendars
      Expanded(
        child: [DateRangeTypes.day, DateRangeTypes.week].contains(rangeType)
            ? Obx(
                () => getDayWeekView(
                  currentPickerDt: DateTime(
                      selectedDrpYear.value, selectedDrpMonth.value, 1),
                  rangeType: rangeType,
                  selectedDays: selectedDays,
                  onDaySelected: onDaySelected,
                  onWeekSelected: onWeekSelected,
                ),
              )
            : [DateRangeTypes.month, DateRangeTypes.monthRange]
                    .contains(rangeType)
                ? Obx(
                    () => getMonthView(
                        currentPickerYr: selectedDrpYear.value,
                        rangeType: rangeType,
                        selectedMonthRange: selectedMonthRange.value,
                        startEndMonthDates: startEndMonthDates,
                        onMonthsSelected: onMonthSelected),
                  )
                : Obx(
                    () => getYearView(
                      selectedYear: selectedYear,
                      onYearSelected: onYearSelected,
                      selectedDecade: selectedDecade.value,
                    ),
                  ),
      ),
    ],
  );
}
