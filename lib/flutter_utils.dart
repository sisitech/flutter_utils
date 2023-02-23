library flutter_utils;

import 'package:flutter/foundation.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

dprint(dynamic value) {
  if (kDebugMode) {
    if (value.runtimeType == String) {
      // debugPrint("DebugPrint");
      debugPrint(value, wrapWidth: 1024);
    } else {
      print(value);
    }
  }
}
