import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/functions.dart';

// Constants
//

// Models
//

// View
//
class SistchPieDonutChart extends StatelessWidget {
  final List<double> dataSeries;
  final List<String> pieLabels;
  final List<Color>? pieColors;
  final Axis? chartDirection;
  final double? chartHeight;
  final double? donutCenterRadius;
  final Color? bgColor;
  final bool? hideIndicators;
  final String? chartTitle;
  final double? badgeOffset;
  final double? titleOffset;
  final bool? hideIndicatorExt;
  final bool? useIndIcons;

  ///[SistchPieDonutChart] renders custom Sisitech Pie or Donut Chart
  /// Required Fields:
  ///- List<double> dataSeries: single series of data points
  ///- List<String> pieLabels: list of labels for each data point
  /// Other Fields:
  ///- double? donutCenterRadius = 0: to get pie chart instead of donut
  ///
  const SistchPieDonutChart({
    super.key,
    required this.dataSeries,
    required this.pieLabels,
    this.pieColors,
    this.chartDirection,
    this.chartHeight = 200,
    this.donutCenterRadius,
    this.bgColor,
    this.hideIndicators,
    this.chartTitle,
    this.badgeOffset,
    this.titleOffset,
    this.hideIndicatorExt,
    this.useIndIcons,
  });

  /// [_createChartData]
  ///Returns [0]: chartData, [1] chartIndicators
  _createChartData() {
    List<Color> chartColors = pieColors ?? getChartColors(dataSeries.length);
    List<Widget> pieChartIndicators = getChartIndicators(pieLabels, chartColors,
        values: hideIndicatorExt == true ? null : dataSeries,
        isPercent: false,
        useIcons: useIndIcons);

    List<PieChartSectionData> chartData =
        getPieChartSections(chartColors: chartColors);

    return [chartData, pieChartIndicators];
  }

  List<PieChartSectionData> getPieChartSections(
      {required List<Color> chartColors}) {
    List<PieChartSectionData> pieSections = [];
    double total = getListOfDoublesSum(dataSeries);

    for (int i = 0; i < dataSeries.length; i++) {
      String percentTitle =
          "${((dataSeries[i] / total) * 100).toStringAsFixed(1)}%";
      String sectionTitle = hideIndicators == true
          ? "${pieLabels[i]} ($percentTitle)"
          : percentTitle;

      PieChartSectionData pieSection = PieChartSectionData(
        color: chartColors[i],
        value: dataSeries[i],
        title: hideIndicators == true ? sectionTitle : "",
        titleStyle: TextStyle(
          color: defaultTextChartColors[chartColors[i]],
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        badgeWidget: hideIndicators == true
            ? null
            : Text(
                percentTitle,
                style: TextStyle(
                  color: bgColor ?? Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
        radius: donutCenterRadius != 0 ? null : 80,
        badgePositionPercentageOffset: badgeOffset,
        titlePositionPercentageOffset: titleOffset,
      );
      pieSections.add(pieSection);
    }
    return pieSections;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    bool isHorizFormat = chartDirection == Axis.horizontal;

    var createChartRes = _createChartData();
    List<PieChartSectionData> pieSections = createChartRes[0];
    List<Widget> chartIndicators = createChartRes[1];

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
          isHorizFormat
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getChartSection(
                      isHorizFormat: isHorizFormat,
                      context: context,
                      pieSections: pieSections,
                    ),
                    const SizedBox(width: 10),
                    hideIndicators == true
                        ? const SizedBox()
                        : _getIndicatorsSection(
                            isHorizFormat: isHorizFormat,
                            context: context,
                            chartIndicators: chartIndicators,
                          ),
                  ],
                )
              : Column(
                  children: [
                    _getChartSection(
                      isHorizFormat: isHorizFormat,
                      context: context,
                      pieSections: pieSections,
                    ),
                    hideIndicators == true
                        ? const SizedBox()
                        : _getIndicatorsSection(
                            isHorizFormat: isHorizFormat,
                            context: context,
                            chartIndicators: chartIndicators,
                          ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _getChartSection({
    required bool isHorizFormat,
    required BuildContext context,
    required List<PieChartSectionData> pieSections,
  }) {
    return SizedBox(
      width: isHorizFormat
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width,
      height: chartHeight,
      child: PieChart(
        PieChartData(
          sections: pieSections,
          startDegreeOffset: 180,
          borderData: FlBorderData(show: false),
          centerSpaceRadius: donutCenterRadius,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // setState(() {
              //   if (!event.isInterestedForInteractions ||
              //       pieTouchResponse == null ||
              //       pieTouchResponse.touchedSection == null) {
              //     touchedIndex = -1;
              //     return;
              //   }
              //   touchedIndex =
              //       pieTouchResponse.touchedSection!.touchedSectionIndex;
              // });
            },
          ),
        ),
      ),
    );
  }

  Widget _getIndicatorsSection({
    required bool isHorizFormat,
    required BuildContext context,
    required List<Widget> chartIndicators,
  }) {
    return Container(
      margin: isHorizFormat
          ? null
          : EdgeInsets.only(left: MediaQuery.of(context).size.width / 12),
      width: isHorizFormat ? MediaQuery.of(context).size.width * 0.25 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chartIndicators.map((indicator) => indicator).toList(),
      ),
    );
  }
}