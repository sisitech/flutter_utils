# Sisitech WorkManager

A Flutter package for scheduling background tasks with notification support on both Android and iOS.

## Overview

This package provides a unified API for background task scheduling that works differently on each platform:

- **Android**: Uses the native WorkManager API for reliable background task execution
- **iOS**: Uses a notification-triggered approach where scheduled notifications prompt the user to execute tasks (since iOS severely restricts true background execution)

## Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  workmanager: ^0.9.0
  flutter_local_notifications: ^18.0.1
  shared_preferences: ^2.2.0
  get: ^4.6.5
  get_storage: ^2.0.3  # Optional, for task data storage
  timezone: ^0.9.2
  flutter_timezone: ^3.0.1
  path_provider: ^2.1.0
```

## Platform Setup

### Android Setup

Android requires minimal configuration. The workmanager plugin handles most setup automatically.

**No MainActivity changes needed** - the plugin auto-registers.

### iOS Setup

iOS requires additional configuration for notifications and background tasks.

#### 1. Info.plist

Add the following to `ios/Runner/Info.plist`:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.sisitech.flutterutils.workmanager.iOSBackgroundProcessingTask</string>
    <string>com.sisitech.flutterutils.workmanager.iOSBackgroundAppRefresh</string>
</array>
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
    <string>fetch</string>
</array>
```

#### 2. AppDelegate.swift

Update `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register WorkManager for iOS background tasks
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }

    // Set notification center delegate for tap handling
    // This enables flutter_local_notifications to receive notification taps
    // when the app is launched from terminated state
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Flutter Implementation

### 1. Define Tasks

Create a list of `BackgroundWorkManagerTask` objects:

```dart
import 'package:flutter_utils/sisitech_workmanager/utils.dart';

List<BackgroundWorkManagerTask> tasks = [
  // Periodic task - runs at intervals
  BackgroundWorkManagerTask(
    uniqueName: 'my_periodic_task',
    name: 'periodic_sync',
    type: BackgroundWorkManagerTaskType.periodic,
    frequency: const Duration(minutes: 15), // Minimum 15 min on Android
    iosNotificationTitle: 'Sync Ready',      // iOS notification customization
    iosNotificationBody: 'Tap to sync data',
    executeFunction: (task, inputData) async {
      // Your background work here
      print('Executing periodic task');
      return true; // Return true on success
    },
  ),

  // One-off task - runs once after delay
  BackgroundWorkManagerTask(
    uniqueName: 'my_oneoff_task',
    name: 'oneoff_upload',
    type: BackgroundWorkManagerTaskType.oneOff,
    initialDelay: const Duration(seconds: 10),
    executeFunction: (task, inputData) async {
      // Your one-time work here
      return true;
    },
  ),
];
```

### 2. Create Callback Dispatcher

The callback dispatcher must be a **top-level function** (not inside a class):

```dart
import 'package:flutter_utils/sisitech_workmanager/utils.dart';
import 'package:get_storage/get_storage.dart';

@pragma('vm:entry-point')
void callbackDispatcher() async {
  return getCallbackDispathcer(
    tasks,
    commonTasksInitalizations: () async {
      // Initialize any plugins needed in background isolate
      await GetStorage.init();
    },
  );
}
```

### 3. Initialize in main()

```dart
import 'package:flutter_utils/sisitech_workmanager/controller.dart';
import 'package:flutter_utils/sisitech_workmanager/ios_notification_scheduler.dart';
import 'package:flutter_utils/local_nofitications/local_notification_controller.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage (if using GetStorage)
  await GetStorage.init();

  // Initialize notifications (required for iOS)
  await initializeNotifications();

  // Create and register the controller
  var controller = Get.put(BackgroundWorkManagerController(
    callbackDispatcher: callbackDispatcher,
    tasks: tasks,
    isInDebugMode: true, // Set false in production
  ));

  await controller.initializeBackgroundWorkManager();
  await controller.registerTasks();
  await controller.loadTaskStatuses();

  // Handle notification that may have launched the app (iOS)
  await handleLaunchNotification();

  runApp(MyApp());
}
```

### 4. Notification Setup (Required for iOS)

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_utils/local_nofitications/local_notification_controller.dart';
import 'package:flutter_utils/sisitech_workmanager/ios_notification_scheduler.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS settings with WorkManager notification categories
  final iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    notificationCategories: LocalNotificationController.buildWorkManagerCategories(),
  );

  final initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: onNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
  );

  // Request iOS permissions
  if (Platform.isIOS) {
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
}

/// Handle notification tap (foreground)
void onNotificationResponse(NotificationResponse response) async {
  final handled = await WorkManagerNotificationHandler.handleIfWorkManager(
    response,
    tasks,
    commonTasksInitalizations: () async {
      await GetStorage.init();
    },
  );

  if (handled && Get.isRegistered<BackgroundWorkManagerController>()) {
    Get.find<BackgroundWorkManagerController>().refreshStatuses();
  }
}

/// Handle notification tap (background) - must be top-level
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) async {
  await GetStorage.init();
  await WorkManagerNotificationHandler.handleIfWorkManager(
    response,
    tasks,
    commonTasksInitalizations: () async {
      await GetStorage.init();
    },
  );
}

/// Handle notification that launched the app from terminated state
Future<void> handleLaunchNotification() async {
  final launchDetails = await notificationsPlugin.getNotificationAppLaunchDetails();

  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final response = launchDetails!.notificationResponse;
    if (response != null) {
      await WorkManagerNotificationHandler.handleIfWorkManager(
        response,
        tasks,
        commonTasksInitalizations: () async {
          await GetStorage.init();
        },
      );
    }
  }
}
```

