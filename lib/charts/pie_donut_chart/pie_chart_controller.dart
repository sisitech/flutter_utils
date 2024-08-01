import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';

// Models
//
class SistchPieDonutChartData {
  List<PieChartSectionData> pieChartSections;

  SistchPieDonutChartData({
    required this.pieChartSections,
  });
}

// Controller
//
class PieDonutChartController extends GetxController {
  // --- widget variables
  Rx<SistchPieDonutChartData> chartData = SistchPieDonutChartData(
    pieChartSections: [],
  ).obs;
  RxList<Widget> pieChartIndicators = <Widget>[].obs;
  // ----- State variables
  RxBool isPieChartLoading = false.obs;
  int touchedIndex = -1;
  // --- Holder variables
  List<Color> chartColors = [];
  //--- Passed variables
  List<double> dataSeries;
  List<String> pieLabels;
  bool isDonutChart;
  Color? bgColor;
  List<Color>? pieColors;
  bool? hideIndicators;
  double? badgeOffset;
  double? titleOffset;
  bool? hideIndicatorExt;

  PieDonutChartController({
    required this.dataSeries,
    required this.pieLabels,
    required this.isDonutChart,
    this.bgColor,
    this.pieColors,
    this.hideIndicators,
    this.badgeOffset,
    this.titleOffset,
    this.hideIndicatorExt,
  }) {
    createPieChartData();
  }

  createPieChartData() {
    isPieChartLoading.value = true;

    chartColors = pieColors ?? getChartColors(dataSeries.length);
    pieChartIndicators.value = getChartIndicators(pieLabels, chartColors,
        values: hideIndicatorExt == true ? null : dataSeries, isPercent: false);

    chartData.value = SistchPieDonutChartData(
      pieChartSections: getPieChartSections(),
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
  }) {
    this.dataSeries = dataSeries;
    this.pieLabels = pieLabels;
    this.pieColors = pieColors;
    this.isDonutChart = isDonutChart;
    this.bgColor = bgColor;
    this.hideIndicators = hideIndicators;
    this.titleOffset = titleOffset;
    this.badgeOffset = badgeOffset;
    this.hideIndicatorExt = hideIndicatorExt;

    createPieChartData();
  }

  List<PieChartSectionData> getPieChartSections() {
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
          color: textChartColors[chartColors[i]],
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
      pieSections.add(pieSection);
    }
    return pieSections;
  }
}
