import 'dart:convert';
import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager.dart';

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
    // TODO: implement onInit
    super.onInit();
    checkNfcEnabled();
  }

  checkNfcEnabled() async {
    isAvailable.value = await NfcManager.instance.isAvailable();
    // dprint(await NfcManager.instance.isAvailable());
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
    if (scannedTags.value
        .where((element) => element.nfcTag.handle == tag.handle)
        .isEmpty) {
      var parsedTag = await NfcTagInfo.fromTag(tag);
      if (scannedTags
          .where((tag) => tag.serial_number == parsedTag.serial_number)
          .isEmpty) {
        if (options.infiniteScan) {
          scannedTags.add(parsedTag);
        } else {
          scannedTags.value = [parsedTag];
        }
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
      onDiscovered: (NfcTag tag) async {
        // if (!options.infiniteScan) {
        //   stopReader();
        // }
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
          String inputString = "michameiu";

          if (parsedTag.ndef != null) {
            NdefMessage message = NdefMessage(options.records);
            await parsedTag.ndef?.write(message);
          }
          scannerStatus.value = "Writing Done.".ctr;

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
