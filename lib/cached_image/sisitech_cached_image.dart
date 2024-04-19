import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SisitechCachedImage extends StatelessWidget {
  final String imageUrl;
  final double imageWidth;
  final double imageHeight;
  final double placeholderWidth;
  final double placeholderHeight;
  final BoxFit fit;

  const SisitechCachedImage({
    Key? key,
    required this.imageUrl,
    this.imageWidth = 300.0,
    this.imageHeight = 300.0,
    this.placeholderWidth = 50.0,
    this.placeholderHeight = 50.0,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: imageWidth,
      height: imageHeight,
      fit: fit,
      placeholder: (context, url) => SizedBox(
        width: placeholderWidth,
        height: placeholderHeight,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.error,
        size: placeholderWidth,
      ),
    );
  }
}
