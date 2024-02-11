import 'package:get/get.dart';

class ExtendedFABController extends GetxController {
  var showOptions = false.obs;

  void toggleOptions() {
    showOptions.value = !showOptions.value;
  }
}
