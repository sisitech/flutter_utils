import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:flutter_utils/utils/icon_mapper.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

Widget chartIndicator({
  Color? color,
  function,
  String? extension,
  String? percentage,
  bool? useIcons,
  required String label,
}) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: Get.size.width * 0.6,
    ),
    child: Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          useIcons == true
              ? Icon(
                  defaultIconMapper[label] ?? Icons.circle,
                  color: color,
                  size: 12,
                )
              : Container(
                  padding: const EdgeInsets.all(4),
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
          const SizedBox(width: 4),
          Flexible(
            child: Text.rich(
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: percentage == null ? '' : ' ($percentage)',
                    style: const TextStyle(fontSize: 8),
                  ),
                  TextSpan(
                    text: extension != null ? ' • $extension' : '',
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildLinearPercentTile({
  bool isSelected = false,
  required ColorScheme colorScheme,
  Color? selectedColor,
  Function(String val)? onChartTileTap,
  required String label,
  double tileHeight = 42.0,
  required double percent,
  Widget? leadingWidget,
  required Color bgColor,
  required Color fgColor,
  String? indicatorPrefix = "",
  required double value,
  Widget? trailingWidget,
}) {
  return buildFadeAnimateWidget(
    child: buildGlassWidget(
      theme: Get.theme,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding:
          EdgeInsets.symmetric(vertical: isSelected ? 8 : 5, horizontal: 15),
      mainColor: isSelected
          ? selectedColor ?? colorScheme.surfaceContainerHighest
          : null,
      child: GestureDetector(
        onTap: () {
          if (onChartTileTap != null) {
            onChartTileTap(label);
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
                    progressColor: bgColor,
                    barRadius: const Radius.circular(5),
                    leading: leadingWidget,
                  ),
                  Container(
                    width: Get.width * 0.4,
                    margin: const EdgeInsets.only(left: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                percent < 0.6 ? colorScheme.onSurface : fgColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$indicatorPrefix${addThousandSeparators(value)} • ${(percent * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                percent < 0.6 ? colorScheme.onSurface : fgColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    ),
  );
}

Widget actionChartIndicator({
  Color? color,
  function,
  String? extension,
  String? percentage,
  bool? useIcons,
  double? value,
  required String label,
  required Function(String val) onIndicatorTap,
  required bool isSelected,
}) {
  return Container(
    padding: EdgeInsets.all(isSelected ? 8 : 5),
    decoration: BoxDecoration(
      color: isSelected
          ? Get.theme.colorScheme.surfaceVariant
          : Colors.transparent,
      borderRadius: BorderRadius.circular(2),
    ),
    width: Get.size.width * 0.6,
    child: GestureDetector(
      onTap: () => onIndicatorTap(label),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              useIcons == true
                  ? Icon(
                      defaultIconMapper[label] ?? Icons.circle,
                      color: color,
                      size: 12,
                    )
                  : Container(
                      padding: const EdgeInsets.all(4),
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
              const SizedBox(width: 5),
              SizedBox(
                width: Get.size.width * 0.45,
                child: Text.rich(
                  maxLines: 4,
                  overflow: TextOverflow.clip,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: const TextStyle(fontSize: 10),
                      ),
                      TextSpan(
                        text: percentage == null ? '' : ' ($percentage)',
                        style: const TextStyle(fontSize: 8),
                      ),
                      TextSpan(
                        text: extension != null ? ' • $extension' : '',
                        style: const TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Icon(
            Icons.read_more_rounded,
            color: Get.theme.colorScheme.primary,
            size: 22,
          ),
        ],
      ),
    ),
  );
}

List<Widget> getChartIndicators(
  List<String> labels,
  List<Color> colors,
  List<double> values, {
  bool hidePerc = true,
  bool? useIcons,
  String? indicatorPrefix,
  String? selectedIndicator,
  Function(String val)? onIndicatorTap,
}) {
  double total = getListOfDoublesSum(values);
  return List.generate(labels.length, (i) {
    double? percentage =
        (total != 0 && values.isNotEmpty) ? (values[i] / total) * 100 : null;
    return onIndicatorTap != null
        ? actionChartIndicator(
            useIcons: useIcons,
            percentage: hidePerc || percentage == null
                ? null
                : "${percentage.toStringAsFixed(1)}%",
            label: labels[i],
            extension: values.isNotEmpty
                ? "${indicatorPrefix ?? ''}${addThousandSeparators(values[i])}"
                : null,
            color: colors[i],
            onIndicatorTap: onIndicatorTap,
            isSelected: selectedIndicator == labels[i],
          )
        : chartIndicator(
            useIcons: useIcons,
            percentage: hidePerc || percentage == null
                ? null
                : "${percentage.toStringAsFixed(1)}%",
            label: labels[i],
            extension: values.isNotEmpty
                ? "${indicatorPrefix ?? ''}${addThousandSeparators(values[i])}"
                : null,
            color: colors[i],
          );
  });
}

List<Color> getChartColors(int seriesLength) {
  return seriesLength > defaultChartColors.length
      ? List.generate(
          seriesLength,
          (i) => Get.theme.colorScheme.primaryContainer,
        )
      : defaultChartColors.sublist(0, seriesLength);
}

List<Color> getOnChartColors(int seriesLength) {
  return seriesLength > defaultChartColors.length
      ? List.generate(
          seriesLength,
          (i) => Get.theme.colorScheme.onPrimaryContainer,
        )
      : defaultChartColors
          .map((e) => defaultTextChartColors[e] ?? Colors.white)
          .toList();
}

// chart constants
List<Color> defaultChartColors = const [
  Color(0xFF0292B7),
  Color(0xFF18A558),
  Color(0xFFE59349),
  Color(0xFFF9E56A),
  Color(0xFFF54D3D),
  Color(0xFF7A77E9),
  Color(0xFF84D3C5),
  Color(0xFF5C99F0),
  Color(0xFF955670),
  Color(0xFFDF7A57),
  Color(0xFF3D5B59),
  Color(0xFFDB668D),
  Color(0xFF000C66),
  Color(0xFFF3E1C0),
];

Map<Color, Color> defaultTextChartColors = {
  const Color(0xFF0292B7): Colors.white, // Blue
  const Color(0xFF18A558): Colors.white, // Green
  const Color(0xFFE59349): Colors.white, // Orange
  const Color(0xFFF54D3D): Colors.white, // Red
  const Color(0xFFF9E56A): Colors.black, // Yellow
  const Color(0xFF7A77E9): Colors.white, // Purple
  const Color(0xFF84D3C5): Colors.black, // Light teal
  const Color(0xFF5C99F0): Colors.white, // Sky blue
  const Color(0xFF955670): Colors.white, // Dark purple
  const Color(0xFFDF7A57): Colors.white, // Peach
  const Color(0xFF3D5B59): Colors.white, // Dark teal
  const Color(0xFFDB668D): Colors.white, // Pink
  const Color(0xFF000C66): Colors.white, // Navy
  const Color(0xFFF3E1C0): Colors.black, // Beige
};
