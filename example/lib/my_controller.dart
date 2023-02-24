import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MyAppController extends GetxController {
  var isAuthenticated$ = false.obs;
  final box = GetStorage();
  

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    print("My Controller...");
  }
}
