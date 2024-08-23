import 'package:flutter/material.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:flutter_utils/utils/icon_mapper.dart';
import 'package:get/get.dart';

void showSnackbar(
    {required String title,
    required String subtitle,
    required IconData iconPath,
    required ColorScheme colorScheme,
    SnackPosition? snackPosition = SnackPosition.BOTTOM}) {
  Get.snackbar(title, subtitle,
      backgroundColor: colorScheme.primary,
      colorText: colorScheme.onPrimary,
      icon: Icon(
        iconPath,
        size: 28,
        color: colorScheme.onPrimary,
      ),
      snackPosition: snackPosition);
}

Widget loadingWidget(String loadingTxt) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: Text(
        loadingTxt,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget noDataWidget(String widgetText) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: Text(widgetText, textAlign: TextAlign.center),
    ),
  );
}

String addThousandSeparators(double value) {
  String formattedValue = value.toStringAsFixed(0);
  List<String> parts = formattedValue.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

  final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return integerPart.replaceAllMapped(regExp, (Match match) => '${match[1]},') +
      decimalPart;
}

Widget chartIndicator(
    {Color? color,
    function,
    required String label,
    bool? useIcons,
    required String rawLabel}) {
  return Padding(
    padding: const EdgeInsets.only(right: 8, bottom: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        useIcons == true
            ? Icon(
                iconMapper[rawLabel] ?? Icons.circle,
                color: color,
                size: 12,
              )
            : Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

List<Widget> getChartIndicators(List<String> labels, List<Color> colors,
    {List<double>? values, bool? isPercent = false, bool? useIcons}) {
  return List.generate(
    labels.length,
    (i) => chartIndicator(
      useIcons: useIcons,
      rawLabel: labels[i],
      label: "@label#@value#".interpolate({
        "label": labels[i],
        "value": values != null
            ? isPercent == true
                ? " (${values[i].toStringAsFixed(1)}%)"
                : " (KES.${addThousandSeparators(values[i])})"
            : "",
      }),
      color: colors[i],
    ),
  );
}

List<Color> getChartColors(int seriesLength) {
  return chartColors.sublist(0, seriesLength);
}

double getListOfDoublesSum(List<double> items) {
  double sum = 0.0;
  for (var item in items) {
    sum += item;
  }
  return sum;
}

// chart constants
List<Color> chartColors = const [
  Color(0xFF18A558),
  Color(0xFF0292B7),
  Color(0xFFE59349),
  Color(0xFF7A77E9),
  Color(0xFFF9E56A),
  Color(0xFF84D3C5),
  Color(0xFF5C99F0),
  Color(0xFFF54D3D),
  Color(0xFF955670),
  Color(0xFFDF7A57),
  Color(0xFF3D5B59),
  Color(0xFFDB668D),
  Color(0xFF000C66),
  Color(0xFFF3E1C0),
];

Map<Color, Color> textChartColors = {
  const Color(0xFFDB668D): Colors.white,
  const Color(0xFF955670): Colors.white,
  const Color(0xFF0292B7): Colors.white,
  const Color(0xFFDF7A57): Colors.white,
  const Color(0xFF7A77E9): Colors.white,
  const Color(0xFFF9E56A): Colors.black,
  const Color(0xFF5C99F0): Colors.white,
  const Color(0xFFF54D3D): Colors.white,
  const Color(0xFF84D3C5): Colors.black,
  const Color(0xFFE59349): Colors.white,
  const Color(0xFF18A558): Colors.white,
  const Color(0xFF3D5B59): Colors.white,
  const Color(0xFF000C66): Colors.white,
  const Color(0xFFF3E1C0): Colors.black,
};
