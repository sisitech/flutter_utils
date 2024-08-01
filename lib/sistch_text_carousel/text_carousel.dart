import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// View
//
class SistchTextCarousel extends StatefulWidget {
  final List<String> texts;
  final int? viewDuration;
  final Color? bgColor;
  final Color? textColor;
  final IconData? icon;

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
  });

  @override
  State<SistchTextCarousel> createState() => _SistchTextCarouselState();
}

class _SistchTextCarouselState extends State<SistchTextCarousel> {
  late TextCarouselController textCarouselCtrl;

  @override
  void initState() {
    super.initState();
    textCarouselCtrl = Get.put(
      TextCarouselController(
        viewDuration: widget.viewDuration,
        textsLength: widget.texts.length,
      ),
      tag: widget.key.toString(),
    );
    textCarouselCtrl.startCarousel();
  }

  @override
  void dispose() {
    textCarouselCtrl.stopCarousel();
    Get.delete<TextCarouselController>(tag: widget.key.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return widget.texts.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              color: widget.bgColor ?? colorScheme.primary,
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
                      widget.icon ?? Icons.stars,
                      color: colorScheme.primaryContainer,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Obx(
                    () => FadeInDownText(
                      currentText:
                          widget.texts[textCarouselCtrl.currentIndex.value],
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}

class FadeInDownText extends StatefulWidget {
  final String currentText;
  final Color? textColor;

  const FadeInDownText({
    required this.currentText,
    this.textColor,
    super.key,
  });

  @override
  State<FadeInDownText> createState() => _FadeInDownTextState();
}

class _FadeInDownTextState extends State<FadeInDownText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(FadeInDownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentText != widget.currentText) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: _offsetAnimation.value,
            child: child,
          ),
        );
      },
      child: Text(
        widget.currentText,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontStyle: FontStyle.italic,
              color:
                  widget.textColor ?? Theme.of(context).colorScheme.onPrimary,
            ),
      ),
    );
  }
}

// Controller
//

class TextCarouselController extends GetxController {
  var currentIndex = 0.obs;
  var progressValue = 0.0.obs;
  Timer? timer;
  RxBool showText = false.obs;

  //--- Passed variables
  int viewTimerDuration = 7;
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

    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
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
}
