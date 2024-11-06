import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../flutter_utils.dart';
import '../mixpanel/mixpanel_controller.dart';

mixpanelTrackEvent(String eventName, {Map<String, dynamic>? properties}) {
  try {
    MixPanelController? mixCont = Get.find<MixPanelController>();
    mixCont.track(
      eventName,
      properties: properties,
    );
    dprint("$eventName clicked");
  } catch (e) {
    dprint(e);
  }
}

mixpanelLogin() {
  try {
    MixPanelController? mixCont = Get.find<MixPanelController>();
    mixCont.logoutUser();
    mixCont.setLoggedInUser();
  } catch (e) {
    dprint(e);
  }
}

mixpanelLogout() {
  try {
    MixPanelController? mixCont = Get.find<MixPanelController>();
    mixCont.logoutUser();
  } catch (e) {
    dprint(e);
  }
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

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

var formatter = NumberFormat('###,###');

formatNumber(dynamic value) {
  if (value == null) return "0";
  var formattedValue = formatter.format(value);
  return "$formattedValue";
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

String getThousandsNumber(double number) {
  if (number < 10000) return addThousandSeparators(number);

  double divisor = 1;
  String suffix = '';

  if (number < 1000000) {
    divisor = 1000;
    suffix = 'K';
  } else if (number < 1000000000) {
    divisor = 1000000;
    suffix = 'M';
  } else if (number < 1000000000000) {
    divisor = 1000000000;
    suffix = 'B';
  } else {
    divisor = 1000000000000;
    suffix = 'T';
  }

  double val = number / divisor;
  return val.toStringAsFixed(val % 1 == 0 ? 0 : 1) + suffix;
}

double getListOfDoublesSum(List<double> items) {
  double sum = 0.0;
  for (var item in items) {
    sum += item;
  }
  return sum;
}

String strToTitleCase(String input) {
  return input
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

double getListOfDoublesAvg(List<double>? values) {
  if (values == null || values.isEmpty) return 0.0;
  double sum = values.reduce((a, b) => a + b);
  return sum / values.length;
}

double getListOfDoublesMax(List<double>? values) {
  if (values == null || values.isEmpty) return 0.0;
  return values.reduce((a, b) => a > b ? a : b);
}

double getListOfDoublesMin(List<double>? values) {
  if (values == null || values.isEmpty) return 0.0;
  return values.reduce((a, b) => a < b ? a : b);
}
