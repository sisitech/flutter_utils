import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/screen_lock/controller.dart';
import 'package:get/get.dart';

class AppStateController extends FullLifeCycleController
    with FullLifeCycleMixin {
  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
    dprint("App paused");
    var controller = Get.find<ScreenLockController>();
    controller.lock();
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
    var controller = Get.find<ScreenLockController>();
    dprint("THE VALUE IS ${controller.isLocked.value}");
    if (controller.isLocked.value) {
      controller.unLock();
    }
  }
}
