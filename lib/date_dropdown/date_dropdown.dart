import 'package:flutter/material.dart';
import 'package:flutter_utils/date_dropdown/constants.dart';
import 'package:flutter_utils/date_dropdown/models.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

class SisitechDateDropdownSerializer extends GetxController {
  final formGroup = FormGroup({
    'duration': FormControl<int>(),
  });
}

class SistchDateDropdown extends StatelessWidget {
  final bool isFullWidth;
  final TimePeriod datePeriod;
  final Function? onDatePeriodChange;
  final Function(TimePeriod timePeriod)? onTimePeriodChange;
  final String? name;
  late List<TimePeriod> finalTimePeriods;

  SistchDateDropdown({
    super.key,
    this.isFullWidth = true,
    required this.datePeriod,
    this.onDatePeriodChange,
    this.onTimePeriodChange,
    List<TimePeriod> timePeriods = const [],
    this.name,
  }) {
    if (timePeriods.isEmpty) {
      finalTimePeriods = defaultDateRanges;
    } else {
      finalTimePeriods = timePeriods;
    }
  }

  @override
  Widget build(BuildContext context) {
    var cont = Get.put(SisitechDateDropdownSerializer(), tag: name);
    return SizedBox(
      width:
          isFullWidth ? double.infinity : MediaQuery.of(context).size.width / 2,
      child: ReactiveForm(
        formGroup: cont.formGroup,
        child: Column(
          children: <Widget>[
            ReactiveDropdownField<int>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(2),
              ),
              formControlName: 'duration',
              hint: Text(
                datePeriod.displayText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onChanged: (FormControl formControl) async {
                if (onDatePeriodChange != null) {
                  await onDatePeriodChange!(formControl.value);
                }
                if (onTimePeriodChange != null) {
                  var selectedTimePeriod = finalTimePeriods
                      .where((element) => element.value == formControl.value)
                      .firstOrNull;
                  if (selectedTimePeriod != null) {
                    await onTimePeriodChange!(selectedTimePeriod);
                  }
                }
              },
              items: finalTimePeriods.map((e) => e.dropDownItem).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
