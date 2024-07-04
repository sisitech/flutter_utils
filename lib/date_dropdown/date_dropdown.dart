import 'package:flutter/material.dart';
import 'package:flutter_utils/date_dropdown/constants.dart';
import 'package:flutter_utils/date_dropdown/models.dart';
import 'package:reactive_forms/reactive_forms.dart';

class SistchDateDropdown extends StatefulWidget {
  final bool isFullWidth;
  final TimePeriod datePeriod;
  final dynamic onDatePeriodChange;
  const SistchDateDropdown({
    super.key,
    this.isFullWidth = true,
    required this.datePeriod,
    required this.onDatePeriodChange,
  });

  @override
  State<SistchDateDropdown> createState() => _SistchDateDropdownState();
}

class _SistchDateDropdownState extends State<SistchDateDropdown> {
  var formGroup = FormGroup({
    'duration': FormControl<int>(),
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.isFullWidth
          ? double.infinity
          : MediaQuery.of(context).size.width / 2,
      child: ReactiveForm(
        formGroup: formGroup,
        child: Column(
          children: <Widget>[
            ReactiveDropdownField<int>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(2),
              ),
              formControlName: 'duration',
              hint: Text(
                widget.datePeriod.displayText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onChanged: (FormControl formControl) async {
                await widget.onDatePeriodChange(formControl.value);
              },
              items: dateRanges.map((e) => e.dropDownItem).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
