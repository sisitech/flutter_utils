import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/utils.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// Constants
//
const double defChartWidth = 200.0;

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

// View
//
class SistchStackedDonutChart extends StatelessWidget {
  final List<double> dataSeries;
  final List<String> chartLabels;
  final List<Color>? dtColors;
  final Axis? chartDirection;
  final String? chartTitle;
  final double? chartWidth;
  final Widget? centerWidget;
  final Color? firstColor;
  final bool? useIndIcons;
  final double? firstStartAngle;

  ///[SistchStackedDonutChart] renders custom Sisitech Stack of Donut Charts
  /// Required Fields:
  ///- List<double> dataSeries: single series of data points
  ///- List<String> chartLabels: list of labels for each data point
  const SistchStackedDonutChart({
    super.key,
    required this.dataSeries,
    required this.chartLabels,
    this.dtColors,
    this.chartDirection,
    this.chartTitle,
    this.chartWidth = defChartWidth,
    this.centerWidget,
    this.firstColor,
    this.useIndIcons,
    this.firstStartAngle,
  });

  /// [_createChartData]
  ///Returns [0]: chartData, [1] chartIndicators
  List<dynamic> _createChartData() {
    List<Color> chartColors = dtColors != null
        ? dtColors!
        : firstColor != null
            ? [firstColor!, ...getChartColors(dataSeries.length)]
            : getChartColors(dataSeries.length);
    double seriesTotal = getListOfDoublesSum(dataSeries);
    double startRadius = (chartWidth ?? defChartWidth) * 0.6;
    double radDcr = 10;
    double startAngle = 28;
    double angleIncr = 6;

    List<SistchDtChartData> chartData = dataSeries.asMap().entries.map((entry) {
      int index = entry.key;
      var e = entry.value;
      var angle = startAngle + ((index + 1) * angleIncr);

      return SistchDtChartData(
        percent: e / seriesTotal,
        radius: startRadius - ((index + 1) * radDcr),
        sectionColor: chartColors[index],
        startAngle: index == 0
            ? (firstStartAngle ?? 335)
            : angle + ((index - 1) * angleIncr),
      );
    }).toList();

    List<Widget> donutChartIndicators = getChartIndicators(
        chartLabels, chartColors,
        values: chartData.map((e) => e.percent * 100).toList(),
        useIcons: useIndIcons,
        isPercent: true);

    return [chartData, donutChartIndicators];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // bool isHorizFormat = chartDirection == Axis.horizontal;

    var createChartRes = _createChartData();
    List<SistchDtChartData> chartData = createChartRes[0];
    List<Widget> donutChartIndicators = createChartRes[1];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          if (chartTitle != null)
            Text(
              chartTitle!,
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
              _getChartSection(
                isHorizFormat: false,
                colorScheme: colorScheme,
                context: context,
                chartData: chartData,
              ),
              const SizedBox(height: 15),
              _getIndicatorsSection(
                isHorizFormat: false,
                donutChartIndicators: donutChartIndicators,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getChartSection({
    required bool isHorizFormat,
    required ColorScheme colorScheme,
    required BuildContext context,
    required List<SistchDtChartData> chartData,
  }) {
    return SizedBox(
      width: isHorizFormat
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width,
      // height: widget.chartWidth ?? defChartWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...chartData.map(
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
          centerWidget ?? const SizedBox()
        ],
      ),
    );
  }

  Widget _getIndicatorsSection({
    required bool isHorizFormat,
    required List<Widget> donutChartIndicators,
  }) {
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
      children: donutChartIndicators.map((indicator) => indicator).toList(),
      // ),
    );
  }
}
