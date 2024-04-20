import 'package:flutter/material.dart';
import 'package:flutter_utils/nfc/nfc_controller.dart';
import 'package:get/get.dart';

class NFCTagsFoundWidget extends StatelessWidget {
  const NFCTagsFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var nfcController = Get.find<NFCController>();
    var size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      child: Column(
        children: [
          Text(
            "Found Tag",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
