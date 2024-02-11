import 'package:flutter/material.dart';
import 'switch_controller.dart';
import 'package:get/get.dart';

class SwitchExample extends StatelessWidget {
  const SwitchExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SwitchExampleController controller =
        Get.put(SwitchExampleController());

    return Obx(
      () => Switch(
        value: controller.light1.value,
        onChanged: (bool value) {
          controller.light1(value);
        },
      ),
    );
  }
}
