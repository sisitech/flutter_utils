import 'package:flutter/material.dart';
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
  final RxString? selectedTitle;
  final Function(String)? onChartTileTap;
  final List<Widget>? leadingWidgets;
  final List<Widget>? trailingWidgets;
  final Color? selectedColor;
  final String? chartTitle;

  const SistchLinearPercentChart({
    required this.dataSeries,
    required this.chartLabels,
    this.tileColors,
    this.selectedTitle,
    this.onChartTileTap,
    this.leadingWidgets,
    this.trailingWidgets,
    this.selectedColor,
    this.chartTitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    List<Color> chtColors =
        tileColors != null ? [...tileColors!] : [...chartColors];

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

              bool isSelected = selectedTitle?.value == chartLabels[idx];
              return Container(
                padding: EdgeInsets.all(isSelected ? 10 : 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? selectedColor ??
                          colorScheme.onBackground.withOpacity(0.2)
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
                    mainAxisAlignment: trailingWidgets != null
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            LinearPercentIndicator(
                              animation: true,
                              lineHeight: 20.0,
                              animationDuration: 1000,
                              percent: percent,
                              backgroundColor:
                                  colorScheme.background.withOpacity(0.1),
                              progressColor: chtColors[idx],
                              barRadius: const Radius.circular(10),
                              leading: leadingWidgets == null
                                  ? null
                                  : leadingWidgets![idx],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                "${chartLabels[idx]} (${(percent * 100).toStringAsFixed(1)}%)",
                                style: textTheme.bodySmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: percent < 0.6
                                      ? colorScheme.onBackground
                                      : textChartColors[chtColors[idx]],
                                ),
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
