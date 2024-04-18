import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'nfc_controller.dart';
import 'utils.dart';

class NFCScanningLoader extends StatelessWidget {
  const NFCScanningLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      // 'assets/loading-animation.json',
      'packages/flutter_utils/assets/loading-animation.json',
      height: 150,
      frameRate: const FrameRate(60),
    );
  }
}

class NFCScanningNoTagFound extends StatelessWidget {
  const NFCScanningNoTagFound({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Text(
            'Hold your device near the NFC pass'.ctr,
            textAlign: TextAlign.center,
            style: Get.theme.textTheme.titleMedium?.copyWith(
              color: Get.theme.colorScheme.surface,
            ),
          ),
        ),
      ],
    );
  }
}

class TagFoundWidget extends StatelessWidget {
  const TagFoundWidget({super.key});
  @override
  Widget build(BuildContext context) {
    var nfcController = Get.find<NFCController>();

    return Obx(() {
      var tag = nfcController.scannedTags.value?.first;
      return Column(
        children: [
          SizedBox(height: Get.height * 0.02),
          Divider(
            color: Get.theme.colorScheme.surface,
            thickness: 2,
            indent: 220,
            endIndent: 220,
          ),
          Text(
            // 'Pass Found'.ctr,
            nfcController.options.foundTitle,
            textAlign: TextAlign.center,
            style: Get.theme.textTheme.bodyLarge?.copyWith(
              color: Get.theme.colorScheme.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            Icons.check,
            size: Get.height * 0.09,
          ),
          Text(
            tag?.serial_number ?? "N/A",
            textAlign: TextAlign.center,
            style: Get.theme.textTheme.bodyLarge?.copyWith(
              color: Get.theme.colorScheme.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Get.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  nfcController.startReader();
                },
                child: Text(
                  // 'Scan Again'.ctr,
                  nfcController.options.scanAgainButtonText,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nfcController.options.onScanComplete != null) {
                    nfcController.options
                        .onScanComplete!(nfcController.scannedTags.value);
                  }
                  Get.back();
                },
                child: Text(
                  nfcController.options.okButtonText,
                  // 'Use'.ctr,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class NFCScannerBottomSheet extends StatelessWidget {
  final Widget? child;
  const NFCScannerBottomSheet({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    var nfcController = Get.find<NFCController>();
    if (child != null) {
      return child!;
    }
    return SafeArea(
      child: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (nfcController.scannedTags.value.isEmpty)
              const NFCScanningNoTagFound(),
            if (nfcController.scannedTags.value.isNotEmpty)
              const TagFoundWidget(),
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

Future<List<NfcTagInfo>> startScannerWithBottomSheet() async {
  var nfcController = Get.find<NFCController>();
  nfcController.startReader();
  var res = await Get.bottomSheet(
    const NFCScannerBottomSheet(),
    isDismissible: false,
    backgroundColor: Get.theme.colorScheme.surfaceTint,
  );
  // dprint("BottomSheet doin");
  // dprint(res);
  nfcController.stopReader();
  var tags = nfcController.scannedTags.value;
  return tags;
  // showModalBottomSheet(
  //   backgroundColor: Get.theme.colorScheme.surfaceTint,
  //   context: Get.context!,
  //   builder: (BuildContext context) {
  //     return ;
  //   },
  // );
}

class IsScanning extends StatelessWidget {
  const IsScanning({super.key});
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var nfcController = Get.find<NFCController>();

    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Scanning..."),
        // Padding(
        //   padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
        //   child: const CircularProgressIndicator(),
        // ),
        // SizedBox(width: size.width * 0.1),
        // ElevatedButton.icon(
        //   onPressed: () {
        //     nfcController.stopReader();
        //   },
        //   icon: const Icon(Icons.stop),
        //   label: Text(''),
        // )
      ],
    );
  }
}
