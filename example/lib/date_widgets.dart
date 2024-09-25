import 'package:flutter/material.dart';
import 'package:flutter_utils/date_dropdown/constants.dart';
import 'package:flutter_utils/date_dropdown/date_dropdown.dart';
import 'package:flutter_utils/date_dropdown/models.dart';
import 'package:flutter_utils/date_pickers/date_range_picker.dart';
import 'package:flutter_utils/date_pickers/utils.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/sisitech_themes/theme_controller.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:get/get.dart';

class DateWidgetsScreen extends StatefulWidget {
  static const routeName = "/date-widgets";
  const DateWidgetsScreen({super.key});

  @override
  State<DateWidgetsScreen> createState() => _DateWidgetsScreenState();
}

class _DateWidgetsScreenState extends State<DateWidgetsScreen> {
  TimePeriod datePeriod = defaultDateRanges[0];
  final ThemeController themeController = Get.find<ThemeController>();

  Future<void> onDatePeriodChange(int newPeriod) async {
    datePeriod =
        defaultDateRanges.firstWhere((element) => element.value == newPeriod);
    dprint(datePeriod.displayName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Widgets'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getHeaderWidget(theme: theme, title: "Date Dropdown"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SistchDateDropdown(
                  datePeriod: datePeriod,
                  // timePeriods: [
                  //   TimePeriod(
                  //     displayName: 'Today',
                  //     value: 1,
                  //     startDate: () {
                  //       var now = DateTime.now();
                  //       return DateTime(now.year, now.month, now.day);
                  //     },
                  //     endDate: () {
                  //       var now = DateTime.now();
                  //       return DateTime(now.year, now.month, now.day + 1);
                  //     },
                  //   ),
                  // ],
                  // onDatePeriodChange: onDatePeriodChange,
                  onTimePeriodChange: (TimePeriod timePeriod) {
                    dprint(timePeriod.toJson());
                    dprint(timePeriod.getGroupingType());
                  },
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
              getHeaderWidget(theme: theme, title: "Range Picker"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SistchDateRangePicker(
                  onDatesSelected: ((SelectedDateRange val) => {}),
                  hideSuggestions: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
