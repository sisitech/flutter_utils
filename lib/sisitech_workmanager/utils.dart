import 'dart:convert';
import 'dart:io';

import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'ios_notification_scheduler.dart';
import 'models.dart';

enum BackgroundWorkManagerTaskType { oneOff, periodic, notificationTriggered }

/// Represents a single background task and implements / copies all the fields
/// required when starting a `oneOff` or `periodic` task.
///
class BackgroundWorkManagerTask {
  /// Required by workmanager and must be unique across your tasks
  final String uniqueName;

  /// The name that is sent to callback dispatcher
  final String name;

  /// Useful only for `periodic` type and must be greater than
  /// 15 minutes as required on android
  final Duration? frequency;
  final Duration initialDelay;
  final BackgroundWorkManagerTaskType type;
  final String? tag;
  final Map<String, dynamic>? inputData;
  final bool removeAndCleanupTasks;
  final ExistingWorkPolicy? existingWorkPolicy;
  final ExistingPeriodicWorkPolicy? existingPeriodicWorkPolicy;
  final Constraints? constraints;
  final BackoffPolicy? backoffPolicy;
  final Duration backoffPolicyDelay;
  final OutOfQuotaPolicy? outOfQuotaPolicy;
  final bool cancelPrevious;

  /// iOS-specific: Schedule configuration for notification-triggered tasks
  final IOSNotificationScheduleConfig? iosScheduleConfig;

  /// iOS-specific: Custom notification title (defaults to task name)
  final String? iosNotificationTitle;

  /// iOS-specific: Custom notification body
  final String? iosNotificationBody;

  /// iOS-specific: Number of notification reminders to schedule (default: 5)
  final int? iosRemindersNumber;

  /// Function executed by the callback dispatcher
  /// Make sure all the required plugins are loaded in
  /// the `commonTasksInitalizations` or within this function
  final Future<bool> Function(
    BackgroundWorkManagerTask task,
    Map<String, dynamic>? inputData,
  ) executeFunction;

  const BackgroundWorkManagerTask({
    required this.uniqueName,
    required this.name,
    required this.type,
    this.backoffPolicyDelay = Duration.zero,
    this.initialDelay = Duration.zero,
    this.cancelPrevious = false,
    this.existingWorkPolicy,
    this.existingPeriodicWorkPolicy,
    this.outOfQuotaPolicy,
    this.removeAndCleanupTasks = false,
    this.backoffPolicy,
    this.constraints,
    this.inputData,
    this.tag,
    required this.executeFunction,
    this.frequency,
    this.iosScheduleConfig,
    this.iosNotificationTitle,
    this.iosNotificationBody,
    this.iosRemindersNumber,
  });

  /// Create a copy of this task with some fields replaced
  BackgroundWorkManagerTask copyWith({
    String? uniqueName,
    String? name,
    Duration? frequency,
    Duration? initialDelay,
    BackgroundWorkManagerTaskType? type,
    String? tag,
    Map<String, dynamic>? inputData,
    bool? removeAndCleanupTasks,
    ExistingWorkPolicy? existingWorkPolicy,
    ExistingPeriodicWorkPolicy? existingPeriodicWorkPolicy,
    Constraints? constraints,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    OutOfQuotaPolicy? outOfQuotaPolicy,
    bool? cancelPrevious,
    IOSNotificationScheduleConfig? iosScheduleConfig,
    String? iosNotificationTitle,
    String? iosNotificationBody,
    int? iosRemindersNumber,
    Future<bool> Function(BackgroundWorkManagerTask, Map<String, dynamic>?)?
        executeFunction,
  }) {
    return BackgroundWorkManagerTask(
      uniqueName: uniqueName ?? this.uniqueName,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      initialDelay: initialDelay ?? this.initialDelay,
      type: type ?? this.type,
      tag: tag ?? this.tag,
      inputData: inputData ?? this.inputData,
      removeAndCleanupTasks:
          removeAndCleanupTasks ?? this.removeAndCleanupTasks,
      existingWorkPolicy: existingWorkPolicy ?? this.existingWorkPolicy,
      existingPeriodicWorkPolicy:
          existingPeriodicWorkPolicy ?? this.existingPeriodicWorkPolicy,
      constraints: constraints ?? this.constraints,
      backoffPolicy: backoffPolicy ?? this.backoffPolicy,
      backoffPolicyDelay: backoffPolicyDelay ?? this.backoffPolicyDelay,
      outOfQuotaPolicy: outOfQuotaPolicy ?? this.outOfQuotaPolicy,
      cancelPrevious: cancelPrevious ?? this.cancelPrevious,
      iosScheduleConfig: iosScheduleConfig ?? this.iosScheduleConfig,
      iosNotificationTitle: iosNotificationTitle ?? this.iosNotificationTitle,
      iosNotificationBody: iosNotificationBody ?? this.iosNotificationBody,
      iosRemindersNumber: iosRemindersNumber ?? this.iosRemindersNumber,
      executeFunction: executeFunction ?? this.executeFunction,
    );
  }

