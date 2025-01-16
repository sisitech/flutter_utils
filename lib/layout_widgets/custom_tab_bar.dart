import 'package:flutter/material.dart';
import 'package:flutter_utils/layout_widgets/models.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';

/// ==================================================== View
///
class SistchTabBarScaffold extends StatelessWidget {
  final TabViewOptions options;
  late final TabViewController controller;

  /// [SistchTabBarScaffold]
  /// When defining tabs for this scaffold,
  /// avoid wrapping the widgets or the children within the widgets with 'Expanded'.
  /// Leads to RenderFlex issues and would force defining children height!
  SistchTabBarScaffold({
    Key? key,
    required this.options,
  }) : super(key: key) {
    controller = Get.put(
      TabViewController(options),
      tag: options.controllerTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
      () => Column(
        children: [
          buildTabHeader(theme),
          options.tabs[controller.currentTabIdx.value].widget,
        ],
      ),
    );
  }

  buildTabHeader(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.tabs.asMap().entries.map((e) {
        Color tabColor = controller.currentTabIdx.value == e.key
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface;
        return GestureDetector(
          onTap: () => controller.onTabIndexChange(e.key),
          child: Container(
            color: Colors.transparent,
            width: (Get.width * 0.87) / options.tabs.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      e.value.icon,
                      color: tabColor,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      e.value.label,
                      style: TextStyle(
                        color: tabColor,
                        fontSize: 12,
                      ),
                    ),
                    if (!controller.viewedTabs[e.key])
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: CircleAvatar(
                          radius: 2.5,
                          backgroundColor: theme.primaryColor,
                        ),
                      ),
                  ],
                ),
                SizedBox(
                    height: controller.currentTabIdx.value == e.key ? 10 : 13),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: controller.currentTabIdx.value == e.key ? 3 : 1,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// ==================================================== Controller
///

class TabViewController extends GetxController {
  TabViewOptions options;
  late RxList<bool> viewedTabs;
  RxInt currentTabIdx = 0.obs;

  TabViewController(this.options) {
    viewedTabs = RxList<bool>(List.generate(options.tabs.length, (i) {
      return options.showUnViewedIndicator
          ? options.initialIndex == i
              ? true
              : false
          : true;
    }));
    currentTabIdx.value = options.initialIndex;
  }

  onTabIndexChange(int? val) {
    if (val != null) {
      //
      currentTabIdx.value = val;

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
