library flutter_utils;

import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'graphs/graphs_models.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

dprint(dynamic value) {
  if (kDebugMode) {
    if (value.runtimeType == String) {
      // debugPrint("DebugPrint");
      debugPrint(value, wrapWidth: 1024);
    } else {
      print(value);
    }
  }
}

BarChartGroupData makeGroupData(
    int x, dynamic row, List<CustomBarChartRodData> yAxisFields) {
  return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: yAxisFields
          .map((e) => BarChartRodData(
                toY: row[e.field] * 1.0,
                color: e.color,
                gradient: e.gradient,
                width: e.width,
                borderRadius: e.borderRadius,
                borderSide: e.borderSide,
                backDrawRodData: e.backDrawRodData,
                rodStackItems: e.rodStackItems,
              ))
          .toList()
      // barRods: [

      //   BarChartRodData(
      //     toY: y1,
      //     color: Colors.red,
      //     width: 10,
      //   ),
      //   BarChartRodData(
      //     toY: y2,
      //     color: Colors.blue,
      //     width: 12,
      //   ),
      // ],
      );
}
