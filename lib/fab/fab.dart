import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'fab_controller.dart';

class ExtendedFAB extends StatelessWidget {
  final ExtendedFABController controller = Get.put(ExtendedFABController());
  final List<FabItem> items;
  final Widget? mainIcon; // Optional main icon for the extended FAB.
  final Color backgroundColor; // Background color for the main FAB.

  ExtendedFAB({
    Key? key,
    required this.items,
    this.mainIcon = const Icon(Icons.add),
    this.backgroundColor = Colors.blue, // Default color if not specified.
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () {
            controller.toggleOptions();
          },
          backgroundColor: backgroundColor,
          child: mainIcon,
        ),
        const SizedBox(height: 16.0),
        Obx(() => Visibility(
              visible: controller.showOptions.value,
              child: Column(
                  children: items
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: FloatingActionButton(
                              onPressed: item.onPressed,
                              child: item.icon,
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

  FabItem({required this.icon, required this.onPressed});
}
