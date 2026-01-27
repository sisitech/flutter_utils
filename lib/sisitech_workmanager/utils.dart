import 'dart:convert';

import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'models.dart';

enum BackgroundWorkManagerTaskType { oneOff, periodic }

const tasksStorageName = "BackgroundTasks";

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
  Duration initialDelay;
  final BackgroundWorkManagerTaskType type;
  final String? tag;
  Map<String, dynamic>? inputData;
  bool removeAndCleanupTasks;
  ExistingWorkPolicy? existingWorkPolicy;
  ExistingPeriodicWorkPolicy? existingPeriodicWorkPolicy;
  Constraints? constraints;
  BackoffPolicy? backoffPolicy;
  Duration backoffPolicyDelay;
  OutOfQuotaPolicy? outOfQuotaPolicy;
  bool cancelPrevious;

  /// Function executed by the callback dispatcher
  /// Make sure all the required plugins are loaded in
  /// the `commonTasksInitalizations` or within this function
  final Future<bool> Function(
    BackgroundWorkManagerTask task,
    Map<String, dynamic>? inputData,
  ) executeFunction;

  BackgroundWorkManagerTask({
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
  });

  String getUniqueIdHash() {
    return "${name}${uniqueName}${type}${existingWorkPolicy}${cancelPrevious}${constraints}${inputData}"
        .md5Hash;
  }

  Future<void> cancel() async {
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

Future<void> registerTask(BackgroundWorkManagerTask task) async {
  final prefs = await SharedPreferences.getInstance();

  if (task.removeAndCleanupTasks) {
    await task.cancel();
    String? jsonStr = prefs.getString(tasksStorageName);
    Map<String, dynamic> readAllTasks =
        jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};
    bool isAlreadyRegistered = readAllTasks.containsKey(task.getUniqueIdHash());
    if (isAlreadyRegistered) {
      readAllTasks.remove(task.getUniqueIdHash());
      await prefs.setString(tasksStorageName, jsonEncode(readAllTasks));
    }
    // Update task status as unregistered
    await _updateTaskRegistrationStatus(task, isRegistered: false);
    return;
  }

  // Check if task already registered
  if (task.cancelPrevious) {
    await task.cancel();
  }
  String? jsonStr = prefs.getString(tasksStorageName);
  Map<String, dynamic> readAllTasks =
      jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};
  bool isAlreadyRegistered = readAllTasks.containsKey(task.getUniqueIdHash());

  if (isAlreadyRegistered && !task.cancelPrevious) {
    dprint("Already registered");
    return;
  }

  dprint("REGISTERING NEW");
  if (task.type == BackgroundWorkManagerTaskType.oneOff) {
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
  } else if (task.type == BackgroundWorkManagerTaskType.periodic) {
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

  // Track legacy registration
  String? tasksJson = prefs.getString(tasksStorageName);
  Map<String, dynamic> allTasks =
      tasksJson != null ? jsonDecode(tasksJson) as Map<String, dynamic> : {};
  allTasks[task.getUniqueIdHash()] = "true";
  await prefs.setString(tasksStorageName, jsonEncode(allTasks));

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
