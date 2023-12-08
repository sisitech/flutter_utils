import 'package:flutter_utils/flutter_utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';

import '../models.dart';

class OfflineHttpCacheController extends SuperController {
  Future<void> saveOfflineCache(OfflineHttpCall offlineHttpCall,
      {String taskPrefix = ""}) async {
    dprint("Box is ${offlineHttpCall.storageContainer}");

    // dprint(value)
    final box = GetStorage(offlineHttpCall.storageContainer);
    String id = offlineHttpCall.id;
    dprint("The id is $id");
    String taskName = "$taskPrefix.${offlineHttpCall.storageContainer}";
    dprint("Saving...");
    await box.write(id, offlineHttpCall.toJson());
    dprint("Saved the following");
    dprint(await box.read(id));
    return Workmanager().registerOneOffTask(
      taskName,
      taskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 30),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  Future<List<OfflineHttpCall>> getOfflineCaches(
      String storageContainer) async {
    final box = GetStorage(storageContainer);
    var keys = await getOfflineKeys(storageContainer);
    List<OfflineHttpCall> objs = [];
    for (var key in keys) {
      var value = await box.read<Map<String, dynamic>>(key);
      if (value != null) {
        try {
          objs.add(OfflineHttpCall.fromJson(value));
        } catch (e) {
          dprint(e);
        }
      }
    }
    return Future.value(objs);
  }

  Future<List<String>> getOfflineKeys(String storageContainer) async {
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

  @override
  void onHidden() {
    // TODO: implement onHidden
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
