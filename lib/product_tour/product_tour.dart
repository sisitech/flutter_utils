import 'package:flutter/material.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:get/get.dart';

/// ==================================================== Models
///
class ProductTourOptions {
  final List<TourStepModel> steps;
  final String controllerTag;
  final VoidCallback? onFinish;

  ProductTourOptions({
    required this.steps,
    required this.controllerTag,
    this.onFinish,
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
    double overlayOffset = 0.28;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, toolbarHeight: 20.0),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Obx(
          () {
            double contentWidth = Get.width * 0.82;
            var width = contentWidth;
            var height = contentWidth;
            Color bgColor = Theme.of(context)
                .colorScheme
                .primaryContainer; //.withOpacity(0.5);
            var size = MediaQuery.of(context).size;
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                controller.currentStep.value.stepWidget,
                //
                Stack(
                  children: [
                    Positioned(
                      bottom: -width / 4,
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
                        allowNext: controller.allowNext.value,
                        stepNoTxt:
                            "Step @step_no# of @total_steps#".interpolate({
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
    double contentPadding = Get.height * 0.24;
    double contentWidth = Get.width * 0.82;
    double bgRadius = Get.height * 0.52;
    Color bgColor = colorScheme.primaryContainer; //.withOpacity(0.5);
    TextStyle stepStyle = const TextStyle(fontSize: 11);
    var width = contentWidth;
    var height = contentWidth;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Positioned(
        //   bottom: -width / 4,
        //   height: height,
        //   right: -width * 1.1,
        //   width: width * 2.1,
        //   child: Container(
        //     width: width,
        //     height: height * 2,
        //     decoration: BoxDecoration(
        //       shape: BoxShape.rectangle,
        //       // color: bgColor,
        //       borderRadius: BorderRadius.all(Radius.circular(height * 2)),
        //     ),
        //   ),
        // ),
        Container(
          width: contentWidth,
          padding: EdgeInsets.all(4),
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
              const SizedBox(height: 7),
              Text(
                step.description,
                style: stepStyle,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: onFinish, child: const Text("Skip")),
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
}
