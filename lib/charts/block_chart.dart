import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/utils.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

/// Made for only two values atm :)
class SistchDuoBlockChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final List<Color>? blockColors;
  final List<Color>? textColors;
  final String? chartTitle;
  final String? valuePrefix;
  final double chartHeight;

  const SistchDuoBlockChart({
    super.key,
    required this.values,
    required this.labels,
    this.valuePrefix,
    this.chartTitle,
    this.blockColors,
    this.textColors,
    this.chartHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (values.length != 2) return const SizedBox();

    final combinedList = List.generate(
      values.length,
      (index) => MapEntry(values[index], labels[index]),
    )..sort((a, b) => b.key.compareTo(a.key));

    final sortedValues = combinedList.map((e) => e.key).toList();
    final sortedLabels = combinedList.map((e) => e.value).toList();

    List<Color> ctColors = blockColors ?? defaultChartColors.take(2).toList();
    List<Color> txtColors =
        textColors ?? defaultTextChartColors.values.take(2).toList();

    double total = sortedValues.reduce((a, b) => a + b);
    List<double> percentages =
        sortedValues.map((e) => (e / total) * 100).toList();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          if (chartTitle != null)
            Text(
              chartTitle!,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBlockSection(
                  label: sortedLabels[0],
                  value: addThousandSeparators(sortedValues[0]),
                  percentage: '${percentages[0].toStringAsFixed(1)}%',
                  bgColor: ctColors[0],
                  textColor: txtColors[0],
                  isBiggerValue: true,
                  height: chartHeight,
                ),
              ),
              const SizedBox(width: 7),
              _buildBlockSection(
                width: Get.size.width * 0.25,
                label: sortedLabels[1],
                value: addThousandSeparators(sortedValues[1]),
                percentage: '${percentages[1].toStringAsFixed(1)}%',
                bgColor: ctColors[1],
                textColor: txtColors[1],
                isBiggerValue: false,
                hideSmaller: percentages[1] == 0,
                height: chartHeight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlockSection({
    double? width,
    required double height,
    required String label,
    required String value,
    required String percentage,
    required Color bgColor,
    required Color textColor,
    required bool isBiggerValue,
    bool hideSmaller = false,
  }) {
    final blockKey = ValueKey(value);

    return Column(
      children: [
        buildFadeAnimateWidget(
          child: buildGlassWidget(
            theme: Get.theme,
            width: width,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(5),
            mainColor: textColor.withOpacity(0.5),
            child: LinearPercentIndicator(
              key: blockKey,
              percent: 1.0,
              animation: true,
              animationDuration: 1000,
              padding: EdgeInsets.zero,
              barRadius: const Radius.circular(5),
              lineHeight: height * (isBiggerValue ? 0.9 : 0.7),
              progressColor:
                  (hideSmaller ? Colors.transparent : bgColor).withOpacity(0.6),
              backgroundColor: Get.theme.colorScheme.surfaceContainerHighest,
              center: SizedBox(
                width: (width ?? Get.width * 0.65) * 0.7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: valuePrefix,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 10,
                            ),
                          ),
                          TextSpan(
                            text: value,
                            style: TextStyle(
                              color: textColor,
                              fontSize: isBiggerValue ? 14 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: isBiggerValue ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 2,
          height: Get.size.height * 0.03,
          color: Get.theme.colorScheme.onSurface,
        ),
        buildCardWidget(
          theme: Get.theme,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            percentage,
            style: TextStyle(
              fontSize: height * 0.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
