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
  final int maxRangeCount;
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
    this.maxRangeCount = 6,
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
          maxRangeCount: maxRangeCount,
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
  final int maxRangeCount;
  final bool hideSuggestions;
  final String btnLabel;
  const DatePickerScaffold({
    super.key,
    required this.chosenFormat,
    required this.lastYrPicker,
    required this.maxRangeCount,
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
      height: Get.height * (hideSuggestions ? 0.75 : 0.85),
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
                  maxRangeCount: maxRangeCount,
                  lastYrPicker: lastYrPicker,
                  onRangeSelected: onRangeSelected,
                )
              : DateOptionsPickerWidget(
                  onRangeSelected: onRangeSelected,
                  onSwitchPickers: onSwitchPickers,
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: ElevatedButton(
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
        ),
      ],
    );
  }
}

class DateOptionsPickerWidget extends StatelessWidget {
  final Function(SelectedDateRange val) onRangeSelected;
  final Function() onSwitchPickers;
  const DateOptionsPickerWidget({
    super.key,
    required this.onRangeSelected,
    required this.onSwitchPickers,
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
                    if (val == kCustomTPKeyword) {
                      onSwitchPickers();
                      return;
                    }
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
  final int maxRangeCount;
  final bool hideSuggestions;
  final Function(SelectedDateRange val) onRangeSelected;

  const DateRangePickerWidget({
    super.key,
    required this.chosenFormat,
    required this.lastYrPicker,
    required this.maxRangeCount,
    this.hideSuggestions = true,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    RxList<DateTime> startEndDates = RxList([]);

    /// Pickers Logic ==============================================

    onDateRangeSelected(
        {required DateTime startDate,
        required DateTime endDate,
        required DateRangeTypes rangeType,
        required bool isRange}) {
      startEndDates.value = [startDate, endDate];

      DateRangeTypes? rnType;
      String? rangeLabel;

      switch (rangeType) {
        case DateRangeTypes.day:
          rnType = DateRangeTypes.day;
          rangeLabel = isRange
              ? "${dayFormat.format(startDate)} to ${dayFormat.format(endDate)}"
              : dateToLabelMap[rangeType]?[startDate] ??
                  DateFormat('EEE, dd/MMM/yy').format(startDate);
          break;

        case DateRangeTypes.week:
          rnType = DateRangeTypes.week;
          rangeLabel = isRange
              ? "Week ${getWeekNumberFromDate(startDate)} to Week ${getWeekNumberFromDate(endDate)}"
              : dateToLabelMap[rangeType]?[startDate] ??
                  "Week ${getWeekNumberFromDate(startDate)}";
          break;

        case DateRangeTypes.month:
          rnType = isRange ? DateRangeTypes.monthRange : DateRangeTypes.month;
          rangeLabel = isRange
              ? "${monthFormat.format(startDate)} to ${monthFormat.format(endDate)}"
              : dateToLabelMap[rangeType]?[startDate] ??
                  DateFormat('MMMM').format(startDate);
          break;

        case DateRangeTypes.year:
          rnType = isRange ? DateRangeTypes.yearRange : DateRangeTypes.year;
          rangeLabel = isRange
              ? "${yearFormat.format(startDate)} to ${yearFormat.format(endDate)}"
              : dateToLabelMap[rangeType]?[startDate] ??
                  yearFormat.format(startDate);
          break;

        default:
      }

      onRangeSelected(SelectedDateRange(
        startDate: startDate,
        endDate: endDate,
        rangeType: rnType!,
        rangeLabel: rangeLabel!,
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
          startEndDates.clear();
        }
      }
    }

    /// ============================================== Dropdown logic

    Rx<int> selectedDrpMonth = Rx<int>(now.month);
    onMonthDrpSelected(int? val) {
      if (val != null) {
        selectedDrpMonth.value = val;
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

    /// ============================================== Picker Logic
    Rx<int> selectedRangeCount = Rx<int>(1);
    onRangeCountSelected(int? val, DateRangeTypes rangeType) {
      if (val != null) {
        selectedRangeCount.value = val;
        if (startEndDates.isNotEmpty) {
          onDateRangeSelected(
            startDate: startEndDates.first,
            endDate:
                getLastPeriodRangeDate(val, startEndDates.first, rangeType),
            rangeType: rangeType,
            isRange: val != 1,
          );
        }
      }
    }

    return SistchTabBarScaffold(
      tabLabels: const ["Day", "Week", "Month", "Year"],
      showUnViewedIndicator: false,
      height: Get.height * (hideSuggestions ? 0.55 : 0.6),
      isScrollable: false,
      onIndexChange: (val) => startEndDates.clear(),
      tabWidgets: [
        DateRangeTypes.day,
        DateRangeTypes.week,
        DateRangeTypes.month,
        DateRangeTypes.year
      ]
          .map((e) => Obx(() => getRangePickerScaffold(
                rangeType: e,
                firstYearPicker: lastYrPicker,
                maxRangeCount: maxRangeCount,
                startEndDates: startEndDates,
                onDateRangeSelected: onDateRangeSelected,
                onSuggestionSelected: onSuggestionChipSelected,
                hideSuggestions: hideSuggestions,
                selectedDecade: selectedDecade.value,
                selectedDrpMonth: selectedDrpMonth.value,
                selectedDrpYear: selectedDrpYear.value,
                selectedRangeCount: selectedRangeCount.value,
                onDecadeSelected: onDecadeSelected,
                onRangeCountSelected: onRangeCountSelected,
                onMonthDrpSelected: onMonthDrpSelected,
                onYearDrpSelected: onYearDrpSelected,
              )))
          .toList(),
    );
  }
}

Widget getRangePickerScaffold({
  required DateRangeTypes rangeType,
  required int firstYearPicker,
  required int maxRangeCount,
  required Function(String suggestion) onSuggestionSelected,
  required bool hideSuggestions,

  ///
  required List<DateTime> startEndDates,
  required Function(
          {required DateTime startDate,
          required DateTime endDate,
          required bool isRange,
          required DateRangeTypes rangeType})
      onDateRangeSelected,

  ///
  required int selectedDecade,
  required int selectedDrpMonth,
  required int selectedDrpYear,
  required int selectedRangeCount,
  required Function(int? val) onMonthDrpSelected,
  required Function(int? val) onYearDrpSelected,
  required Function(int? val) onDecadeSelected,
  required Function(int rangeCount, DateRangeTypes rangeType)
      onRangeCountSelected,
}) {
  final width = Get.size.width;

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

  handleRangeCountChange(int? val) {
    if (val != null) onRangeCountSelected(val, rangeType);
  }

  handleDateRangeChange(DateTime startDate, DateTime endDate) {
    onDateRangeSelected(
      startDate: startDate,
      endDate: endDate,
      rangeType: rangeType,
      isRange: selectedRangeCount != 1,
    );
  }

  double drpWidth = Get.width * 0.2;

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
          children: [
            getDropDownFormField(
              width: width * 0.26,
              selectedValue: selectedRangeCount,
              items: getPickerPeriodCounts(
                  maxRangeCount,
                  rangeType == DateRangeTypes.year
                      ? "Year"
                      : rangeType == DateRangeTypes.month
                          ? "Month"
                          : rangeType == DateRangeTypes.week
                              ? "Week"
                              : "Day"),
              onChanged: handleRangeCountChange,
            ),
            const SizedBox(width: 7),
            rangeType == DateRangeTypes.year
                ? getDropDownFormField(
                    width: drpWidth,
                    selectedValue: selectedDecade,
                    items: getPickerDecades(firstYearPicker),
                    onChanged: (val) => onDecadeSelected(val),
                  )
                : Row(
                    children: [
                      if ([DateRangeTypes.day, DateRangeTypes.week]
                          .contains(rangeType))
                        Padding(
                          padding: const EdgeInsets.only(right: 7),
                          child: getDropDownFormField(
                            width: drpWidth,
                            selectedValue: selectedDrpMonth,
                            items: getPickerMonths(selectedDrpYear),
                            onChanged: onMonthDrpSelected,
                          ),
                        ),
                      getDropDownFormField(
                        width: drpWidth,
                        selectedValue: selectedDrpYear,
                        items: getPickerYears(firstYearPicker),
                        onChanged: onYearDrpSelected,
                      )
                    ],
                  ),
          ],
        ),
      ),
      const Divider(),
      const SizedBox(height: 10),

      /// the calendars
      Expanded(
        child: [DateRangeTypes.day, DateRangeTypes.week].contains(rangeType)
            ? getDayWeekView(
                currentPickerDt: DateTime(selectedDrpYear, selectedDrpMonth, 1),
                rangeType: rangeType,
                startEndDates: startEndDates,
                onRangeSelected: handleDateRangeChange,
                selectedRangeCount: selectedRangeCount,
              )
            : [DateRangeTypes.month, DateRangeTypes.monthRange]
                    .contains(rangeType)
                ? getMonthYearView(
                    currentPickerYear: selectedDrpYear,
                    rangeType: rangeType,
                    selectedRangeCount: selectedRangeCount,
                    startEndDates: startEndDates,
                    onRangeSelected: handleDateRangeChange,
                  )
                : getMonthYearView(
                    currentPickerDecade: selectedDecade,
                    rangeType: rangeType,
                    selectedRangeCount: selectedRangeCount,
                    startEndDates: startEndDates,
                    onRangeSelected: handleDateRangeChange,
                  ),
      ),
    ],
  );
}
