import 'package:flutter/material.dart';
import 'package:flutter_utils/activity_streak/activity_streak.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/constants.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/date_dropdown.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/models.dart';
import 'package:flutter_utils/date_widgets/date_range_picker/date_range_picker.dart';
import 'package:flutter_utils/date_widgets/date_range_picker/utils.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/sisitech_themes/theme_controller.dart';
import 'package:flutter_utils/text_widgets/text_carousel.dart';
import 'package:flutter_utils/text_widgets/carousel.dart';
import 'package:flutter_utils/text_widgets/animated_counter.dart';
import 'package:flutter_utils/layout_widgets/custom_tab_bar.dart';
import 'package:flutter_utils/layout_widgets/collapsible_scaffold.dart';
import 'package:flutter_utils/utils/icon_mapper.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:get/get.dart';

class UtilWidgetsScreen extends StatefulWidget {
  static const routeName = "/util-widgets";
  const UtilWidgetsScreen({super.key});

  @override
  State<UtilWidgetsScreen> createState() => _UtilWidgetsScreenState();
}

class _UtilWidgetsScreenState extends State<UtilWidgetsScreen> {
  TimePeriod datePeriod = defaultDateRanges[0];
  final ThemeController themeController = Get.find<ThemeController>();
  Rx<SelectedDateRange> selectedRange = Rx(SelectedDateRange());

  Future<void> onDatePeriodChange(int newPeriod) async {
    datePeriod =
        defaultDateRanges.firstWhere((element) => element.value == newPeriod);
    dprint(datePeriod.displayName);
  }

  RxInt currentTabIdx = RxInt(0);
  onTabChange(int? val) {
    if (val != null) {
      currentTabIdx.value = val;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              getHeaderWidget(title: "Date Dropdown"),
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

              ///
              getHeaderWidget(title: "Range Picker"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Obx(
                  () => SistchDateRangePicker(
                    onDatesSelected: (SelectedDateRange val) {
                      selectedRange.value = val;
                    },
                    selectedRange: selectedRange.value,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ///
              getHeaderWidget(
                  title: "Text Carousel",
                  trailingWidget: const Icon(Icons.menu_book)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SistchTextCarousel(
                  texts: [
                    "Your highest earnings were in 2024-09-12, with a total of Kes.57,400. A notable 6.5 increase from the beginning of This Month",
                    "2024-09-12 was your biggest spending day, with Kes.51,820 spent! Your biggest spend surged by 31.9 from the start of This Month",
                    "You made an average of 5 transactions during This Month. Each day, you moved an average of Kes.3,868 through your transactions."
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ///
              getHeaderWidget(title: "Animated Counter"),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SistchAnimatedCounter(
                  valueToAnimate: 415000,
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ///
              getHeaderWidget(title: "Streak Indicator"),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SistchTagStreakIndicator(
                  totalCount: 10,
                  currentCount: 3,
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ///
              getHeaderWidget(title: "Tab Bar Scaffold"),
              Container(
                color: theme.colorScheme.surfaceVariant,
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Obx(
                  () => SistchTabBarScaffold(
                    tabLabels: const ["Tab One", "Tab Two", "Tab Three"],
                    // showUnViewedIndicator: false,
                    height: currentTabIdx.value == 1 ? 250 : 150,
                    isScrollable: false,
                    // useWantKeepAlive: false,
                    onIndexChange: onTabChange,
                    tabWidgets: const [
                      Center(
                        child: SistchAnimatedCounter(
                          valueToAnimate: 9999,
                        ),
                      ),
                      Center(
                        child: SistchAnimatedCounter(
                          valueToAnimate: 99999,
                          // useWantKeepAlive: false,
                        ),
                      ),
                      Center(child: Icon(Icons.three_k)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ///
              getHeaderWidget(title: "Collapsible Sections Scaffold"),
              SistchCollapsibleScaffold(
                sectionTitles: const [
                  "Section One",
                  "Section Two",
                  "Section Three"
                ],
                sections: const [
                  Center(child: Icon(Icons.one_k)),
                  Center(child: Icon(Icons.two_k)),
                  Center(child: Icon(Icons.three_k)),
                ],
                sectionIcons: defaultIconMapper.values.toList().sublist(0, 3),
                initialExpandedIdx: 1,
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ///
              getHeaderWidget(title: "Mini Cards"),
              const SizedBox(height: 10),
              SistchCarousel(
                // autoPlay: false,
                // waitTime: 5,
                // isScrollable: false,
                children: [
                  Container(
                    width: 150,
                    height: 70,
                    color: Colors.pink,
                    child: const Center(child: Text('Box 1')),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 150,
                    height: 70,
                    color: Colors.green,
                    child: const Center(child: Text('Box 2')),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 150,
                    height: 70,
                    color: Colors.blue,
                    child: const Center(child: Text('Box 3')),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 150,
                    height: 70,
                    color: Colors.yellow,
                    child: const Center(child: Text('Box 4')),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ////
            ],
          ),
        ),
      ),
    );
  }
}
