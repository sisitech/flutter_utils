import 'package:flutter/material.dart';

class NameLocale {
  String name;
  Locale locale;
  NameLocale({
    required this.name,
    required this.locale,
  });
}

class LolaleConfig {
  final bool updateAPIDebug;
  final bool printDebug;
  final bool updateAPIRelease;
  final bool updateMissOnlyDebug;
  final bool updateMissOnlyRelease;
  final String firebaseUrl;

  const LolaleConfig({
    this.updateAPIDebug = false,
    this.updateAPIRelease = false,
    this.updateMissOnlyDebug = false,
    this.updateMissOnlyRelease = false,
    this.printDebug = true,
    this.firebaseUrl =
        "https://somtranslation-1f5b5-default-rtdb.firebaseio.com",
  });
}
