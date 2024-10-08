import 'package:flutter/foundation.dart';
import 'package:flutter_auth/flutter_auth_controller.dart';
import 'package:flutter_utils/extensions/date_extensions.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixpanel/mixpanel.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelOptions {
  final bool enableAnonymous;
  final bool enabled;
  final bool persistentAnonymous;
  final bool disableInDebug;
  final bool flushNow;
  // Requires manual calling of initializeMixPanel somewhere in your project if enabled
  final bool enableManualInit;
  const MixpanelOptions({
    this.enableAnonymous = true,
    this.flushNow = false,
    this.enabled = true,
    this.persistentAnonymous = true,
    this.disableInDebug = true,
    this.enableManualInit = false,
  });
}

class MixPanelController extends GetxController {
  late String mixpanelToken;
  Mixpanel? _mixpanel;
  late MixpanelOptions options;
  AuthController authController = Get.find<AuthController>();

  MixPanelController(
      {required this.mixpanelToken, this.options = const MixpanelOptions()});

  @override
  void onInit() {
    super.onInit();
    dprint("Mixpanel Oninti");
    if (!options.enableManualInit) {
      initializeMixPanel();
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  get mixpanel {
    return _mixpanel;
  }

  saveAnonymousId() {}

  getSavedAnonymousId() {}

  get isDisAbled {
    if (options.disableInDebug) {
      return false;
    }
    return !options.enabled;
  }

  getUser() {
    var anymousProfile = {"username": "Anonymous"};
    Map<String, dynamic> profile;
    if (authController.isAuthenticated$.value != null) {
      profile = authController.profile.value ?? anymousProfile;
    } else {
      profile = anymousProfile;
    }

    if (options.enableAnonymous) {
      profile["username"] = generateMd5(profile["email"] ?? "");
      dprint("Username: ${profile["username"]}");
    } else {
      dprint("Username: ${profile["username"]}");
    }

    return profile;
  }

  setLoggedInUser() {
    if (_mixpanel == null) {
      dprint("No intialized _mixpanel instance found");
      return;
    }
    var profile = getUser();

    _mixpanel?.identify(profile["username"]);
    _mixpanel?.getPeople().set('username', profile["username"]);

    _mixpanel?.getPeople().set('last_login', DateTime.now().toWeekDayDate);
    // dprint("Mixpanel Set Profile");
    dprint(profile);
  }

  logoutUser() {
    if (_mixpanel != null) {
      _mixpanel?.reset();
    }
  }

  initializeMixPanel() async {
    dprint("Initializing Mixpanel");
    if (isDisAbled) {
      dprint(
          "Mixpanel disabled,disableInDebug:${options.disableInDebug} enabled:${options.enabled}");
      return;
    }
    try {
      _mixpanel = await initMixpanel(mixpanelToken);
    } catch (e) {
      dprint(e);
    }
    setLoggedInUser();
  }

  track(String eventName, {Map<String, dynamic>? properties}) {
    _mixpanel?.track(eventName, properties: properties);
    if (options.flushNow) {
      if (kDebugMode) {
        // dprint("value")
        _mixpanel?.flush();
      }
    }
  }

  timeEvent(String eventName) {
    _mixpanel?.timeEvent(eventName);
  }
}
