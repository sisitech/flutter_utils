import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/utils.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// View
//

///[SistchLinearPercentChart] renders custom Sisitech Linear Percent Indicators Charts
/// Required Fields:
///- List<double> dataSeries: single series of data points
///- List<String> chartLabels: list of labels for each data point
class SistchLinearPercentChart extends StatelessWidget {
  final List<double> dataSeries;
  final List<String> chartLabels;
  final List<Color>? tileColors;
  final String? selectedTile;
  final Function(String val)? onChartTileTap;
  final List<Widget>? leadingWidgets;
  final List<Widget>? trailingWidgets;
  final Color? selectedColor;
  final String? chartTitle;
  final double tileHeight;
  final List<Color>? textColors;
  final String? indicatorPrefix;

  const SistchLinearPercentChart({
    required this.dataSeries,
    required this.chartLabels,
    this.tileColors,
    this.selectedTile,
    this.onChartTileTap,
    this.leadingWidgets,
    this.trailingWidgets,
    this.selectedColor,
    this.chartTitle,
    this.tileHeight = 42.0,
    this.textColors,
    this.indicatorPrefix,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    List<Color> bgColors = tileColors ?? getChartColors(dataSeries.length);
    List<Color> fgColors = textColors ?? getOnChartColors(dataSeries.length);

    double total = dataSeries.fold(0, (sum, item) => sum + item);
    List<double> percentages = total != 0
        ? dataSeries.map((item) => item / total).toList()
        : List.filled(dataSeries.length, 0.0);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          if (chartTitle != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chartTitle!,
                  style: textTheme.titleLarge!.copyWith(
                      color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
              ],
            ),
          if (percentages.isNotEmpty)
            ...percentages.asMap().entries.map((entry) {
              int idx = entry.key;
              double percent = percentages[idx];

              bool isSelected = selectedTile == chartLabels[idx];
              return Container(
                padding: EdgeInsets.all(isSelected ? 8 : 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? selectedColor ?? colorScheme.surfaceContainerHighest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: GestureDetector(
                  onTap: () {
                    if (onChartTileTap != null) {
                      onChartTileTap!(chartLabels[idx]);
                    }
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            LinearPercentIndicator(
                              animation: true,
                              lineHeight: tileHeight,
                              animationDuration: 1000,
                              percent: percent,
                              backgroundColor: colorScheme.surface,
                              progressColor: bgColors[idx],
                              barRadius: const Radius.circular(5),
                              leading: leadingWidgets == null
                                  ? null
                                  : leadingWidgets![idx],
                            ),
                            Container(
                              width: Get.width * 0.4,
                              margin: const EdgeInsets.only(left: 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    chartLabels[idx],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: percent < 0.6
                                          ? colorScheme.onSurface
                                          : fgColors[idx],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${indicatorPrefix ?? ""}${addThousandSeparators(dataSeries[idx])} • ${(percent * 100).toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: percent < 0.6
                                          ? colorScheme.onSurface
                                          : fgColors[idx],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (trailingWidgets != null) trailingWidgets![idx]
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
