import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import 'package:flutter/material.dart';

class ScreenLockOptions {
  // Core configuration
  final bool promptOnStart;
  final int maxTries;

  final String storageName;

  // Options for creating a password with screenLockCreate
  final Widget createTitle;
  final Widget createConfirmTitle;
  final Widget? createCancelButton;
  final bool createCanCancel;
  final int createDigits;
  final int? createMaxRetries;
  final Duration? createRetryDelay;

  // Options for authenticating with screenLock
  final Widget authTitle;
  final Widget? authCancelButton;
  final List<int> authDigits;
  final int authMaxRetries;
  final bool authCanCancel;
  final Duration? authRetryDelay;
  final Widget? authFooter;
  final String updatePasswordConfirmationTitle;
  final String biometricRecoveryPasswordTitle;

  final void Function() onMaxTriesExceeded;
  final void Function()? onLock;
  final bool enabled;

  ScreenLockOptions({
    this.authDigits = const [1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
    // Core configuration
    this.promptOnStart = false,
    required this.maxTries,
    required this.onMaxTriesExceeded,
    this.storageName = "drowssap_nerekscol",
    this.updatePasswordConfirmationTitle = "Enter Current passcode",
    this.biometricRecoveryPasswordTitle = "Set a recovery passcode",
    this.onLock,
    this.enabled = true,
    // Create password (screenLockCreate) configuration
    required this.createTitle,
    required this.createConfirmTitle,
    this.createCancelButton,
    this.createCanCancel = true,
    this.createDigits = 4,
    this.createMaxRetries,
    this.createRetryDelay,

    // Auth (screenLock) configuration
    required this.authTitle,
    this.authCancelButton,
    this.authMaxRetries = 3,
    this.authCanCancel = true,
    this.authRetryDelay,
    this.authFooter,
  });
}

class ScreenLockController extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  final ScreenLockOptions options;

  final inputController = InputController();

  var isSetupDone = false.obs;
  var isAuthenticated = false.obs;
  var availableAuthTypes = <String>[].obs;

  var isLocked = false.obs;

  String? _encryptionKey;

  ScreenLockController({required this.options});

  @override
  void onInit() {
    super.onInit();
    _loadEncryptionKey();
    _checkSetupStatus();
    _fetchAvailableAuthTypes();

    if (!options.enabled) {
      setAuthenticated();
    }

    // if (_options.promptOnStart) {
    //   authenticate();
    // }
  }

  void _loadEncryptionKey() async {
    _encryptionKey = await _secureStorage.read(key: 'encryption_key');
    if (_encryptionKey == null) {
      _encryptionKey = base64UrlEncode(
        List<int>.generate(32, (_) => Random.secure().nextInt(256)),
      );
      await _secureStorage.write(key: 'encryption_key', value: _encryptionKey);
    }
  }

  void _checkSetupStatus() async {
    isSetupDone.value =
        await _secureStorage.containsKey(key: options.storageName);
  }

