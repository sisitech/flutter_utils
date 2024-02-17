import 'package:flutter/material.dart';
import 'switch_controller.dart';
import 'package:get/get.dart';

class SisitechSwitch extends StatelessWidget {
  final void Function(bool)? externalOnChanged;
  const SisitechSwitch({Key? key, this.externalOnChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SisitechSwitchController controller =
        Get.put(SisitechSwitchController());

    return Obx(
      () => Switch(
        value: controller.light1.value,
        onChanged: (bool value) {
          controller.toggleLight(value);
          externalOnChanged?.call(value);
        },
      ),
    );
  }
}
