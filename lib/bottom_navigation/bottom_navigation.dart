import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'bottom_controller.dart';
import 'models.dart';

class CustomGetxBottomNavigation extends StatelessWidget {
  final List<BottomNavigationItem> tabs;
  final Function? onControllerSetup;
  final String name;

  final Function? onTap;
  double? elevation;
  BottomNavigationBarType? type;
  Color? fixedColor;
  Color? backgroundColor;
  double iconSize;
  Color? selectedItemColor;
  Color? unselectedItemColor;
  IconThemeData? selectedIconTheme;
  IconThemeData? unselectedIconTheme;
  double selectedFontSize;
  double unselectedFontSize;
  TextStyle? selectedLabelStyle;
  TextStyle? unselectedLabelStyle;
  bool? showSelectedLabels;
  bool? showUnselectedLabels;
  MouseCursor? mouseCursor;
  bool? enableFeedback;
  BottomNavigationBarLandscapeLayout? landscapeLayout;

  BottomNavigationController? bottomNavigationController;
  CustomGetxBottomNavigation({
    super.key,
    required this.tabs,
    required this.name,
    this.onControllerSetup,
    this.onTap,
    this.elevation,
    this.fixedColor,
    this.backgroundColor,
    this.iconSize = 24.0,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedIconTheme,
    this.unselectedIconTheme,
    this.selectedFontSize = 14.0,
    this.unselectedFontSize = 12.0,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.showSelectedLabels,
    this.showUnselectedLabels,
    this.mouseCursor,
    this.enableFeedback,
    this.landscapeLayout,
  }) {
    bottomNavigationController =
        Get.put(BottomNavigationController(), tag: name);
    if (tabs.length == 0) if (onControllerSetup != null) {
      onControllerSetup!(bottomNavigationController);
    }
  }
  @override
  Widget build(BuildContext context) {
    var bottomNavigationController =
        Get.put(BottomNavigationController(), tag: name);
    // return Obx(() => bottomNavigationController.selectedTab(tabs));
    return Obx(
      () => Scaffold(
        body: bottomNavigationController.selectedTab(tabs),
        bottomNavigationBar: BottomNavigationBar(
          items: tabs.map((e) => e.barItem).toList(),
          onTap: (index) {
            bottomNavigationController?.selectTab(index, onTap);
          },
          currentIndex: bottomNavigationController?.selectedIndex.value ?? 0,
          elevation: elevation,
          fixedColor: fixedColor,
          backgroundColor: backgroundColor,
          iconSize: iconSize,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          selectedIconTheme: selectedIconTheme,
          unselectedIconTheme: unselectedIconTheme,
          selectedFontSize: selectedFontSize,
          unselectedFontSize: unselectedFontSize,
          selectedLabelStyle: selectedLabelStyle,
          unselectedLabelStyle: unselectedLabelStyle,
          showSelectedLabels: showSelectedLabels,
          showUnselectedLabels: showUnselectedLabels,
          mouseCursor: mouseCursor,
          enableFeedback: enableFeedback,
          landscapeLayout: landscapeLayout,
        ),
      ),
    );
  }
}