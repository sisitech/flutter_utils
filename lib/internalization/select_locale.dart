import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'language_controller.dart';

class LocaleSelectorWidget extends StatelessWidget {
  const LocaleSelectorWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var localeCont = Get.find<LocaleController>();
    return GestureDetector(
      onTap: localeCont.selectLocale,
      child: child,
    );
  }
}
