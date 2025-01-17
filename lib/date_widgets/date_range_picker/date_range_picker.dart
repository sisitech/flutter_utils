import 'package:flutter/material.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/constants.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/models.dart';
import 'package:flutter_utils/date_widgets/date_range_picker/utils.dart';
import 'package:flutter_utils/date_widgets/date_range_picker/widgets.dart';
import 'package:flutter_utils/layout_widgets/custom_tab_bar.dart';
import 'package:flutter_utils/layout_widgets/models.dart';
import 'package:flutter_utils/utils/functions.dart';
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
  final SelectedDateRange selectedRange;
  final String btnLabel;
  final bool enableMixpanel;

  const SistchDateRangePicker({
    super.key,
    this.dateFormat,
    this.lastYrPicker = 2015,
    this.maxRangeCount = 6,
    this.defaultPicker = DateRangeDefaults.thisMonth,
    required this.onDatesSelected,
    this.onTimePeriodChange,
    required this.selectedRange,
    this.btnLabel = "Show Me The Data",
    this.enableMixpanel = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    DateFormat chosenFormat = dateFormat ?? DateFormat("dd/MM/yyy");

    onOpenDatePickerBottomSheet() async {
      SelectedDateRange? val = await getBottomSheet(
        theme: theme,
        heightFactor: 0.8,
        children: [
          DatePickerScaffold(
            chosenFormat: chosenFormat,
            maxRangeCount: maxRangeCount,
            lastYrPicker: lastYrPicker,
            btnLabel: btnLabel,
            enableMixpanel: enableMixpanel,
          ),
        ],
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
  final String btnLabel;
  final bool enableMixpanel;
  const DatePickerScaffold({
    super.key,
    required this.chosenFormat,
    required this.lastYrPicker,
    required this.maxRangeCount,
    required this.btnLabel,
    required this.enableMixpanel,
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

    onSwitchPickers() {
      if (enableMixpanel) {
        mixpanelTrackEvent('switch_picker');
      }
      showFullPicker.value = !showFullPicker.value;
    }

    return Column(
      children: [
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
                  enableMixpanel: enableMixpanel,
                )
              : DateOptionsPickerWidget(
                  onRangeSelected: onRangeSelected,
                  onSwitchPickers: onSwitchPickers,
                  enableMixpanel: enableMixpanel,
                ),
        ),
        const SizedBox(height: 10),
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
  final bool enableMixpanel;

  const DateOptionsPickerWidget({
    super.key,
    required this.onRangeSelected,
    required this.onSwitchPickers,
    required this.enableMixpanel,
  });

  @override
  Widget build(BuildContext context) {
    RxString selectedOption = ''.obs;
    final scrollCtrl = ScrollController();
    return SizedBox(
      height: Get.height * 0.55,
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
                      //
                      if (enableMixpanel) {
                        mixpanelTrackEvent('date_option:${tp.displayText}');
                      }
                      //
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
  final Function(SelectedDateRange val) onRangeSelected;
  final bool enableMixpanel;

  const DateRangePickerWidget({
    super.key,
    required this.chosenFormat,
    required this.lastYrPicker,
    required this.maxRangeCount,
    required this.onRangeSelected,
    required this.enableMixpanel,
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
        //
        if (enableMixpanel) {
          mixpanelTrackEvent('date_range:$val');
        }
        //
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

    TabViewItem buildTabViewItem(
        {required String label, required DateRangeTypes rangeType}) {
      return TabViewItem(
        label: label,
        widget: Obx(
          () => getRangePickerScaffold(
            rangeType: rangeType,
            firstYearPicker: lastYrPicker,
            maxRangeCount: maxRangeCount,
            startEndDates: startEndDates,
            onDateRangeSelected: onDateRangeSelected,
            selectedDecade: selectedDecade.value,
            selectedDrpMonth: selectedDrpMonth.value,
            selectedDrpYear: selectedDrpYear.value,
            selectedRangeCount: selectedRangeCount.value,
            onDecadeSelected: onDecadeSelected,
            onRangeCountSelected: onRangeCountSelected,
            onMonthDrpSelected: onMonthDrpSelected,
            onYearDrpSelected: onYearDrpSelected,
          ),
        ),
      );
    }

    return SistchTabBarScaffold(
      options: TabViewOptions(
        controllerTag: "sistch_date_range_picker",
        enableMixpanel: enableMixpanel,
        showUnViewedIndicator: false,
        onIndexChange: (val) => startEndDates.clear(),
        tabs: [
          buildTabViewItem(
            label: "Day",
            rangeType: DateRangeTypes.day,
          ),
          buildTabViewItem(
            label: "Week",
            rangeType: DateRangeTypes.week,
          ),
          buildTabViewItem(
            label: "Month",
            rangeType: DateRangeTypes.month,
          ),
          buildTabViewItem(
            label: "Year",
            rangeType: DateRangeTypes.year,
          ),
        ],
      ),
    );
  }
}

Widget getRangePickerScaffold({
  required DateRangeTypes rangeType,
  required int firstYearPicker,
  required int maxRangeCount,

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
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
      const SizedBox(height: 5),
      const Divider(),
      const SizedBox(height: 10),

      /// the calendars
      [DateRangeTypes.day, DateRangeTypes.week].contains(rangeType)
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
      const SizedBox(height: 5),
    ],
  );
}
