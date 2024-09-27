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
  final double? height;
  final TextStyle? textStyle;

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
    this.textStyle,
  });

  @override
  State<SistchTextCarousel> createState() => _SistchTextCarouselState();
}

class _SistchTextCarouselState extends State<SistchTextCarousel> {
  RxInt currentIndex = RxInt(0);
  RxDouble progressValue = RxDouble(0.0);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startCarousel();
  }

  void startCarousel() {
    ever(currentIndex, (_) {
      progressValue.value = 0.0;
    });

    timer =
        Timer.periodic(Duration(seconds: widget.viewDuration ?? 5), (timer) {
      progressValue.value = 0.0;
      currentIndex.value = (currentIndex.value + 1) % widget.texts.length;
    });
  }

  void stopCarousel() {
    timer?.cancel();
  }

  @override
  void dispose() {
    stopCarousel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return widget.texts.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              color: widget.bgColor ?? theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(5),
            ),
            width: MediaQuery.sizeOf(context).width,
            height: widget.height ?? MediaQuery.sizeOf(context).height * 0.08,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon ?? Icons.lightbulb_circle_rounded,
                  color: theme.colorScheme.primaryContainer,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => FadeInDownText(
                      currentText: widget.texts[currentIndex.value],
                      textColor: widget.textColor,
                      textStyle: widget.textStyle,
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
  final TextStyle? textStyle;

  const FadeInDownText({
    required this.currentText,
    this.textColor,
    this.textStyle,
    super.key,
  });

  @override
  State<FadeInDownText> createState() => _FadeInDownTextState();
}

class _FadeInDownTextState extends State<FadeInDownText>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offsetAnimation;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    super.initState();

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

    startAnimation(); // Start animation for the first text
  }

  @override
  void didUpdateWidget(covariant FadeInDownText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentText != widget.currentText) {
      startAnimation(); // Start animation when text changes
    }
  }

  void startAnimation() {
    controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: opacityAnimation.value,
          child: Transform.translate(
            offset: offsetAnimation.value,
            child: child,
          ),
        );
      },
      child: Text(
        widget.currentText,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        style: widget.textStyle ??
            theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.textColor ??
                  Theme.of(context).colorScheme.primaryContainer,
            ),
      ),
    );
  }
}
