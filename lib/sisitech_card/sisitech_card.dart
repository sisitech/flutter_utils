import 'package:flutter/material.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16.0,
          bottom: 16.0,
        ),
        child: Column(
          children: [
            if (assetImage != null)
              Image.asset(
                assetImage!,
                scale: imageScale ?? 1.0, // Use provided scale or default
              )
            else if (iconData != null)
              Icon(
                iconData,
                size: iconSize ?? 24.0, // Use provided icon size or default
                color: iconColor ??
                    Colors.white, // Use provided icon color or default
              ),
            SizedBox(
              height: Get.height * 0.006,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(
              height: Get.height * 0.006,
            ),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
