import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'utils.dart';

class NFCReaderOptions {
  final bool infiniteScan;
  final String scanButtonText;
  final String scanAgainButtonText;
  final String foundTitle;
  final String cancelButtonText;
  final String okButtonText;
  final Widget? foundWidget;
  final String tag;
  final Function(List<NfcTagInfo> tags)? onScanComplete;

  const NFCReaderOptions({
    this.infiniteScan = false,
    this.tag = defaultControllerTagName,
    this.scanButtonText = "Scan",
    this.foundWidget,
    this.scanAgainButtonText = "Scan Again",
    this.foundTitle = "Pass Found",
    this.cancelButtonText = "Cancel",
    this.okButtonText = "Use",
    this.onScanComplete,
  });
}

class NFCWriterOptions {
  final bool infiniteScan;
  final String scanButtonText;
  final String scanAgainButtonText;
  final String foundTitle;
  final Widget? foundWidget;
  final String cancelButtonText;
  final String tag;
  final String okButtonText;
  final Function(List<NfcTagInfo> tags)? onScanComplete;

  final List<NdefRecord> records;

  const NFCWriterOptions({
    this.infiniteScan = false,
    this.tag = defaultControllerTagName,
    this.foundWidget,
    this.scanButtonText = "Writer",
    this.scanAgainButtonText = "Writer Again",
    this.foundTitle = "Pass Found",
    this.cancelButtonText = "Cancel",
    this.okButtonText = "Use",
    this.onScanComplete,
    required this.records,
  });
}