  String getUniqueIdHash() {
    return "${name}${uniqueName}${type}${existingWorkPolicy}${cancelPrevious}${constraints}${inputData}"
        .md5Hash;
  }

  Future<void> cancel() async {
    // Cancel iOS notifications if this is a periodic or notification-triggered task on iOS
    if ((type == BackgroundWorkManagerTaskType.periodic ||
            type == BackgroundWorkManagerTaskType.notificationTriggered) &&
        Platform.isIOS) {
      final scheduler = IOSNotificationScheduler();
      await scheduler.cancelAllNotificationsForTask(uniqueName);
    }
    return Workmanager().cancelByUniqueName(uniqueName);
  }

  Future<void> register() async {
    return registerTask(this);
  }
}

/// Used to generate the main callbackDispatcher
/// and map the execute functions based on the name
/// Call the `commonTasksInitalizations` if provided
///
/// **Parameters**
/// - [tasks]: A list of `BackgroundWorkManagerTask` tasks
/// - [commonTasksInitalizations]: A function to initialize the required libraries for all the tasks
///
/// **Example Usage**:
/// ``` dart
/// @pragma('vm:entry-point')
/// void callbackDispatcher() async {
///  return getCallbackDispathcer(
///   tasks,
///   commonTasksInitalizations: () async {
///     await GetStorage.init();
///   },
/// );
/// }
@pragma('vm:entry-point')
void getCallbackDispathcer(
  List<BackgroundWorkManagerTask> tasks, {
  Future<void> Function()? commonTasksInitalizations,
}) {
  Workmanager().executeTask((taskName, inputData) async {
    final startTime = DateTime.now();
    bool success = false;
    String? errorMessage;

    try {
      var task =
          tasks.where((element) => element.name == taskName).singleOrNull;
      if (task == null) return Future.value(true);

      if (commonTasksInitalizations != null) {
        await commonTasksInitalizations();
      }

      // Mark task as running
      await _markTaskRunning(task.uniqueName, true);

      // Execute the task
      var res = await task.executeFunction(task, inputData);
      success = res;

      // Mark task as finished
      await _markTaskRunning(task.uniqueName, false);

      // Track execution (GetStorage should be initialized in commonTasksInitalizations)
      await _trackTaskExecution(
        task.uniqueName,
        taskName,
        task.type,
        task.frequency,
        startTime,
        success,
        null,
      );

      return Future.value(res);
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      errorMessage = e.toString();

      // Try to track the failed execution
      try {
        var task =
            tasks.where((element) => element.name == taskName).singleOrNull;
        if (task != null) {
          // Mark task as finished
          await _markTaskRunning(task.uniqueName, false);
          await _trackTaskExecution(
            task.uniqueName,
            taskName,
            task.type,
            task.frequency,
            startTime,
            false,
            errorMessage,
          );
        }
      } catch (_) {
        // Ignore tracking errors
      }

      return Future.value(true);
    }
  });
}

