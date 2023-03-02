import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './network_status_controller.dart';

class NetworkStatusWidget extends StatelessWidget {
  NetworkStatusWidget(
      {Key? key,
      this.internetConnectionActiveLabel,
      this.internetConnectionActiveLabelStyle,
      this.internetConnectionInActiveLabel,
      this.internetConnectionInActiveLabelStyle,
      this.title,
      this.connectionSourceStyle,
      this.titleStyle})
      : super(key: key);

  String? title;
  TextStyle? titleStyle;
  TextStyle? connectionSourceStyle;

  String? internetConnectionActiveLabel;
  String? internetConnectionInActiveLabel;

  TextStyle? internetConnectionActiveLabelStyle;
  TextStyle? internetConnectionInActiveLabelStyle;

  @override
  Widget build(BuildContext context) {
    NetworkStatusController networkCont = Get.find<NetworkStatusController>();

    return Obx(() {
      TextStyle? style = networkCont.isDeviceConnected.value
          ? internetConnectionActiveLabelStyle
          : internetConnectionInActiveLabelStyle;
      return ListTile(
        title: Text(
          title ?? "Internet Status".tr,
          style: titleStyle ?? Get.theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          networkCont.connectionSource.value.tr,
          style: connectionSourceStyle ?? Get.theme.textTheme.titleSmall,
        ),
        trailing: Card(
          // color: "tile.trailingBackgroundColor",
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              networkCont.isDeviceConnected.value
                  ? internetConnectionActiveLabel ?? "Connected".tr
                  : internetConnectionInActiveLabel ?? "No internet".tr,
              style: style ??
                  Get.theme.textTheme.titleSmall?.copyWith(
                    fontSize: 13,
                    color: networkCont.isDeviceConnected.value
                        ? Colors.green
                        : Colors.red,
                  ),
            ),
          ),
        ),
      );
    });
  }
}
