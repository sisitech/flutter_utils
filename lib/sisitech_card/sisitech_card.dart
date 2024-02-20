import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SisitechCard extends StatelessWidget {
  final String? assetImage; // Optional image path
  final IconData? iconData; // Optional icon data
  final String description;
  final String title;
  final Color color; // Card color
  final double? imageScale; // Optional image scale
  final Color? iconColor; // Optional icon color
  final double? iconSize; // Optional icon size
  final Color? titleColor;
  final Color? descriptionColor;
  final CrossAxisAlignment? cardAxisAlignment;

  const SisitechCard({
    super.key,
    this.assetImage, // Image path is optional
    required this.description,
    required this.title,
    this.imageScale, // Image scale is optional
    this.color = Colors.teal, // Default card color is teal
    this.iconData, // Icon data is optional
    this.iconColor, // Icon color is optional
    this.iconSize, // Icon size is optional
    this.titleColor,
    this.descriptionColor,
    this.cardAxisAlignment,
  });

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
                  SizedBox(
                    height: Get.height * 0.006,
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: titleColor,
                        ),
                  ),
                  SizedBox(
                    height: Get.height * 0.006,
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: descriptionColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
