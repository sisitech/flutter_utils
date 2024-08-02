String formatThemeName(String themeName) {
  // Remove "M3"
  String withoutM3 = themeName.replaceAll("M3", "");

  // Insert spaces before uppercase letters (except the first letter)
  String withSpaces = withoutM3.replaceAllMapped(
    RegExp(r'(?<!^)(?=[A-Z])'),
    (Match match) => ' ',
  );

  // Capitalize each word
  List<String> words = withSpaces.split(' ');
  List<String> capitalizedWords = words.map((word) {
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).toList();

  // Join the words back together with spaces
  return capitalizedWords.join(' ');
}
