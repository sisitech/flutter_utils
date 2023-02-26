import 'package:flutter/material.dart';
import 'package:flutter_utils/bottom_navigation/bottom_navigation.dart';
import 'package:flutter_utils/bottom_navigation/models.dart';
import 'package:flutter_utils/models.dart';
import 'package:flutter_utils/phone_call_launcher.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'internalization/translate.dart';

void main() async {
  Get.put<APIConfig>(APIConfig(
      apiEndpoint: "https://dukapi.roometo.com",
      version: "api/v1",
      clientId: "NUiCuG59zwZJR14tIdWD7iQ5ILFnpxbdrO2epHIG",
      tokenUrl: 'o/token/',
      grantType: "password",
      revokeTokenUrl: 'o/revoke_token/'));
  await GetStorage.init();
  // StoreBinding();
  runApp(const MyApp());
}

class StoreBinding implements Bindings {
// default dependency
  @override
  void dependencies() {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
                    const Text("Hello"),
                    IconButton(
                      onPressed: () async {
                        await triggerPhoneCall("0727290364");
                      },
                      icon: Icon(Icons.phone),
                    )
                  ],
                ),
              ),
              barItem: const BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: "Home"),
            ),
            BottomNavigationItem(
              widget: const Text("Hello 2"),
              barItem: const BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Settings",
              ),
            ),
            BottomNavigationItem(
              widget: const Text("Hello 4"),
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
