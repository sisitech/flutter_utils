import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/functions.dart';

/// Constants
List<Color> sunColors = [
  Colors.white,
  Colors.yellow,
  Colors.orange,
  Colors.red,
];

/// Models
class TimeLapseChartSection {
  String? timeTile;
  double? value;
  String? displayVal;

  TimeLapseChartSection({
    this.timeTile,
    this.value,
    this.displayVal,
  });
}

/// Views
class SistchTimeLapseChart extends StatelessWidget {
  final List<double> dataSeries;
  final List<String> timeLabels;
  final String prefix;
  final double chartHeight;
  final bool useSunColors;
  final String? chartTitle;
  final Color? highlightColor;
  const SistchTimeLapseChart({
    super.key,
    required this.dataSeries,
    required this.timeLabels,
    this.chartHeight = 450,
    this.prefix = "",
    this.chartTitle,
    this.useSunColors = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    double maxValue = getListOfDoublesMax(dataSeries) ?? 0;

    List<TimeLapseChartSection> sections = getTimeLapseChartSections(
      timeTitles: timeLabels,
      values: dataSeries,
      prefix: prefix,
      width: width,
      chartHeight: chartHeight,
    ).reversed.toList();
    double timeTilesRadius = width * 0.44;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          if (chartTitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                chartTitle!,
                style: theme.textTheme.titleLarge!.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          SizedBox(
            width: width,
            height: chartHeight,
            child: Stack(
              children: [
                getSunBackground(
                  width: width,
                  theme: theme,
                  chartHeight: chartHeight,
                  useSunColors: useSunColors,
                ),
                Positioned(
                  left: -width * 0.5,
                  top: 15,
                  child: Transform.rotate(
                    angle: (pi / 2),
                    child: SizedBox(
                      width: width * 1.21,
                      height: chartHeight,
                      child: Stack(
                        children: sections.asMap().entries.map((entry) {
                          int idx = entry.key;
                          TimeLapseChartSection e = sections[idx];
                          double angle = pi * idx / (sections.length - 1);

                          return Positioned(
                            left: (timeTilesRadius +
                                timeTilesRadius * cos(angle)),
                            top: timeTilesRadius - timeTilesRadius * sin(angle),
                            child: getTimeRangeItem(
                              theme: theme,
                              timeTile: e,
                              isHighlighted: e.value == maxValue,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Functions ===============================

  Widget getTimeRangeItem({
    required ThemeData theme,
    required TimeLapseChartSection timeTile,
    bool isHighlighted = false,
  }) {
    return Transform.rotate(
      angle: -(pi / 2), // Rotate -90 degrees (pi/2 radians)
      child: Row(
        children: [
          Icon(
            Icons.timelapse,
            size: theme.textTheme.titleLarge?.fontSize,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 5),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: isHighlighted
                  ? highlightColor ?? theme.colorScheme.primary
                  : theme.colorScheme.surfaceVariant.withOpacity(0.2),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeTile.timeTile ?? "--",
                  style: TextStyle(
                    color: isHighlighted ? theme.colorScheme.onPrimary : null,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  timeTile.displayVal ?? "-",
                  style: TextStyle(
                    color: isHighlighted ? theme.colorScheme.onPrimary : null,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getSunBackground({
    required double width,
    required ThemeData theme,
    required double chartHeight,
    required bool useSunColors,
  }) {
    double ringRadiusFactor = 0.88;
    double sunRadiusFactor = 0.72;
    double sunBgOffsetFactor = 0.38;
    double ringRadius = width * ringRadiusFactor;
    double sunRadius = width * sunRadiusFactor;

    List<Color> themeColors = [
      Colors.white,
      theme.colorScheme.primary,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
    ];

    return Stack(
      children: [
        Positioned(
          left: -width *
              sunBgOffsetFactor, // Moves the Stack's content to the left edge
          child: SizedBox(
            width: ringRadius,
            height: chartHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: useSunColors
                          ? sunColors.last
                          : highlightColor ??
                              theme.colorScheme.primaryContainer,
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: sunRadius,
                  height: sunRadius,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: useSunColors ? sunColors : themeColors,
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Util Functions ===============================
  List<TimeLapseChartSection> getTimeLapseChartSections({
    required List<double> values,
    required List<String> timeTitles,
    required String prefix,
    required double width,
    required double chartHeight,
  }) {
    List<TimeLapseChartSection> sections = [];

    for (int i = 0; i < values.length; i++) {
      sections.add(TimeLapseChartSection(
        timeTile: timeTitles[i],
        value: values[i],
        displayVal: "$prefix${addThousandSeparators(values[i])}",
      ));
    }
    return sections;
  }
}
