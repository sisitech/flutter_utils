import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sistch_progress_controller.dart';

class SisitechProgressIndicator extends StatelessWidget {
  final String name;

  const SisitechProgressIndicator({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final ProgressBarController controller =
        Get.put(ProgressBarController(), tag: name);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 200,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Obx(
                () => LinearProgressIndicator(
                  value: controller
                      .progress.value, // Bind to the observable progress value
                ),
              ),
            ),
            const SizedBox(
                height: 20), // Spacing between the progress bar and text
            Obx(
              () => Text(
                "Importing ${controller.currentTransaction.value}/${controller.totalTransactions} transactions",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