## Task Types

### OneOff Tasks

Run once after an optional initial delay.

```dart
BackgroundWorkManagerTask(
  uniqueName: 'upload_task',
  name: 'upload',
  type: BackgroundWorkManagerTaskType.oneOff,
  initialDelay: const Duration(seconds: 30),
  executeFunction: (task, inputData) async {
    // Upload logic
    return true;
  },
)
```

**Platform behavior:**
- **Android**: Scheduled via WorkManager, runs in background
- **iOS**: Executes immediately (fire-and-forget) since iOS WorkManager is unreliable

### Periodic Tasks

Run repeatedly at specified intervals.

```dart
BackgroundWorkManagerTask(
  uniqueName: 'sync_task',
  name: 'sync',
  type: BackgroundWorkManagerTaskType.periodic,
  frequency: const Duration(hours: 1),
  iosNotificationTitle: 'Sync Available',
  iosNotificationBody: 'Tap to sync your data',
  iosRemindersNumber: 3, // Optional: schedule 3 notifications instead of default 5
  executeFunction: (task, inputData) async {
    // Sync logic
    return true;
  },
)
```

**Platform behavior:**
- **Android**: Scheduled via WorkManager with minimum 15-minute frequency
- **iOS**: Schedules 5 notifications ahead; when user taps, task executes and next notification is scheduled

### NotificationTriggered Tasks (iOS-specific)

For more control over iOS notification scheduling:

```dart
BackgroundWorkManagerTask(
  uniqueName: 'daily_reminder',
  name: 'reminder',
  type: BackgroundWorkManagerTaskType.notificationTriggered,
  iosScheduleConfig: IOSNotificationScheduleConfig(
    hour: 9,
    minute: 0,
    // weekday: 1, // Optional: 1=Monday, 7=Sunday for weekly
  ),
  iosNotificationTitle: 'Daily Check',
  iosNotificationBody: 'Time for your daily check-in',
  executeFunction: (task, inputData) async {
    return true;
  },
)
```

**Note:** On Android, `notificationTriggered` falls back to periodic task behavior.

## iOS Notification Schedule Configuration

```dart
// Interval-based (every N minutes)
IOSNotificationScheduleConfig(
  intervalMinutes: 60, // Every hour
)

// Daily at specific time
IOSNotificationScheduleConfig(
  hour: 9,
  minute: 30,
)

// Weekly at specific day and time
IOSNotificationScheduleConfig(
  hour: 10,
  minute: 0,
  weekday: 1, // Monday
)

// Auto-generate from Duration (used internally for periodic tasks)
IOSNotificationScheduleConfig.fromFrequency(Duration(minutes: 30))
```

## Task Management API

The `BackgroundWorkManagerController` provides these methods:

```dart
final controller = Get.find<BackgroundWorkManagerController>();

// Register all tasks
await controller.registerTasks();

// Cancel all tasks
await controller.cancelAll();

// Cancel specific task
await controller.cancelTask('task_unique_name');

// Pause a task (cancels but preserves status)
await controller.pauseTask('task_unique_name');

// Resume a paused task
await controller.resumeTask('task_unique_name');

// Remove task completely (cancels and clears history)
await controller.removeTask('task_unique_name');

// Clear execution history for a task
await controller.clearHistory('task_unique_name');

// Refresh task statuses from storage
await controller.refreshStatuses();

// Get status for specific task
BackgroundTaskStatus? status = controller.getTaskStatusByName('task_unique_name');

// Check if task is scheduled (native API)
bool scheduled = await controller.isTaskScheduled('task_unique_name');
```

### Reactive Status Tracking

```dart
// Observable list of task statuses
Obx(() {
  final statuses = controller.taskStatuses;
  return ListView.builder(
    itemCount: statuses.length,
    itemBuilder: (context, index) {
      final status = statuses[index];
      return ListTile(
        title: Text(status.name),
        subtitle: Text('Executions: ${status.executionCount}'),
        trailing: status.isRunning
          ? CircularProgressIndicator()
          : Icon(status.isRegistered ? Icons.check : Icons.pause),
      );
    },
  );
})
```

### Task Status Model

