import 'package:flutter/material.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:get/get.dart';

/// ==================================================== View

class SistchProductTour extends StatelessWidget {
  final List<TourStepModel> steps;
  final ProductTourController controller;
  final VoidCallback? onFinish;

  const SistchProductTour({
    Key? key,
    required this.steps,
    required this.controller,
    this.onFinish,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double overlayOffset = 0.28;
    controller.initialize(steps);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, toolbarHeight: 20.0),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Obx(
          () {
            final step = controller.steps[controller.currentStep.value];
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                step.stepWidget,
                //
                Stack(
                  children: [
                    Positioned(
                      bottom: -(Get.height * overlayOffset),
                      child: _TourOverlay(
                        step: step,
                        isLastStep: controller.showFinish.value,
                        onFinish: onFinish ?? () => Get.back(),
                        onNext: controller._goToNext,
                        allowNext: controller.allowNext.value,
                        stepNoTxt:
                            "Step @step_no# of @total_steps#".interpolate({
                          "step_no": controller.currentStep.value + 1,
                          "total_steps": steps.length,
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TourOverlay extends StatelessWidget {
  final TourStepModel step;
  final String stepNoTxt;
  final bool isLastStep;
  final VoidCallback onFinish;
  final VoidCallback? onNext;
  final bool allowNext;

  const _TourOverlay({
    Key? key,
    required this.step,
    required this.isLastStep,
    required this.stepNoTxt,
    required this.onFinish,
    this.onNext,
    required this.allowNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final colorScheme = theme.colorScheme;
    double contentPadding = Get.height * 0.23;
    double contentWidth = Get.width * 0.7;
    double bgRadius = Get.height * 0.5;
    Color bgColor = colorScheme.primaryContainer.withOpacity(0.5);

    return Container(
      width: bgRadius,
      height: bgRadius,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: contentWidth,
            margin: EdgeInsets.only(
              bottom: contentPadding,
              right: Get.height * 0.05,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (step.icon != null)
                  Icon(step.icon, color: colorScheme.tertiary),
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stepNoTxt,
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: colorScheme.onPrimaryContainer),
                    ),
                    ElevatedButton.icon(
                      onPressed: allowNext
                          ? isLastStep
                              ? onFinish
                              : onNext
                          : null,
                      label: Text(isLastStep ? "Finish" : "Next"),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ==================================================== Models

class TourStepModel {
  final String title;
  final String description;
  final Widget stepWidget;
  final IconData? icon;
  final bool autoAllowNext;

  TourStepModel({
    required this.title,
    required this.description,
    required this.stepWidget,
    this.icon,
    this.autoAllowNext = false,
  });
}

/// ==================================================== Controller

class ProductTourController extends GetxController {
  final RxInt currentStep = 0.obs;
  final RxBool showFinish = false.obs;
  final RxBool allowNext = false.obs;
  final RxBool showIndicator = true.obs;

  List<TourStepModel> steps = [];

  void initialize(List<TourStepModel> newSteps) {
    currentStep.value = 0;
    showFinish.value = false;
    showIndicator.value = true;
    allowNext.value = false;
    steps = newSteps;
  }

  void hideIndicator() => showIndicator.value = false;

  void enableNext() => allowNext.value = true;

  void _goToNext() {
    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      showFinish.value = currentStep.value == steps.length - 1;
    }
    allowNext.value = steps[currentStep.value].autoAllowNext ? true : false;
    showIndicator.value = true;
  }
}
