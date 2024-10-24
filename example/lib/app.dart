import 'dart:convert';
import 'dart:typed_data';

import 'package:example/chart_widgets.dart';
import 'package:example/svg_widgets.dart';
import 'package:example/util_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form/form_connect.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_utils/bottom_navigation/bottom_navigation.dart';
import 'package:flutter_utils/bottom_navigation/models.dart';
import 'package:flutter_utils/cached_image/sisitech_cached_image.dart';
import 'package:flutter_utils/drawer/drawer.dart';
import 'package:flutter_utils/fab/fab_controller.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/graphs/bar.dart';
import 'package:flutter_utils/graphs/graphs_models.dart';
import 'package:flutter_utils/graphs/pie.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:flutter_utils/internalization/language_controller.dart';
import 'package:flutter_utils/local_nofitications/local_notification_controller.dart';
import 'package:flutter_utils/lock_screen/lock_controller.dart';
import 'package:flutter_utils/lock_screen/lock_screen.dart';
import 'package:flutter_utils/lock_screen/set_lock_screen.dart';
import 'package:flutter_utils/mixpanel/mixpanel_controller.dart';
import 'package:flutter_utils/models.dart';
import 'package:flutter_utils/network_status/network_status.dart';
import 'package:flutter_utils/nfc/models.dart';
import 'package:flutter_utils/nfc/nfc_writer.dart';
import 'package:flutter_utils/nfc/nfc_controller.dart';
import 'package:flutter_utils/nfc/utils.dart';
import 'package:flutter_utils/offline_http_cache/offline_http_cache.dart';
import 'package:flutter_utils/package_info/package_info_widget.dart';
import 'package:flutter_utils/phone_call_launcher.dart';
import 'package:flutter_utils/sisitech_themes/theme_controller.dart';
import 'package:flutter_utils/sisitech_themes/theme_picker.dart';
import 'package:flutter_utils/sistch_progress_indicator/sistch_progress_controller.dart';
import 'package:flutter_utils/sistch_progress_indicator/sistch_progress_indicator.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:get/get.dart';
import 'package:flutter_utils/fab/fab.dart';
import 'package:flutter_utils/internalization/select_locale.dart';
import 'package:flutter_utils/extensions/date_extensions.dart';
import 'package:flutter_utils/switch/switch.dart';
import 'package:flutter_utils/sisitech_card/sisitech_card.dart';
import 'package:flutter_utils/nfc/nfc.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'constatns.dart';
import 'nfc_found_widget.dart';

const progressBar = "main";

class MyApp extends StatelessWidget {
  OfflineHttpCacheController offlineCont =
      Get.find<OfflineHttpCacheController>();

  MixPanelController mixCont = Get.find<MixPanelController>();

  // final LockScreenController lockScreenController =
  //     Get.put(LockScreenController());

  MyApp({super.key}) {
    // OfflineHttpCall()
    offlineCont
        .saveOfflineCache(OfflineHttpCall(
      name: "add friend",
      httpMethod: "GET",
      urlPath: "api/v1/users",
    ))
        .then((value) {
      dprint("Saved recordss");
    }, onError: (error) {
      dprint("Fialed to saved offline redocrd");
    });
  }

  var data = [
    {
      "value": "June",
      "present_males": 10,
      "absent_males": 1,
      "present_females": 10,
      "absent_females": 1,
    },
    {
      "value": "July",
      "present_males": 110,
      "absent_males": 11,
      "present_females": 30,
      "absent_females": 4,
    }
  ];
  List<String> titles = []; //['Mn', 'Te', 'Wd', 'Tu', 'Fr', 'St', 'Su'];
  // var titles;
  List<BarChartGroupData> mybarGroups = [];

