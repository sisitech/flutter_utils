import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/beta/bar_chart_beta/bar_chart_controller_beta.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SistchBarChartBeta extends StatelessWidget {
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

  const SistchBarChartBeta({
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
    this.tipPreText = "KES.",
  });

  @override
  Widget build(BuildContext context) {
    final barChartCtrl = Get.put(
        BarChartControllerBeta(
          dataSeries: dataSeries,
          seriesColors: seriesColors,
          xAxisLabels: xAxisLabels,
          textColor: textColor,
          seriesLabels: seriesLabels,
        ),
        tag: name);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
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
        if (dataSeries.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(
                () => Wrap(
                  children: barChartCtrl.barChartIndicators
                      .map((indicator) => indicator)
                      .toList(),
                ),
              ),
              IconButton(
                onPressed: barChartCtrl.onSwapChartSeries,
                icon: const Icon(Icons.swap_horiz),
              )
            ],
          ),
        SizedBox(
          height: chartHeight,
          child: Obx(
            () => barChartCtrl.isBarChartLoading.value
                ? loadingWidget("Loading ...")
                : BarChart(
                    BarChartData(
                      maxY: barChartCtrl.chartData.value.maxY,
                      minY: 0.0,
                      barGroups: barChartCtrl.chartData.value.barGroupData,
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
                            getTitlesWidget: barChartCtrl.getXAxisTitles,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: barChartCtrl.getYAxisTitles,
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
                          getTooltipItem: (BarChartGroupData group,
                              int groupIndex,
                              BarChartRodData rod,
                              int rodIndex) {
                            final NumberFormat currencyFormat =
                                NumberFormat.currency(
                              symbol: tipPreText,
                              decimalDigits: 2,
                            );

                            return BarTooltipItem(
                              "${xAxisLabels[group.x]}: ",
                              TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: currencyFormat.format(rod.toY),
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
        ),
      ],
    );
  }
}
