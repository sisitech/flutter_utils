import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';

class TabViewOptions {
  final List<TabViewItem> tabs;
  final String? controllerTag;
  final Function(int? val)? onIndexChange;
  final bool showUnViewedIndicator;
  final double sectionsGapSize;
  final bool enableMixpanel;
  //
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
    this.showUnViewedIndicator = true,
    //
    this.isScrollable = false,
    this.dividerColor,
    this.indicatorWeight = 3,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.enableMixpanel = false,
    this.sectionsGapSize = 16.0,
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

class CollapsibleSection {
  String? title;
  IconData? titleIcon;
  Widget? child;
  bool isExpanded;
  bool isViewed;

  CollapsibleSection({
    this.title,
    this.titleIcon,
    this.child,
    this.isExpanded = true,
    this.isViewed = true,
  });

  CollapsibleSection copyWith({
    String? title,
    IconData? titleIcon,
    Widget? child,
    bool? isExpanded,
    bool? isViewed,
  }) {
    return CollapsibleSection(
      title: title ?? this.title,
      titleIcon: titleIcon ?? this.titleIcon,
      child: child ?? this.child,
      isExpanded: isExpanded ?? this.isExpanded,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}

enum TabViewTypes { tabBar, collapsible }

class TabViewController extends GetxController {
  TabViewOptions options;
  TabViewTypes tabType;
  late RxList<bool> viewedTabs;
  RxInt currentTabIdx = 0.obs;
  RxBool isCurrentExpanded = false.obs;

  TabViewController(this.options, this.tabType) {
    viewedTabs = RxList<bool>(List.generate(options.tabs.length, (i) {
      return options.showUnViewedIndicator
          ? tabType == TabViewTypes.collapsible
              ? false
              : i == 0
                  ? true
                  : false
          : true;
    }));
  }

  onTabIndexChange(int? val) {
    if (val != null) {
      //

      if (currentTabIdx.value == val) {
        isCurrentExpanded.value = !isCurrentExpanded.value;
      } else {
        currentTabIdx.value = val;
        isCurrentExpanded.value = true;
      }

      //
      if (options.showUnViewedIndicator) updateViewedTabs(val);

      //
      if (options.enableMixpanel) {
        mixpanelTrackEvent('tab_view:${options.tabs[val].label}');
      }

      //
      if (options.onIndexChange != null) options.onIndexChange!(val);
    }
  }

  updateViewedTabs(int idx) {
    if (idx >= 0 && idx < viewedTabs.length) viewedTabs[idx] = true;
  }
}
