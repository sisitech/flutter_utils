import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:get/get.dart';

class LockScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        // screenLockCreate(
        //   context: Get.context!,
        //   onConfirmed: (value) =>
        //       print(value), // store new passcode somewhere here
        // );
        screenLock(
          context: Get.context!,
          correctString: '1234',
          canCancel: false,
          config: ScreenLockConfig(
            backgroundColor:
                Theme.of(Get.context!).colorScheme.primaryContainer,
            titleTextStyle: TextStyle(
              color: Theme.of(Get.context!).colorScheme.primary,
            ),
          ),
        );
      }
    });
  }
}
