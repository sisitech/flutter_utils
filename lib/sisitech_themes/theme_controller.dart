import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Color primaryColor = Colors.blue;
Color secondaryColor = Colors.green;

ColorScheme defaultColorScheme = ColorScheme(
  primary: primaryColor,
  secondary: secondaryColor,
  surface: Colors.white,
  background: Colors.grey[200]!,
  error: Colors.red,
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onSurface: Colors.black,
  onBackground: Colors.black,
  onError: Colors.white,
  brightness: Brightness.light,
);

class M3Theme {
  FlexScheme flexScheme;
  ColorScheme colorScheme;

  M3Theme({required this.flexScheme, required this.colorScheme});
}

class CustomFlexThemeData {
  FlexScheme? scheme;
  FlexSurfaceMode? surfaceMode;
  int blendLevel = 0;
  FlexSubThemesData? subThemesData;
  VisualDensity? visualDensity;
  bool useMaterial3 = false;
  bool swapLegacyOnMaterial3 = false;
  String? fontFamily;
  CustomFlexThemeData({
    this.scheme,
    this.surfaceMode,
    this.blendLevel = 0,
    this.subThemesData,
    this.visualDensity,
    this.useMaterial3 = true,
    this.swapLegacyOnMaterial3 = false,
    this.fontFamily,
  });
}

class ThemeController extends GetxController {
  var currentScheme = FlexScheme.tealM3.obs; // Track the current scheme
  var currentThemeMode = ThemeMode.system.obs;
  late Rx<ThemeData?> lightTheme = Rx(null);
  late Rx<ThemeData?> darkTheme = Rx(null);
  late CustomFlexThemeData defaultLightTheme;
  late CustomFlexThemeData defaultDarkTheme;
  final box = GetStorage();
  List<M3Theme> m3Themes = [];

  ThemeController(
      {required this.defaultLightTheme, required this.defaultDarkTheme}) {
    // this.lightTheme.value = defaultLightTheme;
    darkTheme.value = FlexThemeData.dark(
      scheme: defaultDarkTheme.scheme,
      surfaceMode: defaultDarkTheme.surfaceMode,
      blendLevel: defaultDarkTheme.blendLevel,
      subThemesData: defaultDarkTheme.subThemesData,
      visualDensity: defaultDarkTheme.visualDensity,
      useMaterial3: defaultDarkTheme.useMaterial3,
      swapLegacyOnMaterial3: defaultDarkTheme.swapLegacyOnMaterial3,
      fontFamily: defaultDarkTheme.fontFamily,
    );
    lightTheme.value = FlexThemeData.light(
      scheme: defaultDarkTheme.scheme,
      surfaceMode: defaultDarkTheme.surfaceMode,
      blendLevel: defaultDarkTheme.blendLevel,
      subThemesData: defaultDarkTheme.subThemesData,
      visualDensity: defaultDarkTheme.visualDensity,
      useMaterial3: defaultDarkTheme.useMaterial3,
      swapLegacyOnMaterial3: defaultDarkTheme.swapLegacyOnMaterial3,
      fontFamily: defaultDarkTheme.fontFamily,
    );
  }

  @override
  void onInit() {
    super.onInit();
    getM3Themes();
    _getColorScheme();
    _getThemeMode();
  }

  void getM3Themes() {
    var m3FlexThemes = FlexScheme.values
        .where((element) => element.toString().contains('M3'))
        .toList();
    for (var m3Scheme in m3FlexThemes) {
      ColorScheme m3Colors =
          FlexColorScheme.dark(scheme: m3Scheme).colorScheme ??
              defaultColorScheme;
      m3Themes.add(M3Theme(flexScheme: m3Scheme, colorScheme: m3Colors));
    }
  }

  // Observable for the current theme data
  Future<void> _saveColorScheme(FlexScheme scheme) async {
    dprint(scheme.toString());
    await box.write("defaultFlexColorScheme", scheme.toString());
  }

  Future<void> _getColorScheme() async {
    var scheme_str = await box.read("defaultFlexColorScheme");
    dprint("Value is $scheme_str");
    if (scheme_str != null) {
      FlexScheme scheme = FlexScheme.values.byName(scheme_str.split(".")[1]);
      dprint(scheme.runtimeType);
      currentScheme.value = scheme;
      changeTheme(scheme);
    }
  }

  void changeTheme(FlexScheme scheme) {
    currentScheme.value = scheme;
    _saveColorScheme(scheme);
    darkTheme.value = darkTheme.value?.copyWith(
        colorScheme: FlexColorScheme.dark(scheme: scheme).colorScheme);
    darkTheme.value = FlexThemeData.dark(
      scheme: scheme,
      surfaceMode: defaultDarkTheme.surfaceMode,
      blendLevel: defaultDarkTheme.blendLevel,
      subThemesData: defaultDarkTheme.subThemesData,
      visualDensity: defaultDarkTheme.visualDensity,
      useMaterial3: defaultDarkTheme.useMaterial3,
      swapLegacyOnMaterial3: defaultDarkTheme.swapLegacyOnMaterial3,
      fontFamily: defaultDarkTheme.fontFamily,
    );
    lightTheme.value = FlexThemeData.light(
      scheme: scheme,
      surfaceMode: defaultLightTheme.surfaceMode,
      blendLevel: defaultLightTheme.blendLevel,
      subThemesData: defaultLightTheme.subThemesData,
      visualDensity: defaultLightTheme.visualDensity,
      useMaterial3: defaultLightTheme.useMaterial3,
      swapLegacyOnMaterial3: defaultLightTheme.swapLegacyOnMaterial3,
      fontFamily: defaultLightTheme.fontFamily,
    );

    dprint(Get.theme.brightness);

    if (Get.theme.brightness == Brightness.dark) {
      Get.changeTheme(darkTheme.value!);
    } else {
      Get.changeTheme(lightTheme.value!);
    }

    // Notify listeners
    update();
  }

  void changeThemeMode(ThemeMode mode) {
    currentThemeMode.value = mode;
    _saveThemeMode(mode);
    Get.changeThemeMode(mode);
    update();
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    await box.write("themeMode", mode.name);
  }

  Future<void> _getThemeMode() async {
    var modeStr = box.read("themeMode");
    if (modeStr != null) {
      try {
        final mode = ThemeMode.values.byName(modeStr);
        changeThemeMode(mode);
      } catch (_) {}
    }
  }
}
