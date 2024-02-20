// File: lib/sisitech_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SisitechCard extends StatelessWidget {
  final String assetImage;
  final String description;
  final String title;
  final Color color;
  final double imageScale;

  const SisitechCard({
    super.key,
    required this.assetImage,
    required this.description,
    required this.title,
    required this.imageScale,
    this.color = Colors.teal, // Default color is teal
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
            Image.asset(
              assetImage,
              scale: imageScale,
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
