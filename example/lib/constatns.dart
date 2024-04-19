import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/nfc/models.dart';

var defaultNfcOptions = NFCReaderOptions(onScanComplete: (value) {
  dprint(value);
});
