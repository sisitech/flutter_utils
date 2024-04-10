import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_utils/svg_widget/utils.dart';

class SistchSvgWidget extends StatefulWidget {
  final String svgPath;
  const SistchSvgWidget({super.key, required this.svgPath});

  @override
  State<SistchSvgWidget> createState() => _SistchSvgWidgetState();
}

class _SistchSvgWidgetState extends State<SistchSvgWidget> {
  @override
  Widget build(BuildContext context) {
    return isValidSvgPath(widget.svgPath)
        ? FutureBuilder<String>(
            future: getHexSvgString(
                widget.svgPath,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return SvgPicture.string(
                  snapshot.data!,
                  fit: BoxFit.cover,
                );
              }
            },
          )
        : const Text('Invalid svg path');
  }
}
