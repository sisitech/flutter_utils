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
  final String? title;
  final String? subTitle;
  const BaseScreenLockPage(
      {super.key, required this.child, this.title, this.subTitle});
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
        final theme = Theme.of(context);
        final buttonStyle = ElevatedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          minimumSize: const Size(double.infinity, 48),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        );
        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            size: 28,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title ?? "Secure Your App",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subTitle ??
                              "Protect your financial data with a screen lock. Choose your preferred authentication method.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                            height: 1.5,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 28),
                        if (controller.biometricAvailable.value) ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              controller.buildPasswordCreationLock(
                                  biometricType, context);
                            },
                            icon: Icon(
                              Icons.fingerprint,
                              color: theme.colorScheme.secondary,
                            ),
                            label: const Text("Biometric"),
                            style: buttonStyle,
                          ),
                          const SizedBox(height: 12),
                        ],
                        ElevatedButton.icon(
                          onPressed: () {
                            controller.buildPasswordCreationLock(
                                passwordType, context);
                          },
                          icon: Icon(
                            Icons.lock,
                            color: theme.colorScheme.secondary,
                          ),
                          label: const Text("Password"),
                          style: buttonStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  elevation: 2,
                  color: theme.colorScheme.surface,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () async {
                            await controller.clearTriggerScreenLockSetup();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Set Up Later",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
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
          body: SafeArea(
            child: Center(
              child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock),
                  label: const Text("Unlock")),
            ),
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
          body: SafeArea(
            child: Center(
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
          ),
        );
      } else {
        // User is authenticated, show the main content.
        return child;
      }
    });
  }
}
