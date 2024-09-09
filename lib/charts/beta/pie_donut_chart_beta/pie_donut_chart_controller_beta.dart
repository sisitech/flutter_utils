import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/pie_donut_chart/pie_chart_controller.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';

class PieDonutChartControllerBeta extends GetxController {
  // Observable state
  Rx<SistchPieDonutChartData> chartData = SistchPieDonutChartData(
    pieChartSections: [],
  ).obs;
  RxList<Widget> pieChartIndicators = <Widget>[].obs;
  RxBool isPieChartLoading = false.obs;

  late List<double> dataSeries;
  late List<String> pieLabels;
  late bool isDonutChart;
  Color? bgColor;
  List<Color>? pieColors;
  bool? hideIndicators;
  double? badgeOffset;
  double? titleOffset;
  bool? hideIndicatorExt;
  bool? useIndIcons;

  PieDonutChartControllerBeta({
    required this.dataSeries,
    required this.pieLabels,
    required this.isDonutChart,
    this.bgColor,
    this.pieColors,
    this.hideIndicators,
    this.badgeOffset,
    this.titleOffset,
    this.hideIndicatorExt,
    this.useIndIcons,
  }) {
    _initializeChart();
  }

  List<Color> chartColors = defaultChartColors;

  void _initializeChart() {
    isPieChartLoading.value = true;

    chartColors = pieColors ?? getChartColors(dataSeries.length);
    pieChartIndicators.value = getChartIndicators(
      pieLabels,
      chartColors,
      values: hideIndicatorExt == true ? null : dataSeries,
      isPercent: false,
      useIcons: useIndIcons,
    );

    chartData.value = SistchPieDonutChartData(
      pieChartSections: _getPieChartSections(),
    );

    isPieChartLoading.value = false;
  }

  void updateChart({
    required List<double> dataSeries,
    required List<String> pieLabels,
    required bool isDonutChart,
    Color? bgColor,
    List<Color>? pieColors,
    bool? hideIndicators,
    double? badgeOffset,
    double? titleOffset,
    bool? hideIndicatorExt,
    bool? useIndIcons,
  }) {
    this.dataSeries = dataSeries;
    this.pieLabels = pieLabels;
    this.isDonutChart = isDonutChart;
    this.bgColor = bgColor;
    this.pieColors = pieColors;
    this.hideIndicators = hideIndicators;
    this.badgeOffset = badgeOffset;
    this.titleOffset = titleOffset;
    this.hideIndicatorExt = hideIndicatorExt;
    this.useIndIcons = useIndIcons;

    _initializeChart();
  }

  List<PieChartSectionData> _getPieChartSections() {
    final double total = getListOfDoublesSum(dataSeries);
    return List.generate(dataSeries.length, (i) {
      final String percentTitle =
          "${((dataSeries[i] / total) * 100).toStringAsFixed(1)}%";
      final String sectionTitle = hideIndicators == true
          ? "${pieLabels[i]} ($percentTitle)"
          : percentTitle;

      return PieChartSectionData(
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
        radius: isDonutChart ? null : 80,
        badgePositionPercentageOffset: badgeOffset,
        titlePositionPercentageOffset: titleOffset,
      );
    });
  }
}
