import 'package:flutter/material.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/models.dart';
import 'package:flutter_utils/date_widgets/date_range_picker/options_picker.dart';
import 'package:flutter_utils/date_widgets/date_range_picker/range_picker.dart';
import 'package:flutter_utils/date_widgets/utils.dart';
import 'package:flutter_utils/flutter_utils.dart';
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
  final Function? onShowCustomPicker;
  final List<int>? optionsToRemoveByValue;

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
    this.onShowCustomPicker,
    this.optionsToRemoveByValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    DateFormat chosenFormat = dateFormat ?? DateFormat("dd/MM/yy");

    onOpenDatePickerBottomSheet() async {
      SelectedDateRange? val = await getBottomSheetScaffold(
        theme: theme,
        heightFactor: 0.92,
        childBuilder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16.0),
            child: DatePickerScaffold(
              chosenFormat: chosenFormat,
              maxRangeCount: maxRangeCount,
              lastYrPicker: lastYrPicker,
              btnLabel: btnLabel,
              enableMixpanel: enableMixpanel,
              onShowCustomPicker: onShowCustomPicker,
              optionsToRemoveByValue: optionsToRemoveByValue,
            ),
          );
        },
      );
      if (val != null) {
        dprint(val.startDate);
        dprint(val.endDate);
        if (onTimePeriodChange != null) {
          onTimePeriodChange!(TimePeriod(
              startDate: () => val.startDate!, endDate: () => val.endDate!));
          return;
        }
        onDatesSelected(val);
      }
    }

    return GestureDetector(
      onTap: onOpenDatePickerBottomSheet,
      child: Container(
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
                theme: theme,
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
  final Function? onShowCustomPicker;
  final List<int>? optionsToRemoveByValue;
  const DatePickerScaffold({
    super.key,
    required this.chosenFormat,
    required this.lastYrPicker,
    required this.maxRangeCount,
    required this.btnLabel,
    required this.enableMixpanel,
    required this.onShowCustomPicker,
    this.optionsToRemoveByValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Rx<SelectedDateRange?> selectedDateRange = Rx(null);
    RxBool showCustomPicker = RxBool(false);

    onDatePickerClose() => Get.back(result: selectedDateRange.value);

    onRangeSelected(SelectedDateRange? val) {
      selectedDateRange.value = val;
      // Auto-close and return when selecting from preset options (non-custom)
      if (!showCustomPicker.value && val != null) {
        onDatePickerClose();
      }
    }

    onSwitchPickers() {
      if (enableMixpanel) {
        mixpanelTrackEvent('switch_picker');
      }
      showCustomPicker.value = !showCustomPicker.value;
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => getSelectedDatesWidget(
                  theme: theme,
                  dateRange: selectedDateRange.value,
                  dateFormat: chosenFormat,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: getIconBtn(
                fgColor: colorScheme.primary,
                action: onShowCustomPicker ?? onSwitchPickers,
                iconPath: Icons.switch_access_shortcut,
              ),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 10),
        Obx(
          () => showCustomPicker.value
              ? YearDatePicker(
                  lastYear: lastYrPicker,
                  chosenDateFormat: chosenFormat,
                  onRangeSelected: onRangeSelected,
                  enableMixpanel: enableMixpanel,
                )
              : DateOptionsPickerWidget(
                  onRangeSelected: onRangeSelected,
                  onSwitchPickers: onSwitchPickers,
                  enableMixpanel: enableMixpanel,
                  onShowCustomPicker: onShowCustomPicker,
                  optionsToRemoveByValue: optionsToRemoveByValue,
                ),
        ),
        const SizedBox(height: 10),
        Obx(
          () {
            final val = selectedDateRange.value;
            final isCustom = showCustomPicker.value;
            final canApply =
                isCustom && val?.startDate != null && val?.endDate != null;
            if (!canApply) return const SizedBox.shrink();
            return Padding(
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
            );
          },
        ),
      ],
    );
  }
}
