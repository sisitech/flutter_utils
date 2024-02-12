import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  Widget? floatingActionButton;
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
    this.floatingActionButton,
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
        floatingActionButton: floatingActionButton,
        appBar: AppBar(
          backgroundColor: Get.theme.primaryColor,
          title: const Text('Flutter Utils'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
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
