import 'package:flutter/material.dart';
import 'package:flutter_utils/activity_streak/activity_streak.dart';
import 'package:flutter_utils/date_dropdown/constants.dart';
import 'package:flutter_utils/date_dropdown/models.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/sisitech_themes/theme_controller.dart';
import 'package:flutter_utils/sistch_text_carousel/text_carousel.dart';
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
        title: const Text('Util Widgets'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            children: [
              getHeaderWidget(theme: theme, title: "Text Carousel"),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SistchTextCarousel(
                  texts: [
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent et enim hendrerit, aliquet sem quis, faucibus elit. Praesent neque ex, suscipit et condimentum nec, scelerisque ac dui.",
                    "Nunc massa magna, laoreet eu diam nec, tincidunt porttitor nibh. Aenean fermentum, nulla eu molestie iaculis, enim ipsum ultricies libero, eget imperdiet nisi dolor eget risus. Morbi ac mi ex ultricies."
                        "Mauris tincidunt ultricies mauris, sit amet molestie eros elementum dapibus. Nam ipsum dui. Suspendisse vel diam mauris.",
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
              getHeaderWidget(theme: theme, title: "Streak Indicator"),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SistchTagStreakIndicator(
                  totalCount: 10,
                  currentCount: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
