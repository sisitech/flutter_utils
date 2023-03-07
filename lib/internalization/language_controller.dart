import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../flutter_utils.dart';
import 'models.dart';

const languages_map = {"som": Locale('swa', 'KE'), "eng": Locale('en', 'US')};
const locale_key = "current_locale";

class LocaleController extends SuperController {
  var current_local_name = "eng".obs;
  var box = GetStorage();

  String defaultLocaleName;
  List<NameLocale> locales;
  Widget? header;
  Widget? footer;
  Widget Function(BuildContext context, int index, NameLocale locale)?
      localBuilder;

  LocaleController(
      {required this.defaultLocaleName,
      required this.locales,
      this.localBuilder});

  @override
  void onInit() {
    super.onInit();
    udpateLocale();
  }

  setLocale(NameLocale nameLocale) async {
    if (nameLocale.locale != null) {
      await box.write(locale_key, nameLocale.name);
      Get.updateLocale(nameLocale.locale!);
    }
    Get.back();
  }

  udpateLocale() async {
    var selectedLocaleName = await getCurrentLanguage();
    var nameLocale =
        locales.firstWhere((element) => element.name == selectedLocaleName);
    if (nameLocale != null) {
      dprint("Selecting language ${nameLocale.name}");
      Get.updateLocale(nameLocale.locale);
    }
  }

  getCurrentLanguage() async {
    var selectedLocale = await box.read(locale_key);
    dprint("Previouse locale $selectedLocale");
    if (selectedLocale != null) {
      return selectedLocale;
    }
    return defaultLocaleName;
  }

  selectLocale() async {
    var res = await Get.defaultDialog(
      title: "Select Language".tr,
      titleStyle: Get.textTheme.displayMedium,
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (header != null) header!,
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
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
                return ListTile(
                  onTap: () {
                    setLocale(nameLocale);
                  },
                  title: Text(
                    nameLocale.name,
                    style: Get.textTheme.displaySmall,
                  ),
                );
              },
              itemCount: locales.length,
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
