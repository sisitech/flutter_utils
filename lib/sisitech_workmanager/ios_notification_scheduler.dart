import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/local_nofitications/local_notification_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'models.dart';
import 'utils.dart';

/// Scheduler for iOS notification-triggered background tasks.
/// Manages a queue of 5 scheduled notifications that trigger work execution.
class IOSNotificationScheduler {
  static const int notificationQueueSize = 5;

  /// Base notification ID offset for WorkManager notifications
  /// Using high numbers to avoid conflicts with app notifications
  static const int notificationIdBase = 900000;

  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  IOSNotificationScheduler({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
            notificationsPlugin ?? LocalNotificationController.notificationsPlugin;

  /// Ensure timezone is initialized
  static bool _timezoneInitialized = false;
  static Future<void> _ensureTimezoneInitialized() async {
    if (!_timezoneInitialized) {
      tz_data.initializeTimeZones();
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
      _timezoneInitialized = true;
    }
  }

  /// Schedule initial notifications for a task
  /// Returns the list of scheduled notification IDs
  /// [remindersCount] - Optional number of notifications to schedule (default: 5)
  Future<List<int>> scheduleInitialNotifications(
    BackgroundWorkManagerTask task,
    IOSNotificationScheduleConfig config, {
    int? remindersCount,
  }) async {
    if (!Platform.isIOS) {
      dprint("IOSNotificationScheduler: Only runs on iOS");
      return [];
    }

    final queueSize = remindersCount ?? notificationQueueSize;
    await _ensureTimezoneInitialized();
    final notificationIds = <int>[];
    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < queueSize; i++) {
      final scheduledDate = _calculateNextScheduleDate(config, now, i);
      final notificationId = _generateNotificationId(task.uniqueName, i);

      await _scheduleNotification(
        notificationId: notificationId,
        task: task,
        scheduledDate: scheduledDate,
      );

      notificationIds.add(notificationId);
    }

    // Update task status with notification IDs
    await _updateTaskNotificationStatus(
      task.uniqueName,
      notificationIds,
      queueSize,
      config,
      queueSize,
    );

    dprint(
        "IOSNotificationScheduler: Scheduled $queueSize notifications for ${task.uniqueName}");
    return notificationIds;
  }

  /// Schedule the next notification after one was consumed (by "Run Now" action)
  /// Returns the new notification ID, or null if scheduling failed
  Future<int?> scheduleNextNotification(
    BackgroundWorkManagerTask task,
    IOSNotificationScheduleConfig config,
    int currentIndex,
  ) async {
    if (!Platform.isIOS) return null;

    await _ensureTimezoneInitialized();
    final now = tz.TZDateTime.now(tz.local);
    // Schedule for notificationQueueSize intervals ahead
    final scheduledDate =
        _calculateNextScheduleDate(config, now, notificationQueueSize - 1);
    final notificationId = _generateNotificationId(task.uniqueName, currentIndex);

    await _scheduleNotification(
      notificationId: notificationId,
      task: task,
      scheduledDate: scheduledDate,
    );

    dprint(
        "IOSNotificationScheduler: Scheduled next notification $notificationId for ${task.uniqueName}");
    return notificationId;
  }

  /// Cancel all scheduled notifications for a task
  Future<void> cancelAllNotifications(List<int> notificationIds) async {
    for (final id in notificationIds) {
      await _notificationsPlugin.cancel(id);
    }
    dprint(
        "IOSNotificationScheduler: Cancelled ${notificationIds.length} notifications");
  }

  /// Cancel all notifications for a task by deriving IDs from uniqueName
  /// More robust than relying on stored IDs - works even if status is corrupted
  Future<void> cancelNotificationsByUniqueName(String uniqueName, {int maxIndex = 20}) async {
    final hash = uniqueName.hashCode.abs() % 100000;
    for (int i = 0; i < maxIndex; i++) {
      final notificationId = notificationIdBase + hash + i;
      await _notificationsPlugin.cancel(notificationId);
    }
    dprint("IOSNotificationScheduler: Cancelled up to $maxIndex notifications for $uniqueName (derived IDs)");
  }

  /// Cancel all notifications for a task by unique name
  /// Uses derived IDs - works even if status is corrupted
  Future<void> cancelAllNotificationsForTask(String uniqueName) async {
    await cancelNotificationsByUniqueName(uniqueName);
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int notificationId,
    required BackgroundWorkManagerTask task,
    required tz.TZDateTime scheduledDate,
  }) async {
    final title = task.iosNotificationTitle ?? task.name;
    final body = task.iosNotificationBody ?? 'Tap to run background task';

    // Create payload with task identification
    final payload = jsonEncode({
      'type': WorkManagerNotificationHandler.payloadType,
      'taskUniqueName': task.uniqueName,
      'taskName': task.name,
      'notificationId': notificationId,
    });

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: workManagerNotificationCategoryId,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(iOS: iosDetails);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: null, // One-time notification
    );
  }

  /// Calculate the next schedule date based on config
  tz.TZDateTime _calculateNextScheduleDate(
    IOSNotificationScheduleConfig config,
    tz.TZDateTime fromDate,
    int offsetIndex,
  ) {
    // Interval-based scheduling: schedule at now + (intervalMinutes * (index + 1))
    if (config.intervalMinutes != null) {
      return fromDate.add(Duration(minutes: config.intervalMinutes! * (offsetIndex + 1)));
    }

    // Daily/weekly scheduling requires hour and minute
    final hour = config.hour ?? 0;
    final minute = config.minute ?? 0;

    // Start with the configured time today
    var scheduledDate = tz.TZDateTime(
      tz.local,
      fromDate.year,
      fromDate.month,
      fromDate.day,
      hour,
      minute,
    );

    // If it's already past this time today, start from tomorrow
    if (scheduledDate.isBefore(fromDate) ||
        scheduledDate.isAtSameMomentAs(fromDate)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Add offset based on index
    if (config.weekday != null) {
      // Weekly scheduling: add weeks
      scheduledDate = scheduledDate.add(Duration(days: 7 * offsetIndex));
      // Adjust to the correct weekday
      while (scheduledDate.weekday != config.weekday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    } else {
      // Daily scheduling: add days
      scheduledDate = scheduledDate.add(Duration(days: offsetIndex));
    }

    return scheduledDate;
  }

  /// Generate a unique notification ID for a task
  int _generateNotificationId(String uniqueName, int index) {
    // Use hash of uniqueName + index to generate consistent IDs
    final hash = uniqueName.hashCode.abs() % 100000;
    return notificationIdBase + hash + index;
  }

  /// Update task status with notification tracking info
  Future<void> _updateTaskNotificationStatus(
    String uniqueName,
    List<int> notificationIds,
    int remainingCount,
    IOSNotificationScheduleConfig config,
    int nextIndex,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    String? jsonStr = prefs.getString(taskStatusStorageName);
    Map<String, dynamic> allStatuses =
        jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

    if (allStatuses.containsKey(uniqueName)) {
      var status = BackgroundTaskStatus.fromJson(
          allStatuses[uniqueName] as Map<String, dynamic>);
      status = status.copyWith(
        scheduledNotificationIds: notificationIds,
        remainingNotifications: remainingCount,
        scheduleConfig: config,
        nextNotificationIndex: nextIndex,
      );
      allStatuses[uniqueName] = status.toJson();
      await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
    }
  }
}

/// Handler for WorkManager notification responses.
/// Checks if a notification belongs to WorkManager and handles it appropriately.
class WorkManagerNotificationHandler {
  static const String payloadType = 'sisitech_workmanager';

  /// Check if a notification response belongs to WorkManager
  static bool isWorkManagerNotification(NotificationResponse response) {
    if (response.payload == null) return false;
    try {
      final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
      return payload['type'] == payloadType;
    } catch (e) {
      return false;
    }
  }

  /// Parse the payload from a notification response
  static Map<String, dynamic>? parsePayload(NotificationResponse response) {
    if (response.payload == null) return null;
    try {
      return jsonDecode(response.payload!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Handle a notification response if it belongs to WorkManager.
  /// Returns true if the notification was handled, false if it's not a WorkManager notification.
  ///
  /// [response] - The notification response from flutter_local_notifications
  /// [tasks] - List of registered background tasks
  /// [commonTasksInitalizations] - Optional initialization function to run before task execution
  static Future<bool> handleIfWorkManager(
    NotificationResponse response,
    List<BackgroundWorkManagerTask> tasks, {
    Future<void> Function()? commonTasksInitalizations,
  }) async {
    dprint("handleIfWorkManager: Starting...");
    dprint("handleIfWorkManager: payload = ${response.payload}");
    dprint("handleIfWorkManager: actionId = ${response.actionId}");
    dprint("handleIfWorkManager: tasks count = ${tasks.length}");

    if (!isWorkManagerNotification(response)) {
      dprint("handleIfWorkManager: NOT a WorkManager notification");
      return false; // Not ours, let app handle it
    }

    dprint("handleIfWorkManager: IS a WorkManager notification");

    final payload = parsePayload(response);
    if (payload == null) {
      dprint("handleIfWorkManager: Failed to parse payload");
      return false;
    }

    dprint("handleIfWorkManager: parsed payload = $payload");

    final taskUniqueName = payload['taskUniqueName'] as String?;
    final notificationId = payload['notificationId'] as int?;

    dprint("handleIfWorkManager: taskUniqueName = $taskUniqueName");
    dprint("handleIfWorkManager: notificationId = $notificationId");

    if (taskUniqueName == null) {
      dprint("handleIfWorkManager: taskUniqueName is null");
      return false;
    }

    // Find the task
    dprint("handleIfWorkManager: Looking for task in list...");
    for (var t in tasks) {
      dprint("handleIfWorkManager: - ${t.uniqueName}");
    }

    final task = tasks
        .where((t) => t.uniqueName == taskUniqueName)
        .firstOrNull;

    if (task == null) {
      dprint("handleIfWorkManager: Task NOT found: $taskUniqueName");
      return true; // Handled (even if task not found)
    }

    dprint("handleIfWorkManager: Task FOUND: ${task.name}");

    // Check the action
    if (response.actionId == workManagerExecuteActionId ||
        response.actionId == null) {
      dprint("handleIfWorkManager: Executing task (actionId=${response.actionId})...");
      // "Run Now" was tapped or notification body was tapped
      await _executeTaskAndScheduleNext(
        task,
        notificationId,
        commonTasksInitalizations,
      );
      dprint("handleIfWorkManager: Task execution completed");
    } else if (response.actionId == workManagerDismissActionId) {
      dprint("handleIfWorkManager: Dismiss action");
      // "Dismiss" was tapped - decrement remaining count
      await _handleDismiss(taskUniqueName, notificationId);
    }

    return true;
  }

  /// Execute the task and schedule the next notification
  static Future<void> _executeTaskAndScheduleNext(
    BackgroundWorkManagerTask task,
    int? notificationId,
    Future<void> Function()? commonTasksInitalizations,
  ) async {
    dprint("_executeTaskAndScheduleNext: Starting for ${task.name}");
    final startTime = DateTime.now();
    bool success = false;
    String? errorMessage;

    try {
      // Run initializations if provided
      if (commonTasksInitalizations != null) {
        dprint("_executeTaskAndScheduleNext: Running commonTasksInitalizations...");
        await commonTasksInitalizations();
        dprint("_executeTaskAndScheduleNext: commonTasksInitalizations complete");
      }

      // Mark task as running
      dprint("_executeTaskAndScheduleNext: Marking task as running...");
      await _markTaskRunning(task.uniqueName, true);

      // Execute the task
      dprint("_executeTaskAndScheduleNext: Calling executeFunction...");
      success = await task.executeFunction(task, task.inputData);
      dprint("_executeTaskAndScheduleNext: executeFunction returned: $success");

      // Mark task as finished
      dprint("_executeTaskAndScheduleNext: Marking task as finished...");
      await _markTaskRunning(task.uniqueName, false);

      // Track execution
      dprint("_executeTaskAndScheduleNext: Tracking execution...");
      await _trackTaskExecution(
        task.uniqueName,
        task.name,
        task.type,
        task.frequency,
        startTime,
        success,
        null,
      );

      dprint(
          "WorkManagerNotificationHandler: Task ${task.name} executed, success: $success");
    } catch (e, stackTrace) {
      dprint("WorkManagerNotificationHandler: Task execution error: $e");
      dprint(stackTrace.toString());
      errorMessage = e.toString();

      // Mark task as finished
      await _markTaskRunning(task.uniqueName, false);

      // Track failed execution
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

    // Schedule the next notification for periodic or notificationTriggered tasks
    // For periodic tasks without explicit iosScheduleConfig, auto-generate from frequency
    final config = task.iosScheduleConfig ??
        (task.type == BackgroundWorkManagerTaskType.periodic
            ? IOSNotificationScheduleConfig.fromFrequency(
                task.frequency ?? const Duration(hours: 1))
            : null);

    if (config != null) {
      final scheduler = IOSNotificationScheduler();
      final status = await getTaskStatus(task.uniqueName);
      if (status != null) {
        final nextIndex = (status.nextNotificationIndex + 1) % 1000;
        final newNotificationId = await scheduler.scheduleNextNotification(
          task,
          config,
          nextIndex,
        );

        // Update status with new notification info
        await _updateNotificationStatus(
          task.uniqueName,
          status.scheduledNotificationIds,
          status.remainingNotifications,
          nextIndex,
          newNotificationId: newNotificationId,
        );
      }
    }
  }

  /// Handle dismiss action - decrement remaining notifications
  static Future<void> _handleDismiss(
    String uniqueName,
    int? notificationId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    String? jsonStr = prefs.getString(taskStatusStorageName);
    Map<String, dynamic> allStatuses =
        jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

    if (allStatuses.containsKey(uniqueName)) {
      var status = BackgroundTaskStatus.fromJson(
          allStatuses[uniqueName] as Map<String, dynamic>);

      // Remove the notification ID from the list
      final updatedIds = status.scheduledNotificationIds
          .where((id) => id != notificationId)
          .toList();

      status = status.copyWith(
        scheduledNotificationIds: updatedIds,
        remainingNotifications: status.remainingNotifications - 1,
      );

      allStatuses[uniqueName] = status.toJson();
      await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));

      dprint(
          "WorkManagerNotificationHandler: Dismissed notification, ${status.remainingNotifications} remaining");
    }
  }

  /// Mark task as running/not running
  static Future<void> _markTaskRunning(String uniqueName, bool isRunning) async {
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
      dprint("Error marking task running state: $e");
    }
  }

  /// Track task execution
  static Future<void> _trackTaskExecution(
    String uniqueName,
    String name,
    BackgroundWorkManagerTaskType type,
    Duration? frequency,
    DateTime startTime,
    bool success,
    String? errorMessage,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final record = TaskExecutionRecord(
        executedAt: startTime,
        success: success,
        errorMessage: errorMessage,
        duration: duration,
      );

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

      status = status.addExecutionRecord(record);
      allStatuses[uniqueName] = status.toJson();
      await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
    } catch (e) {
      dprint("Error tracking task execution: $e");
    }
  }

  /// Update notification status after scheduling next
  static Future<void> _updateNotificationStatus(
    String uniqueName,
    List<int> currentIds,
    int remainingCount,
    int nextIndex, {
    int? newNotificationId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    String? jsonStr = prefs.getString(taskStatusStorageName);
    Map<String, dynamic> allStatuses =
        jsonStr != null ? jsonDecode(jsonStr) as Map<String, dynamic> : {};

    if (allStatuses.containsKey(uniqueName)) {
      var status = BackgroundTaskStatus.fromJson(
          allStatuses[uniqueName] as Map<String, dynamic>);

      // Add new notification ID to the list if provided
      List<int> updatedIds = List.from(status.scheduledNotificationIds);
      if (newNotificationId != null && !updatedIds.contains(newNotificationId)) {
        updatedIds.add(newNotificationId);
      }

      status = status.copyWith(
        nextNotificationIndex: nextIndex,
        scheduledNotificationIds: updatedIds,
      );
      allStatuses[uniqueName] = status.toJson();
      await prefs.setString(taskStatusStorageName, jsonEncode(allStatuses));
    }
  }
}
