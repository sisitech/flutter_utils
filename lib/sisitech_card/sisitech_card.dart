import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Assuming SisitechCardController is defined elsewhere in your project
class SisitechCardController extends GetxController {
  var isTextVisible = false.obs;

  void toggleTextVisibility() {
    isTextVisible.value = !isTextVisible.value;
  }
}

class SisitechCard extends StatelessWidget {
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

  SisitechCard({
    super.key,
    this.assetImage,
    this.description,
    this.title,
    this.imageScale,
    this.color = Colors.teal,
    this.iconData,
    this.iconColor,
    this.iconSize,
    this.titleColor,
    this.descriptionColor,
    this.cardAxisAlignment,
    this.cardMainAxisAlignment,
    this.enableTextVisibilityToggle = false,
    this.lockedIcon,
    this.unlockedIcon,
  }) : controller = enableTextVisibilityToggle
            ? Get.put(SisitechCardController())
            : null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: Get.width,
          child: Card(
            color: color,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment:
                    cardAxisAlignment ?? CrossAxisAlignment.center,
                mainAxisAlignment:
                    cardMainAxisAlignment ?? MainAxisAlignment.center,
                children: [
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
                  if (enableTextVisibilityToggle)
                    Obx(() => Visibility(
                          visible: controller!.isTextVisible.value,
                          replacement: Column(
                            children: [
                              Text(
                                '___,___,___',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
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
                        )),
                  if (!enableTextVisibilityToggle)
                    Text(
                      description ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: descriptionColor),
                    ),
                  if (enableTextVisibilityToggle)
                    GestureDetector(
                      onTap: () => controller!.toggleTextVisibility(),
                      child: Obx(
                        () => Icon(
                          controller!.isTextVisible.value
                              ? (unlockedIcon ?? Icons.lock_open)
                              : (lockedIcon ?? Icons.lock),
                          color: iconColor ??
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
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
}
