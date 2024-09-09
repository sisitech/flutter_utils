import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/pie_donut_chart/pie_chart_controller.dart';
import 'package:get/get.dart';

class SistchPieDonutChartBeta extends StatelessWidget {
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

  const SistchPieDonutChartBeta({
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

  @override
  Widget build(BuildContext context) {
    final pieChartCtrl = Get.put(PieDonutChartController(
      dataSeries: dataSeries,
      pieLabels: pieLabels,
      isDonutChart: donutCenterRadius != 0,
      bgColor: bgColor,
      pieColors: pieColors,
      hideIndicators: hideIndicators,
      badgeOffset: badgeOffset,
      titleOffset: titleOffset,
      hideIndicatorExt: hideIndicatorExt,
      useIndIcons: useIndIcons,
    ));

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    bool isHorizFormat = chartDirection == Axis.horizontal;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          if (chartTitle != null)
            Text(
              chartTitle!,
              style: textTheme.titleLarge!.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          isHorizFormat
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getChartSection(isHorizFormat, pieChartCtrl),
                    const SizedBox(width: 10),
                    hideIndicators == true
                        ? const SizedBox()
                        : _getIndicatorsSection(isHorizFormat, pieChartCtrl),
                  ],
                )
              : Column(
                  children: [
                    _getChartSection(isHorizFormat, pieChartCtrl),
                    hideIndicators == true
                        ? const SizedBox()
                        : _getIndicatorsSection(isHorizFormat, pieChartCtrl),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _getChartSection(
      bool isHorizFormat, PieDonutChartController pieChartCtrl) {
    return SizedBox(
      width: isHorizFormat ? Get.width * 0.5 : Get.width,
      height: chartHeight,
      child: Obx(
        () => PieChart(
          PieChartData(
            sections: pieChartCtrl.chartData.value.pieChartSections,
            startDegreeOffset: 180,
            borderData: FlBorderData(show: false),
            centerSpaceRadius: donutCenterRadius,
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                // Handle touch events if necessary
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _getIndicatorsSection(
      bool isHorizFormat, PieDonutChartController pieChartCtrl) {
    return Obx(
      () => Container(
        margin: isHorizFormat ? null : EdgeInsets.only(left: Get.width / 12),
        width: isHorizFormat ? Get.width * 0.25 : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pieChartCtrl.pieChartIndicators
              .map((indicator) => indicator)
              .toList(),
        ),
      ),
    );
  }
}
