import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomBarChartRodData {
  String field;
  Color? color;
  Gradient? gradient;
  double? width;
  BorderRadius? borderRadius;
  BorderSide? borderSide;
  BackgroundBarChartRodData? backDrawRodData;
  List<BarChartRodStackItem>? rodStackItems;
  CustomBarChartRodData({
    required this.field,
    this.color,
    this.gradient,
    this.width,
    this.borderRadius,
    this.borderSide,
    this.backDrawRodData,
    this.rodStackItems,
  });
}
