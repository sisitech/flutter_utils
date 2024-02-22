import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sistch_progress_controller.dart';

class SisitechProgressOptions {
  final String name;
  final int totalSteps;
  final ProgressBarController? progressBarController;
  const SisitechProgressOptions({
    required this.name,
    required this.totalSteps,
    this.progressBarController,
  });
}

class SisitechProgressIndicator extends StatelessWidget {
  final SisitechProgressOptions options;

  const SisitechProgressIndicator({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final ProgressBarController controller;
    if (options.progressBarController == null) {
      controller =
          Get.put(ProgressBarController(options: options), tag: options.name);
    } else {
      controller = options.progressBarController!;
    }

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
                "Importing ${controller.currentTransaction.value}/${controller.options.totalSteps} transactions",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
