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
  final bool updateAPIRelease;
  final bool updateDebugMissOnlyDebug;
  final bool updateDebugMissOnlyRelease;
  final String firebaseUrl;

  const LolaleConfig({
    this.updateAPIDebug = false,
    this.updateAPIRelease = false,
    this.updateDebugMissOnlyDebug = false,
    this.updateDebugMissOnlyRelease = false,
    this.firebaseUrl =
        "https://somtranslation-1f5b5-default-rtdb.firebaseio.com",
  });
}
