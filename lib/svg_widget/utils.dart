import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

Future<String> getHexSvgString(
    String svgPath, Color priColor, Color secColor) async {
  String svgString = await extractSVGString(svgPath);
  List<String> hexCodes = getSvgHexCodes(svgString);

  String priColorHex = colorToHex(priColor);
  String secColorHex = colorToHex(secColor);

  String hexSvgString = svgString.replaceAll(hexCodes[0], priColorHex);

  // Replace secondary color if hexCodes has enough elements
  if (hexCodes.length >= 2) {
    hexSvgString = hexSvgString.replaceAll(hexCodes[1], secColorHex);
  }

  // Replace tertiary color if hexCodes has enough elements
  if (hexCodes.length >= 3) {
    hexSvgString = hexSvgString.replaceAll(hexCodes[2], '#eee');
  }

  return hexSvgString;
}

Future<String> extractSVGString(String filePath) async {
  try {
    final content = await rootBundle.loadString(filePath);
    return content;
  } catch (e) {
    debugPrint('Error reading SVG file: $e');
    return "";
  }
}

List<String> getSvgHexCodes(String input) {
  final hexRegex = RegExp(r'#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?\b');
  final hexMatches = hexRegex.allMatches(input);
  var hexCodes = hexMatches.map((match) => match.group(0)).toList();
  hexCodes = hexCodes.where((element) => element != null).toList();
  // Count occurrences of each hex code
  final Map<String, int> hexCounts = {};
  for (final hexCode in hexCodes) {
    hexCounts[hexCode ?? ''] = (hexCounts[hexCode] ?? 0) + 1;
  }

  final sortedHexCodes = hexCounts.keys.toList()
    ..sort((a, b) => hexCounts[b]!.compareTo(hexCounts[a]!));

  return sortedHexCodes;
}

String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).substring(2)}';
}

bool isValidSvgPath(String path) {
  return path.toLowerCase().endsWith('.svg');
}