  handleTag(String serial_number) async {
    var nfcControllera = Get.find<NFCController>(tag: defaultNfcOptions.tag);
    dprint("Found: ${serial_number}");
    dprint("Searching online");
    nfcControllera.scannerStatus.value = "Verifying NFC Tag...";
    FormProvider serv = Get.put<FormProvider>(FormProvider());

    if (serial_number == "") {
      nfcControllera.scannerStatus.value = "NFC card not supported";
      return;
    }
    var response = await serv.formGet("api/v1/nfc-tags/${serial_number}/");
    dprint(response.statusCode);
    if (response.statusCode == 404) {
      nfcControllera.scannerStatus.value = "Invalid or Unregistered.";
      var data = {"order": 1, "model": 2, "manufacturer_serial": serial_number};
      var response = await serv.formPost(
          "api/v1/nfc-tag-orders/${data["order"]}/tags/", data);
      if (response.statusCode == 201) {
        nfcControllera.scannerStatus.value =
            "Registered Successfully. Scan another Tag";
      } else if (response.statusCode == 400) {
        nfcControllera.scannerStatus.value = "Form filled wrongly";
      } else {
        nfcControllera.scannerStatus.value = "Failed .${response.statusCode}";
      }
    } else {
      nfcControllera.scannerStatus.value = "Already Registered and Valid";
    }
  }

