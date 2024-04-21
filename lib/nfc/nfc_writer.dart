import 'package:flutter/material.dart';
import 'package:flutter_utils/nfc/utils.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'models.dart';
import 'nfc.dart';
import 'nfc_controller.dart';
import 'nfc_scan.dart';

class NfcWriter extends StatelessWidget {
  final NFCWriterOptions options;
  final Future<void> Function(NfcTagInfo tag)? onNfcTagDiscovered;

  const NfcWriter({super.key, required this.options, this.onNfcTagDiscovered});

  @override
  Widget build(BuildContext context) {
    var nfcController = Get.find<NFCController>(tag: options.tag);
    // nfcController.onNfcTagDiscovered = onNfcTagDiscovered;
    return Obx(() {
      if (nfcController.isAvailable.value) {
        return NfcWriterSupported(
          options: options,
        );
      }
      return const NfcNotSupported();
    });
  }
}

class NfcWriterSupported extends StatelessWidget {
  final NFCWriterOptions options;

  const NfcWriterSupported({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    var nfcController = Get.find<NFCController>(tag: options.tag);
    var size = MediaQuery.of(context).size;
    return Obx(() {
      return Column(
        children: [
          if (nfcController.isScanning.value)
            IsScanning(
              tag: options.tag,
            ),
          if (!nfcController.isScanning.value)
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.002),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await startNFCWriterWithBottomSheet("welcome",
                      options: options);
                },
                icon: const Icon(Icons.nfc_rounded),
                label: Text(options?.scanButtonText ?? "Scana"),
              ),
            ),
          // const ScannedTagsList()
        ],
      );
    });
  }
}
