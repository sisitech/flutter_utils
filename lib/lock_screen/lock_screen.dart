import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:flutter_utils/lock_screen/lock_controller.dart';
import 'package:get/get.dart';

class SistchLockScreen extends StatefulWidget {
  static const routeName = "/lock_screen";
  final String? imagePath;
  final IconData? iconPath;
  final Function onSuccess;
  final Widget? footer;

  const SistchLockScreen(
      {super.key,
      this.imagePath,
      this.iconPath,
      required this.onSuccess,
      this.footer});

  @override
  State<SistchLockScreen> createState() => _SistchLockScreenState();
}

class _SistchLockScreenState extends State<SistchLockScreen> {
  final lockCtrl = Get.find<LocalAuthController>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return ScreenLock(
      correctString: lockCtrl.passCode.toString(),
      onUnlocked: () async {
        await widget.onSuccess();
      },
      maxRetries: 3,
      retryDelay: const Duration(seconds: 30),
      delayBuilder: (context, delay) => Text(
        'Try again in ${(delay.inMilliseconds / 1000).ceil()} seconds.',
        style: textTheme.bodyMedium!.copyWith(color: colorScheme.primary),
      ),
      title: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        if (widget.imagePath != null && widget.iconPath == null)
          Image.asset(
            widget.imagePath!,
            width: 60,
            height: 60,
            fit: BoxFit.fill,
          ),
        if (widget.imagePath == null)
          Icon(
            widget.iconPath ?? Icons.lock,
            size: 50,
            color: colorScheme.primary,
          ),
        const SizedBox(height: 10),
        Text(
          'Enter your pass code',
          style: textTheme.headlineMedium!.copyWith(color: colorScheme.primary),
        ),
      ]),
      deleteButton: Icon(
        Icons.clear,
        size: 40,
        color: colorScheme.primary,
      ),
      customizedButtonTap: () async {
        bool isAuth = await lockCtrl.bioAuth();
        if (isAuth) {
          widget.onSuccess();
        }
      },
      customizedButtonChild: Icon(
        Icons.fingerprint,
        size: 50,
        color: colorScheme.primary,
      ),
      secretsConfig: SecretsConfig(
        secretConfig: SecretConfig(
          size: 40,
          borderColor: colorScheme.primary,
          enabledColor: colorScheme.primary,
        ),
      ),
      config: ScreenLockConfig(backgroundColor: colorScheme.background),
      keyPadConfig: KeyPadConfig(
        actionButtonConfig: KeyPadButtonConfig(
            buttonStyle: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          side: const BorderSide(color: Colors.transparent),
        )),
        clearOnLongPressed: true,
        buttonConfig: KeyPadButtonConfig(
          buttonStyle: OutlinedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        ),
      ),
      footer: widget.footer,
    );
  }
}
