import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';

class SistchBarChartData {
  List<BarChartGroupData> barGroupData;
  List<String> xAxisLabels;
  double maxY;
  List<Color> seriesColors;
  List<String> seriesLabels;
  Color? textColor;
  bool? useIndIcons;

  SistchBarChartData({
    required this.barGroupData,
    required this.xAxisLabels,
    required this.maxY,
    required this.seriesColors,
    required this.seriesLabels,
    this.textColor,
    this.useIndIcons,
  });

  SistchBarChartData copyWith({
    List<BarChartGroupData>? barGroupData,
    List<String>? xAxisLabels,
    double? maxY,
    List<Color>? seriesColors,
    List<String>? seriesLabels,
    Color? textColor,
    bool? useIndIcons,
  }) {
    return SistchBarChartData(
      barGroupData: barGroupData ?? this.barGroupData,
      xAxisLabels: xAxisLabels ?? this.xAxisLabels,
      maxY: maxY ?? this.maxY,
      seriesColors: seriesColors ?? this.seriesColors,
      seriesLabels: seriesLabels ?? this.seriesLabels,
      textColor: textColor ?? this.textColor,
      useIndIcons: useIndIcons ?? this.useIndIcons,
    );
  }
}

class BarChartController extends GetxController {
  Rx<SistchBarChartData> chartData = SistchBarChartData(
    barGroupData: [],
    xAxisLabels: [],
    maxY: 0,
    seriesColors: [],
    seriesLabels: [],
  ).obs;
  RxList<Widget> barChartIndicators = <Widget>[].obs;
  int currentSeriesIdx = -1;
  int touchedGroupIndex = -1;
  RxBool isBarChartLoading = false.obs;
  List<Color> barChartColors = [];
  List<String> barSeriesLabels = [];
  late List<List<double>> dataSeries;
  late List<String> xAxisLabels;
  Color? textColor;
  List<Color>? seriesColors;
  List<String>? seriesLabels;
  bool? useIndIcons;

  BarChartController({
    required List<List<double>> dataSeries,
    required List<String> xAxisLabels,
    this.seriesColors,
    this.seriesLabels,
    this.textColor,
    this.useIndIcons,
  }) {
    this.dataSeries = dataSeries;
    this.xAxisLabels = xAxisLabels;
    barSeriesLabels =
        seriesLabels ?? List.generate(dataSeries.length, (i) => "Series $i");
    barChartColors = seriesColors ?? getChartColors(dataSeries.length);
    if (barSeriesLabels.length != dataSeries.length ||
        barChartColors.length != dataSeries.length) {
      throw ArgumentError(
          "The length of seriesLabels or seriesColors does not match the data series length.");
    }
    createBarChartData();
  }

  void createBarChartData() {
    isBarChartLoading.value = true;

    List<List<double>> currentSeries;
    List<String> currentSeriesLabels;
    List<Color> currentSeriesColors;

    if (currentSeriesIdx == -1) {
      currentSeries = dataSeries;
      currentSeriesLabels = barSeriesLabels;
      currentSeriesColors = barChartColors;
    } else {
      currentSeries = [dataSeries[currentSeriesIdx]];
      currentSeriesLabels = [barSeriesLabels[currentSeriesIdx]];
      currentSeriesColors = [barChartColors[currentSeriesIdx]];
    }

    barChartIndicators.value = getChartIndicators(
        currentSeriesLabels, currentSeriesColors,
        useIcons: useIndIcons);

    final barGroupData = getBarGroupData(currentSeries, currentSeriesColors);

    chartData.value = SistchBarChartData(
      barGroupData: barGroupData,
      xAxisLabels: xAxisLabels,
      maxY: getMaxY(currentSeries),
      textColor: textColor,
      seriesColors: currentSeriesColors,
      seriesLabels: currentSeriesLabels,
      useIndIcons: useIndIcons,
    );

    isBarChartLoading.value = false;
  }

  void updateChart({
    required List<List<double>> dataSeries,
    List<Color>? seriesColors,
    required List<String> xAxisLabels,
    required Color? textColor,
    required List<String>? seriesLabels,
    bool? useIndIcons,
  }) {
    this.dataSeries = dataSeries;
    this.seriesColors = seriesColors;
    this.xAxisLabels = xAxisLabels;
    this.textColor = textColor;
    this.seriesLabels = seriesLabels;
    this.useIndIcons = useIndIcons;

    createBarChartData();
  }

  List<BarChartGroupData> getBarGroupData(
      List<List<double>> series, List<Color> colors) {
    List<BarChartGroupData> barGroupData = [];

    for (int x = 0; x < series[0].length; x++) {
      var barData = BarChartGroupData(
        barsSpace: 2.0,
        x: x,
        barRods: getBarRods(series, colors, x),
      );
      barGroupData.add(barData);
    }
    return barGroupData;
  }

  List<BarChartRodData> getBarRods(
      List<List<double>> series, List<Color> colors, int seriesIndex) {
    List<BarChartRodData> barRods = [];
    for (int index = 0; index < series.length; index++) {
      var e = series[index];
      barRods.add(
        BarChartRodData(
          toY: e[seriesIndex],
          color: colors[index],
          width: 8.0,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
        ),
      );
    }
    return barRods;
  }

  double getMaxY(List<List<double>> dataSeries) {
    List<double> allPoints = [];
    for (var series in dataSeries) {
      for (var point in series) {
        allPoints.add(point);
      }
    }
    return allPoints.reduce(max);
  }

  Widget getXAxisTitles(double xValue, TitleMeta meta) {
    String text = xAxisLabels[xValue.toInt()];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 11),
      ),
    );
  }

  Widget getYAxisTitles(double yValue, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: TextStyle(color: textColor, fontSize: 11),
      ),
    );
  }

  void onSwapChartSeries() {
    currentSeriesIdx++;
    if (currentSeriesIdx < dataSeries.length) {
      createBarChartData();
    } else {
      currentSeriesIdx = -1;
      createBarChartData();
    }
  }
}
