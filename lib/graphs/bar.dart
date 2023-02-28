import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:get/get.dart';

import '../flutter_utils.dart';
import 'graphs_models.dart';

class CustomBarGraph extends StatelessWidget {
  late List<BarChartGroupData> barGroups;
  late List<String> titles;
  late String xAxisField;
  late List<CustomBarChartRodData> yAxisFields;
  late List<Map<String, dynamic>> data;
  late AxisTitles? bottomTitles;
  late AxisTitles? rightTitles;
  late AxisTitles? topTitles;
  late BarTouchData? barTouchData;
  late FlGridData? gridData;
  late double? maxY;

  BarTooltipItem? Function(BarChartGroupData, int, BarChartRodData, int)?
      getTooltipItem;
  var defaultTextStyle = Get.textTheme.titleSmall;
  CustomBarGraph({
    super.key,
    required this.xAxisField,
    required this.yAxisFields,
    required this.data,
    this.rightTitles,
    this.topTitles,
    this.maxY,
    this.barTouchData,
    this.bottomTitles,
    this.gridData,
    this.getTooltipItem,
  }) {
    if (data.length > 0) {
      var row1 = data[0];
      if (data.contains(this.xAxisField)) {
      } else {
        dprint("x Axis ${xAxisField} field not known.");
      }
    }
    setupBarGroups();
  }

  setupBarGroups() {
    barGroups = [];
    titles = data.map((e) => e[xAxisField].toString()).toList();
    for (int i = 0; i < data.length; i++) {
      var row = data[i];
      int row1 = row["present_males"] as int;
      int row2 = row["absent_males"] as int;
      barGroups.add(makeGroupData(i, row, yAxisFields));
    }
  }

  BarTooltipItem? defaultBarTooltipItem(
    BarChartGroupData group,
    int groupIndex,
    BarChartRodData rod,
    int rodIndex,
  ) {
    final color = rod.gradient?.colors.first ?? rod.color;
    final textStyle = TextStyle(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    dprint(groupIndex);
    var data = {
      "y": rod.toY.toInt().toString(),
      "label": titles[groupIndex] ?? "",
    };
    return BarTooltipItem(
        "@label#: @y#".tr.interpolate(data), defaultTextStyle ?? textStyle);
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    final Widget text = Text(
      titles[value.toInt()],
      style: defaultTextStyle ??
          const TextStyle(
            color: Color(0xff7589a2),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        AspectRatio(
          aspectRatio: 1,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barTouchData: barTouchData ??
                  BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey,
                      getTooltipItem: getTooltipItem ?? defaultBarTooltipItem,
                    ),
                  ),
              gridData: gridData ?? FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: bottomTitles ??
                    AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: getBottomTitles,
                        reservedSize: 42,
                      ),
                    ),
                rightTitles: rightTitles ??
                    AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                topTitles: topTitles ??
                    AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
              ),

              barGroups: barGroups,
              // read about it in the BarChartData section
            ),
            swapAnimationDuration: Duration(milliseconds: 150), // Optional
            swapAnimationCurve: Curves.linear,
            // Optional
          ),
        ),
      ],
    );
    ;
  }
}
