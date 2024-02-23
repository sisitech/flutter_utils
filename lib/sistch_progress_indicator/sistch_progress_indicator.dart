import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SisitechProgressOptions {
  final String name;
  final int totalSteps;
  final int currentStep;
  final String? description;

  const SisitechProgressOptions({
    required this.totalSteps,
    required this.currentStep,
    this.description,
    required this.name,
  });
}

class SisitechProgressIndicator extends StatelessWidget {
  final SisitechProgressOptions options;
  const SisitechProgressIndicator({super.key, required this.options});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Get.height * 0.011),
      child: SizedBox(
        // height: Get.,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.all(Radius.circular(Get.height * 0.011)),
              child: LinearProgressIndicator(
                value: (options.currentStep /
                    options
                        .totalSteps), // Bind to the observable progress value
              ),
            ),
            SizedBox(
                height: Get.height *
                    0.011), // Spacing between the progress bar and text
            if (options.description != null)
              Text(
                // "Importing ${controller.currentTransaction.value}/${controller.totalSteps} transactions",
                options.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
