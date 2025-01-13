import 'package:flutter/material.dart';
import 'package:flutter_utils/layout_widgets/custom_tab_bar.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:get/get.dart';

/// Models
///
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

/// View
///
class SistchCollapsibleScaffold extends StatelessWidget {
  final List<TabViewItem> tabs;
  final int? initialExpandedIdx;
  final bool allExpandedAtStart;
  final double sectionsGapSize;
  final bool hideCollapseAllToggle;
  late final CollapsibleScaffoldCtrl controller;

  SistchCollapsibleScaffold({
    Key? key,
    required this.tabs,
    this.initialExpandedIdx,
    this.allExpandedAtStart = false,
    this.hideCollapseAllToggle = false,
    this.sectionsGapSize = 16.0,
  }) : super(key: key) {
    controller = Get.put(CollapsibleScaffoldCtrl(
      tabs: tabs,
      allExpandedAtStart: allExpandedAtStart,
      initialExpandedIdx: initialExpandedIdx,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (!hideCollapseAllToggle)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => controller.toggleAllSections(),
                icon: Obx(
                  () => Icon(
                    controller.allOpen.value
                        ? Icons.close_fullscreen_rounded
                        : Icons.expand_rounded,
                    color: colorScheme.primary,
                  ),
                ),
              )
            ],
          ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Obx(
            () => ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              materialGapSize: sectionsGapSize,
              expansionCallback: controller.toggleSection,
              children: controller.items
                  .map(
                    (e) => ExpansionPanel(
                      canTapOnHeader: true,
                      isExpanded: e.isExpanded,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: getHeaderWidget(
                            leadingWidget: e.titleIcon != null
                                ? Icon(
                                    e.titleIcon,
                                    size: 18,
                                    color: Get.theme.colorScheme.primary,
                                  )
                                : null,
                            title: e.title!,
                            style: Get.theme.textTheme.titleMedium!.copyWith(
                              color: Get.theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            trailingWidget: !e.isViewed
                                ? CircleAvatar(
                                    radius: 2.5,
                                    backgroundColor: colorScheme.primary,
                                  )
                                : null,
                          ),
                        );
                      },
                      body: e.child ?? const SizedBox(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class CollapsibleScaffoldCtrl extends GetxController {
  final List<TabViewItem> tabs;
  final int? initialExpandedIdx;
  final bool allExpandedAtStart;

  CollapsibleScaffoldCtrl({
    required this.tabs,
    this.initialExpandedIdx,
    this.allExpandedAtStart = false,
  }) {
    viewedTabs.value = List.generate(tabs.length,
        (index) => allExpandedAtStart || index == initialExpandedIdx);
    items.value = createSections();
    allOpen.value = allExpandedAtStart;
  }

  RxList<bool> viewedTabs = RxList();
  RxList<CollapsibleSection> items = RxList();
  RxBool allOpen = false.obs;

  List<CollapsibleSection> createSections() {
    return List.generate(tabs.length, (i) {
      bool viewToggle = initialExpandedIdx == i ? true : allExpandedAtStart;
      return CollapsibleSection(
        title: tabs[i].label,
        titleIcon: tabs[i].icon,
        child: tabs[i].widget,
        isExpanded: viewToggle,
        isViewed: viewToggle,
      );
    });
  }

  void toggleAllSections() {
    items.value = items.map((item) {
      return item.copyWith(isExpanded: !allOpen.value, isViewed: true);
    }).toList();
    allOpen.value = !allOpen.value;
  }

  void toggleSection(int index, bool isExpanded) {
    viewedTabs[index] = true;
    items.value = items.asMap().entries.map((entry) {
      int i = entry.key;
      CollapsibleSection item = entry.value;
      return item.copyWith(
        isExpanded: i == index ? !item.isExpanded : false,
        isViewed: i == index ? true : item.isViewed,
      );
    }).toList();
    allOpen.value = items.every((e) => e.isExpanded);
  }
}
