import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_utils/mixpanel/mixpanel_controller.dart';
import 'package:get/get.dart';

import '../utils/functions.dart';

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

  final bool enableMixpanel;

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => controller!.toggleTextVisibility(
              eventName: "card_${slug}_clicked",
              enableMixpanel: enableMixpanel),
          child: SizedBox(
            width: cardWidth,
            child: Card(
              color: color,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
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
                    if (assetImage != null)
                      Image.asset(
                        assetImage!,
                        scale: imageScale ?? 1.0,
                      )
                    else if (iconData != null)
                      Icon(
                        iconData,
                        size: iconSize ?? 24.0,
                        color: iconColor ?? Colors.white,
                      ),
                    SizedBox(height: Get.height * 0.006),
                    Text(
                      title ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: titleColor),
                    ),
                    SizedBox(height: Get.height * 0.01),
                    if (enableTextVisibilityToggle && controller != null)
                      Obx(
                        () => Visibility(
                          visible: controller!.isTextVisible.value,
                          replacement: Column(
                            children: [
                              Text(
                                '___,___,___',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: descriptionColor),
                              ),
                              SizedBox(height: Get.height * 0.008),
                            ],
                          ),
                          child: Text(
                            description ?? '',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: descriptionColor),
                          ),
                        ),
                      ),
                    if (!enableTextVisibilityToggle)
                      Text(
                        description ?? '',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: descriptionColor),
                      ),
                    if (enableTextVisibilityToggle && controller != null)
                      Obx(
                        () => Icon(
                          controller!.isTextVisible.value
                              ? (unlockedIcon ?? Icons.lock_open)
                              : (lockedIcon ?? Icons.lock),
                          color: iconColor ??
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                    SizedBox(height: Get.height * 0.01),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
