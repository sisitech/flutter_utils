import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models.dart';
import 'nfc.dart';
import 'nfc_controller.dart';
import 'nfc_scan.dart';

class NfcWriter extends StatelessWidget {
  final NFCWriterOptions options;

  const NfcWriter({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    var nfcController = Get.find<NFCController>();
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
  final NFCWriterOptions? options;

  const NfcWriterSupported({super.key, this.options});

  @override
  Widget build(BuildContext context) {
    var nfcController = Get.find<NFCController>();

    var size = MediaQuery.of(context).size;

    return Obx(() {
      return Column(
        children: [
          if (nfcController.isScanning.value) const IsScanning(),
          if (!nfcController.isScanning.value)
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.002),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await startNFCWriterWithBottomSheet("welcome");
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
