import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/utils.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';

class SistchCardGridView extends StatelessWidget {
  final List<double> dataSeries;
  final List<String> chartLabels;
  final List<IconData>? cardIcons;
  final List<Color>? cardColors;
  final List<Color>? onCardColors;
  final Function(String val)? onCardTap;
  final int crossCount;
  final String valuePrefix;
  final IconData actionIconPath;
  final double? cardAspectRatio;
  final String? chartTitle;
  final double spacing;
  final bool showPercentages;

  const SistchCardGridView({
    super.key,
    required this.dataSeries,
    required this.chartLabels,
    this.valuePrefix = '',
    this.crossCount = 2,
    this.cardIcons,
    this.cardColors,
    this.onCardColors,
    this.onCardTap,
    this.cardAspectRatio,
    this.chartTitle,
    this.spacing = 1.5,
    this.showPercentages = true,
    this.actionIconPath = Icons.call_made,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Get.theme.textTheme;
    final colorScheme = Get.theme.colorScheme;

    double total = getListOfDoublesSum(dataSeries);
    List<Color> bgColors = cardColors ?? getChartColors(dataSeries.length);
    List<Color> fgColors = onCardColors ?? getOnChartColors(dataSeries.length);

    return Column(
      children: [
        if (chartTitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              chartTitle!,
              style: textTheme.titleLarge!.copyWith(
                  color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        GridView.count(
          crossAxisCount: crossCount,
          childAspectRatio: cardAspectRatio ?? (crossCount == 1 ? 3 : 1.4),
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: dataSeries.asMap().entries.map((e) {
            var i = e.key;
            return getGridCardWidget(
              label: chartLabels[i],
              value: e.value,
              iconPath: cardIcons?[i],
              bgColor: bgColors[i],
              fgColor: fgColors[i],
              percentage: showPercentages ? (e.value / total) * 100 : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget getGridCardWidget({
    required String label,
    required double value,
    required Color bgColor,
    required Color fgColor,
    double? percentage,
    IconData? iconPath,
  }) {
    final textTheme = Get.theme.textTheme;
    final colorScheme = Get.theme.colorScheme;
    return GestureDetector(
      onTap: () {
        if (onCardTap != null) {
          onCardTap!(label);
        }
      },
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: iconPath != null
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if (iconPath != null)
                  Icon(
                    iconPath,
                    size: 20,
                    color: fgColor,
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: valuePrefix,
                            style:
                                textTheme.labelSmall!.copyWith(color: fgColor),
                          ),
                          TextSpan(
                            text: getThousandsNumber(value),
                            style: textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: fgColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (percentage != null)
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primaryContainer,
                        ),
                      ),
                  ],
                )
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: onCardTap != null
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: Get.width * (crossCount == 1 ? 0.6 : 0.3),
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: fgColor,
                    ),
                  ),
                ),
                if (onCardTap != null)
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    radius: 12,
                    child: Icon(
                      actionIconPath,
                      color: colorScheme.onPrimaryContainer,
                      size: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
