import 'package:get/get.dart';

class SwitchExampleController extends GetxController {
  var light1 = false.obs; // Initialize with default value

  void toggleLight1(bool value) {
    light1.value = value;
  }
}
