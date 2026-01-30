import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'ios_notification_scheduler.dart';
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
    // Cancel iOS notifications for all tasks
    if (Platform.isIOS) {
      final scheduler = IOSNotificationScheduler();
      for (var status in taskStatuses) {
        await scheduler.cancelAllNotificationsForTask(status.uniqueName);
      }
    }

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
    // Cancel iOS notifications regardless of task definition (handles orphaned tasks)
    if (Platform.isIOS) {
      final scheduler = IOSNotificationScheduler();
      await scheduler.cancelAllNotificationsForTask(uniqueName);
    }

    await Workmanager().cancelByUniqueName(uniqueName);

    // Update status
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    String? jsonStr = prefs.getString(taskStatusStorageName);
    Map<String, dynamic> allStatuses =
        jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

    if (allStatuses.containsKey(uniqueName)) {
      var status = BackgroundTaskStatus.fromJson(
          allStatuses[uniqueName] as Map<String, dynamic>);
      status = status.markUnregistered();
      // Clear notification IDs on cancel
      status = status.copyWith(
        scheduledNotificationIds: [],
        remainingNotifications: 0,
      );
      allStatuses[uniqueName] = status.toJson();
      await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
    }

    await refreshStatuses();
  }

  /// Pause a periodic task (cancels it and marks as paused)
  Future<void> pauseTask(String uniqueName) async {
    // Cancel iOS notifications regardless of task definition (handles orphaned tasks)
    if (Platform.isIOS) {
      final scheduler = IOSNotificationScheduler();
      await scheduler.cancelAllNotificationsForTask(uniqueName);
    }

    await Workmanager().cancelByUniqueName(uniqueName);
    await markTaskPaused(uniqueName);
    await refreshStatuses();
  }

  /// Resume a paused task (re-registers it)
  Future<void> resumeTask(String uniqueName) async {
    var task = tasks.where((t) => t.uniqueName == uniqueName).firstOrNull;
    if (task != null) {
      if ((task.type == BackgroundWorkManagerTaskType.periodic ||
              task.type == BackgroundWorkManagerTaskType.notificationTriggered) &&
          Platform.isIOS) {
        // iOS: reschedule notifications
        final config = task.iosScheduleConfig ??
            IOSNotificationScheduleConfig.fromFrequency(
                task.frequency ?? const Duration(hours: 1));
        final scheduler = IOSNotificationScheduler();
        await scheduler.scheduleInitialNotifications(task, config,
            remindersCount: task.iosRemindersNumber);
        await markTaskRegistered(uniqueName);
      } else {
        // Android: standard re-registration using copyWith to avoid mutation
        final taskWithCancel = task.copyWith(cancelPrevious: true);
        await taskWithCancel.register();
      }
    }
    await refreshStatuses();
  }

  /// Remove a task completely (cancels and clears all history)
  Future<void> removeTask(String uniqueName) async {
    // Cancel iOS notifications regardless of task definition (handles orphaned tasks)
    if (Platform.isIOS) {
      final scheduler = IOSNotificationScheduler();
      await scheduler.cancelAllNotificationsForTask(uniqueName);
    }

    await Workmanager().cancelByUniqueName(uniqueName);
    await removeTaskStatus(uniqueName);

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

  /// Run a task immediately in the foreground
  Future<bool> runTaskNow(String uniqueName) async {
    var task = getTaskDefinition(uniqueName);
    if (task == null) return false;
    final success = await executeTaskNow(task);
    await refreshStatuses();
    return success;
  }
}
