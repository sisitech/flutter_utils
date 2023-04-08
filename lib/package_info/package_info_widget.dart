import 'package:flutter/material.dart';
import 'package:flutter_utils/package_info/package_info_controller.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../internalization/language_controller.dart';

class PackageInfoWidget extends StatelessWidget {
  TextStyle? style;

  Widget Function(BuildContext context, PackageInfo? packageInfo)?
      widgetBuilder;

  PackageInfoWidget({
    super.key,
    this.style,
    this.widgetBuilder,
  });
  PackageInfoController packageInfoController =
      Get.put(PackageInfoController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widgetBuilder != null) {
        return widgetBuilder!(context, packageInfoController.packageInfo.value);
      }
      return Text(
        packageInfoController.packageInfo.value?.version ?? "Loading...",
        style: style,
      );
    });
  }
}
