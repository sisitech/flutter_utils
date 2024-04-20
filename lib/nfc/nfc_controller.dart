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

  NFCController({required this.options});

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

  startReader({bool stopOnFirst = false}) {
    scannedTags.value = [];
    isScanning.value = true;
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // if (!options.infiniteScan) {
        //   stopReader();
        // }
        await onDiscoverTag(tag);
      },
    );
    isScanning.value = true;
  }

  var scannerStatus = "".obs;

  startWriter(message, {bool stopOnFirst = false}) {
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
        // dprint("Parsed Tag");
        // dprint(parsedTag.isWritable);
        // dprint(parsedTag.serial_number);
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
          NdefRecord uriRecord = NdefRecord.createUri(
              Uri.parse("https://sisitech.com/#/case-studies/wavvy"));
          String inputString = "michameiu";
          // Prepare the second external type record

          NdefRecord externalRecord2 = NdefRecord.createExternal(
              'com.sisitech', // domain
              'username', // type
              Uint8List.fromList(
                  utf8.encode(inputString)) // payload as byte array
              );

          if (parsedTag.ndef != null) {
            NdefMessage message = NdefMessage([
              uriRecord,
              externalRecord2,
            ]);

            await parsedTag.ndef?.write(message);
          }

          scannerStatus.value = "Writing Done.".ctr;
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

  Future<void> onDiscoverTag(NfcTag tag) async {
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
}
