import 'package:flutter/material.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:get/get.dart';

/// ==================================================== Models
///
class ProductTourOptions {
  final List<TourStepModel> steps;
  final String controllerTag;
  final VoidCallback? onFinish;
  final bool canSkip;

  ProductTourOptions({
    required this.steps,
    required this.controllerTag,
    this.onFinish,
    this.canSkip = true,
  });
}

class TourStepModel {
  final String slug;
  final String title;
  final String description;
  final Widget stepWidget;
  final IconData? icon;
  final bool autoAllowNext;

  TourStepModel({
    required this.slug,
    required this.title,
    required this.description,
    required this.stepWidget,
    this.icon,
    this.autoAllowNext = false,
  });
}

/// ==================================================== View
///
class SistchProductTour extends StatelessWidget {
  final ProductTourOptions options;
  late final ProductTourController controller;

  SistchProductTour({
    Key? key,
    required this.options,
  }) : super(key: key) {
    controller = Get.put(
      ProductTourController(options: options),
      tag: options.controllerTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.only(
            top: Get.height * 0.1, bottom: 10, left: 10, right: 10),
        child: Obx(
          () {
            double contentWidth = Get.width * 0.82;
            var width = contentWidth;
            var height = contentWidth;
            Color bgColor = Theme.of(context)
                .colorScheme
                .primaryContainer; //.withValues(alpha: 0.5);

            return Stack(
              alignment: Alignment.topCenter,
              children: [
                controller.currentStep.value.stepWidget,
                //
                Stack(
                  children: [
                    Positioned(
                      bottom: -width / 3.4,
                      height: height,
                      right: -width * 1.1,
                      width: width * 2.1,
                      child: Container(
                        width: width / 2,
                        height: height * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: bgColor,
                          borderRadius:
                              BorderRadius.all(Radius.circular(height * 2)),
                        ),
                      ),
                    ),
                    Positioned(
                      // bottom: -(Get.height * overlayOffset),
                      bottom: 0,
                      right: 0,
                      child: _TourOverlay(
                        step: controller.currentStep.value,
                        isLastStep: controller.showFinish.value,
                        onFinish: options.onFinish ?? () => Get.back(),
                        onNext: controller.goToNext,
                        onBack: controller.goToPrev,
                        allowNext: controller.allowNext.value,
                        canSkip: options.canSkip,
                        isFirstStep: controller.currentIdx == 0,
                        stepNoTxt: "@step_no# of @total_steps#".interpolate({
                          "step_no": controller.currentIdx + 1,
                          "total_steps": controller.stepsLength,
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
  final VoidCallback? onBack;
  final bool allowNext;
  final bool canSkip;
  final bool isFirstStep;

  const _TourOverlay({
    Key? key,
    required this.step,
    required this.isLastStep,
    required this.stepNoTxt,
    required this.onFinish,
    required this.onBack,
    this.onNext,
    required this.allowNext,
    required this.canSkip,
    required this.isFirstStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final colorScheme = theme.colorScheme;
    double contentWidth = Get.width * 0.82;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: contentWidth,
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (step.icon != null)
                Icon(step.icon, color: colorScheme.tertiary),
              Text(
                stepNoTxt,
                style: theme.textTheme.labelSmall!
                    .copyWith(color: colorScheme.tertiary),
              ),
              Text(
                step.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  step.description,
                  style: theme.textTheme.bodySmall,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(color: theme.colorScheme.onPrimaryContainer),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isFirstStep
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ElevatedButton.icon(
                              onPressed: canSkip ? onFinish : onBack,
                              label: Text(canSkip ? "Skip" : "Back"),
                            ),
                          ),
                    ElevatedButton.icon(
                      onPressed: allowNext
                          ? isLastStep
                              ? onFinish
                              : onNext
                          : null,
                      label: Text(isLastStep ? "Finish" : "Next"),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          allowNext
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                        foregroundColor:
                            WidgetStatePropertyAll(theme.colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ==================================================== Controller
///
class ProductTourController extends GetxController {
  int currentIdx = 0;
  int stepsLength = 0;
  RxBool showFinish = false.obs;
  RxBool allowNext = false.obs;
  RxBool showIndicator = true.obs;
  ProductTourOptions options;
  late Rx<TourStepModel> currentStep;

  ProductTourController({required this.options}) {
    stepsLength = options.steps.length;
    currentStep = Rx<TourStepModel>(options.steps[currentIdx]);
    changeStep(currentIdx);
  }

  void hideIndicator() => showIndicator.value = false;

  void enableNext() => allowNext.value = true;

  changeStep(int index) {
    currentIdx = index;
    currentStep.value = options.steps[index];

    allowNext.value = currentStep.value.autoAllowNext ? true : false;
    showFinish.value = index == stepsLength - 1;
    showIndicator.value = true;
  }

  void goToNext() {
    if (currentIdx < stepsLength - 1) {
      changeStep(currentIdx + 1);
    }
  }

  void goToPrev() {
    if (currentIdx != 0) {
      changeStep(currentIdx - 1);
    }
  }
}
