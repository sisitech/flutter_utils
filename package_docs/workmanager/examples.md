# Code Examples

Practical examples for using Flutter Workmanager.

## Basic Setup

### Callback Dispatcher

```dart
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print("Background task: $taskName");

    switch (taskName) {
      case "simpleTask":
        await performSimpleWork();
        break;
      case "dataSync":
        await syncDataWithServer(inputData);
        break;
      case "iOSBackgroundTask":
        // iOS Background Fetch
        await refreshData();
        break;
    }
    return Future.value(true);
  });
}
```

### Initialize in main()

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  runApp(MyApp());
}
```

---

## One-Off Tasks

### Basic One-Off Task

```dart
Workmanager().registerOneOffTask(
  "task-identifier",
  "simpleTask",
);
```

### With Initial Delay

```dart
Workmanager().registerOneOffTask(
  "delayed-task",
  "simpleTask",
  initialDelay: Duration(seconds: 30),
);
```

### With Input Data

```dart
Workmanager().registerOneOffTask(
  "task-with-data",
  "dataSync",
  inputData: {
    'userId': 123,
    'syncAll': true,
    'priority': 1.5,
    'endpoint': 'https://api.example.com',
    'items': [1, 2, 3],
  },
);
```

### With Backoff Policy

```dart
Workmanager().registerOneOffTask(
  "task-with-retry",
  "simpleTask",
  backoffPolicy: BackoffPolicy.exponential,
  backoffPolicyDelay: Duration(seconds: 10),
);
```

---

## Periodic Tasks

### Default Frequency (15 minutes)

```dart
Workmanager().registerPeriodicTask(
  "periodic-task",
  "periodicSync",
);
```

### Custom Frequency

```dart
Workmanager().registerPeriodicTask(
  "hourly-task",
  "hourlySync",
  frequency: Duration(hours: 1),
);
```

### With Flex Interval

```dart
Workmanager().registerPeriodicTask(
  "flexible-task",
  "flexibleSync",
  frequency: Duration(hours: 1),
  flexInterval: Duration(minutes: 15),
);
```

---

## Constraints

### Network Required

```dart
Workmanager().registerOneOffTask(
  "network-task",
  "dataSync",
  constraints: Constraints(
    networkType: NetworkType.connected,
  ),
);
```

### WiFi Only

```dart
Workmanager().registerOneOffTask(
  "wifi-task",
  "largeUpload",
  constraints: Constraints(
    networkType: NetworkType.unmetered,
  ),
);
```

### Multiple Constraints

```dart
Workmanager().registerOneOffTask(
  "optimal-conditions-task",
  "heavyProcessing",
  constraints: Constraints(
    networkType: NetworkType.connected,
    requiresBatteryNotLow: true,
    requiresCharging: true,
    requiresDeviceIdle: true,
    requiresStorageNotLow: true,
  ),
);
```

---

## Task Management

### Cancel All Tasks

```dart
await Workmanager().cancelAll();
```

### Cancel by Tag

```dart
// Register with tag
Workmanager().registerOneOffTask(
  "sync-1",
  "dataSync",
  tag: "sync_batch",
);

Workmanager().registerOneOffTask(
  "sync-2",
  "dataSync",
  tag: "sync_batch",
);

// Cancel all tasks with tag
await Workmanager().cancelByTag("sync_batch");
```

### Cancel Specific Task

```dart
await Workmanager().cancelByUniqueName("task-identifier");
```

### Check if Scheduled

```dart
bool isScheduled = await Workmanager().isScheduledByUniqueName("periodic-task");
```

---

## Using flutter_utils Wrapper Classes

This library provides wrapper classes that simplify Workmanager usage with GetX.

### Define Tasks

```dart
import 'package:flutter_utils/workmanager/utils.dart';

