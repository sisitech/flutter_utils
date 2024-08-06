import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/bar_chart/bar_chart_controller.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  final bool? useIndIcons;

  ///[SistchBarChart] renders custom Sisitech Bar Chart
  /// Required Fields:
  ///- List<List<double>> dataSeries: list of series of data points
  ///- List<String> xAxisLabels: list of x-axis titles
  const SistchBarChart(
      {super.key,
      required this.dataSeries,
      required this.xAxisLabels,
      this.seriesLabels,
      this.seriesColors,
      this.bgColor,
      this.useIndIcons,
      this.textColor,
      this.chartTitle,
      this.chartHeight = 200,
      this.tipPreText = "KES."});

  @override
  State<SistchBarChart> createState() => _SistchBarChartState();
}

class _SistchBarChartState extends State<SistchBarChart> {
  late BarChartController barChartCtrl;

  @override
  void initState() {
    super.initState();
    barChartCtrl = Get.put(BarChartController(
      dataSeries: widget.dataSeries,
      seriesColors: widget.seriesColors,
      xAxisLabels: widget.xAxisLabels,
      textColor: widget.textColor,
      seriesLabels: widget.seriesLabels,
      useIndIcons: widget.useIndIcons,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    barChartCtrl.updateChart(
      dataSeries: widget.dataSeries,
      seriesColors: widget.seriesColors,
      xAxisLabels: widget.xAxisLabels,
      textColor: widget.textColor,
      seriesLabels: widget.seriesLabels,
      useIndIcons: widget.useIndIcons,
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
          if (widget.dataSeries.length > 1)
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
                    icon: const Icon(Icons.swap_horiz))
              ],
            ),
          SizedBox(
            height: widget.chartHeight,
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
                                width: 1, color: Theme.of(context).hintColor),
                          ),
                        ),
                        gridData:
                            FlGridData(show: true, drawVerticalLine: false),
                        groupsSpace: 6.0,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (BarChartGroupData group,
                                int groupIndex,
                                BarChartRodData rod,
                                int rodIndex) {
                              final NumberFormat currencyFormat =
                                  NumberFormat.currency(
                                      symbol: widget.tipPreText,
                                      decimalDigits: 2);

                              return BarTooltipItem(
                                "${widget.xAxisLabels[group.x]}: ",
                                TextStyle(
                                  color: widget.textColor,
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
                                horizontal: 8, vertical: 2),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
