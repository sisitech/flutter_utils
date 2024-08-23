import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthController extends GetxController {
  static final _localAuth = LocalAuthentication();
  int? passCode;
  var box = GetStorage();

  /* ------ secret passCode ------- */

  Future<void> storePassCode(int passCode, ColorScheme colorScheme) async {
    box.write("passCode", passCode);
    showSnackbar(
        iconPath: Icons.check_rounded,
        title: "New pass code saved!",
        colorScheme: colorScheme,
        subtitle: "Your data is now more secure");
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<int?> getPassCode() async {
    var pass = box.read<int>('passCode');
    if (pass != null) {
      passCode = pass;
    }
    return pass;
  }

  /* ------ biometrics ------ */

  Future<bool> bioAuth() async {
    final isAuthenticated = await authenticate();
    return isAuthenticated;
  }

  Future<bool> hasBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  static Future<List<BiometricType>> getBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;

    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate using biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /* ------ UI ------- */
  RxBool showValidator = false.obs;
  RxBool isHidden = false.obs;
  int? password;
  int? confirmPass;
  final TextEditingController fieldOne = TextEditingController();
  final TextEditingController fieldTwo = TextEditingController();
  final TextEditingController fieldThree = TextEditingController();
  final TextEditingController fieldFour = TextEditingController();

  ///
  final TextEditingController fieldFive = TextEditingController();
  final TextEditingController fieldSix = TextEditingController();
  final TextEditingController fieldSeven = TextEditingController();
  final TextEditingController fieldEight = TextEditingController();

  ///
  final GlobalKey<FormState> codeFormKey = GlobalKey<FormState>();

  Future<bool> onSavePassCode(ColorScheme colorScheme) async {
    final isValid = codeFormKey.currentState!.validate();
    if (!isValid) {
      return false;
    }
    showValidator.value = false;
    password = int.parse(
        fieldOne.text + fieldTwo.text + fieldThree.text + fieldFour.text);
    confirmPass = int.parse(
        fieldFive.text + fieldSix.text + fieldSeven.text + fieldEight.text);
    if (password == confirmPass) {
      await storePassCode(password!, colorScheme);
      return true;
    } else {
      showValidator.value = true;
    }
    return false;
  }

  resetForm() {
    fieldOne.clear();
    fieldTwo.clear();
    fieldThree.clear();
    fieldFour.clear();
    fieldFive.clear();
    fieldSix.clear();
    fieldSeven.clear();
    fieldEight.clear();
    showValidator.value = false;
    codeFormKey.currentState?.reset();
  }
}
