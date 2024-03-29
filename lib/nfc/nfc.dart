import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:flutter_utils/nfc/utils.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'nfc_controller.dart';

class NfcNotSupported extends StatelessWidget {
  const NfcNotSupported({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
      child: Center(
        child: Text(
          "NFC not Supported or Enabled".ctr,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

class NfcReader extends StatelessWidget {
  const NfcReader({super.key});

  @override
  Widget build(BuildContext context) {
    var nfcController = Get.put(NFCController());
    return Obx(() {
      if (nfcController.isAvailable.value) return const NfcSupported();
      return const NfcNotSupported();
    });
  }
}

class IsScanning extends StatelessWidget {
  const IsScanning({super.key});
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var nfcController = Get.put(NFCController());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
          child: const CircularProgressIndicator(),
        ),
        SizedBox(width: size.width * 0.1),
        ElevatedButton.icon(
          onPressed: () {
            nfcController.stopReader();
          },
          icon: const Icon(Icons.stop),
          label: Text(''),
        )
      ],
    );
  }
}

class NfcTagRecordsList extends StatelessWidget {
  final NfcTagInfo tag;

  const NfcTagRecordsList({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        NdefRecordInfo record = tag.records[index];
        return Card(
          child: ListTile(
            title: Text(record.title),
            subtitle: Text(record.subtitle),
          ),
        );
      },
      itemCount: tag.records.length,
    );
    return Text(tag.records.length.toString());
  }
}

class NfcTagWidget extends StatelessWidget {
  final NfcTagInfo tag;

  const NfcTagWidget({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
        child: Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
      child: ElevatedButton.icon(
        label: Text(tag.nfcTag.handle),
        onPressed: () {
          Get.bottomSheet(
            // NfcTagWidget(
            //   tag: tag,
            // ),
            NfcTagRecordsList(tag: tag),
            // Text("Helloo"),
            // backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          );
        },
        icon: const Icon(Icons.list),
      ),
    ));
  }
}

class ScannedTagsList extends StatelessWidget {
  const ScannedTagsList({super.key});

  @override
  Widget build(BuildContext context) {
    var nfcController = Get.put(NFCController());

    return Obx(() {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          var tag = nfcController.scannedTags.value[index];
          return NfcTagWidget(
            tag: tag,
          );
        },
        itemCount: nfcController.scannedTags.value.length,
      );
    });
  }
}

class NfcSupported extends StatelessWidget {
  const NfcSupported({super.key});

  @override
  Widget build(BuildContext context) {
    var nfcController = Get.put(NFCController());
    var size = MediaQuery.of(context).size;

    return Obx(() {
      return Column(
        children: [
          if (nfcController.isScanning.value) const IsScanning(),
          if (!nfcController.isScanning.value)
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
              child: ElevatedButton.icon(
                onPressed: () {
                  nfcController.startReader();
                },
                icon: const Icon(Icons.nfc_rounded),
                label: Text("Scan".ctr),
              ),
            ),
          const ScannedTagsList()
        ],
      );
    });
  }
}
