import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'fab_controller.dart'; // Ensure this import matches the path of your ExtendedFABController

class ExtendedFAB extends StatelessWidget {
  final ExtendedFABController controller = Get.put(ExtendedFABController());
  final List<FabItem> items;
  final Widget? mainIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  ExtendedFAB({
    Key? key,
    required this.items,
    this.mainIcon = const Icon(Icons.add),
    this.foregroundColor,
    this.backgroundColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(() => Visibility(
              visible: controller.isFABVisible.value,
              child: FloatingActionButton(
                onPressed: () {
                  controller.toggleOptions();
                },
                backgroundColor:
                    backgroundColor ?? Theme.of(context).colorScheme.primary,
                foregroundColor:
                    foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
                child: mainIcon,
              ),
            )),
        const SizedBox(height: 16.0),
        Obx(() => Visibility(
              visible: controller.showOptions.value,
              child: Column(
                  children: items
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: FloatingActionButton(
                              onPressed: item.onPressed,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  item.icon,
                                  Text(item.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall),
                                ],
                              ),
                            ),
                          ))
                      .toList()),
            )),
      ],
    );
  }
}

class FabItem {
  final Widget icon;
  final VoidCallback onPressed;
  final String title;

  FabItem({required this.icon, required this.onPressed, required this.title});
}
