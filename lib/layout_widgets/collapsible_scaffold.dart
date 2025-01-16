import 'package:flutter/material.dart';
import 'package:flutter_utils/layout_widgets/models.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:get/get.dart';

class SistchCollapsibleScaffold extends StatelessWidget {
  final TabViewOptions options;
  late final CollapsibleScaffoldCtrl controller;

  SistchCollapsibleScaffold({Key? key, required this.options})
      : super(key: key) {
    controller = Get.put(CollapsibleScaffoldCtrl(options));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (!options.hideCollapseAllToggle)
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
              materialGapSize: options.sectionsGapSize,
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
  TabViewOptions options;

  CollapsibleScaffoldCtrl(this.options) {
    viewedTabs.value = List.generate(options.tabs.length,
        (index) => options.allExpandedAtStart || index == options.initialIndex);
    items.value = createSections();
    allOpen.value = options.allExpandedAtStart;
  }

  RxList<bool> viewedTabs = RxList();
  RxList<CollapsibleSection> items = RxList();
  RxBool allOpen = false.obs;

  List<CollapsibleSection> createSections() {
    return List.generate(options.tabs.length, (i) {
      bool viewToggle =
          options.initialIndex == i ? true : options.allExpandedAtStart;
      return CollapsibleSection(
        title: options.tabs[i].label,
        titleIcon: options.tabs[i].icon,
        child: options.tabs[i].widget,
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

    //
    if (options.enableMixpanel) {
      mixpanelTrackEvent('collapse_view:${options.tabs[index].label}');
    }

    allOpen.value = items.every((e) => e.isExpanded);
  }
}