/// Mark a task as currently running
Future<void> _markTaskRunning(String uniqueName, bool isRunning) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    String? jsonStr = prefs.getString(taskStatusStorageName);
    Map<String, dynamic> allStatuses =
        jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

    if (allStatuses.containsKey(uniqueName)) {
      var status = BackgroundTaskStatus.fromJson(
          allStatuses[uniqueName] as Map<String, dynamic>);
      status = isRunning ? status.markRunning() : status.markFinished();
      allStatuses[uniqueName] = status.toJson();
      await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
    }
  } catch (e) {
    print("Error marking task running state: $e");
  }
}

/// Track task execution in storage (called from background isolate)
Future<void> _trackTaskExecution(
  String uniqueName,
  String name,
  BackgroundWorkManagerTaskType type,
  Duration? frequency,
  DateTime startTime,
  bool success,
  String? errorMessage,
) async {
  print("_trackTaskExecution called for task: $name (uniqueName: $uniqueName)");
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    print("[$name] SharedPreferences obtained");
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    // Create execution record
    final record = TaskExecutionRecord(
      executedAt: startTime,
      success: success,
      errorMessage: errorMessage,
      duration: duration,
    );

    // Get existing status or create new one
    String? jsonStr = prefs.getString(taskStatusStorageName);
    Map<String, dynamic> allStatuses =
        jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

    BackgroundTaskStatus status;
    if (allStatuses.containsKey(uniqueName)) {
      status = BackgroundTaskStatus.fromJson(
          allStatuses[uniqueName] as Map<String, dynamic>);
    } else {
      status = BackgroundTaskStatus(
        uniqueName: uniqueName,
        name: name,
        type: type,
        frequency: frequency,
        isRegistered: true,
      );
    }

    // Add execution record
    status = status.addExecutionRecord(record);

    // Save to storage
    allStatuses[uniqueName] = status.toJson();
    await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
    print("[$name] Data saved to SharedPreferences successfully");
  } catch (e, stackTrace) {
    print("[$name] Error tracking task execution: $e");
    print("[$name] StackTrace: $stackTrace");
  }
}

/// Execute a task immediately with full status tracking.
/// Returns true if the task executed successfully, false otherwise.
Future<bool> executeTaskNow(BackgroundWorkManagerTask task) async {
  final startTime = DateTime.now();
  bool success = false;
  String? errorMessage;

  try {
    await _markTaskRunning(task.uniqueName, true);
    success = await task.executeFunction(task, task.inputData);
    await _markTaskRunning(task.uniqueName, false);
    await _trackTaskExecution(
      task.uniqueName,
      task.name,
      task.type,
      task.frequency,
      startTime,
      success,
      null,
    );
  } catch (e, stackTrace) {
    dprint("executeTaskNow error: $e");
    dprint(stackTrace.toString());
    errorMessage = e.toString();
    await _markTaskRunning(task.uniqueName, false);
    await _trackTaskExecution(
      task.uniqueName,
      task.name,
      task.type,
      task.frequency,
      startTime,
      false,
      errorMessage,
    );
  }
  return success;
}

/// Execute a one-off task immediately on iOS (fire-and-forget)
/// This runs the task without using WorkManager since iOS WorkManager is unreliable
Future<void> _executeOneOffTaskIOS(BackgroundWorkManagerTask task) async {
  await executeTaskNow(task);
}

