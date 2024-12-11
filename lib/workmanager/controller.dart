import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';

import 'utils.dart';

class BackgroundWorkManagerController extends GetxController {
  bool? isInDebugMode;
  Function callbackDispatcher;
  List<BackgroundWorkManagerTask> tasks;

  BackgroundWorkManagerController({
    required this.callbackDispatcher,
    required this.tasks,
    this.isInDebugMode,
  });

  @override
  void onInit() {
    initializeBackgroundWorkManager();
  }

  /*

*/
  Future<void> initializeBackgroundWorkManager() async {
    Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: isInDebugMode ?? kDebugMode);
  }

  Future<void> cancelAll() async {
    return Workmanager().cancelAll();
  }

  Future<void> registerTasks() async {
    for (var task in tasks) {
      await task.register();
    }
  }
}
