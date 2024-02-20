import 'package:flutter/material.dart';
import 'package:flutter_auth/flutter_auth_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_utils/bottom_navigation/bottom_navigation.dart';
import 'package:flutter_utils/bottom_navigation/models.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/graphs/bar.dart';
import 'package:flutter_utils/graphs/graphs_models.dart';
import 'package:flutter_utils/graphs/pie.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:flutter_utils/internalization/language_controller.dart';
import 'package:flutter_utils/internalization/models.dart';
import 'package:flutter_utils/local_nofitications/local_notification_controller.dart';
import 'package:flutter_utils/mixpanel/mixpanel_controller.dart';
import 'package:flutter_utils/models.dart';
import 'package:flutter_utils/network_status/network_status.dart';
import 'package:flutter_utils/network_status/network_status_controller.dart';
import 'package:flutter_utils/offline_http_cache/offline_http_cache.dart';
import 'package:flutter_utils/package_info/package_info_widget.dart';
import 'package:flutter_utils/phone_call_launcher.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_utils/fab/fab.dart';
import 'internalization/translate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_utils/internalization/select_locale.dart';
import 'package:flutter_utils/extensions/date_extensions.dart';
import 'package:flutter_utils/switch/switch.dart';
import 'package:flutter_utils/sisitech_card/sisitech_card.dart';

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
    updateAPIDebug: true,
    updateMissOnlyDebug: false,
    printMissOnlyDebug: false,
  ));

  Get.put(OfflineHttpCacheController());
  Get.put(
      MixPanelController(mixpanelToken: "f3132cbb2645d462c7b2058cb6e8e8f6"));
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

  runApp(MyApp());
}

class StoreBinding implements Bindings {
// default dependency
  @override
  void dependencies() {}
}

class MyApp extends StatelessWidget {
  OfflineHttpCacheController offlineCont =
      Get.find<OfflineHttpCacheController>();

  MixPanelController mixCont = Get.find<MixPanelController>();
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    titles = data.map((e) => e["value"].toString()).toList();

    return GetMaterialApp(
      // initialBinding: ,
      title: 'Flutter Demo',
      translations: Get.find<LocaleController>().getCustomAppTranslations(),
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: SafeArea(
        child: CustomGetxBottomNavigation(
          floatingActionButton: ExtendedFAB(
            // mainIcon: Icon(Icons.add), // Specify the main icon here
            backgroundColor: Get.theme.primaryColor, // And the background color
            items: [
              FabItem(
                icon: const Icon(Icons.add),
                onPressed: () => print('Add pressed'),
              ),
              FabItem(
                icon: const Icon(Icons.remove),
                onPressed: () => print('Remove pressed'),
              ),
              FabItem(
                icon: const Icon(Icons.share),
                onPressed: () => print('Share pressed'),
              ),
            ],
          ),
          name: 'main',
          tabs: [
            BottomNavigationItem(
              widget: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () async {
                          mixCont.track("Call Made");
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
                      SizedBox(
                        width: Get.width * 1,
                        child: const SisitechCard(
                          assetImage: 'assets/images/sisitech_logo_kinda.png',
                          description: 'Kshs. 10,000',
                          color: Colors.teal,
                          imageScale: 130,
                          title: 'Balance', // Optional, as it defaults to teal
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 1,
                        child: SisitechCard(
                          iconData: Icons.abc,
                          iconSize: 40,
                          iconColor: Theme.of(context).dialogBackgroundColor,
                          description: 'Kshs. 10,000',
                          color: Colors.teal,
                          imageScale: 130,
                          title: 'Balance', // Optional, as it defaults to teal
                        ),
                      ),
                      ElevatedButton.icon(
                          onPressed: () {
                            var notCont =
                                Get.find<LocalNotificationController>();
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
                            notCont.showBasicNotification(
                                notCont.counter.value,
                                "Hello ${notCont.counter.value}",
                                "THis is the body",
                                notificationDetails);
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
                  const LoginWidget(),
                ],
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
                  // LocaleSelectorWidget(child:)
                ],
              ),
              barItem: const BottomNavigationBarItem(
                icon: Icon(Icons.wifi),
                label: "Wifi",
              ),
            )
          ],
        ),
      ),
    );
  }
}


// class HomePage extends StatelessWidget {
//   HomePage({super.key});
//   AuthController authController = Get.find<AuthController>();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text("Logged in"),

//       ],
//     );
//   }
// }
