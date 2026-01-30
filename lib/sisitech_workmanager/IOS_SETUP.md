# iOS Setup Guide for sisitech_workmanager

## Overview

On iOS, background task execution through WorkManager is unreliable. This package uses a **notification-triggered approach** where periodic tasks are simulated by scheduling local notifications. When the user taps the notification (or its action buttons), the task executes.

This approach requires proper delegate setup to ensure notifications work correctly, especially when the app is launched from a terminated state.

## 1. Info.plist Configuration

Add the following entries to your `ios/Runner/Info.plist`:

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

## 2. AppDelegate.swift Configuration

Update your `ios/Runner/AppDelegate.swift`:

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

    // CRITICAL: Set notification center delegate for tap handling
    // This enables flutter_local_notifications to receive notification taps
    // when the app is launched from terminated state
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Why is the delegate setup critical?**

Without `UNUserNotificationCenter.current().delegate = self`, tapping a notification when the app is terminated will launch the app but `flutter_local_notifications` will NOT receive the tap event. This means:
- `getNotificationAppLaunchDetails()` returns `null` or incorrect data
- Your task won't execute when users tap notifications from a terminated state

## 3. Flutter Notification Initialization

### 3.1 Initialize with WorkManager Categories

Use `LocalNotificationController.buildWorkManagerCategories()` to enable "Run Now" and "Dismiss" action buttons on iOS notifications:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_utils/local_nofitications/local_notification_controller.dart';

final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS settings with WorkManager notification categories for action buttons
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    notificationCategories: LocalNotificationController.buildWorkManagerCategories(),
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await _notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _onNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
  );

  // Request iOS permissions
  if (Platform.isIOS) {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}
```

### 3.2 Notification Response Handlers

You need to handle three scenarios:

#### Foreground Handler
Called when notification is tapped while app is in foreground:

```dart
void _onNotificationResponse(NotificationResponse response) async {
  print('Notification tapped: ${response.payload}');
  print('Action ID: ${response.actionId}');

  final handled = await WorkManagerNotificationHandler.handleIfWorkManager(
    response,
    tasks,
    commonTasksInitalizations: () async {
      await GetStorage.init();
    },
  );

  if (handled) {
    print('WorkManager notification handled');
    // Optionally refresh UI
    if (Get.isRegistered<BackgroundWorkManagerController>()) {
      Get.find<BackgroundWorkManagerController>().refreshStatuses();
    }
  }
}
```

#### Background Handler
Must be a **top-level function** with `@pragma('vm:entry-point')`:

```dart
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) async {
  print('Background notification tapped: ${response.payload}');

  // Initialize required services
  await GetStorage.init();

  await WorkManagerNotificationHandler.handleIfWorkManager(
    response,
    tasks,
    commonTasksInitalizations: () async {
      await GetStorage.init();
    },
  );
}
```

#### Launch from Terminated State
Check for launch notification AFTER full initialization:

```dart
Future<void> _handleLaunchNotification() async {
  final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();

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

## 4. Understanding Notification Data

The `NotificationResponse` object contains:

| Field | Description |
|-------|-------------|
| `payload` | JSON string with task info (`taskUniqueName`, `taskName`, `notificationId`) |
| `actionId` | `"EXECUTE_WORK"` (Run Now), `"DISMISS"`, or `null` (direct tap) |
| `id` | Notification ID |

Use `WorkManagerNotificationHandler.handleIfWorkManager()` to automatically:
1. Parse the payload
2. Find the matching task
3. Execute the task (for Run Now or direct tap)
4. Schedule the next notification
5. Track execution history

## 5. Complete Initialization Flow

Here's the recommended initialization sequence in `main()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize storage
  await GetStorage.init();

  // 2. Initialize notifications
  await initializeNotifications();

  // 3. Initialize WorkManager controller and register tasks
  var workManController = Get.put(BackgroundWorkManagerController(
    callbackDispatcher: callbackDispatcher,
    tasks: tasks,
    isInDebugMode: true,
  ));

  await workManController.initializeBackgroundWorkManager();
  await workManController.registerTasks();
  await workManController.loadTaskStatuses();

  // 4. CRITICAL: Check launch notification AFTER full initialization
  // This ensures controllers and tasks are registered before handling the tap
  await _handleLaunchNotification();

  // 5. Start the app
  runApp(const MyApp());
}
```

## 6. Task Definition Example

Define periodic tasks that work on both iOS and Android:

```dart
List<BackgroundWorkManagerTask> tasks = [
  BackgroundWorkManagerTask(
    uniqueName: 'my_periodic_task',
    name: 'my_task',
    type: BackgroundWorkManagerTaskType.periodic,
    frequency: const Duration(minutes: 15), // Used for both platforms
    iosNotificationTitle: 'Task Ready',      // iOS notification title
    iosNotificationBody: 'Tap to run task',  // iOS notification body
    executeFunction: (task, inputData) async {
      // Your task logic here
      return true;
    },
  ),
];
```

## Troubleshooting

### Notification taps not working from terminated state
1. Verify `UNUserNotificationCenter.current().delegate = self` is set in AppDelegate
2. Ensure `_handleLaunchNotification()` is called AFTER task registration
3. Check that the global plugin instance is used consistently

### Action buttons not showing
1. Verify `buildWorkManagerCategories()` is passed to `DarwinInitializationSettings`
2. Ensure notification permissions are granted

### Tasks not executing
1. Add debug prints to trace the flow
2. Verify tasks list is available when handling notifications
3. Check `commonTasksInitalizations` runs required initializations

## 7. Task Manager Widget

Display and manage background tasks in your UI using the built-in widget components.

### 7.1 Available Widgets

| Widget | Description |
|--------|-------------|
| `BackgroundTaskManagerWidget` | Main widget displaying task list with controls |
| `BackgroundTaskManagerPage` | Ready-to-use page wrapper with AppBar |

### 7.2 Widget Parameters

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

### 7.3 Task Item Features

Each task item displays:
- **Status icon**: Animated spinner (running), pause icon (paused), play icon (active), stop icon (cancelled)
- **Type badge**: "Periodic" or "One-Off"
- **Subtitle**: Last execution time and next scheduled run
- **Stats row**: Execution count, success count, failure count
- **Action buttons**:
  - **Pause** - Pause periodic task (cancels scheduling)
  - **Resume** - Resume paused task
  - **Cancel** - Stop task without removing
  - **History** - View execution history in bottom sheet
  - **Clear** - Clear execution history
  - **Remove** - Remove task and all history

### 7.4 Usage Example

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

### 7.5 Controller Methods

The `BackgroundWorkManagerController` provides these methods for programmatic control:

| Method | Description |
|--------|-------------|
| `pauseTask(uniqueName)` | Pause a periodic task (cancels scheduling, marks as paused) |
| `resumeTask(uniqueName)` | Resume a paused task (re-registers with scheduler) |
| `cancelTask(uniqueName)` | Cancel task without removing from storage |
| `removeTask(uniqueName)` | Remove task completely including history |
| `clearHistory(uniqueName)` | Clear execution history only |
| `refreshStatuses()` | Reload task statuses from storage |
| `loadTaskStatuses()` | Initial load of task statuses |
| `getTaskStatusByName(uniqueName)` | Get status for specific task |

```dart
// Example: Programmatic control
final controller = Get.find<BackgroundWorkManagerController>();

// Pause a task
await controller.pauseTask('my_periodic_task');

// Resume later
await controller.resumeTask('my_periodic_task');

// Refresh UI after external changes
await controller.refreshStatuses();
```