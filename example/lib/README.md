# NFC Controller

- Always initalize the NFC controller using Get with  `default`  as the tag. use `defaultControllerTagName` variable to get defualt tagName

```dart
var nfcController = Get.put(NFCController(
        options: defaultNfcOptions,
        onNfcTagDiscovered: (
          NfcTagInfo tag,
        ) async {
          var nfcControllera = Get.find<NFCController>(tag:options.tag)();
          nfcControllera?.defaultOnNfcTagDiscovered(tag.nfcTag);
        }),tag:defaultControllerTagName);
```