  String _biometricTypeToString(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return "face";
      case BiometricType.fingerprint:
        return "fingerprint";
      case BiometricType.iris:
        return "iris";
      case BiometricType.strong:
        return "strong_biometric";
      case BiometricType.weak:
        return "weak_biometric";
      default:
        return "unknown_biometric";
    }
  }

  void _fetchAvailableAuthTypes() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      availableAuthTypes.clear();
      if (canCheckBiometrics && isDeviceSupported) {
        final deviceBiometrics = await _localAuth.getAvailableBiometrics();
        final converted = deviceBiometrics.map(_biometricTypeToString).toList();
        availableAuthTypes.addAll(converted);
      }
      if (!availableAuthTypes.contains("password")) {
        availableAuthTypes.add("password");
      }
    } catch (e) {
      availableAuthTypes.value = ["password"];
    }
  }

  Future<void> setUpAuthentication(
      String password, String authType, BuildContext context) async {
    print("setting up $authType");
    final encryptedPassword = _encryptPassword(password);
    await _secureStorage.write(
        key: options.storageName, value: encryptedPassword);
    await _secureStorage.write(key: 'auth_type', value: authType);
    isSetupDone.value = true;
  }

  Future<void> setAuthenticated() async {
    isAuthenticated.value = true;
    isLocked.value = false;
  }

  Future<bool> authenticate(BuildContext context,
      {String? providedAuthType, String? title}) async {
    try {
      final authType =
          providedAuthType ?? await _secureStorage.read(key: 'auth_type');
      final storedEncryptedPassword =
          await _secureStorage.read(key: options.storageName);

      if (authType == null) {
        return false;
      }

      if (authType.toLowerCase() == "password") {
        // Show screenLock for password authentication
        // We'll let the UI present this, controller just provides the widget
        return await _passwordAuthFlow(storedEncryptedPassword, context,
            title: title);
      } else {
        print("Local auth doing its thing $authType");
        // If supported, attempt biometric authentication
        return await _localAuth.authenticate(
          localizedReason: 'Please authenticate to continue',
          options: const AuthenticationOptions(
              biometricOnly: true, stickyAuth: true),
        );
      }
    } catch (e) {
      return false;
    }
  }

  String _encryptPassword(String password) {
    final keyBytes = utf8.encode(_encryptionKey!);
    final passwordBytes = utf8.encode(password);
    final encryptedBytes = List<int>.generate(passwordBytes.length,
        (i) => passwordBytes[i] ^ keyBytes[i % keyBytes.length]);
    return base64UrlEncode(encryptedBytes);
  }

  String _decryptPassword(String encryptedPassword) {
    final keyBytes = utf8.encode(_encryptionKey!);
    final encryptedBytes = base64Url.decode(encryptedPassword);
    final decryptedBytes = List<int>.generate(encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    return utf8.decode(decryptedBytes);
  }

  bool _verifyPassword(
      String enteredPassword, String? storedEncryptedPassword) {
    if (storedEncryptedPassword == null) return false;
    final decrypted = _decryptPassword(storedEncryptedPassword);
    return enteredPassword == decrypted;
  }

  updatePassowrd(BuildContext context) async {
    bool reset = await authenticate(context,
        providedAuthType: 'password',
        title: options.updatePasswordConfirmationTitle);

    if (reset) {
      clearStorage();
    }
  }

  Future<void> clearStorage() async {
    await _secureStorage.delete(key: options.storageName);
    await _secureStorage.delete(key: 'encryption_key');
    await _secureStorage.delete(key: 'auth_type');
    isSetupDone.value = false;
  }

  Future<void> lock() async {
    isAuthenticated.value = false;
    isLocked.value = true;
    if (options.onLock != null) {
      options.onLock!();
    }
  }

  Future<bool> _passwordAuthFlow(
      String? storedEncryptedPassword, BuildContext context,
      {String? title}) async {
    if (storedEncryptedPassword == null) return Future.value(false);
    bool authenticated = false;
    // Build a screenLock widget
    // The user will enter their password, and we validate it
    await screenLock(
      context: context,
      title: title != null ? Text(title) : options.authTitle,
      correctString:
          _decryptPassword(storedEncryptedPassword), // We'll validate manually
      canCancel: options.authCanCancel,
      maxRetries: options.authMaxRetries ?? 3,
      retryDelay: options.authRetryDelay ?? Duration.zero,
      footer: options.authFooter,
      cancelButton: options.authCancelButton,

      onUnlocked: () {
        // If user enters correct password, didUnlocked called
        authenticated = true;

        Navigator.of(context).pop();
      },
      onMaxRetries: (int count) {
        // Exceeded max tries
        options.onMaxTriesExceeded();
      },
    );
    print("Done with this.");
    return Future.value(authenticated);
  }

  /// Returns a widget that lets the user set up a new password using screenLockCreate.
  /// Call this from your UI to present the password creation flow.
  Future<bool> buildPasswordCreationLock(
      String authType, BuildContext context) async {
    if (isSetupDone.value) {
      final success = await authenticate(context, providedAuthType: 'password');
      if (!success) {
        clearStorage();
        options.onMaxTriesExceeded();
        return Future.value(false);
      }
    }
    var setupDone = false;
    var title = authType.toLowerCase() == "password"
        ? options.createTitle
        : Text(options.biometricRecoveryPasswordTitle);
    await screenLockCreate(
      inputController: inputController,
      context: context,
      title: title,
      confirmTitle: options.createConfirmTitle,
      canCancel: options.createCanCancel,
      cancelButton: options.createCancelButton,
      maxRetries: options.createMaxRetries ?? 3,
      retryDelay: options.createRetryDelay ?? Duration.zero,
      digits: options.createDigits,
      onConfirmed: (password) {
        print(password);
        setUpAuthentication(password, authType, context);
        // Get.back();
        setupDone = true;
        inputController.unsetConfirmed();
        Navigator.of(context).pop();
      },
      onMaxRetries: (value) {
        inputController.unsetConfirmed();
      },
      onCancelled: () {
        Navigator.of(context).pop();
      },
    );
    return Future.value(setupDone);
  }
}