Future<void> registerTask(BackgroundWorkManagerTask task) async {
  final prefs = await SharedPreferences.getInstance();

  if (task.removeAndCleanupTasks) {
    await task.cancel();

    // Cancel iOS notifications if applicable (task.cancel() already handles this,
    // but keep for explicit cleanup)
    if ((task.type == BackgroundWorkManagerTaskType.periodic ||
            task.type == BackgroundWorkManagerTaskType.notificationTriggered) &&
        Platform.isIOS) {
      final scheduler = IOSNotificationScheduler();
      await scheduler.cancelAllNotificationsForTask(task.uniqueName);
    }

    // Update task status as unregistered
    await _updateTaskRegistrationStatus(task, isRegistered: false);
    return;
  }

  // Check if task already registered using taskStatusStorageName
  if (task.cancelPrevious) {
    await task.cancel();
    // Cancel iOS notifications if applicable (task.cancel() already handles this,
    // but keep for explicit cleanup)
    if ((task.type == BackgroundWorkManagerTaskType.periodic ||
            task.type == BackgroundWorkManagerTaskType.notificationTriggered) &&
        Platform.isIOS) {
      final scheduler = IOSNotificationScheduler();
      await scheduler.cancelAllNotificationsForTask(task.uniqueName);
    }
  }

  // Check registration status from taskStatusStorageName
  String? statusJson = prefs.getString(taskStatusStorageName);
  Map<String, dynamic> allStatuses =
      statusJson != null ? jsonDecode(statusJson) as Map<String, dynamic> : {};
  bool isAlreadyRegistered = false;
  bool isAlreadyPaused = false;
  if (allStatuses.containsKey(task.uniqueName)) {
    var status = BackgroundTaskStatus.fromJson(
        allStatuses[task.uniqueName] as Map<String, dynamic>);
    isAlreadyRegistered = status.isRegistered;
    isAlreadyPaused = status.isPaused;
  }

  if ((isAlreadyRegistered || isAlreadyPaused) && !task.cancelPrevious) {
    dprint("Already registered or paused, skipping");
    return;
  }

  dprint("REGISTERING NEW");
  if (task.type == BackgroundWorkManagerTaskType.oneOff) {
    if (Platform.isIOS) {
      // iOS: Execute immediately (fire-and-forget) - don't use WorkManager
      // ignore: unawaited_futures
      _executeOneOffTaskIOS(task);
    } else {
      // Android: Use WorkManager
      Workmanager().registerOneOffTask(
        task.uniqueName,
        task.name,
        initialDelay: task.initialDelay,
        inputData: task.inputData,
        existingWorkPolicy: task.existingWorkPolicy,
        constraints: task.constraints,
        backoffPolicy: task.backoffPolicy,
        tag: task.tag,
        backoffPolicyDelay: task.backoffPolicyDelay,
        outOfQuotaPolicy: task.outOfQuotaPolicy,
      );
    }
  } else if (task.type == BackgroundWorkManagerTaskType.periodic) {
    if (Platform.isIOS) {
      // iOS: use notification-triggered approach with auto-generated config from frequency
      final config = task.iosScheduleConfig ??
          IOSNotificationScheduleConfig.fromFrequency(
              task.frequency ?? const Duration(hours: 1));
      final scheduler = IOSNotificationScheduler();
      await scheduler.scheduleInitialNotifications(task, config,
          remindersCount: task.iosRemindersNumber);
    } else {
      // Android: use standard workmanager
      Workmanager().registerPeriodicTask(
        task.uniqueName,
        task.name,
        frequency: task.frequency,
        initialDelay: task.initialDelay,
        inputData: task.inputData,
        existingWorkPolicy: task.existingPeriodicWorkPolicy,
        constraints: task.constraints,
        backoffPolicy: task.backoffPolicy,
        tag: task.tag,
        backoffPolicyDelay: task.backoffPolicyDelay,
      );
    }
  } else if (task.type == BackgroundWorkManagerTaskType.notificationTriggered) {
    // iOS notification-triggered tasks
    if (Platform.isIOS) {
      if (task.iosScheduleConfig == null) {
        dprint(
            "Error: notificationTriggered task requires iosScheduleConfig on iOS");
        return;
      }
      final scheduler = IOSNotificationScheduler();
      await scheduler.scheduleInitialNotifications(task, task.iosScheduleConfig!,
          remindersCount: task.iosRemindersNumber);
    } else {
      // On Android, fall back to periodic task behavior
      dprint(
          "notificationTriggered task registered as periodic on Android");
      Workmanager().registerPeriodicTask(
        task.uniqueName,
        task.name,
        frequency: task.frequency ?? const Duration(hours: 24),
        initialDelay: task.initialDelay,
        inputData: task.inputData,
        existingWorkPolicy: task.existingPeriodicWorkPolicy,
        constraints: task.constraints,
        backoffPolicy: task.backoffPolicy,
        tag: task.tag,
        backoffPolicyDelay: task.backoffPolicyDelay,
      );
    }
  }

  // Track task status
  await _updateTaskRegistrationStatus(task, isRegistered: true);
}

