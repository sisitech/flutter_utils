import 'package:flutter/material.dart';
import 'package:flutter_utils/screen_lock/controller.dart';
import 'package:get/get.dart';

var screenLockOptions = ScreenLockOptions(
  // Digits for authentication, if needed.
  promptOnStart: false, // We can manually trigger authentication if desired
  maxTries: 3,
  autoStartSetup: false,
  // enabled: false,
  onMaxTriesExceeded: () {
    Get.back();
    Get.snackbar('Error', 'Maximum authentication attempts exceeded!');
  },
  // Create password configuration
  createTitle: const Text('Set a new Passcode'),
  createConfirmTitle: const Text('Confirm your Passcode'),
  createCancelButton: const Icon(Icons.arrow_back),
  createCanCancel: true,
  createDigits: 4,
  createMaxRetries: 3,
  createRetryDelay: const Duration(seconds: 5),

  // Authentication configuration
  authTitle: const Text('Enter your passcode'),
  authCancelButton: const Icon(Icons.arrow_back),
  authMaxRetries: 3,
  authCanCancel: true,
  authRetryDelay: const Duration(seconds: 5),
  onLock: () async {
    Get.toNamed("/");
  },
  authFooter: ElevatedButton.icon(
      onPressed: () {
        print("Gount back");
        var cnt = Get.find<ScreenLockController>();
        cnt.clearStorage();
        Get.back();
      },
      icon: const Icon(Icons.question_mark),
      label: const Text('Forgot passcode?')),
);
