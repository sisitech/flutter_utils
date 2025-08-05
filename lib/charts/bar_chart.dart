import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/utils.dart';
import 'package:flutter_utils/utils/functions.dart';

// Constants
//

// Models
//
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

// View
//
class SistchBarChart extends StatefulWidget {
  final List<List<double>> dataSeries;
  final List<String> xAxisLabels;
  final List<String>? seriesLabels;
  final List<Color>? seriesColors;
  final Color? textColor;
  final Color? bgColor;
  final double? chartHeight;
  final String? tipPreText;
  final String? chartTitle;
  final String? name;
  final bool? useIndIcons;

  const SistchBarChart({
    super.key,
    required this.dataSeries,
    required this.xAxisLabels,
    this.seriesLabels,
    this.seriesColors,
    this.bgColor,
    this.textColor,
    this.chartTitle,
    this.name,
    this.chartHeight = 200,
    this.tipPreText = "",
    this.useIndIcons,
  });

  @override
  State<SistchBarChart> createState() => _SistchBarChartState();
}

class _SistchBarChartState extends State<SistchBarChart> {
  int currentSeriesIdx = -1;

  /// [_createChartData]
  ///Returns [0]: chartData, [1] chartIndicators
  _createChartData() {
    List<List<double>> currentSeries;
    List<String> currentSeriesLabels;
    List<Color> currentSeriesColors;

    List<String> barSeriesLabels = widget.seriesLabels ??
        List.generate(widget.dataSeries.length, (i) => "Series $i");
    List<Color> barChartColors =
        widget.seriesColors ?? getChartColors(widget.dataSeries.length);

    if (currentSeriesIdx == -1) {
      currentSeries = widget.dataSeries;
      currentSeriesLabels = barSeriesLabels;
      currentSeriesColors = barChartColors;
    } else {
      currentSeries = [widget.dataSeries[currentSeriesIdx]];
      currentSeriesLabels = [barSeriesLabels[currentSeriesIdx]];
      currentSeriesColors = [barChartColors[currentSeriesIdx]];
    }

    List<Widget> barChartIndicators = getChartIndicators(
        currentSeriesLabels, currentSeriesColors, [],
        useIcons: widget.useIndIcons);

    final barGroupData = getBarGroupData(currentSeries, currentSeriesColors);

    SistchBarChartData chartData = SistchBarChartData(
      barGroupData: barGroupData,
      xAxisLabels: widget.xAxisLabels,
      maxY: getMaxY(currentSeries),
      textColor: widget.textColor,
      seriesColors: currentSeriesColors,
      seriesLabels: currentSeriesLabels,
      useIndIcons: widget.useIndIcons,
    );

    return [chartData, barChartIndicators];
  }

  void onSwapChartSeries() {
    currentSeriesIdx++;
    if (currentSeriesIdx < widget.dataSeries.length) {
      _createChartData();
    } else {
      currentSeriesIdx = -1;
      _createChartData();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var createChartRes = _createChartData();
    SistchBarChartData chartData = createChartRes[0];
    List<Widget> chartIndicators = createChartRes[1];

    return Column(
      children: [
        const SizedBox(height: 10),
        if (widget.chartTitle != null)
          Text(
            widget.chartTitle!,
            style: textTheme.titleLarge!.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (widget.dataSeries.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Wrap(
                  children:
                      chartIndicators.map((indicator) => indicator).toList(),
                ),
                IconButton(
                  onPressed: onSwapChartSeries,
                  icon: const Icon(Icons.swap_horiz),
                )
              ],
            ),
          ),
        SizedBox(
          height: widget.chartHeight,
          child: BarChart(
            BarChartData(
              maxY: chartData.maxY,
              minY: 0.0,
              barGroups: chartData.barGroupData,
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getXAxisTitles,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: getYAxisTitles,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              gridData: FlGridData(show: true, drawVerticalLine: false),
              groupsSpace: 6.0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withValues(alpha: 0.4),
                  // getTooltipColor: (BarChartGroupData data) => Theme.of(context)
                  //     .colorScheme
                  //     .surfaceVariant
                  //     .withValues(alpha: 0.4),
                  getTooltipItem: (BarChartGroupData group, int groupIndex,
                      BarChartRodData rod, int rodIndex) {
                    return BarTooltipItem(
                      "${widget.xAxisLabels[group.x]}: ",
                      TextStyle(
                        color: widget.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              "${widget.tipPreText}${getThousandsNumber(rod.toY)}",
                          style: TextStyle(
                            color: rod.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  },
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
    String text = widget.xAxisLabels[xValue.toInt()];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: TextStyle(color: widget.textColor, fontSize: 11),
      ),
    );
  }

  Widget getYAxisTitles(double yValue, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: TextStyle(color: widget.textColor, fontSize: 11),
      ),
    );
  }
}
