import 'package:flutter/material.dart';

class TabViewOptions {
  final List<TabViewItem> tabs;
  final String? controllerTag;
  final Function(int? val)? onIndexChange;
  final bool showUnViewedIndicator;
  final int initialIndex;
  final bool allExpandedAtStart;
  final bool hideCollapseAllToggle;
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
    this.initialIndex = 0,
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
    this.allExpandedAtStart = false,
    this.hideCollapseAllToggle = true,
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
