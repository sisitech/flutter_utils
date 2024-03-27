import 'package:flutter_auth/flutter_auth_controller.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixpanel/mixpanel.dart';
import 'package:get/get.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelOptions {
  final bool enableAnonymous;
  final bool enabled;
  final bool persistentAnonymous;
  final bool disableInDebug;
  const MixpanelOptions({
    this.enableAnonymous = false,
    this.enabled = true,
    this.persistentAnonymous = false,
    this.disableInDebug = true,
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
    initializeMixPanel(options);
  }

  get mixpanel {
    return _mixpanel;
  }

  saveAnonymousId() {}

  getSavedAnonymousId() {}

  getAnonymouseuser() {
    // Save a unique id to local storage and use it everytime
    // The key should be passed when initializing.
    if (options.enableAnonymous && options.persistentAnonymous) {
      // Save or get
    }
    return "Anonymous";
  }

  get isDisAbled {
    if (options.disableInDebug) {
      return false;
    }
    // Check if anonymous mode enalbed
    if (!authController.isAuthenticated$.value && !options.enableAnonymous) {
      return false;
    }
    return options.enabled;
  }

  getUser() {
    var anymousProfile = {"username": getAnonymouseuser()};
    Map<String, dynamic> profile;
    if (authController.isAuthenticated$.value) {
      profile = authController.profile.value ?? anymousProfile;
      dprint(
          "Mixpanel User ${authController.profile.value?["username"]} initialized.");
    } else {
      profile = anymousProfile;
    }
    return profile;
  }

  initializeMixPanel(MixpanelOptions options) async {
    if (isDisAbled) {
      dprint(
          "Mixpanel disabled,disableInDebug:${options.disableInDebug} enabled:${options.enabled}");
      return;
    }
    _mixpanel = await initMixpanel(mixpanelToken);
    var profile = getUser();
    _mixpanel?.identify(profile["username"]);
    _mixpanel?.getPeople().set('username', profile["username"]);
    _mixpanel?.getPeople().set('last_login', DateTime.now());
  }

  track(String eventName, {Map<String, dynamic>? properties}) {
    _mixpanel?.track(eventName, properties: properties);
  }

  timeEvent(String eventName) {
    _mixpanel?.timeEvent(eventName);
  }
}
