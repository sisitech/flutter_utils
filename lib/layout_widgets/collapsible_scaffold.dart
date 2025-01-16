import 'package:flutter/material.dart';
import 'package:flutter_utils/layout_widgets/models.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:get/get.dart';

class SistchCollapsibleScaffold extends StatelessWidget {
  final TabViewOptions options;
  late final TabViewController controller;

  SistchCollapsibleScaffold({Key? key, required this.options})
      : super(key: key) {
    controller = Get.put(TabViewController(options));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Obx(
            () => ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              materialGapSize: options.sectionsGapSize,
              expansionCallback: (int idx, bool isExpanded) {
                controller.onTabIndexChange(idx);
              },
              children: options.tabs.asMap().entries.map(
                (e) {
                  TabViewItem item = e.value;
                  return ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: (controller.isCurrentExpanded.value &&
                        controller.currentTabIdx.value == e.key),
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: getHeaderWidget(
                          leadingWidget: item.icon != null
                              ? Icon(
                                  item.icon,
                                  size: 18,
                                  color: Get.theme.colorScheme.primary,
                                )
                              : null,
                          title: item.label,
                          style: Get.theme.textTheme.titleMedium!.copyWith(
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          trailingWidget: !controller.viewedTabs[e.key]
                              ? CircleAvatar(
                                  radius: 2.5,
                                  backgroundColor: colorScheme.primary,
                                )
                              : null,
                        ),
                      );
                    },
                    body: item.widget,
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
