import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ==================================================== Models
///
class TabViewOptions {
  final List<TabViewItem> tabs;
  final String? controllerTag;
  final Function(int? val)? onIndexChange;
  final bool showUnViewedIndicator;
  final int initialIndex;
  //
  double? maxHeight;
  bool isScrollable;
  Color? selectedItemColor;
  Color? unselectedItemColor;
  TextStyle? labelStyle;
  TextStyle? unselectedLabelStyle;
  double indicatorWeight;
  Color? dividerColor;

  TabViewOptions({
    required this.tabs,
    this.controllerTag,
    this.onIndexChange,
    this.initialIndex = 0,
    this.showUnViewedIndicator = true,
    //
    this.maxHeight,
    this.isScrollable = false,
    this.dividerColor,
    this.indicatorWeight = 3,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.labelStyle,
    this.unselectedLabelStyle,
  });
}

class TabViewItem {
  final Widget widget;
  final String label;
  final IconData? icon;

  TabViewItem({
    required this.widget,
    required this.label,
    this.icon,
  });
}

/// ==================================================== View
///
class SistchTabBarScaffold extends StatelessWidget {
  final TabViewOptions options;
  late final TabViewController controller;

  SistchTabBarScaffold({
    Key? key,
    required this.options,
  }) : super(key: key) {
    controller = Get.put(
      TabViewController(options: options),
      tag: options.controllerTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: options.tabs.length,
      initialIndex: options.initialIndex,
      child: Column(
        children: [
          TabBar(
            isScrollable: options.isScrollable,
            onTap: controller.onTabIndexChange,
            tabs: options.tabs.asMap().entries.map((e) {
              int index = e.key;
              TabViewItem tabItem = e.value;

              return Obx(
                () => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tabItem.icon != null) Icon(tabItem.icon, size: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(tabItem.label),
                      ),
                      if (!controller.viewedTabs[index])
                        CircleAvatar(
                          radius: 2.5,
                          backgroundColor: theme.primaryColor,
                        )
                    ],
                  ),
                ),
              );
            }).toList(),
            dividerColor:
                options.dividerColor ?? Theme.of(context).primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: options.indicatorWeight,
            indicatorColor: options.selectedItemColor,
            labelColor: options.selectedItemColor,
            unselectedLabelColor: options.unselectedItemColor,
            labelStyle: options.labelStyle,
            unselectedLabelStyle: options.unselectedLabelStyle,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: options.maxHeight ?? Get.height * 0.7),
            child: TabBarView(
              children: options.tabs.map((e) => e.widget).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// ==================================================== Controller
///

class TabViewController extends GetxController {
  TabViewOptions options;
  late RxList<bool> viewedTabs;

  TabViewController({required this.options}) {
    print("length: ${options.tabs.length}");

    viewedTabs = RxList<bool>(List.generate(options.tabs.length, (i) {
      print(options.tabs[i].label);
      return options.showUnViewedIndicator
          ? options.initialIndex == i
              ? true
              : false
          : true;
    }));
  }

  onTabIndexChange(int? val) {
    if (val != null) {
      updateViewedTabs(val);
      if (options.onIndexChange != null) options.onIndexChange!(val);
    }
  }

  updateViewedTabs(int idx) {
    if (idx >= 0 && idx < viewedTabs.length) viewedTabs[idx] = true;
  }
}
