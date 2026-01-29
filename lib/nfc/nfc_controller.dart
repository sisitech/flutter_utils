import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:get/get.dart';

import 'models.dart';
import 'utils.dart';

class NFCController extends GetxController {
  var isAvailable = false.obs;
  var isScanning = false.obs;
  final NFCReaderOptions options;
  Future<void> Function(NfcTagInfo tag)? onNfcTagDiscovered;

  NFCController({required this.options, this.onNfcTagDiscovered});

  RxList<NfcTagInfo> scannedTags = RxList.empty();

  @override
  void onInit() {
    super.onInit();
    checkNfcEnabled();
  }

  checkNfcEnabled() async {
    final availability = await NfcManager.instance.checkAvailability();
    isAvailable.value = availability == NfcAvailability.enabled;
  }

  @override
  void onClose() {
    stopReader();
    super.onClose();
  }

  setOnDiscoverdFunction(Future<void> Function(NfcTagInfo tag)? onDiscovered) {
    // onNfcTagDiscovered = onDiscovered;
    // dprint(onNfcTagDiscovered == null);
    // dprint(onNfcTagDiscovered);
  }

  startReader({bool stopOnFirst = false}) {
    scannedTags.value = [];
    isScanning.value = true;
    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        if (onNfcTagDiscovered != null) {
          var parsedTag = await NfcTagInfo.fromTag(tag);
          await onNfcTagDiscovered!(parsedTag);
        } else {
          await defaultOnNfcTagDiscovered(tag);
        }
      },
    );
    isScanning.value = true;
  }

  Future<void> defaultOnNfcTagDiscovered(NfcTag tag) async {
    var parsedTag = await NfcTagInfo.fromTag(tag);
    if (scannedTags
        .where((t) => t.serial_number == parsedTag.serial_number)
        .isEmpty) {
      if (options.infiniteScan) {
        scannedTags.add(parsedTag);
      } else {
        scannedTags.value = [parsedTag];
      }
    }
    dprint((await tag.ndefRecordInfos()).map((e) => e.subtitle));
  }

  var scannerStatus = "".obs;

  startWriter(message,
      {bool stopOnFirst = false, required NFCWriterOptions options}) {
    scannedTags.value = [];
    isScanning.value = true;
    scannerStatus.value = "NFC writer started. Waiting for card...".ctr;
    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        scannerStatus.value = "NFC found.".ctr;
        var parsedTag = await NfcTagInfo.fromTag(tag);
        if (parsedTag.serial_number == "") {
          scannerStatus.value =
              "Card is not supported. Please Scan another card.".ctr;
          return;
        }
        if (!parsedTag.isWritable) {
          scannerStatus.value =
              "Card is not writable. Please Scan another card.".ctr;
          return;
        } else {
          scannerStatus.value = "Writing in progress.".ctr;

          if (parsedTag.ndef != null) {
            NdefMessage ndefMessage = NdefMessage(records: options.records);
            await parsedTag.ndef?.write(message: ndefMessage);
          }
          scannerStatus.value = "Writing Done. Please scan another card.".ctr;

          if (onNfcTagDiscovered != null) {
            await onNfcTagDiscovered!(parsedTag);
          }
        }
      },
    );
    isScanning.value = true;
  }

  writeInfo() {
    // NfcManager.instance.
  }

  stopReader() {
    // Stop Session
    NfcManager.instance.stopSession();
    isScanning.value = false;
    scannerStatus.value = "".ctr;
  }
}
