import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/pie_donut_chart/pie_chart_controller.dart';
import 'package:flutter_utils/utils/global_widgets.dart';
import 'package:get/get.dart';

class SistchPieDonutChart extends StatefulWidget {
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
  });

  @override
  State<SistchPieDonutChart> createState() => _SistchPieDonutChartState();
}

class _SistchPieDonutChartState extends State<SistchPieDonutChart> {
  late PieDonutChartController pieChartCtrl;

  @override
  void initState() {
    super.initState();
    _initializeChartData();
  }

  void _initializeChartData() {
    pieChartCtrl = Get.put(PieDonutChartController(
      dataSeries: widget.dataSeries,
      pieLabels: widget.pieLabels,
      pieColors: widget.pieColors ?? getChartColors(widget.dataSeries.length),
      bgColor: widget.bgColor,
      isDonutChart: widget.donutCenterRadius != 0,
      hideIndicators: widget.hideIndicators,
      badgeOffset: widget.badgeOffset,
      titleOffset: widget.titleOffset,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    bool isHorizFormat = widget.chartDirection == Axis.horizontal;

    pieChartCtrl.updateChart(
      dataSeries: widget.dataSeries,
      pieLabels: widget.pieLabels,
      pieColors: widget.pieColors,
      isDonutChart: widget.donutCenterRadius != 0,
      bgColor: widget.bgColor,
      hideIndicators: widget.hideIndicators,
      badgeOffset: widget.badgeOffset,
      titleOffset: widget.titleOffset,
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
          isHorizFormat
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getChartSection(isHorizFormat),
                    const SizedBox(width: 10),
                    widget.hideIndicators == true
                        ? const SizedBox()
                        : _getIndicatorsSection(isHorizFormat),
                  ],
                )
              : Column(
                  children: [
                    _getChartSection(isHorizFormat),
                    widget.hideIndicators == true
                        ? const SizedBox()
                        : _getIndicatorsSection(isHorizFormat),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _getChartSection(bool isHorizFormat) {
    return SizedBox(
      width: isHorizFormat
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width,
      height: widget.chartHeight,
      child: PieChart(
        PieChartData(
          sections: pieChartCtrl.chartData.value.pieChartSections,
          startDegreeOffset: 180,
          borderData: FlBorderData(show: false),
          centerSpaceRadius: widget.donutCenterRadius,
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

  Widget _getIndicatorsSection(bool isHorizFormat) {
    return Container(
      margin: isHorizFormat
          ? null
          : EdgeInsets.only(left: MediaQuery.of(context).size.width / 12),
      width: isHorizFormat
          ? MediaQuery.of(context).size.width * 0.25
          : MediaQuery.of(context).size.width,
      child: Column(
        children: pieChartCtrl.pieChartIndicators
            .map((indicator) => indicator)
            .toList(),
      ),
    );
  }
}
