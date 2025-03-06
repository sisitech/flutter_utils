import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';

class SistchAnimatedCounter extends StatefulWidget {
  final int valueToAnimate;
  final TextStyle? textStyle;
  final int? startValue;
  final List<TextSpan>? preTexts;
  final List<TextSpan>? postTexts;
  final int durationInUs;
  final bool useWantKeepAlive;

  const SistchAnimatedCounter({
    super.key,
    required this.valueToAnimate,
    this.textStyle,
    this.startValue,
    this.durationInUs = 1,
    this.preTexts,
    this.postTexts,
    this.useWantKeepAlive = true,
  });

  @override
  State<SistchAnimatedCounter> createState() => _SistchAnimatedCounterState();
}

class _SistchAnimatedCounterState extends State<SistchAnimatedCounter>
    with AutomaticKeepAliveClientMixin {
  RxInt currentVal = RxInt(0);

  @override
  void initState() {
    super.initState();
    runAnimation();
  }

  @override
  void didUpdateWidget(covariant SistchAnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.valueToAnimate != widget.valueToAnimate) {
      runAnimation();
    }
  }

  void runAnimation() async {
    int start = widget.startValue ?? (widget.valueToAnimate * 0.99).ceil();
    currentVal.value = start;
    for (int i = start; i <= widget.valueToAnimate; i++) {
      await Future.delayed(Duration(microseconds: widget.durationInUs));
      currentVal.value = i;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(
      () => Text.rich(
        TextSpan(
          children: [
            if (widget.preTexts != null) ...widget.preTexts!,
            TextSpan(
              text: addThousandSeparators(currentVal.toDouble()),
              style: widget.textStyle ??
                  Get.theme.textTheme.titleLarge!.copyWith(
                    color: Get.theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (widget.postTexts != null) ...widget.postTexts!,
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.useWantKeepAlive;
}
