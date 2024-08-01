import 'package:flutter/material.dart';

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