  /// Screen Lock Config
  RxBool showMainApp = false.obs;
  final lockCtrl = Get.find<LocalAuthController>();
  Future<void> startApp() async {
    int? pc = await lockCtrl.getPassCode();
    if (pc == null) {
      showMainApp.value = true;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    titles = data.map((e) => e["value"].toString()).toList();

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        debugPrint("Rebuilding...");
        return GetMaterialApp(
          title: 'Flutter Demo',
          translations: Get.find<LocaleController>().getCustomAppTranslations(),
          theme: themeController.lightTheme.value,
          darkTheme: themeController.darkTheme.value,
          home: Obx(
            () => showMainApp.value
                ? mainApp(context)
                : FutureBuilder(
                    future: startApp(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Scaffold(
                            body: CircularProgressIndicator(),
                          );
                        default:
                          if (snapshot.hasError) {
                            debugPrint('$snapshot.error');
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return SistchLockScreen(onSuccess: () {
                              showMainApp.value = true;
                            });
                          }
                      }
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget mainApp(BuildContext context) {
    var writerTag = "writer";
    final ExtendedFABController fabController =
        Get.put(ExtendedFABController());
    var nfcController = Get.put(
      NFCController(
        options: defaultNfcOptions,
        onNfcTagDiscovered: (NfcTagInfo tag) async {
          var serial_number = tag.serial_number ?? "";
          handleTag(serial_number);
        },
      ),
      tag: defaultControllerTagName,
    );
    String inputString = "michameiu";
    NdefRecord uriRecord = NdefRecord.createUri(
        Uri.parse("https://sisitech.com/#/case-studies/wavvy"));
    NdefRecord externalRecord2 = NdefRecord.createExternal(
        'com.sisitech', // domain
        'username', // type
        Uint8List.fromList(utf8.encode(inputString)) // payload as byte array
        );

    var rednfcController = Get.put(
        NFCController(
            options: defaultNfcOptions,
            onNfcTagDiscovered: (
              NfcTagInfo tag,
            ) async {}),
        tag: writerTag);

    return SafeArea(
      child: SistchLayoutWithDrawerBottomNavigation(
        drawer: SisitechDrawer(
          headerText: 'Welcome,',
          headerSubText: 'Ali Dennis',
          // headerImage: "https://avatars.githubusercontent.com/u/9420130?v=4",
          items: [
            SisitechDrawerItem(
              title: 'Theme Picker',
              onTap: () {
                Get.to(() => SistchThemePicker());
              },
              leadingIcon: Icons.settings,
              trailingIcon: Icons.arrow_forward,
            ),
            SisitechDrawerItem(
              title: 'Svg Widgets',
              onTap: () {
                Get.to(() => const SvgWidgetDemo());
              },
              leadingIcon: Icons.image,
              trailingIcon: Icons.arrow_forward,
            ),
            SisitechDrawerItem(
              title: 'Util Widgets',
              onTap: () {
                Get.to(() => const UtilWidgetsScreen());
              },
              leadingIcon: Icons.plumbing,
              trailingIcon: Icons.arrow_forward,
            ),
            SisitechDrawerItem(
              title: 'Chart Widgets',
              onTap: () {
                Get.to(() => const ChartWidgetsScreen());
              },
              leadingIcon: Icons.bar_chart,
              trailingIcon: Icons.arrow_forward,
            ),
            SisitechDrawerItem(
              title: 'Reset Pass Code',
              onTap: () async {
                int? pc = await lockCtrl.getPassCode();
                Get.to(
                  () => pc == null
                      ? const SetLockScreen()
                      : SistchLockScreen(
                          onSuccess: () {
                            Get.off(
                              const SetLockScreen(),
                            );
                          },
                        ),
                );
              },
              leadingIcon: Icons.lock,
              trailingIcon: Icons.arrow_forward,
            ),
            // Add more items as needed
          ],
        ),
        appBar: AppBar(
          title: const Text('Flutter Utils'),
        ),
        floatingActionButton: ExtendedFAB(
          items: [
            FabItem(
              icon: const Icon(Icons.add),
              title: 'Add',
              onPressed: () => print('Add pressed'),
            ),
            FabItem(
              icon: const Icon(Icons.remove),
              title: 'Remove',
              onPressed: () => print('Remove pressed'),
            ),
            FabItem(
              icon: const Icon(Icons.share),
              title: 'Share',
              onPressed: () => print('Share pressed'),
            ),
            FabItem(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Example action to update the progress
                final ProgressBarController controller =
                    Get.find<ProgressBarController>(tag: progressBar);

                var newValue =
                    (controller.progress.value + 0.1).clamp(0.0, 1.0);
                controller.incrementProgress();
              },
              title: "Progress",
            )
          ],
        ),
        name: 'main',
        tabs: [
          BottomNavigationItem(
            widget: SingleChildScrollView(
              controller: fabController.scrollController,
              padding: const EdgeInsets.all(25),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NfcReader(
                      options: NFCReaderOptions(
                          // foundWidget: NFCTagsFoundWidget(
                          //   tag: defaultControllerTagName,
                          // ),
                          ),
                    ),
                    NfcWriter(
                      options: NFCWriterOptions(tag: writerTag, records: [
                        uriRecord,
                        externalRecord2,
                      ]),
                    ),
                    IconButton(
                      onPressed: () async {
                        await triggerPhoneCall("0727290364");
                      },
                      icon: const Icon(Icons.phone),
                    ),
                    PackageInfoWidget(),
                    SisitechSwitch(
                      externalOnChanged: (bool value) {
                        // ignore: avoid_print
                        print("Switch state changed to: $value");
                      },
                    ),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SisitechCard(
                            iconData: Icons.call_received,
                            description: 'Kes. 140,000',
                            color: Theme.of(context).colorScheme.primary,
                            cardAxisAlignment: CrossAxisAlignment.center,
                            title: 'In',
                            enableTextVisibilityToggle: true,
                            controller: SisitechCardController(),
                          ),
                          SisitechCard(
                            cardWidth: Get.width * 0.33,
                            iconData: Icons.wallet,
                            description: 'Kes. 10,000',
                            color: Theme.of(context).colorScheme.primary,
                            cardAxisAlignment: CrossAxisAlignment.center,
                            title: 'Mpesa Balance',
                            enableTextVisibilityToggle: true,
                            topRightWidget: const SizedBox(height: 20),
                            controller: SisitechCardController(),
                          ),
                          SisitechCard(
                            iconData: Icons.call_made,
                            description: 'Kes. 160,000',
                            color: Theme.of(context).colorScheme.primary,
                            cardAxisAlignment: CrossAxisAlignment.center,
                            title: 'Out',
                            enableTextVisibilityToggle: true,
                            controller: SisitechCardController(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 1000,
                      child: SisitechCard(
                        assetImage: "assets/images/sisitech_logo_kinda.png",
                        topRightWidget: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 5),
                          decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_downward, size: 12),
                              SizedBox(width: 2),
                              Text("12.2%"),
                            ],
                          ),
                        ),
                        iconSize: 40,
                        iconColor: Theme.of(context).dialogBackgroundColor,
                        description: 'Kes. 10,000',
                        color: Theme.of(context).colorScheme.primary,
                        imageScale: 130,
                        title: 'Balance', // Optional, as it defaults to teal
                        enableTextVisibilityToggle: true,
                        controller: SisitechCardController(),
                      ),
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          var notCont = Get.find<LocalNotificationController>();
                          notCont.counter.value = notCont.counter.value + 1;
                          const AndroidNotificationDetails
                              androidNotificationDetails =
                              AndroidNotificationDetails('B0', 'Basic',
                                  channelDescription:
                                      'For testing purposes nothing more',
                                  importance: Importance.max,
                                  priority: Priority.high,
                                  ticker: 'ticker');
                          const NotificationDetails notificationDetails =
                              NotificationDetails(
                            android: androidNotificationDetails,
                          );
                          var title = "Hello ${notCont.counter.value}";
                          mixCont.track(title);
                          notCont.showBasicNotification(notCont.counter.value,
                              title, "THis is the body", notificationDetails);
                        },
                        icon: const Icon(Icons.notification_add_outlined),
                        label: const Text("Send Notification")),
                    Text(
                      "@name of @you# "
                              "\nSimple List: @details#"
                              "\nSimple List Index: @details.0#"
                              "\nMap: @map.name.year# "
                              "\nMap - List: @map.name.names# "
                              "\nMap - List: @map.name.details#"
                              "\n List<dynamic>: @studs.0.name#"
                              "\n List<dynamic>2 : @studs..name#"
                          .interpolate({
                        "name": "Micha",
                        "you": "Iu",
                        "details": ["Math", "Eng"],
                        "map": {
                          "name": {
                            "age": 10,
                            "names": [],
                            "details": ["Math", "Eng"],
                            "year": "1999",
                          },
                        },
                        "studs": [
                          {"name": "Mwash"},
                          {"name": "Kev"},
                        ]
                      }, listSeparator: ", "),
                    ),
                    Text("hello".ctr),
                    Text("hello1".ctr),
                    Text("@name#".ctr.interpolate({"name": "hello"})),
                    Text("@name#_@name2#".ctr.interpolate({"name": "hello"})),
                    Text(DateTime.now().toWeekDayDate),
                    Text(DateTime.now().toAPIDate),
                    Text(DateTime.now().toAPIDateTime),
                    Text("hello_dada".titleCase),
                    Text("hello_dada".capitalizeEachWord),
                    UtilsPieChart(
                      data: PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 25,
                            color: Colors.blue,
                            title: '26% Present',
                          ),
                          PieChartSectionData(
                            value: 75,
                            color: Colors.green,
                            title: '75%',
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            barItem: const BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Home"),
          ),
          BottomNavigationItem(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SisitechProgressIndicator(
                  options: SisitechProgressOptions(
                    name: progressBar,
                    totalSteps: 0,
                    currentStep: 1,
                  ),
                ),
                NetworkStatusWidget(),
                const LocaleSelectorWidget(
                  child: Text("Select language / Chagua Lugha"),
                ),
                // LocaleSelectorWidget(child:)
              ],
            ),
            barItem: const BottomNavigationBarItem(
              icon: Icon(Icons.wifi),
              label: "Wifi",
            ),
          ),
          BottomNavigationItem(
            widget: SingleChildScrollView(
              child: Column(
                children: [
                  CustomBarGraph(
                    data: data,
                    xAxisField: "value",
                    yAxisFields: [
                      CustomBarChartRodData(field: 'present_males'),
                      CustomBarChartRodData(field: 'absent_males'),
                      CustomBarChartRodData(
                          field: 'present_females', color: Colors.amber),
                    ],
                  ),
                  LoginWidget(
                    onLoginChange: (data) {
                      dprint(data);
                      try {
                        MixPanelController? mixCont =
                            Get.find<MixPanelController>();
                        mixCont.setLoggedInUser();
                        // dprint("Set the mixpanel user");
                      } catch (e) {
                        // dprint("Error setting mixpanel user");
                        dprint(e);
                      }
                    },
                  ),
                ],
              ),
            ),
            barItem: const BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ),
          BottomNavigationItem(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NetworkStatusWidget(),
                const LocaleSelectorWidget(
                  child: Text("Select language / Chagua Lugha"),
                ),
                const SizedBox(
                  height: 50,
                ),
                const SisitechCachedImage(
                    imageUrl:
                        "https://cdn.vox-cdn.com/thumbor/mlWqtqxSTJ4KuqOB65JvA6u5sTQ=/1400x1050/filters:format(jpeg)/cdn.vox-cdn.com/uploads/chorus_asset/file/24729976/1498680017.jpg"),
              ],
            ),
            barItem: const BottomNavigationBarItem(
              icon: Icon(Icons.wifi),
              label: "Wifi",
            ),
          ),
        ],
      ),
    );
  }
}
