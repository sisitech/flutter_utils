import 'package:flutter/foundation.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/internalization/models.dart';
import 'package:get/get.dart';

extension TranslationExt on String {
  bool get isTranslatable {
    return Get.translations.containsKey(
            "${Get.locale!.languageCode}_${Get.locale!.countryCode}") &&
        Get.translations[
                "${Get.locale!.languageCode}_${Get.locale!.countryCode}"]!
            .containsKey(this);
  }

  _updateResult(String value) {
    LolaleConfig config;
    var isPossible = this.isTranslatable;
    try {
      config = Get.find<LolaleConfig>();
    } catch (e) {
      config = Get.put(const LolaleConfig());
    }
    var canUpdate =
        kDebugMode ? config.updateAPIDebug : config.updateAPIRelease;
    var updateMissOnly =
        kDebugMode ? config.updateAPIDebug : config.updateAPIRelease;
    // If can't update ignore
    if (!canUpdate) {
      return;
    }
    // If update miss only and its a match
    if (updateMissOnly) {
      if (isPossible) {
        return;
      }
    }
    dprint(
        "Posting after canUpdate:$canUpdate updateMissOnly:$updateMissOnly and isPossible:$isPossible");
    dprint(this);

    //Update api
    String firebaseUrl = config.firebaseUrl;
    final connect = GetConnect();
    var language_code = "${Get.locale!.languageCode}";
    String url = "$firebaseUrl/$this/$language_code.json";
    var body = {
      "language": "${Get.locale!.languageCode}",
      "country": "${Get.locale!.countryCode}"
    };
    dprint("POSTING TRANSLATION");
    connect.patch(url, body).then((response) {
      // dprint(response.body);
    }, onError: (error) {
      dprint(error);
    });
  }

  String get ctr {
    _updateResult(this);
    return this.tr;
  }
}
