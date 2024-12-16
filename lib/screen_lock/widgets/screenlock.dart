import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
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

const biometricIcons = Row(
  children: [
    Icon(Icons.fingerprint),
    Icon(Icons.face_unlock_sharp),
  ],
);

class BaseScreenLockPage extends StatelessWidget {
  final Widget child;
  const BaseScreenLockPage({super.key, required this.child});
  final String passwordType = "Password";
  final String biometricType = "Biometric";

  void authenticateAndUpdate(controller, context) async {
    final success = await controller.authenticate(context, setOngoing: true);
    controller.resetAuthenticationOngoing();

    if (success) {
      controller.setAuthenticated();
    } else {
      // If authentication fails, show a message or handle accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<ScreenLockController>();

    return Obx(() {
      // If setup is not done, allow the user to select authentication type and set a password.

      if (!controller.options.autoStartSetup &&
          !controller.isSetUpTriggered.value) {
        // Wait for the trigger
        return child;
      } else if (!controller.isSetupDone.value) {
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
                if (controller.biometricAvailable.value)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton.icon(
                      icon: biometricIcons,
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
      } else if (!controller.isAuthenticated.value &&
          controller.triggerUnlock.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (controller.triggerUnlock.value) {
            dprint("LOCK UNLOCK AUTO PROMPT");
            controller.isLocked.value = false;
            authenticateAndUpdate(controller, context);
            controller.triggerUnlock.value = false;
          }
        });
        return Scaffold(
          body: Center(
            child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.lock),
                label: const Text("Unlock")),
          ),
        );
      } else if (!controller.isAuthenticated.value) {
        // If setup is done but not authenticated, attempt authentication when the widget builds.
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!controller.isLocked.value) {
            dprint("UI AUTHENCITA");
            authenticateAndUpdate(controller, context);
          }
        });
        final authType = controller.isLocked.value ? null : 'password';
        String unlockAuthmessage = "Unlock";
        String authMessage = controller.isLocked.value
            ? unlockAuthmessage
            : 'Unlock With Password';
        Widget authIcon = controller.isLocked.value
            ? const Icon(Icons.lock_outline)
            : const Icon(Icons.password);

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.biometricAvailable.value &&
                    !controller.isLocked.value &&
                    controller.selectedAuthType.value.toLowerCase() ==
                        "biometric") ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      dprint("CLIECKED AGAIN");
                      authenticateAndUpdate(controller, context);
                    },
                    icon: biometricIcons,
                    label: Text("Try Again"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
                ElevatedButton.icon(
                  onPressed: () async {
                    dprint("CLIECKED AUTH MESSAGE");
                    if (authMessage == unlockAuthmessage) {
                      controller.isLocked.value = false;
                    }
                    // Resets the lockstate so as to see try again and unlock with password
                    final success = await controller.authenticate(context,
                        providedAuthType: authType, setOngoing: true);
                    controller.resetAuthenticationOngoing();

                    if (success) {
                      controller.setAuthenticated();
                    } else {
                      // If authentication fails, show a message or handle accordingly
                    }
                  },
                  icon: authIcon,
                  label: Text(authMessage),
                ),
              ],
            ),
          ),
        );
      } else {
        // User is authenticated, show the main content.
        return child;
      }
    });
  }
}
