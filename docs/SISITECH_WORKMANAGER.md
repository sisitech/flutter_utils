# Sisitech Workmanager

A comprehensive wrapper around [flutter_workmanager](https://pub.dev/packages/workmanager) that provides task tracking, execution history, UI widgets, GetX integration, and pause/resume functionality for background tasks in Flutter applications.

## Key Features

- **Task Tracking**: Automatically tracks task registration, execution count, success/failure rates
- **Execution History**: Stores the last 10 execution records per task with timing and error details
- **UI Widgets**: Ready-to-use widgets for displaying and managing background tasks
- **GetX Integration**: Reactive state management with `BackgroundWorkManagerController`
- **Pause/Resume**: Pause and resume periodic tasks without losing history
- **Cross-Isolate Sync**: Task status updates from background isolates are synced to the UI

---

## Installation & Setup

### Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  workmanager: ^0.5.0
  get: ^4.6.0
  get_storage: ^2.1.0
  shared_preferences: ^2.0.0
  flutter_utils:
    path: ../  # or your path to flutter_utils
```

### Native Configuration

Follow the official workmanager setup for Android and iOS:

- **Android**: [Android Setup Guide](https://pub.dev/packages/workmanager#android-setup)
- **iOS**: [iOS Setup Guide](https://pub.dev/packages/workmanager#ios-setup)

---

## Quick Start

Here's a complete minimal example:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_utils/sisitech_workmanager/controller.dart';
import 'package:flutter_utils/sisitech_workmanager/task_manager_widget.dart';
import 'package:flutter_utils/sisitech_workmanager/utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// 1. Define your tasks
List<BackgroundWorkManagerTask> tasks = [
  BackgroundWorkManagerTask(
    uniqueName: 'sync_data',
    name: 'sync_data_task',
    type: BackgroundWorkManagerTaskType.periodic,
    frequency: Duration(minutes: 15),
    initialDelay: Duration(seconds: 10),
    executeFunction: (task, inputData) async {
      // Your background work here
      print("Syncing data...");
      return true; // Return true for success, false for failure
    },
  ),
];

// 2. Create callback dispatcher with @pragma annotation
@pragma('vm:entry-point')
void callbackDispatcher() async {
  return getCallbackDispathcer(
    tasks,
    commonTasksInitalizations: () async {
      await GetStorage.init(); // Re-init storage in background isolate
    },
  );
}

// 3. Initialize and run
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize controller with GetX
  var controller = Get.put(BackgroundWorkManagerController(
    callbackDispatcher: callbackDispatcher,
    tasks: tasks,
    isInDebugMode: true,
  ));

  await controller.initializeBackgroundWorkManager();
  await controller.registerTasks();
  await controller.loadTaskStatuses();

  runApp(MyApp());
}

// 4. Use the widget in your UI
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Background Tasks')),
        body: BackgroundTaskManagerWidget(),
      ),
    );
  }
}
```

---

## Core Concepts

### BackgroundWorkManagerTask

Represents a single background task definition. This class wraps all workmanager parameters and adds execution tracking.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `uniqueName` | `String` | Yes | - | Unique identifier for the task. Must be unique across all tasks. |
| `name` | `String` | Yes | - | Name sent to the callback dispatcher for task identification. |
| `type` | `BackgroundWorkManagerTaskType` | Yes | - | Either `oneOff` (runs once) or `periodic` (repeats). |
| `executeFunction` | `Future<bool> Function(...)` | Yes | - | The function executed when the task runs. Returns `true` for success. |
| `frequency` | `Duration?` | No | `null` | For periodic tasks. Must be >= 15 minutes on Android. |
| `initialDelay` | `Duration` | No | `Duration.zero` | Delay before the first execution. |
| `inputData` | `Map<String, dynamic>?` | No | `null` | Data passed to the executeFunction. |
| `constraints` | `Constraints?` | No | `null` | Conditions that must be met for the task to run. |
| `backoffPolicy` | `BackoffPolicy?` | No | `null` | Retry behavior on failure (`linear` or `exponential`). |
| `backoffPolicyDelay` | `Duration` | No | `Duration.zero` | Initial delay for backoff retries. |
| `cancelPrevious` | `bool` | No | `false` | If `true`, cancels any existing task with the same uniqueName before registering. |
| `removeAndCleanupTasks` | `bool` | No | `false` | If `true`, removes the task and cleans up storage instead of registering. |
| `tag` | `String?` | No | `null` | Optional tag for grouping tasks. |
| `existingWorkPolicy` | `ExistingWorkPolicy?` | No | `null` | Policy for one-off tasks when a task with the same name exists. |
| `existingPeriodicWorkPolicy` | `ExistingPeriodicWorkPolicy?` | No | `null` | Policy for periodic tasks when a task with the same name exists. |
| `outOfQuotaPolicy` | `OutOfQuotaPolicy?` | No | `null` | Behavior when the system quota is exceeded (Android 12+). |

#### Execute Function Signature

```dart
Future<bool> Function(
  BackgroundWorkManagerTask task,
  Map<String, dynamic>? inputData,
)
```

- **task**: The task definition, useful for accessing task properties
- **inputData**: Data passed when registering the task
- **Returns**: `true` for success, `false` for failure (tracked in history)

#### Task Types

**One-Off Task** - Runs once and completes:

```dart
BackgroundWorkManagerTask(
  uniqueName: 'upload_logs',
  name: 'upload_logs_task',
  type: BackgroundWorkManagerTaskType.oneOff,
  initialDelay: Duration(seconds: 30),
  executeFunction: (task, inputData) async {
    await uploadPendingLogs();
    return true;
  },
)
```

**Periodic Task** - Repeats at the specified frequency:

```dart
BackgroundWorkManagerTask(
  uniqueName: 'sync_data',
  name: 'sync_data_task',
  type: BackgroundWorkManagerTaskType.periodic,
  frequency: Duration(minutes: 15), // Minimum 15 minutes on Android
  initialDelay: Duration(minutes: 1),
  executeFunction: (task, inputData) async {
    await syncWithServer();
    return true;
  },
)
```

#### Methods

| Method | Description |
|--------|-------------|
| `register()` | Registers the task with workmanager |
| `cancel()` | Cancels the task by uniqueName |
| `getUniqueIdHash()` | Returns a hash used for detecting task configuration changes |

---

### BackgroundWorkManagerController

The main GetX controller for managing background tasks. Provides reactive state and UI integration.

#### Constructor

```dart
BackgroundWorkManagerController({
  required Function callbackDispatcher,
  required List<BackgroundWorkManagerTask> tasks,
  bool? isInDebugMode,
})
```

| Parameter | Description |
|-----------|-------------|
| `callbackDispatcher` | The top-level function annotated with `@pragma('vm:entry-point')` |
| `tasks` | List of task definitions |
| `isInDebugMode` | Enables debug logging. Defaults to `kDebugMode`. |

#### Observable Properties

| Property | Type | Description |
|----------|------|-------------|
| `taskStatuses` | `RxList<BackgroundTaskStatus>` | Reactive list of all task statuses |
| `isLoading` | `RxBool` | Loading state for UI feedback |

#### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `initializeBackgroundWorkManager()` | `Future<void>` | Initializes workmanager with the callback dispatcher |
| `registerTasks()` | `Future<void>` | Registers all tasks defined in the controller |
| `loadTaskStatuses()` | `Future<void>` | Loads task statuses from storage |
| `refreshStatuses()` | `Future<void>` | Reloads statuses from disk (syncs background updates) |
| `cancelTask(String uniqueName)` | `Future<void>` | Cancels a specific task and marks it as unregistered |
| `pauseTask(String uniqueName)` | `Future<void>` | Pauses a periodic task (cancels but marks as paused) |
| `resumeTask(String uniqueName)` | `Future<void>` | Resumes a paused task by re-registering it |
| `removeTask(String uniqueName)` | `Future<void>` | Removes a task completely (cancels and clears history) |
| `clearHistory(String uniqueName)` | `Future<void>` | Clears execution history for a task |
| `cancelAll()` | `Future<void>` | Cancels all tasks and clears storage |
| `getTaskStatusByName(String)` | `BackgroundTaskStatus?` | Gets status for a specific task |
| `getTaskDefinition(String)` | `BackgroundWorkManagerTask?` | Gets task definition by uniqueName |
| `isTaskScheduled(String)` | `Future<bool>` | Checks if a task is currently scheduled (native API) |

---

### BackgroundTaskStatus

Represents the current status and execution history of a background task.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `uniqueName` | `String` | Task unique identifier |
| `name` | `String` | Task name |
| `type` | `BackgroundWorkManagerTaskType` | oneOff or periodic |
| `isRegistered` | `bool` | Whether the task is currently registered |
| `isPaused` | `bool` | Whether the task is paused |
| `isRunning` | `bool` | Whether the task is currently executing |
| `registeredAt` | `DateTime?` | When the task was registered |
| `lastExecutedAt` | `DateTime?` | When the task last ran |
| `nextScheduledRun` | `DateTime?` | Estimated next run (for periodic tasks) |
| `executionCount` | `int` | Total number of executions |
| `successCount` | `int` | Number of successful executions |
| `failureCount` | `int` | Number of failed executions |
| `frequency` | `Duration?` | Task frequency (for periodic tasks) |
| `history` | `List<TaskExecutionRecord>` | Last 10 execution records |

### TaskExecutionRecord

Represents a single execution of a task.

| Property | Type | Description |
|----------|------|-------------|
| `executedAt` | `DateTime` | When the execution started |
| `success` | `bool` | Whether it succeeded |
| `errorMessage` | `String?` | Error message if failed |
| `duration` | `Duration` | How long the execution took |

---

## UI Widgets

### BackgroundTaskManagerWidget

A widget that displays all registered tasks with their status, stats, and action buttons.

```dart
BackgroundTaskManagerWidget(
  controllerTag: null,        // Optional tag if using multiple controllers
  showRefreshButton: true,    // Show/hide the refresh button
  shrinkWrap: false,          // ListView shrinkWrap property
  physics: null,              // Custom scroll physics
)
```

**Features:**
- Displays task status with visual indicators (running, paused, registered, stopped)
- Shows task type badge (Periodic / One-Off)
- Execution statistics (total, success, failure counts)
- Last/next execution times
- Action buttons: Pause, Resume, Cancel, View History, Clear History, Remove

### BackgroundTaskManagerPage

A full-page scaffold wrapper for the task manager widget.

```dart
BackgroundTaskManagerPage(
  controllerTag: null,
  title: 'Background Tasks',
)
```

**Usage:**

```dart
// Navigate to task manager page
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => BackgroundTaskManagerPage()),
);

// Or with GetX
Get.to(() => BackgroundTaskManagerPage());
```

### TaskHistoryBottomSheet

Displays execution history in a draggable bottom sheet (used internally by `BackgroundTaskManagerWidget`).

---

## Advanced Usage

### Custom Constraints

Use constraints to control when tasks can run:

```dart
BackgroundWorkManagerTask(
  uniqueName: 'sync_on_wifi',
  name: 'sync_on_wifi_task',
  type: BackgroundWorkManagerTaskType.periodic,
  frequency: Duration(hours: 1),
  constraints: Constraints(
    networkType: NetworkType.unmetered,  // WiFi only
    requiresBatteryNotLow: true,
    requiresCharging: false,
    requiresStorageNotLow: true,
    requiresDeviceIdle: false,
  ),
  executeFunction: (task, inputData) async {
    await heavyDataSync();
    return true;
  },
)
```

### Passing Input Data

Pass data to your task when registering:

```dart
BackgroundWorkManagerTask(
  uniqueName: 'upload_file',
  name: 'upload_file_task',
  type: BackgroundWorkManagerTaskType.oneOff,
  inputData: {
    'filePath': '/path/to/file.pdf',
    'userId': 12345,
  },
  executeFunction: (task, inputData) async {
    String filePath = inputData?['filePath'];
    int userId = inputData?['userId'];
    await uploadFile(filePath, userId);
    return true;
  },
)
```

### Background Isolate Considerations

Background tasks run in a separate isolate. You must re-initialize any dependencies:

```dart
@pragma('vm:entry-point')
void callbackDispatcher() async {
  return getCallbackDispathcer(
    tasks,
    commonTasksInitalizations: () async {
      // Re-initialize in background isolate
      await GetStorage.init();
      // SharedPreferences doesn't need explicit init
      // Note: GetX controllers from main isolate are NOT available here
    },
  );
}
```

### Showing Notifications from Background Tasks

```dart
Future<void> showNotification(String title, String body) async {
  final plugin = FlutterLocalNotificationsPlugin();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  final initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await plugin.initialize(initSettings);

  await plugin.show(
    0,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'Channel Name',
        importance: Importance.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
}

// Use in your task
BackgroundWorkManagerTask(
  uniqueName: 'notify_task',
  name: 'notify_task',
  type: BackgroundWorkManagerTaskType.periodic,
  frequency: Duration(minutes: 15),
  executeFunction: (task, inputData) async {
    await doWork();
    await showNotification('Task Complete', 'Data synced successfully');
    return true;
  },
)
```

### Task Hashing and Re-registration

Tasks use a hash to detect configuration changes. If you change task properties (constraints, inputData, etc.), set `cancelPrevious: true` to force re-registration:

```dart
BackgroundWorkManagerTask(
  uniqueName: 'my_task',
  name: 'my_task',
  type: BackgroundWorkManagerTaskType.periodic,
  frequency: Duration(minutes: 15),
  cancelPrevious: true,  // Forces re-registration even if already registered
  // ... other properties
)
```

---

## Task Lifecycle

```
┌─────────────────┐
│   UNREGISTERED  │◄──────────────────────────────────────┐
└────────┬────────┘                                       │
         │ register()                                     │
         ▼                                                │
┌─────────────────┐                              ┌────────┴────────┐
│   REGISTERED    │──────────────────────────────►│    REMOVED      │
└────────┬────────┘  removeTask()                └─────────────────┘
         │                                                ▲
         │ task executes                                  │
         ▼                                                │
┌─────────────────┐                                       │
│    RUNNING      │                                       │
└────────┬────────┘                                       │
         │ completes                                      │
         ▼                                                │
┌─────────────────┐  cancelTask()                         │
│   REGISTERED    │───────────────────────────────────────┘
└────────┬────────┘
         │ pauseTask() (periodic only)
         ▼
┌─────────────────┐
│     PAUSED      │
└────────┬────────┘
         │ resumeTask()
         ▼
┌─────────────────┐
│   REGISTERED    │
└─────────────────┘
```

**State Descriptions:**

- **UNREGISTERED**: Task definition exists but not scheduled with workmanager
- **REGISTERED**: Task is scheduled and will execute at the specified time
- **RUNNING**: Task is currently executing (shown with spinner in UI)
- **PAUSED**: Periodic task is temporarily stopped but can be resumed
- **REMOVED**: Task is completely removed including all history

---

## API Reference

### Classes

| Class | Description |
|-------|-------------|
| `BackgroundWorkManagerTask` | Task definition with all workmanager parameters |
| `BackgroundWorkManagerController` | GetX controller for managing tasks |
| `BackgroundTaskStatus` | Task status and execution history |
| `TaskExecutionRecord` | Single execution record |
| `BackgroundTaskManagerWidget` | UI widget for task management |
| `BackgroundTaskManagerPage` | Full page wrapper for task widget |

### Enums

| Enum | Values | Description |
|------|--------|-------------|
| `BackgroundWorkManagerTaskType` | `oneOff`, `periodic` | Task execution type |

### Key Functions

| Function | Description |
|----------|-------------|
| `getCallbackDispathcer()` | Creates the workmanager callback dispatcher |
| `registerTask()` | Registers a single task |
| `getTaskStatus()` | Gets status for a specific task |
| `getAllTaskStatuses()` | Gets all task statuses from storage |
| `clearTaskHistory()` | Clears execution history for a task |
| `removeTaskStatus()` | Removes a task status from storage |
| `markTaskPaused()` | Marks a task as paused in storage |

### Storage Keys

| Key | Description |
|-----|-------------|
| `BackgroundTasks` | Legacy task registration tracking |
| `BackgroundTaskStatus` | Task status and history storage |
