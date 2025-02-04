import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';

class SisitechCardController extends GetxController {
  var isTextVisible = false.obs;

  void toggleTextVisibility(
      {bool enableMixpanel = true, required String eventName}) {
    isTextVisible.toggle();
    if (enableMixpanel) {
      mixpanelTrackEvent(eventName);
    }
  }
}

class SisitechCard extends StatelessWidget {
  final String slug;
  final String? assetImage;
  final IconData? iconData;
  final String? description;
  final String? title;
  final Color color;
  final double? imageScale;
  final Color? iconColor;
  final double? iconSize;
  final Color? titleColor;
  final Color? descriptionColor;
  final CrossAxisAlignment? cardAxisAlignment;
  final MainAxisAlignment? cardMainAxisAlignment;
  final bool enableTextVisibilityToggle;
  final SisitechCardController? controller;
  final IconData? lockedIcon;
  final IconData? unlockedIcon;
  final Widget? topRightWidget;
  final double? cardWidth;
  final double borderRadius;
  final bool enableMixpanel;
  final bool isLinear;
  final bool isDense;

  const SisitechCard({
    super.key,
    this.assetImage,
    this.description,
    this.title,
    this.enableMixpanel = true,
    this.imageScale,
    this.color = Colors.teal,
    this.iconData,
    this.iconColor,
    this.slug = "defaultCard",
    this.iconSize,
    this.titleColor,
    this.descriptionColor,
    this.cardAxisAlignment,
    this.cardMainAxisAlignment,
    this.enableTextVisibilityToggle = false,
    required this.controller, // Make it required and remove the initialization
    this.lockedIcon,
    this.unlockedIcon,
    this.topRightWidget,
    this.cardWidth,
    this.borderRadius = 12.0,
    this.isLinear = false,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () => controller!.toggleTextVisibility(
            eventName: "card_${slug}_clicked",
            enableMixpanel: enableMixpanel,
          ),
          child: SizedBox(
            width: cardWidth,
            child: Container(
              margin: const EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isLinear
                  ? Row(
                      children: [
                        buildTopImg(),
                        SizedBox(width: Get.width * 0.006),
                        buildLabelTxt(theme),
                        const Spacer(),
                        Row(
                          children: buildVisibilityWidget(theme),
                        ),
                      ],
                    )
                  : isDense
                      ? Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildTopImg(),
                                SizedBox(width: Get.width * 0.006),
                                buildLabelTxt(theme),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: buildVisibilityWidget(theme),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment:
                              cardAxisAlignment ?? CrossAxisAlignment.center,
                          mainAxisAlignment:
                              cardMainAxisAlignment ?? MainAxisAlignment.center,
                          children: [
                            if (topRightWidget != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [topRightWidget!],
                              ),
                            buildTopImg(),
                            SizedBox(height: Get.height * 0.006),
                            buildLabelTxt(theme),
                            SizedBox(height: Get.height * 0.01),
                            Column(
                              children: buildVisibilityWidget(theme),
                            ),
                            SizedBox(height: Get.height * 0.01),
                          ],
                        ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTopImg() {
    if (assetImage != null) {
      return Image.asset(
        assetImage!,
        scale: imageScale ?? 1.0,
      );
    } else if (iconData != null) {
      return Icon(
        iconData,
        size: iconSize ?? 24.0,
        color: iconColor ?? Colors.white,
      );
    }
    return const SizedBox();
  }

  Widget buildLabelTxt(ThemeData theme) {
    return Text(
      title ?? '',
      textAlign: TextAlign.center,
      style: theme.textTheme.titleSmall?.copyWith(color: titleColor),
    );
  }

  List<Widget> buildVisibilityWidget(ThemeData theme) {
    return [
      if (enableTextVisibilityToggle && controller != null)
        Obx(
          () => Visibility(
            visible: controller!.isTextVisible.value,
            replacement: Column(
              children: [
                Text(
                  '___,___,___',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: descriptionColor),
                ),
                SizedBox(height: Get.height * 0.008),
              ],
            ),
            child: Text(
              description ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: descriptionColor),
            ),
          ),
        ),
      if (!enableTextVisibilityToggle)
        Text(
          description ?? '',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(color: descriptionColor),
        ),
      if (enableTextVisibilityToggle && controller != null)
        Padding(
          padding: const EdgeInsets.all(5),
          child: Obx(
            () => Icon(
              controller!.isTextVisible.value
                  ? (unlockedIcon ?? Icons.lock_open)
                  : (lockedIcon ?? Icons.lock),
              color: iconColor ?? theme.colorScheme.primaryContainer,
            ),
          ),
        ),
    ];
  }
}
