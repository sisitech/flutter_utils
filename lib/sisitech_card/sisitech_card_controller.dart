import 'package:get/get.dart';

class SisitechCardController extends GetxController {
  var isTextVisible = false.obs;
  void toggleTextVisibility() {
    isTextVisible.value = !isTextVisible.value;
  }
}
