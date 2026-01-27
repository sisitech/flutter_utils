import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String get toWeekDayDate {
    return DateFormat("E, dd MMM hh:mm aaa").format(this);
  }

  String get toAPIDate {
    return DateFormat("yyyy-MM-dd").format(this);
  }

  String get toAPIDateTime {
    return DateFormat("yyyy-MM-ddTHH:mm").format(this);
  }

  String toDateTimeFormat(String format) {
    return DateFormat(format).format(this);
  }

  /// Returns a human-readable relative time string.
  /// Handles both past dates ("4m ago") and future dates ("in 15m").
  String get toRelativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);

    // Future date
    if (diff.isNegative) {
      final futureDiff = difference(now);
      if (futureDiff.inMinutes < 1) {
        return 'Soon';
      } else if (futureDiff.inHours < 1) {
        return 'in ${futureDiff.inMinutes}m';
      } else if (futureDiff.inDays < 1) {
        return 'in ${futureDiff.inHours}h';
      } else {
        return toDateTimeFormat('MMM d, HH:mm');
      }
    }

    // Past date
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return toDateTimeFormat('MMM d, HH:mm');
    }
  }
}

extension StringDateExt on String {
  DateTime? get toDate {
    try {
      if (toLowerCase() == "today" || toLowerCase() == "now") {
        return DateTime.now();
      }

      var format = DateFormat("yyyy-MM-dd");
      return format.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// Parses relative time strings like "4m ago", "in 15m" back to DateTime.
  /// Returns null if the string cannot be parsed.
  DateTime? get toRelativeDateTime {
    final now = DateTime.now();
    final trimmed = trim().toLowerCase();

    // Handle special cases
    if (trimmed == 'just now' || trimmed == 'soon') {
      return now;
    }

    // Future: "in Xm", "in Xh"
    final futureMatch = RegExp(r'^in\s+(\d+)([mhd])$').firstMatch(trimmed);
    if (futureMatch != null) {
      final value = int.parse(futureMatch.group(1)!);
      final unit = futureMatch.group(2)!;
      switch (unit) {
        case 'm':
          return now.add(Duration(minutes: value));
        case 'h':
          return now.add(Duration(hours: value));
        case 'd':
          return now.add(Duration(days: value));
      }
    }

    // Past: "Xm ago", "Xh ago", "Xd ago"
    final pastMatch = RegExp(r'^(\d+)([mhd])\s+ago$').firstMatch(trimmed);
    if (pastMatch != null) {
      final value = int.parse(pastMatch.group(1)!);
      final unit = pastMatch.group(2)!;
      switch (unit) {
        case 'm':
          return now.subtract(Duration(minutes: value));
        case 'h':
          return now.subtract(Duration(hours: value));
        case 'd':
          return now.subtract(Duration(days: value));
      }
    }

    return null;
  }
}
