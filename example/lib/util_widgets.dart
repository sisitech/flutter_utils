import 'package:flutter/material.dart';
import 'package:flutter_utils/activity_streak/activity_streak.dart';
import 'package:flutter_utils/date_dropdown/constants.dart';
import 'package:flutter_utils/date_dropdown/date_dropdown.dart';
import 'package:flutter_utils/date_dropdown/models.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:flutter_utils/sisitech_themes/theme_controller.dart';
import 'package:flutter_utils/sistch_text_carousel/text_carousel.dart';
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
              const SistchTagStreakIndicator(
                totalCount: 10,
                currentCount: 3,
              ),
              const Divider(),
              Text(
                'Text Carousel Widget'.ctr,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SistchTextCarousel(
                viewDuration: 2,
                texts: ["Text One", "Text Two", "Text Three"],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
