import 'package:flutter/material.dart';
import 'package:flutter_utils/bottom_navigation/bottom_navigation.dart';
import 'package:flutter_utils/bottom_navigation/models.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/graphs/bar.dart';
import 'package:flutter_utils/graphs/graphs_models.dart';
import 'package:flutter_utils/graphs/pie.dart';
import 'package:flutter_utils/models.dart';
import 'package:flutter_utils/network_status/network_status.dart';
import 'package:flutter_utils/network_status/network_status_controller.dart';
import 'package:flutter_utils/phone_call_launcher.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'internalization/translate.dart';
import 'package:fl_chart/fl_chart.dart';

// import 'package:flutter_utils/';
void main() async {
  Get.put<APIConfig>(APIConfig(
      apiEndpoint: "https://dukapi.roometo.com",
      version: "api/v1",
      clientId: "NUiCuG59zwZJR14tIdWD7iQ5ILFnpxbdrO2epHIG",
      tokenUrl: 'o/token/',
      grantType: "password",
      revokeTokenUrl: 'o/revoke_token/'));
  await GetStorage.init();

  Get.put(NetworkStatusController());
  // StoreBinding();
  runApp(MyApp());
}

class StoreBinding implements Bindings {
// default dependency
  @override
  void dependencies() {}
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
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

    var textStyle = Get.textTheme.displayMedium;

    return GetMaterialApp(
      // initialBinding: ,
      title: 'Flutter Demo',
      translations: AppTranslations(),
      locale: const Locale('swa', 'KE'),
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: SafeArea(
        child: CustomGetxBottomNavigation(
          name: 'main',
          tabs: [
            BottomNavigationItem(
              widget: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await triggerPhoneCall("0727290364");
                      },
                      icon: Icon(Icons.phone),
                    ),
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
                ],
              ),
              barItem: const BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Settings",
              ),
            ),
            BottomNavigationItem(
              widget: Center(
                child: NetworkStatusWidget(),
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