List<BackgroundWorkManagerTask> tasks = [
  // One-off task
  BackgroundWorkManagerTask(
    uniqueName: 'sync_task',
    name: 'data_sync',
    type: BackgroundWorkManagerTaskType.oneOff,
    initialDelay: Duration(seconds: 5),
    executeFunction: (task, inputData) async {
      print("Syncing data...");
      // Your sync logic here
      return Future.value(true);
    },
  ),

  // Periodic task
  BackgroundWorkManagerTask(
    uniqueName: 'cleanup_task',
    name: 'cleanup',
    type: BackgroundWorkManagerTaskType.periodic,
    frequency: Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    executeFunction: (task, inputData) async {
      print("Running cleanup...");
      // Your cleanup logic here
      return Future.value(true);
    },
  ),
];
```

### Create Callback Dispatcher

```dart
import 'package:flutter_utils/workmanager/utils.dart';
import 'package:get_storage/get_storage.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  return getCallbackDispathcer(
    tasks,
    commonTasksInitalizations: () async {
      // Initialize required plugins
      await GetStorage.init();
    },
  );
}
```

### Initialize Controller

```dart
import 'package:flutter_utils/workmanager/controller.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage first
  await GetStorage.init();

  // Create controller
  var workManagerController = Get.put(BackgroundWorkManagerController(
    callbackDispatcher: callbackDispatcher,
    tasks: tasks,
    isInDebugMode: true,
  ));

  // Register all tasks
  await workManagerController.registerTasks();

  runApp(MyApp());
}
```

### Cancel All Tasks

```dart
final controller = Get.find<BackgroundWorkManagerController>();
await controller.cancelAll();
```

### Task with Cleanup Flag

```dart
BackgroundWorkManagerTask(
  uniqueName: 'temporary_task',
  name: 'temp_work',
  type: BackgroundWorkManagerTaskType.oneOff,
  removeAndCleanupTasks: true, // Removes task after execution
  executeFunction: (task, inputData) async {
    // One-time work
    return Future.value(true);
  },
),
```

### Task with Cancel Previous

```dart
BackgroundWorkManagerTask(
  uniqueName: 'update_task',
  name: 'update_data',
  type: BackgroundWorkManagerTaskType.oneOff,
  cancelPrevious: true, // Cancels any existing task with same uniqueName
  executeFunction: (task, inputData) async {
    // Updated work
    return Future.value(true);
  },
),
```

---

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_utils/workmanager/controller.dart';
import 'package:flutter_utils/workmanager/utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';

const counterKey = "BACKGROUND_COUNTER";

// Define tasks
List<BackgroundWorkManagerTask> tasks = [
  BackgroundWorkManagerTask(
    uniqueName: 'counter_task',
    name: 'increment_counter',
    type: BackgroundWorkManagerTaskType.periodic,
    frequency: Duration(minutes: 15),
    executeFunction: (task, inputData) async {
      final storage = GetStorage();
      int count = storage.read<int>(counterKey) ?? 0;
      await storage.write(counterKey, count + 1);
      print("Counter incremented to: ${count + 1}");
      return Future.value(true);
    },
  ),
];

// Callback dispatcher (must be top-level)
@pragma('vm:entry-point')
void callbackDispatcher() {
  return getCallbackDispathcer(
    tasks,
    commonTasksInitalizations: () async {
      await GetStorage.init();
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  var controller = Get.put(BackgroundWorkManagerController(
    callbackDispatcher: callbackDispatcher,
    tasks: tasks,
    isInDebugMode: true,
  ));

  await controller.registerTasks();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Background Counter',
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();

    return Scaffold(
      appBar: AppBar(title: const Text('Background Counter')),
      body: Center(
        child: Obx(() {
          int count = storage.read<int>(counterKey) ?? 0;
          return Text(
            'Background count: $count',
            style: Theme.of(context).textTheme.headlineMedium,
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = Get.find<BackgroundWorkManagerController>();
          await controller.cancelAll();
          await controller.registerTasks();
          Get.snackbar('Tasks', 'Re-registered all tasks');
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```
