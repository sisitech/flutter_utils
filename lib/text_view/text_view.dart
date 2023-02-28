library flutter_utils;

import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:intl/intl.dart';

class TextView extends StatelessWidget {
  final String display_message;
  final Map<String, dynamic>? data;
  final String startFiedSymbol;
  final String endFiedSymbol;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;

  TextView({
    super.key,
    required this.display_message,
    this.startFiedSymbol = "@",
    this.endFiedSymbol = "#",
    this.data,
    this.style,
    this.overflow = TextOverflow.clip,
    this.maxLines = 2,
    this.softWrap = true,
  }) {
    // dprint(display_message);
    // dprint(data);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      getFieldValue(data, display_message),
      style: style,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}
