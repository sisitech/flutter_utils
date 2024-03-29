import 'dart:convert';

import 'package:flutter_utils/flutter_utils.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'utils.dart';

class NFCController extends GetxController {
  var isAvailable = false.obs;
  var isScanning = false.obs;

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
        if (stopOnFirst) {
          stopReader();
        }
        await onDiscoverTag(tag);
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
  }

  Future<void> onDiscoverTag(NfcTag tag) async {
    if (scannedTags.value
        .where((element) => element.nfcTag.handle == tag.handle)
        .isEmpty) {
      scannedTags.add(await NfcTagInfo.fromTag(tag));
    }
    dprint((await tag.ndefRecordInfos()).map((e) => e.subtitle));
  }
}
