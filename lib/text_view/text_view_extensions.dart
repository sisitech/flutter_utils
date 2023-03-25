import 'package:flutter/foundation.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:intl/intl.dart';
import 'package:slugify/slugify.dart';

var charachtersToRemove = [" ", "@", "#"];

getFieldValue(Map<String, dynamic>? row, String? message,
    {String listSeparator = ","}) {
  if (message == null) {
    return "Noa";
  }
  RegExp regExp = RegExp(
    r"@(.*?)[ ,#,]",
    caseSensitive: false,
    multiLine: false,
  );
  var variables = [];
  // dprint("Matching");
  var mateches = regExp.allMatches(message);
  var parsedMatches = mateches.map(
    (e) {
      var match = message.substring(e.start, e.end).trim();
      var name = match
          .split("")
          .map((e) => charachtersToRemove.contains(e) ? "" : e)
          .join("");
      return {
        "match": match.trim(),
        "name": name,
        "value": getMatchValue(row, name, listSeparator: listSeparator)
      };
    },
    // (e) => e.,
  );
  var parsedMessage = message;
  Map<String, dynamic> matchesMap = {};
  parsedMatches.forEach((value) {
    matchesMap[value["name"]] = value["value"];
    parsedMessage =
        parsedMessage.replaceAll(value["match"], "${value["value"]}");
  });
  // dprint(matchesMap);
  // dprint(parsedMessage);
  // dprint(DateTime.now());
  return parsedMessage;
}

getMapValue(
  Map<String, dynamic>? row,
) {}

getMatchValue(dynamic? row, String matchName, {String listSeparator = ","}) {
  if (row == null) {
    if (kDebugMode) {
      return "@${matchName}# No Data";
    } else {
      return "";
    }
  }
  // dprint(matchName);
  // Recursive checking
  if (matchName.contains(".")) {
    var matches = matchName.split(".");
    if (matches.isNotEmpty) {
      var currentMatch = matches[0]?.trim();
      if (row.containsKey(currentMatch)) {
        var currentValue = row[currentMatch];
        bool isList = currentValue.runtimeType.toString().contains("List");
        if (!isList) {
          matches.remove(currentMatch);
          return getMatchValue(currentValue, matches.join("."));
        }
        matches.remove(currentMatch);
        var next_match = matches[0];
        matches.remove(next_match);

        var index = int.tryParse(next_match);

        if ((currentValue as List<dynamic>).isEmpty) {
          return "";
        }

        if (index == null) {
          if (matches.isEmpty) {
            return getMatchValue({"value": currentValue}, "value");
          } else {
            var nextMatch = matches.join(".").trim();
            var instance = (currentValue as List<dynamic>)[0];
            if (!instance.runtimeType.toString().contains("Map")) {
              return kDebugMode ? "$matchName map not found" : "";
            }
            if (!instance.containsKey(nextMatch)) {
              return kDebugMode
                  ? "$matchName No $nextMatch found in instance"
                  : "";
            }
            // dprint(instance);
            // dprint(nextMatch);
            return (currentValue as List<dynamic>)
                .map((e) => e[nextMatch])
                .toList()
                .join(listSeparator);
          }
        } else {
          // dprint("The set Index is $index");
          if (index != null) {
            var nextValue = (currentValue as List<dynamic>)[index];
            // dprint("Index value $nextValue $matches");
            if (matches.isEmpty) {
              return getMatchValue({"value": nextValue}, "value");
            }
            return getMatchValue(nextValue, matches.join("."));
          }
        }
      }
    }

    return kDebugMode ? "@${matchName}# No recursive" : "";
  }

  if (row!.containsKey(matchName)) {
    var value = row?[matchName];

    if (value == null) {
      if (kDebugMode) {
        return "N/A";
      } else {
        return "";
      }
    }

    if (value.runtimeType.toString().contains("List")) {
      if (value.runtimeType == List<String>) {
        return (value as List<String>).join(listSeparator);
      }
    }
    // Apply formatting
    // dprint(value.runtimeType);
    if (value.runtimeType == double || value.runtimeType == int) {
      // dprint("Double detected");
      var formatter = NumberFormat('###,###');
      value = formatter.format(value);
    }
    return value;
  }
  if (kDebugMode) {
    return "No Idea ${matchName}";
  } else {
    return "";
  }
}

extension MyStringExt on String {
  String interpolate(Map<String, dynamic> row, {String listSeparator = ", "}) {
    return getFieldValue(row, this, listSeparator: listSeparator);
  }

  String get slug {
    return slugify(this, delimiter: '_');
  }
}
