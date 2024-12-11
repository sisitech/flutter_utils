import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller.dart';

class ScreenLockSamplePage extends StatelessWidget {
  const ScreenLockSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<ScreenLockController>();
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome! Authenticated'),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await controller.updatePassowrd(context);
              },
              icon: const Icon(Icons.password),
              label: const Text("Update Pattern"),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await controller.lock();
              },
              icon: const Icon(Icons.lock_open_sharp),
              label: const Text("Lock"),
            ),
          ],
        )),
      ),
    );
  }
}

class BaseScreenLockPage extends StatelessWidget {
  final Widget child;
  const BaseScreenLockPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<ScreenLockController>();
    var passwordType = "Password";
    var biometricType = "Biometric";

    return Obx(() {
      // If setup is not done, allow the user to select authentication type and set a password.
      if (!controller.isSetupDone.value) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Screen Lock Setup"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select Authentication Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton.icon(
                    icon: Row(
                      children: [
                        Icon(Icons.fingerprint),
                        Icon(Icons.face_unlock_sharp),
                      ],
                    ),
                    onPressed: () {
                      // Start the password creation flow for the selected auth type
                      controller.buildPasswordCreationLock(
                          biometricType, context);
                    },
                    label: Text(biometricType),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.keyboard_alt_outlined),
                    onPressed: () {
                      // Start the password creation flow for the selected auth type
                      controller.buildPasswordCreationLock(
                          passwordType, context);
                    },
                    label: Text(passwordType),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (!controller.isAuthenticated.value) {
        // If setup is done but not authenticated, attempt authentication when the widget builds.
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!controller.isLocked.value) {
            final success = await controller.authenticate(context);
            if (success) {
              controller.isAuthenticated.value = true;
            } else {
              // If authentication fails, show a message or handle accordingly
            }
          }
        });
        final authType = controller.isLocked.value ? null : 'password';
        String authMessage =
            controller.isLocked.value ? 'Unlock' : 'Unlock With Password';
        Widget authIcon = controller.isLocked.value
            ? Icon(Icons.lock_outline)
            : Icon(Icons.password);
        return Scaffold(
          body: Center(
            child: ElevatedButton.icon(
                onPressed: () async {
                  final success = await controller.authenticate(context,
                      providedAuthType: authType);
                  if (success) {
                    controller.isAuthenticated.value = true;
                  } else {
                    // If authentication fails, show a message or handle accordingly
                  }
                },
                icon: authIcon,
                label: Text(authMessage)),
          ),
        );
      } else {
        // User is authenticated, show the main content.
        return child;
      }
    });
  }
}
