import 'package:intl/intl.dart';

var charachtersToRemove = [" ", "@", "#"];

getFieldValue(Map<String, dynamic>? row, String? message) {
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
      var match = message.substring(e.start, e.end);
      var name = match
          .split("")
          .map((e) => charachtersToRemove.contains(e) ? "" : e)
          .join("");
      return {
        "match": match.trim(),
        "name": name,
        "value": getMatchValue(row, name)
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

getMatchValue(Map<String, dynamic>? row, String matchName) {
  if (row == null) {
    return "@${matchName}# No Data";
  }
  if (row!.containsKey(matchName)) {
    var value = row?[matchName];
    if (value == null) {
      // dprint("Null value");
      return "N/A";
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
  return "No Idea ${matchName}";
}

extension MyStringExt on String {
  String interpolate(Map<String, dynamic> row) {
    return getFieldValue(row, this);
  }
}