```dart
class BackgroundTaskStatus {
  final String uniqueName;
  final String name;
  final BackgroundWorkManagerTaskType type;
  final bool isRegistered;
  final bool isPaused;
  final bool isRunning;
  final DateTime? registeredAt;
  final DateTime? lastExecutedAt;
  final DateTime? nextScheduledRun;
  final int executionCount;
  final int successCount;
  final int failureCount;
  final List<TaskExecutionRecord> history; // Last 10 executions
  final Duration? frequency;

  // iOS-specific
  final List<int> scheduledNotificationIds;
  final int remainingNotifications;
}
```

## Platform-Specific Notes

### Android

- **Minimum frequency**: 15 minutes for periodic tasks (WorkManager limitation)
- **Constraints**: Can specify network, battery, charging requirements
- **Execution**: Runs in background isolate, survives app termination

### iOS

- **Notification queue**: Maintains scheduled notifications ahead (default: 5, configurable via `iosRemindersNumber`)
- **Tap-to-execute**: User must tap notification to trigger task execution
- **Automatic rescheduling**: After execution, next notification is automatically scheduled
- **Action buttons**: Notifications include "Run Now" and "Dismiss" actions
- **Terminated state**: App can be launched from notification tap to execute task

## Task Properties Reference

```dart
BackgroundWorkManagerTask({
  required String uniqueName,          // Unique identifier
  required String name,                // Name sent to callback
  required BackgroundWorkManagerTaskType type,
  required Future<bool> Function(...) executeFunction,

  Duration? frequency,                 // For periodic tasks
  Duration initialDelay,               // Delay before first run
  bool cancelPrevious,                 // Cancel existing on re-register
  bool removeAndCleanupTasks,          // Unregister and cleanup

  // WorkManager options (Android)
  ExistingWorkPolicy? existingWorkPolicy,
  ExistingPeriodicWorkPolicy? existingPeriodicWorkPolicy,
  Constraints? constraints,
  BackoffPolicy? backoffPolicy,
  Duration backoffPolicyDelay,
  OutOfQuotaPolicy? outOfQuotaPolicy,
  String? tag,
  Map<String, dynamic>? inputData,

  // iOS-specific
  IOSNotificationScheduleConfig? iosScheduleConfig,
  String? iosNotificationTitle,
  String? iosNotificationBody,
  int? iosRemindersNumber,       // Number of notifications to schedule (default: 5)
})
```

## UI Widget

The package includes ready-to-use widgets for displaying and managing background tasks.

### Available Widgets

| Widget | Description |
|--------|-------------|
| `BackgroundTaskManagerWidget` | Main widget displaying task list with controls |
| `BackgroundTaskManagerPage` | Ready-to-use page wrapper with AppBar |

### Widget Parameters

**BackgroundTaskManagerWidget:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `controllerTag` | `String?` | `null` | Tag for finding specific controller instance |
| `showRefreshButton` | `bool` | `true` | Show/hide the refresh button in header |
| `shrinkWrap` | `bool` | `false` | Enable for nested scrolling contexts |
| `physics` | `ScrollPhysics?` | `null` | Custom scroll physics for the list |

**BackgroundTaskManagerPage:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `controllerTag` | `String?` | `null` | Tag for finding specific controller instance |
| `title` | `String` | `'Background Tasks'` | AppBar title |

### Task Item Features

Each task item displays:
- **Status icon**: Animated spinner (running), pause icon (paused), play icon (active), stop icon (cancelled)
- **Type badge**: "Periodic" or "One-Off"
- **Subtitle**: Last execution time and next scheduled run
- **Stats row**: Execution count, success count, failure count
- **Action buttons**: Pause, Resume, Cancel, History, Clear, Remove

### Usage Examples

```dart
import 'package:flutter_utils/sisitech_workmanager/task_manager_widget.dart';

// Option 1: Use as an embedded widget
Scaffold(
  body: Column(
    children: [
      // Other widgets...
      const Expanded(
        child: BackgroundTaskManagerWidget(),
      ),
    ],
  ),
)

// Option 2: Use as a standalone page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const BackgroundTaskManagerPage(
      title: 'My Background Tasks',
    ),
  ),
);

// Option 3: With custom controller tag
const BackgroundTaskManagerWidget(
  controllerTag: 'myCustomTag',
  showRefreshButton: true,
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
)
```

## Troubleshooting

### iOS Module Conflicts

If you encounter module conflicts or build errors after updating dependencies:

```bash
# Clean Flutter build cache
flutter clean

# Remove iOS pods and reinstall
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..

# Rebuild
flutter pub get
flutter build ios
```

### Pod Installation Issues

If `pod install` fails with version conflicts:

1. Update CocoaPods: `sudo gem install cocoapods`
2. Clear pod cache: `pod cache clean --all`
3. Reinstall pods with repo update: `pod install --repo-update`

### Android WorkManager Issues

If background tasks aren't executing on Android:

1. Ensure the app has battery optimization disabled
2. Check that the callback dispatcher is a top-level function with `@pragma('vm:entry-point')`
3. Verify minimum SDK version is 21 or higher

## Known Issues

For a detailed list of known issues and planned improvements, see [features/improvements.md](features/improvements.md).
