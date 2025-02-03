import 'package:flutter/material.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/constants.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/models.dart';
import 'package:flutter_utils/date_widgets/utils.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';

class DateOptionsPickerWidget extends StatelessWidget {
  final Function(SelectedDateRange val) onRangeSelected;
  final Function() onSwitchPickers;
  final bool enableMixpanel;
  final bool hideCustomPicker;

  const DateOptionsPickerWidget({
    super.key,
    required this.onRangeSelected,
    required this.onSwitchPickers,
    required this.enableMixpanel,
    required this.hideCustomPicker,
  });

  @override
  Widget build(BuildContext context) {
    RxString selectedOption = ''.obs;
    final scrollCtrl = ScrollController();
    List<TimePeriod> dateRanges = hideCustomPicker
        ? defaultDateRanges
            .where((e) => e.displayName != kCustomTPKeyword)
            .toList()
        : defaultDateRanges;
    return SizedBox(
      height: Get.height * 0.55,
      child: Scrollbar(
        controller: scrollCtrl,
        thumbVisibility: true,
        child: ListView.builder(
          shrinkWrap: true,
          controller: scrollCtrl,
          itemBuilder: (context, index) {
            String dateTxt = dateRanges[index].displayText;
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

                    TimePeriod? tp = dateRanges
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
          itemCount: dateRanges.length,
        ),
      ),
    );
  }
}
