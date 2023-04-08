import 'package:flutter/foundation.dart';
import 'package:flutter_auth/auth_connect.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/internalization/models.dart';
import 'package:get/get.dart';

extension TranslationExt on String {
  bool get isTranslatable {
    if (Get.locale == null) {
      return false;
    }
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
        kDebugMode ? config.updateMissOnlyDebug : config.updateMissOnlyRelease;
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
    //Check if it's an interpolation variable only
    dprint(this);
    var hasSpace = contains(" ");
    if (!hasSpace && split("").first == "@" && split("").last == "#") {
      dprint("Ignore interpilation string only");
      dprint(value);
      return;
    }

    //Update api
    String firebaseUrl = config.firebaseUrl;
    final connect = GetConnect();
    if (Get?.locale == null) {
      return;
    }

    var languageCode = "${Get.locale!.languageCode}";

    String nameToPost = this.replaceAll("#", "_hsh_").replaceAll("\n", "_nl_");
    String firanseUrl = "$firebaseUrl/$nameToPost/$languageCode.json";

    var body = {
      "language": "${Get.locale!.languageCode}",
      "country": "${Get.locale!.countryCode}"
    };

    if (config.printDebug && kDebugMode) {
      if (!config.printMissOnlyDebug || !isPossible) {
        dprint("\n ***POSTING TRANSLATION***");
        dprint(
            "Posting after canUpdate:$canUpdate updateMissOnly:$updateMissOnly and isPossible:$isPossible");
        dprint(nameToPost);

        //TODO: Select between firebase dn normal url

        // connect.patch(firanseUrl, body).then((response) {
        //   // dprint(response.body);
        // }, onError: (error) {
        //   dprint(error);
        // });
        try {
          var authProvider = Get.find<AuthProvider>();
          var apiUrl = "api/v1/translation-texts/";
          authProvider.formPost(apiUrl, {"title": this});
        } catch (e, trace) {
          dprint(e);
          dprint(trace);
        }

        dprint("******");
      }
    }
  }

  String get ctr {
    _updateResult(this);
    return tr;
  }
}
