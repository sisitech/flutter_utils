import 'package:flutter/material.dart';

import 'bottom_controller.dart';

class BottomNavigationItem {
  final Widget widget;
  final BottomNavigationBarItem barItem;
  // final void Function(BottomNavigationController cont)? onSelect;

  BottomNavigationItem({
    required this.widget,
    required this.barItem,
    // this.onSelect,
  });
}
