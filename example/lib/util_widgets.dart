import 'package:flutter/material.dart';
import 'package:flutter_utils/activity_streak/activity_streak.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/constants.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/date_dropdown.dart';
import 'package:flutter_utils/date_widgets/date_dropdown/models.dart';
import 'package:flutter_utils/date_widgets/date_range_picker/date_range_picker.dart';
import 'package:flutter_utils/date_widgets/utils.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/layout_widgets/models.dart';
import 'package:flutter_utils/sisitech_themes/theme_controller.dart';
import 'package:flutter_utils/text_widgets/text_carousel.dart';
import 'package:flutter_utils/text_widgets/carousel.dart';
import 'package:flutter_utils/text_widgets/animated_counter.dart';
import 'package:flutter_utils/layout_widgets/custom_tab_bar.dart';
import 'package:flutter_utils/layout_widgets/collapsible_scaffold.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:flutter_utils/product_tour/product_tour.dart';
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
  final String tourTag = "example_tour";
  RxList<DateTime> startEndDates = RxList([]);
  Rx<DateTime?> currentDate = Rx(null);

  onTourNxt() {
    final ProductTourController tourCtrl =
        Get.find<ProductTourController>(tag: tourTag);
    tourCtrl.enableNext();
  }

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

  List<IconData> sampleIcons = [Icons.one_k, Icons.two_k, Icons.three_k];

  List<String> sampleLabels = ["One", "Two", "Three"];

  List<Widget> sampleWidgets = [
    Container(
        width: 150,
        height: 100,
        color: Colors.pink,
        child: const Center(child: Text('Box 1'))),
    Container(
      width: 150,
      height: 150,
      color: Colors.green,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: const Center(child: Text('Box 2')),
    ),
    Container(
      width: 150,
      height: 100,
      color: Colors.blue,
      child: const Center(child: Text('Box 3')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<TourStepModel> tourSteps = [
      TourStepModel(
        slug: "feature_one",
        title: "Feature One",
        description:
            "This is Feature One of this tour. Press Action One to continue.",
        icon: Icons.interests_rounded,
        stepWidget: Center(
          child: ElevatedButton(
            onPressed: onTourNxt,
            child: const Text("Action One"),
          ),
        ),
      ),
      TourStepModel(
        slug: "feature_two",
        title: "Feature Two",
        description:
            "This is Feature Tow of this tour. Press Action Two to continue.",
        icon: Icons.interests_rounded,
        stepWidget: Center(
          child: ElevatedButton(
            onPressed: onTourNxt,
            child: const Text("Action Two"),
          ),
        ),
      ),
      TourStepModel(
        slug: "feature_three",
        title: "Feature Three",
        description: "You don't have to do anything here, just view.",
        icon: Icons.interests_rounded,
        autoAllowNext: true,
        stepWidget: const Center(child: Text("Hello!")),
      ),
      TourStepModel(
        slug: "feature_four",
        title: "Feature Four",
        description:
            "This is the last feature of this tour. Press Action Four to finish.",
        icon: Icons.interests_rounded,
        stepWidget: Center(
          child: ElevatedButton(
            onPressed: onTourNxt,
            child: const Text("Action Four"),
          ),
        ),
      ),
    ];

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
              getHeaderWidget(title: "Product Tour"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => SistchProductTour(
                          options: ProductTourOptions(
                            steps: tourSteps,
                            controllerTag: tourTag,
                            onFinish: () => debugPrint("done with tour"),
                          ),
                        ));
                  },
                  child: const Text("Go to Tour"),
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
                    // enableMixpanel: true,
                    // hideCustomPicker: true,
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
                child: Column(
                  children: [
                    SistchAnimatedCounter(valueToAnimate: 4150),
                    SistchAnimatedCounter(valueToAnimate: 41500),
                    SistchAnimatedCounter(valueToAnimate: 415000),
                    SistchAnimatedCounter(valueToAnimate: 4150000),
                  ],
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
                  bottomWidget: Text("Poa"),
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ///
              getHeaderWidget(title: "Tab Bar Scaffold"),
              Container(
                color: theme.colorScheme.surfaceContainerHighest,
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: SistchTabBarScaffold(
                  options: TabViewOptions(
                    controllerTag: "tabViewExpCtrl",
                    // enableMixpanel: true,
                    // showUnViewedIndicator: false,
                    onIndexChange: onTabChange,
                    tabs: sampleWidgets.asMap().entries.map((e) {
                      int index = e.key;
                      return TabViewItem(
                        widget:
                            //
                            e.value,

                        //
                        label: sampleLabels[index],
                        icon: sampleIcons[index],
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ///
              getHeaderWidget(title: "Collapsible Sections Scaffold"),
              SistchCollapsibleScaffold(
                options: TabViewOptions(
                  controllerTag: "collapsibleExpCtrl",
                  // enableMixpanel: true,
                  // showUnViewedIndicator: false,
                  tabs: sampleWidgets.asMap().entries.map((e) {
                    int index = e.key;
                    return TabViewItem(
                      widget: e.value,
                      label: sampleLabels[index],
                      icon: sampleIcons[index],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ///
              getHeaderWidget(title: "Mini Cards"),
              const SizedBox(height: 10),
              SistchCarousel(
                  // autoPlay: false,
                  // waitTime: 5,
                  // isScrollable: false,
                  children: sampleWidgets),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

              ////
            ],
          ),
        ),
      ),
    );
  }
}
