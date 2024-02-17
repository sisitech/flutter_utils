import 'package:get/get.dart';

class SisitechSwitchController extends GetxController {
  var light1 = false.obs;
  void toggleLight(bool value) {
    light1(value);
  }
}
