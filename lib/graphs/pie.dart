import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UtilsPieChart extends StatelessWidget {
  PieChartData data;

  UtilsPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        data,

        swapAnimationDuration: Duration(milliseconds: 150), // Optional
        swapAnimationCurve: Curves.linear, // Optional
      ),
    );
  }
}
