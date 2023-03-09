import 'package:flutter/material.dart';
import 'package:flutter_utils/package_info/package_info_controller.dart';
import 'package:get/get.dart';

class PackageInfoWidget extends StatelessWidget {
  TextStyle? style;

  PackageInfoWidget({
    super.key,
    this.style,
  });
  PackageInfoController packageInfoController =
      Get.put(PackageInfoController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Text(
        packageInfoController.packageInfo.value?.version ?? "Loading...",
        style: style,
      );
    });
  }
}
