import 'package:flutter/material.dart';
import 'package:flutter_utils/drawer/drawer.dart';
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
        drawer: SisitechDrawer(
          // headerWidget: SisitechDrawerHeader(
          //   headerBackgroundColor: Colors.black,
          //   headerText: 'Halooooo',
          //   headerSubText: 'Halooooooooo',
          // ),
          headerBackgroundColor: Get.theme.primaryColor,
          headerText: 'Welcome,',
          headerSubText: 'Ali Dennis',
          headerImage: "https://avatars.githubusercontent.com/u/9420130?v=4",
          items: [
            SisitechDrawerItem(
              title: 'Home',
              onTap: () {
                Navigator.pop(context); // Close the drawer
                print('Home tapped');
              },
              leadingIcon: Icons.home,
              trailingIcon: Icons.arrow_forward,
            ),
            SisitechDrawerItem(
              title: 'Settings',
              onTap: () {
                Navigator.pop(context); // Close the drawer
                print('Settings tapped');
              },
              leadingIcon: Icons.settings,
              trailingIcon: Icons.arrow_forward,
            ),
            // Add more items as needed
          ],
        ),
        body: bottomNavigationController.selectedTab(tabs),
        bottomNavigationBar: BottomNavigationBar(
          items: tabs.map((e) => e.barItem).toList(),
          onTap: (index) {
            bottomNavigationController.selectTab(index, onTap);
          },
          currentIndex: bottomNavigationController.selectedIndex.value,
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
