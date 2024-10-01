import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/utils.dart';
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
  final bool isHalfArcChart;
  final double? sectionsSpace;
  final String indicatorPrefix;
  final String? selectedIndicator;
  final Function(String val)? onIndicatorTap;
  final Widget? centerWidget;

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
    this.chartHeight = 220,
    this.donutCenterRadius,
    this.bgColor,
    this.hideIndicators,
    this.chartTitle,
    this.badgeOffset,
    this.titleOffset,
    this.hideIndicatorExt,
    this.useIndIcons,
    this.isHalfArcChart = false,
    this.sectionsSpace,
    this.indicatorPrefix = '',
    this.onIndicatorTap,
    this.selectedIndicator,
    this.centerWidget,
  });

  /// [_createChartData]
  ///Returns [0]: chartData, [1] chartIndicators
  _createChartData() {
    List<double> chartSeries =
        isHalfArcChart ? getHalfArcChartValues(dataSeries) : dataSeries;

    List<Color> chartColors = pieColors ?? getChartColors(chartSeries.length);
    List<Widget> pieChartIndicators = getChartIndicators(
      pieLabels,
      chartColors,
      hideIndicatorExt == true ? [] : dataSeries,
      useIcons: useIndIcons,
      indicatorPrefix: indicatorPrefix,
      selectedIndicator: selectedIndicator,
      onIndicatorTap: chartDirection != Axis.horizontal ? onIndicatorTap : null,
    );

    List<PieChartSectionData> chartData =
        getPieChartSections(chartColors: chartColors);

    return [chartData, pieChartIndicators];
  }

  List<PieChartSectionData> getPieChartSections(
      {required List<Color> chartColors}) {
    List<PieChartSectionData> pieSections = [];
    double total = getListOfDoublesSum(dataSeries);
    List<double> chartSeries =
        isHalfArcChart ? getHalfArcChartValues(dataSeries) : dataSeries;
    int chartSeriesMax =
        isHalfArcChart ? chartSeries.length - 1 : chartSeries.length;

    for (int i = 0; i < chartSeries.length; i++) {
      double percent = (chartSeries[i] / total) * 100;
      String percentTitle = "${percent.toStringAsFixed(1)}%";
      String sectionTitle = hideIndicators == true && i < chartSeriesMax
          ? "${pieLabels[i]} • $percentTitle"
          : percentTitle;
      Color? textColor =
          i < chartSeriesMax ? defaultTextChartColors[chartColors[i]] : null;

      PieChartSectionData pieSection = PieChartSectionData(
        color: i < chartSeriesMax ? chartColors[i] : null,
        value: percent,
        title: hideIndicators == true ? sectionTitle : "",
        titleStyle: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        badgeWidget: hideIndicators == true
            ? null
            : Text(
                percentTitle,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
        radius: isHalfArcChart
            ? null
            : donutCenterRadius != 0
                ? null
                : 80,
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
          if (chartTitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                chartTitle!,
                style: textTheme.titleLarge!.copyWith(
                    color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          isHorizFormat
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _getChartSection(
                        isHorizFormat: isHorizFormat,
                        context: context,
                        pieSections: pieSections,
                        sectionsSpace: sectionsSpace,
                        centerWidget: centerWidget,
                      ),
                    ),
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
                      sectionsSpace: sectionsSpace,
                      centerWidget: centerWidget,
                    ),
                    const SizedBox(height: 10),
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
    double? sectionsSpace,
    Widget? centerWidget,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: isHalfArcChart ? 0.5 : 1,
            child: SizedBox(
              height: chartHeight,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  startDegreeOffset: 180,
                  sectionsSpace: sectionsSpace,
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
            ),
          ),
        ),
        if (centerWidget != null) centerWidget
      ],
    );
  }

  Widget _getIndicatorsSection({
    required bool isHorizFormat,
    required BuildContext context,
    required List<Widget> chartIndicators,
  }) {
    return SizedBox(
      width: isHorizFormat ? MediaQuery.of(context).size.width * 0.25 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chartIndicators.map((indicator) => indicator).toList(),
      ),
    );
  }

  List<double> getHalfArcChartValues(List<double> ogSeries) {
    List<double> values = [];
    double total = getListOfDoublesSum(dataSeries);
    for (var val in ogSeries) {
      values.add(val / 2);
    }
    values.add(total / 2);
    return values;
  }
}
