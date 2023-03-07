import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../flutter_utils.dart';
import 'models.dart';

const locale_key = "current_locale";

class LocaleController extends SuperController {
  var box = GetStorage();

  Rx<NameLocale?> selectedNameLocale = Rx(null);

  String defaultLocaleName;
  String? selectorTitle;
  List<NameLocale> locales;
  Widget? header;
  Widget? footer;
  Widget Function(BuildContext context, int index, NameLocale locale)?
      localBuilder;

  LocaleController(
      {required this.defaultLocaleName,
      required this.locales,
      this.selectorTitle,
      this.localBuilder});

  @override
  void onInit() {
    super.onInit();
    udpateLocale();
  }

  setLocale(NameLocale nameLocale) async {
    if (nameLocale.locale != null) {
      await box.write(locale_key, nameLocale.name);
      await udpateLocale();
    }
    Get.back();
  }

  udpateLocale() async {
    var selectedLocaleName = await getCurrentLanguage();
    var nameLocale =
        locales.firstWhere((element) => element.name == selectedLocaleName);
    if (nameLocale != null) {
      dprint("Selecting language ${nameLocale.name}");
      selectedNameLocale.value = nameLocale;
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
    var res = await Get.bottomSheet(
      // title: selectorTitle?.tr ?? "Select Language".tr,
      // titleStyle: Get.textTheme.displayMedium,
      Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectorTitle?.tr ?? "Select Language".tr,
              style: Get.theme.textTheme.displayMedium,
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
                      },
                      title: Text(
                        nameLocale.name,
                        style: Get.textTheme.displaySmall,
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
