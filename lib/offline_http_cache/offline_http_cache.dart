import 'package:flutter_utils/flutter_utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models.dart';

class OfflineHttpCacheController extends SuperController {
  Future<void> saveOfflineCache(OfflineHttpCall offlineHttpCall) async {
    dprint("Box is ${offlineHttpCall.storageContainer}");
    final box = GetStorage(offlineHttpCall.storageContainer);
    String id = offlineHttpCall.id;
    dprint("The id is ${id}");
    return box.write(id, offlineHttpCall);
  }

  Future<List<OfflineHttpCall>> getOfflineCaches(
      String storageContainer) async {
    final box = GetStorage(storageContainer);
    var keys = await getOfflineKeys(storageContainer);
    List<OfflineHttpCall> objs = [];
    for (var key in keys) {
      OfflineHttpCall? value = await box.read<OfflineHttpCall>(key);
      if (value != null) {
        objs.add(value);
      }
    }
    return Future.value(objs);
  }

  getOfflineKeys(String storageContainer) async {
    final box = GetStorage(storageContainer);
    var keys = await box.getKeys<Iterable<String>>();
    return keys
        .where((element) => element.startsWith(offline_http_call_prefix))
        .toList();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getInstances();
  }

  getInstances() async {
    var keys = await getOfflineKeys("GetStorage");
    dprint(keys);

    var data = await getOfflineCaches("GetStorage");
    dprint(data);
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }
}
