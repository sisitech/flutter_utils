import 'package:flutter_utils/flutter_utils.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoController extends GetxController {
  Rx<PackageInfo?> packageInfo = Rx(null);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getPacakgeVersion();
  }

  getPacakgeVersion() async {
    packageInfo.value = await PackageInfo.fromPlatform();
    // dprint(packageInfo.value?.appName);
  }
}
