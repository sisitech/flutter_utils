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
}

/// View
///
class SistchCollapsibleScaffold extends StatelessWidget {
  final List<TabViewItem> tabs;
  final int? initialExpandedIdx;
  final bool allExpandedAtStart;
  final double sectionsGapSize;
  final bool hideCollapseAllToggle;

  const SistchCollapsibleScaffold({
    super.key,
    required this.tabs,
    this.initialExpandedIdx,
    this.allExpandedAtStart = false,
    this.hideCollapseAllToggle = false,
    this.sectionsGapSize = 16.0,
  });

  List<CollapsibleSection> _createSections() {
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

  List<CollapsibleSection> toggleSections({
    required List<CollapsibleSection> items,
    required bool isExpanded,
    int? idx,
    bool toggleAll = false,
  }) {
    return items.asMap().entries.map((entry) {
      int i = entry.key;
      CollapsibleSection item = entry.value;

      if (toggleAll) {
        return CollapsibleSection(
          title: item.title,
          titleIcon: item.titleIcon,
          child: item.child,
          isExpanded: isExpanded,
          isViewed: true,
        );
      } else if (i == idx) {
        return CollapsibleSection(
          title: item.title,
          titleIcon: item.titleIcon,
          child: item.child,
          isExpanded: isExpanded,
          isViewed: true,
        );
      }

      return item;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    RxList<CollapsibleSection> items = RxList(_createSections());
    RxBool allOpen = RxBool(allExpandedAtStart);

    return Column(
      children: [
        if (!hideCollapseAllToggle)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  items.value = toggleSections(
                      items: items,
                      isExpanded: !allOpen.value,
                      toggleAll: true);
                  allOpen.value = !allOpen.value;
                },
                icon: Obx(
                  () => Icon(
                    allOpen.value
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
              expansionCallback: (int index, bool isExpanded) {
                items.value = toggleSections(
                    idx: index, items: items, isExpanded: isExpanded);
                allOpen.value = items
                    .map((e) => e.isExpanded)
                    .toList()
                    .every((element) => element == true);
              },
              children: items
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
