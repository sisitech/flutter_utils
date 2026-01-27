import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'models.dart';
import 'utils.dart';

class BackgroundWorkManagerController extends GetxController {
  bool? isInDebugMode;
  Function callbackDispatcher;
  List<BackgroundWorkManagerTask> tasks;

  /// Observable list of task statuses for reactive UI
  RxList<BackgroundTaskStatus> taskStatuses = RxList.empty();

  /// Loading state
  RxBool isLoading = false.obs;

  BackgroundWorkManagerController({
    required this.callbackDispatcher,
    required this.tasks,
    this.isInDebugMode,
  });

  @override
  void onInit() {
    super.onInit();
  }

  /// Initialize the workmanager with callback dispatcher
  Future<void> initializeBackgroundWorkManager() async {
    Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: isInDebugMode ?? kDebugMode);
  }

  /// Cancel all tasks and clear storage
  Future<void> cancelAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tasksStorageName);

    // Mark all tasks as unregistered
    for (var status in taskStatuses) {
      await markTaskPaused(status.uniqueName);
    }

    await Workmanager().cancelAll();
    await refreshStatuses();
  }

  /// Register all configured tasks
  Future<void> registerTasks() async {
    for (var task in tasks) {
      await task.register();
    }
    await refreshStatuses();
  }

  /// Load all task statuses from storage
  Future<void> loadTaskStatuses() async {
    isLoading.value = true;
    try {
      final statuses = await getAllTaskStatuses();
      taskStatuses.value = statuses;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh task statuses from disk (for cross-isolate sync)
  Future<void> refreshStatuses() async {
    isLoading.value = true;
    try {
      // getAllTaskStatuses() calls prefs.reload() to sync cross-isolate changes
      final statuses = await getAllTaskStatuses();
      taskStatuses.value = statuses;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get status for a specific task by uniqueName
  BackgroundTaskStatus? getTaskStatusByName(String uniqueName) {
    try {
      return taskStatuses.firstWhere((s) => s.uniqueName == uniqueName);
    } catch (_) {
      return null;
    }
  }

  /// Cancel a specific task by uniqueName
  Future<void> cancelTask(String uniqueName) async {
    await Workmanager().cancelByUniqueName(uniqueName);

    // Update status
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(taskStatusStorageName);
    Map<String, dynamic> allStatuses =
        jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

    if (allStatuses.containsKey(uniqueName)) {
      var status = BackgroundTaskStatus.fromJson(
          allStatuses[uniqueName] as Map<String, dynamic>);
      status = status.markUnregistered();
      allStatuses[uniqueName] = status.toJson();
      await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
    }

    // Also remove from legacy storage
    String? tasksJson = prefs.getString(tasksStorageName);
    Map<String, dynamic> readAllTasks =
        tasksJson != null ? jsonDecode(tasksJson) as Map<String, dynamic> : {};
    // Find and remove matching task
    var task = tasks.where((t) => t.uniqueName == uniqueName).firstOrNull;
    if (task != null) {
      readAllTasks.remove(task.getUniqueIdHash());
      await prefs.setString(tasksStorageName, jsonEncode(readAllTasks));
    }

    await refreshStatuses();
  }

  /// Pause a periodic task (cancels it and marks as paused)
  Future<void> pauseTask(String uniqueName) async {
    await Workmanager().cancelByUniqueName(uniqueName);
    await markTaskPaused(uniqueName);
    await refreshStatuses();
  }

  /// Resume a paused task (re-registers it)
  Future<void> resumeTask(String uniqueName) async {
    var task = tasks.where((t) => t.uniqueName == uniqueName).firstOrNull;
    if (task != null) {
      // Force re-registration by setting cancelPrevious
      var originalCancelPrevious = task.cancelPrevious;
      task.cancelPrevious = true;
      await task.register();
      task.cancelPrevious = originalCancelPrevious;
    }
    await refreshStatuses();
  }

  /// Remove a task completely (cancels and clears all history)
  Future<void> removeTask(String uniqueName) async {
    await Workmanager().cancelByUniqueName(uniqueName);
    await removeTaskStatus(uniqueName);

    // Also remove from legacy storage
    final prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString(tasksStorageName);
    Map<String, dynamic> readAllTasks =
        tasksJson != null ? jsonDecode(tasksJson) as Map<String, dynamic> : {};
    var task = tasks.where((t) => t.uniqueName == uniqueName).firstOrNull;
    if (task != null) {
      readAllTasks.remove(task.getUniqueIdHash());
      await prefs.setString(tasksStorageName, jsonEncode(readAllTasks));
    }

    await refreshStatuses();
  }

  /// Clear execution history for a task
  Future<void> clearHistory(String uniqueName) async {
    await clearTaskHistory(uniqueName);
    await refreshStatuses();
  }

  /// Check if a task is scheduled (uses native workmanager API)
  Future<bool> isTaskScheduled(String uniqueName) async {
    return await Workmanager().isScheduledByUniqueName(uniqueName);
  }

  /// Get the BackgroundWorkManagerTask definition for a uniqueName
  BackgroundWorkManagerTask? getTaskDefinition(String uniqueName) {
    return tasks.where((t) => t.uniqueName == uniqueName).firstOrNull;
  }
}
