import 'package:flutter/material.dart';
import 'package:flutter_utils/date_dropdown/constants.dart';
import 'package:flutter_utils/date_dropdown/date_dropdown.dart';
import 'package:flutter_utils/date_dropdown/models.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:flutter_utils/sisitech_themes/theme_controller.dart';
import 'package:get/get.dart';

class UtilWidgetsScreen extends StatefulWidget {
  static const routeName = "/util-widgets";
  const UtilWidgetsScreen({super.key});

  @override
  State<UtilWidgetsScreen> createState() => _UtilWidgetsScreenState();
}

class _UtilWidgetsScreenState extends State<UtilWidgetsScreen> {
  TimePeriod datePeriod = dateRanges[0];
  final ThemeController themeController = Get.find<ThemeController>();

  Future<void> onDatePeriodChange(int newPeriod) async {
    datePeriod = dateRanges.firstWhere((element) => element.value == newPeriod);
    dprint(datePeriod.displayName);
    dprint(datePeriod.prevStartDate);
    dprint(datePeriod.startDateFunc!());
    dprint(datePeriod.intervalLabels);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Util Widgets'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            children: [
              Text(
                'Date Dropdown Widget'.ctr,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SistchDateDropdown(
                  datePeriod: datePeriod,
                  onDatePeriodChange: onDatePeriodChange,
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
