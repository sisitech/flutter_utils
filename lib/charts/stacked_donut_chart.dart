import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// Constants
//
const double defChartWidth = 200.0;

// View
//
class SistchStackedDonutChart extends StatefulWidget {
  final List<double> dataSeries;
  final List<String> dtLabels;
  final List<Color>? dtColors;
  // final Axis? chartDirection;
  final String? chartTitle;
  final double? chartWidth;
  final Widget? centerWidget;
  final Color? firstColor;

  ///[SistchStackedDonutChart] renders custom Sisitech Stack of Donut Charts
  /// Required Fields:
  ///- List<double> dataSeries: single series of data points
  ///- List<String> dtLabels: list of labels for each data point
  const SistchStackedDonutChart({
    super.key,
    required this.dataSeries,
    required this.dtLabels,
    this.dtColors,
    // this.chartDirection,
    this.chartTitle,
    this.chartWidth = defChartWidth,
    this.centerWidget,
    this.firstColor,
  });

  @override
  State<SistchStackedDonutChart> createState() =>
      _SistchStackedDonutChartState();
}

class _SistchStackedDonutChartState extends State<SistchStackedDonutChart> {
  late StackedDonutChartController stackedDtChartCtrl;

  @override
  void initState() {
    super.initState();
    _initializeChartData();
  }

  void _initializeChartData() {
    stackedDtChartCtrl = Get.put(StackedDonutChartController(
      dataSeries: widget.dataSeries,
      dtLabels: widget.dtLabels,
      dtColors: widget.dtColors ?? getChartColors(widget.dataSeries.length),
      chartWidth: widget.chartWidth ?? defChartWidth,
      firstColor: widget.firstColor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // bool isHorizFormat = widget.chartDirection == Axis.horizontal;

    stackedDtChartCtrl.updateDtChart(
      dataSeries: widget.dataSeries,
      dtLabels: widget.dtLabels,
      dtColors: widget.dtColors,
      firstColor: widget.firstColor,
    );

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          if (widget.chartTitle != null)
            Text(
              widget.chartTitle!,
              style: textTheme.titleLarge!.copyWith(
                  color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 10),
          // isHorizFormat
          //     ? Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           _getChartSection(isHorizFormat, colorScheme),
          //           const SizedBox(width: 10),
          //           _getIndicatorsSection(isHorizFormat),
          //         ],
          //       )
          //     :

          Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getChartSection(false, colorScheme),
              const SizedBox(height: 15),
              _getIndicatorsSection(false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getChartSection(bool isHorizFormat, ColorScheme colorScheme) {
    return SizedBox(
      width: isHorizFormat
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width,
      // height: widget.chartWidth ?? defChartWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...stackedDtChartCtrl.chartData.map(
            (e) => CircularPercentIndicator(
              radius: e.radius,
              // lineWidth: 10.0,
              startAngle: e.startAngle,
              animation: true,
              animationDuration: 1000,
              percent: e.percent,
              backgroundColor: colorScheme.background,
              progressColor: e.sectionColor,
            ),
          ),
          widget.centerWidget ?? const SizedBox()
        ],
      ),
    );
  }

  Widget _getIndicatorsSection(bool isHorizFormat) {
    return
        // Container(
        //   margin: isHorizFormat
        //       ? null
        //       : EdgeInsets.only(left: MediaQuery.of(context).size.width / 12),
        //   width: isHorizFormat
        //       ? MediaQuery.of(context).size.width * 0.25
        //       : MediaQuery.of(context).size.width,
        //   child:
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stackedDtChartCtrl.donutChartIndicators
          .map((indicator) => indicator)
          .toList(),
      // ),
    );
  }
}

// Models
//
class SistchDtChartData {
  final double radius;
  final double percent;
  final Color sectionColor;
  final double startAngle;

  SistchDtChartData({
    required this.radius,
    required this.percent,
    required this.sectionColor,
    required this.startAngle,
  });
}

// Controller
//
class StackedDonutChartController extends GetxController {
  RxList<Widget> donutChartIndicators = <Widget>[].obs;
  RxList<SistchDtChartData> chartData = <SistchDtChartData>[].obs;
  // ----- State variables
  RxBool isDtChartLoading = false.obs;
// --- Holder variables
  List<Color> chartColors = [];
  //--- Passed variables
  List<double> dataSeries;
  List<String> dtLabels;
  List<Color>? dtColors;
  double? chartWidth;
  Color? firstColor;

  StackedDonutChartController({
    required this.dataSeries,
    required this.dtLabels,
    required this.firstColor,
    this.dtColors,
    this.chartWidth,
  }) {
    createDtChartData();
  }

  createDtChartData() {
    isDtChartLoading.value = true;

    chartColors = dtColors != null
        ? dtColors!
        : firstColor != null
            ? [firstColor!, ...getChartColors(dataSeries.length)]
            : getChartColors(dataSeries.length);
    double seriesTotal = getListOfDoublesSum(dataSeries);
    double startRadius = (chartWidth ?? defChartWidth) * 0.6;
    double radDcr = 10;
    double startAngle = 28;
    double angleIncr = 6;

    chartData.value = dataSeries.asMap().entries.map((entry) {
      int index = entry.key;
      var e = entry.value;
      var angle = startAngle + ((index + 1) * angleIncr);

      return SistchDtChartData(
        percent: e / seriesTotal,
        radius: startRadius - ((index + 1) * radDcr),
        sectionColor: chartColors[index],
        startAngle: index == 0 ? 335 : angle + ((index - 1) * angleIncr),
      );
    }).toList();

    donutChartIndicators.value = getChartIndicators(dtLabels, chartColors,
        values: chartData.map((e) => e.percent * 100).toList(),
        isPercent: true);

    isDtChartLoading.value = false;
  }

  void updateDtChart({
    required List<double> dataSeries,
    required List<String> dtLabels,
    Color? firstColor,
    List<Color>? dtColors,
    double? chartWidth,
  }) {
    this.dataSeries = dataSeries;
    this.dtLabels = dtLabels;
    this.dtColors = dtColors;
    this.chartWidth = chartWidth;
    this.firstColor = firstColor;

    createDtChartData();
  }
}
