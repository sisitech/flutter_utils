import 'package:flutter/material.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:get/get.dart';

import 'nfc_controller.dart';
import 'nfc_scan.dart';

class NFCScanningNoTagFound extends StatelessWidget {
  final String tag;

  const NFCScanningNoTagFound({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    var nfc_controller = Get.find<NFCController>(tag: tag);

    return Obx(() {
      return Column(
        children: [
          SizedBox(height: Get.height * 0.02),
          Divider(
            color: Get.theme.colorScheme.surface,
            thickness: 2,
            indent: 220,
            endIndent: 220,
          ),
          SizedBox(height: Get.height * 0.02),
          Text(
            'Ready to Scan'.ctr,
            textAlign: TextAlign.center,
            style: Get.theme.textTheme.bodyLarge?.copyWith(
              color: Get.theme.colorScheme.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const NFCScanningLoader(),
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 20.0,
              top: 0.0,
            ),
            child: Column(
              children: [
                Text(
                  'Hold your device near the NFC pass'.ctr,
                  textAlign: TextAlign.center,
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    color: Get.theme.colorScheme.surface,
                  ),
                ),
                Text(
                  nfc_controller.scannerStatus.value.ctr,
                  textAlign: TextAlign.center,
                  style: Get.theme.textTheme.titleSmall?.copyWith(
                    color: Get.theme.colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class NFCScannerBottomSheet extends StatelessWidget {
  final Widget? child;
  final Widget? foundWidget;
  final String tag;

  const NFCScannerBottomSheet(
      {super.key, this.foundWidget, this.child, required this.tag});

  @override
  Widget build(BuildContext context) {
    var nfcController = Get.find<NFCController>(tag: tag);
    var finalWidget = foundWidget ??
        TagFoundWidget(
          tag: tag,
        );

    if (child != null) {
      return child!;
    }
    return SafeArea(
      child: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (nfcController.scannedTags.value.isEmpty)
              NFCScanningNoTagFound(
                tag: tag,
              ),
            if (nfcController.scannedTags.value.isNotEmpty) finalWidget,
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                nfcController.options.cancelButtonText,
              ),
            ),
            SizedBox(height: Get.height * 0.02),
          ],
        );
      }),
    );
  }
}
