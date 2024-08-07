import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// View
//
class SistchTextCarousel extends StatelessWidget {
  final List<String> texts;
  final int? viewDuration;
  final Color? bgColor;
  final Color? textColor;
  final IconData? icon;
  final double? height;

  ///[SistchTextCarousel] renders an animated text carousel widget
  ///Required Fields:
  ///-List<string> texts: list of Strings to be displayed
  ///Other Fields:
  ///- int viewDuration: time to display each text, default 5s.
  const SistchTextCarousel({
    super.key,
    required this.texts,
    this.viewDuration,
    this.bgColor,
    this.textColor,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final TextCarouselController textCarouselCtrl = Get.put(
      TextCarouselController(
        viewDuration: viewDuration,
        textsLength: texts.length,
      ),
      tag: key.toString(),
    );

    return texts.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              color: bgColor ?? colorScheme.primary,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    CircularProgressIndicator(
                      value: 100,
                      color: colorScheme.primaryContainer,
                    ),
                    Icon(
                      icon ?? Icons.stars,
                      color: colorScheme.primaryContainer,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: height,
                  child: Obx(
                    () => FadeInDownText(
                      currentText: texts[textCarouselCtrl.currentIndex.value],
                      textColor: textColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}

class FadeInDownText extends StatelessWidget {
  final String currentText;
  final Color? textColor;

  const FadeInDownText({
    required this.currentText,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextAnimationController textAnimationCtrl = Get.put(
      TextAnimationController(),
      tag: key.toString(),
    );

    textAnimationCtrl.startAnimation();

    return AnimatedBuilder(
      animation: textAnimationCtrl.controller,
      builder: (context, child) {
        return Opacity(
          opacity: textAnimationCtrl.opacityAnimation.value,
          child: Transform.translate(
            offset: textAnimationCtrl.offsetAnimation.value,
            child: child,
          ),
        );
      },
      child: Text(
        currentText,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontStyle: FontStyle.italic,
              color: textColor ?? Theme.of(context).colorScheme.onPrimary,
            ),
      ),
    );
  }
}

// Text Animation Controller
//
class TextAnimationController extends GetxController
    with SingleGetTickerProviderMixin {
  late AnimationController controller;
  late Animation<Offset> offsetAnimation;
  late Animation<double> opacityAnimation;

  @override
  void onInit() {
    super.onInit();
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));
  }

  void startAnimation() {
    controller.forward(from: 0.0);
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}

// Text Carousel Controller
//
class TextCarouselController extends GetxController {
  var currentIndex = 0.obs;
  var progressValue = 0.0.obs;
  Timer? timer;
  RxBool showText = false.obs;

  //--- Passed variables
  int viewTimerDuration = 5;
  int textsLength;

  TextCarouselController({
    required this.textsLength,
    int? viewDuration,
  }) {
    if (viewDuration != null) {
      viewTimerDuration = viewDuration;
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (textsLength > 0 && viewTimerDuration > 0) {
      startCarousel();
    }
  }

  void startCarousel() {
    ever(currentIndex, (_) {
      progressValue.value = 0.0;
    });

    timer = Timer.periodic(Duration(seconds: viewTimerDuration), (timer) {
      if (progressValue.value < 1.0) {
        showText.value = true;
        progressValue.value += 1 / viewTimerDuration;
      } else {
        showText.value = false;
        currentIndex.value = (currentIndex.value + 1) % textsLength;
        progressValue.value = 0.0;
      }
    });
  }

  void stopCarousel() {
    timer?.cancel();
  }

  @override
  void onClose() {
    stopCarousel();
    super.onClose();
  }
}
