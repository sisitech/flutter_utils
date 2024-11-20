import 'package:example/app.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/flutter_auth_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_utils/internalization/language_controller.dart';
import 'package:flutter_utils/internalization/models.dart';
import 'package:flutter_utils/local_nofitications/local_notification_controller.dart';
import 'package:flutter_utils/lock_screen/lock_controller.dart';
import 'package:flutter_utils/mixpanel/mixpanel_controller.dart';
import 'package:flutter_utils/models.dart';
import 'package:flutter_utils/network_status/network_status_controller.dart';
import 'package:flutter_utils/offline_http_cache/offline_http_cache.dart';
import 'package:flutter_utils/product_tour/product_tour.dart';
import 'package:flutter_utils/sisitech_themes/theme_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'internalization/translate.dart';

const default_local_name = "Kiswahili";
// import 'package:flutter_utils/';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

void main() async {
  Get.put<APIConfig>(APIConfig(
      apiEndpoint: "https://somapi.request.africa",
      version: "api/v1",
      clientId: "lrPkKtmh14glEbCaeMdLL4yLO1oFkac1yTq2ctdm",
      tokenUrl: 'o/token/',
      grantType: "password",
      revokeTokenUrl: 'o/revoke_token/'));
  Get.put(AuthController());

  await GetStorage.init();
  await GetStorage.init('GetStorage');
  Get.put(const LolaleConfig(
    updateAPIDebug: false,
    updateMissOnlyDebug: false,
    printMissOnlyDebug: false,
  ));

  Get.put(OfflineHttpCacheController());
  Get.put(
    MixPanelController(
        mixpanelToken: "f3132cbb2645d462c7b2058cb6e8e8f6",
        options: const MixpanelOptions(
          enableAnonymous: true,
          disableInDebug: false,
        )),
  );
  Get.put(NetworkStatusController());

  var notificationCont = Get.put(LocalNotificationController(
      notificationTapBackground: notificationTapBackground));

  await notificationCont.initializeLocalNotifications();

  var localeCont = LocaleController(
    defaultLocaleName: "English",
    defaultTranslationKeys: translationKeys,
  );

  Get.put(localeCont);
  var box = GetStorage();
  await box.remove(allLocalesKey);
  await localeCont.apiGetLocales();
  await localeCont.readAllStorageLocales();
  Get.put(
    ThemeController(
      defaultLightTheme: CustomFlexThemeData(
        scheme: FlexScheme.tealM3,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      defaultDarkTheme: CustomFlexThemeData(
        scheme: FlexScheme.tealM3,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
    ),
  );

  Get.put(LocalAuthController());

  Get.put(ProductTourController(), tag: "example_tour");

  runApp(MyApp());
}

class StoreBinding implements Bindings {
// default dependency
  @override
  void dependencies() {}
}
