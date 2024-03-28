import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_auth/auth_connect.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import '../flutter_utils.dart';
import '../mixpanel/mixpanel_controller.dart';
import 'models.dart';

// import 'aut'
// ignore: constant_identifier_names
const locale_key = "current_locale";

const allLocalesKey = "all_locales_key";

const localeLanguageNameProperty = "language_name";
const localeLanguagePromptProperty = "language_prompt";

const missing_translation_keys = "missing_translations";

class CustomTranslations extends Translations {
  final Map<String, Map<String, String>> localesConfig;

  CustomTranslations({
    required this.localesConfig,
  }) {
    dprint("Loading1 the customtranslation class");
  }

  @override
  Map<String, Map<String, String>> get keys {
    dprint("Reting.");
    dprint(localesConfig.keys.length);
    return localesConfig;
  }
}

class LocaleController extends SuperController {
  var box = GetStorage();

  Map<String, Map<String, String>> localesConfigs = {};
  final Map<String, Map<String, String>> defaultTranslationKeys;

  Rx<NameLocale?> selectedNameLocale = Rx(null);

  final String urlPath;

  String defaultLocaleName;
  String? selectorTitle;
  List<NameLocale> locales = [];
  Widget? header;
  Widget? footer;

  Widget Function(BuildContext context, int index, NameLocale locale)?
      localBuilder;

  LocaleController(
      {required this.defaultLocaleName,
      this.urlPath = "api/v1/translation-locales/flutter/",
      this.selectorTitle,
      required this.defaultTranslationKeys,
      this.localBuilder});

  @override
  void onInit() {
    super.onInit();
    // readAllStorageLocales();
    // apiGetLocales();
    setCurrentLocale();
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  addMissingTranslation() {}

  CustomTranslations getCustomAppTranslations() {
    // dprint("Checking daa, configs");
    return Get.put(CustomTranslations(localesConfig: localesConfigs));
  }

  apiGetLocales() async {
    var authProv = Get.find<AuthProvider>();
    try {
      var res = await authProv.formGet(urlPath);
      if (res.statusCode == 200) {
        if (res.body.keys.isNotEmpty) {
          await box.write(allLocalesKey, res.body);
        }
      }
    } catch (e, trace) {
      dprint(e);
      dprint(trace);
    }
  }

  readAllStorageLocales() async {
    var readLocalesConfigs = await box.read(allLocalesKey);
    // dprint(readLocalesConfigs);
    Map<String, Map<String, String>> parsedLocales = {};

    if (readLocalesConfigs != null) {
      Map<String, Map<String, dynamic>>.from(readLocalesConfigs)
          .forEach((key, value) {
        value.forEach((valueKey, valueValue) {
          if (!parsedLocales.containsKey(key)) {
            parsedLocales[key] = {};
          }
          parsedLocales[key]![valueKey] = valueValue.toString();
        });
      });
    }
    localesConfigs =
        readLocalesConfigs != null ? parsedLocales : defaultTranslationKeys;
    dprint("localeCOnfigs");
    // dprint(localesConfigs);
    await Future.delayed(Duration(milliseconds: 500));
    createLocales(localesConfigs);
    if (localesConfigs == null) {
      return {};
    }
    return localesConfigs;
  }

  getLanguageName(String languageKey, dynamic translationProvidedKeys) {
    // const languageNameProperty = "language_name";
    // const languagePromptProperty = "language_prompt";
    if (translationProvidedKeys.containsKey(languageKey)) {
      var translationKeys = translationProvidedKeys[languageKey];

      if (translationKeys.containsKey(localeLanguageNameProperty)) {
        return translationKeys[localeLanguageNameProperty];
      }
    }
    return languageKey.titleCase.capitalizeEachWord;
  }

  createLocales(dynamic translationExampleKeys) {
    if (translationExampleKeys.runtimeType
        .toString()
        .contains("Map<String, Map<String, String>>")) {
      localesConfigs =
          Map<String, Map<String, String>>.from(translationExampleKeys);
      locales = localesConfigs.keys
          .map((e) => NameLocale(
                name: "@name#".interpolate(
                  {
                    "name": getLanguageName(e, translationExampleKeys),
                  },
                ),
                locale: Locale(e.split("_")[0], e.split("_")[1]),
              ))
          .toList();
    }
  }

  setLocale(NameLocale nameLocale) async {
    if (nameLocale.locale != null) {
      await box.write(locale_key, nameLocale.name);
      await setCurrentLocale();
    }
    Get.back();
  }

  setCurrentLocale() async {
    var selectedLocaleName = await getCurrentLanguage();
    // dprint(locales);
    if (locales.isEmpty) {
      return;
    }
    // dprint(selectedLocaleName);
    // dprint(locales);
    var nameLocales =
        locales.where((element) => element.name == selectedLocaleName);

    if (nameLocales.isNotEmpty) {
      selectedNameLocale.value = nameLocales.first;
      await Get.updateLocale(nameLocales.first.locale);
    } else {
      setLocale(locales.first);
    }
  }

  getCurrentLanguage() async {
    var selectedLocale = await box.read(locale_key);
    // dprint("Previouse1 locale $selectedLocale");
    if (selectedLocale != null) {
      return selectedLocale;
    }
    return defaultLocaleName;
  }

  selectLocale() async {
    bool mixPanelEnabled = false;
    MixPanelController? mixCont;
    try {
      mixCont = Get.find<MixPanelController>();
      mixPanelEnabled = true;
    } catch (e) {
      mixPanelEnabled = false;
    }

    var res = await Get.bottomSheet(
      // title: selectorTitle?.tr ?? "Select Language".tr,
      // titleStyle: Get.textTheme.displayMedium,
      Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              selectorTitle?.tr ?? "Select Language".tr,
            ),
            if (header != null) header!,
            SizedBox(
              height: Get.height * .3,
              child: ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                // shrinkWrap: true,
                itemBuilder: (context, int) {
                  var nameLocale = locales[int];

                  if (localBuilder != null) {
                    return GestureDetector(
                      onTap: () {
                        setLocale(nameLocale);
                      },
                      child: localBuilder!(context, int, nameLocale),
                    );
                  }

                  return Obx(() {
                    dprint("Selected ${selectedNameLocale.value?.name}");
                    return ListTile(
                      onTap: () {
                        setLocale(nameLocale);
                        mixCont?.track(
                          "language_selected",
                          properties: {
                            "language": selectedNameLocale.value?.name,
                          },
                        );
                      },
                      title: Text(
                        nameLocale.name,
                      ),
                      trailing:
                          selectedNameLocale.value?.name == nameLocale.name
                              ? const Icon(Icons.check_circle_sharp)
                              : const Icon(Icons.circle_outlined),
                    );
                  });
                },
                itemCount: locales.length,
              ),
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }
}