/// Update task registration status in storage
Future<void> _updateTaskRegistrationStatus(
  BackgroundWorkManagerTask task, {
  required bool isRegistered,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    String? jsonStr = prefs.getString(taskStatusStorageName);
    Map<String, dynamic> allStatuses =
        jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

    BackgroundTaskStatus status;
    if (allStatuses.containsKey(task.uniqueName)) {
      status = BackgroundTaskStatus.fromJson(
          allStatuses[task.uniqueName] as Map<String, dynamic>);
    } else {
      status = BackgroundTaskStatus.fromTask(task);
    }

    if (isRegistered) {
      status = status.markRegistered();
    } else {
      status = status.markUnregistered();
    }

    allStatuses[task.uniqueName] = status.toJson();
    await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
  } catch (e) {
    dprint("Error updating task registration status: $e");
  }
}

// ============================================================================
// Task Status Helper Functions
// ============================================================================

/// Get status for a specific task
Future<BackgroundTaskStatus?> getTaskStatus(String uniqueName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  String? jsonStr = prefs.getString(taskStatusStorageName);
  Map<String, dynamic> allStatuses =
      jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

  if (allStatuses.containsKey(uniqueName)) {
    return BackgroundTaskStatus.fromJson(
        allStatuses[uniqueName] as Map<String, dynamic>);
  }
  return null;
}

/// Get all task statuses
Future<List<BackgroundTaskStatus>> getAllTaskStatuses() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload(); // Force reload from disk to get cross-isolate updates
  String? jsonStr = prefs.getString(taskStatusStorageName);
  Map<String, dynamic> allStatuses =
      jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

  return allStatuses.entries
      .map((e) =>
          BackgroundTaskStatus.fromJson(e.value as Map<String, dynamic>))
      .toList();
}

/// Clear execution history for a task
Future<void> clearTaskHistory(String uniqueName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  String? jsonStr = prefs.getString(taskStatusStorageName);
  Map<String, dynamic> allStatuses =
      jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

  if (allStatuses.containsKey(uniqueName)) {
    var status = BackgroundTaskStatus.fromJson(
        allStatuses[uniqueName] as Map<String, dynamic>);
    status = status.copyWith(
      history: [],
      executionCount: 0,
      successCount: 0,
      failureCount: 0,
    );
    allStatuses[uniqueName] = status.toJson();
    await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
  }
}

/// Remove a task status completely
Future<void> removeTaskStatus(String uniqueName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  String? jsonStr = prefs.getString(taskStatusStorageName);
  Map<String, dynamic> allStatuses =
      jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

  if (allStatuses.containsKey(uniqueName)) {
    allStatuses.remove(uniqueName);
    await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
  }
}

/// Mark a task as paused in storage
Future<void> markTaskPaused(String uniqueName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  String? jsonStr = prefs.getString(taskStatusStorageName);
  Map<String, dynamic> allStatuses =
      jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

  if (allStatuses.containsKey(uniqueName)) {
    var status = BackgroundTaskStatus.fromJson(
        allStatuses[uniqueName] as Map<String, dynamic>);
    status = status.markPaused();
    allStatuses[uniqueName] = status.toJson();
    await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
  }
}

/// Mark a task as registered (resumed) in storage
Future<void> markTaskRegistered(String uniqueName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  String? jsonStr = prefs.getString(taskStatusStorageName);
  Map<String, dynamic> allStatuses =
      jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

  if (allStatuses.containsKey(uniqueName)) {
    var status = BackgroundTaskStatus.fromJson(
        allStatuses[uniqueName] as Map<String, dynamic>);
    status = status.markRegistered();
    allStatuses[uniqueName] = status.toJson();
    await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
  }
}
