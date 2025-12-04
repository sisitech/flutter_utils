import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SistchGrowingWidget extends StatelessWidget {
  final IconData? icon;
  final String? lottiePath;
  final Widget? customWidget;
  final Duration duration;
  final double? maxSize;
  final Color? color;
  final Color? bgColor;

  const SistchGrowingWidget({
    super.key,
    this.icon,
    this.maxSize,
    this.lottiePath,
    this.customWidget,
    this.duration = const Duration(seconds: 2),
    this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = maxSize ?? Get.height * 0.08;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: iconSize),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, size, child) {
        return Container(
          width: size + 10,
          height: size + 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color?.withValues(alpha: 0.4),
            boxShadow: [
              BoxShadow(
                color: bgColor ?? Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: customWidget ??
                (lottiePath != null
                    ? Lottie.asset(
                        lottiePath!,
                        fit: BoxFit.contain,
                        frameRate: FrameRate.max,
                      )
                    : Icon(
                        icon,
                        size: size,
                        color: color ?? theme.primaryColor,
                      )),
          ),
        );
      },
    );
  }
}
