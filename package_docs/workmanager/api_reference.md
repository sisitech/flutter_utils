# API Reference

Complete API documentation for Flutter Workmanager.

## Workmanager Class

### initialize

Initialize the Workmanager with a callback dispatcher.

```dart
Future<void> initialize(
  Function callbackDispatcher,
  {bool isInDebugMode = false}
)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `callbackDispatcher` | `Function` | Top-level function with `@pragma('vm:entry-point')` |
| `isInDebugMode` | `bool` | Shows notifications for debugging (default: false) |

### registerOneOffTask

Register a one-time background task.

```dart
Future<void> registerOneOffTask(
  String uniqueName,
  String taskName,
  {
    Map<String, dynamic>? inputData,
    Duration? initialDelay,
    Constraints? constraints,
    ExistingWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    String? tag,
    OutOfQuotaPolicy? outOfQuotaPolicy,
  }
)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueName` | `String` | Unique identifier for the task |
| `taskName` | `String` | Name passed to callback dispatcher |
| `inputData` | `Map<String, dynamic>?` | Data passed to task (int, bool, double, String, lists) |
| `initialDelay` | `Duration?` | Delay before first execution |
| `constraints` | `Constraints?` | Operational restrictions |
| `existingWorkPolicy` | `ExistingWorkPolicy?` | How to handle duplicate uniqueName |
| `backoffPolicy` | `BackoffPolicy?` | Retry strategy |
| `backoffPolicyDelay` | `Duration?` | Initial retry delay |
| `tag` | `String?` | Group identifier for batch operations |
| `outOfQuotaPolicy` | `OutOfQuotaPolicy?` | Android only - behavior when quota unavailable |

### registerPeriodicTask

Register a recurring background task.

```dart
Future<void> registerPeriodicTask(
  String uniqueName,
  String taskName,
  {
    Duration? frequency,
    Duration? flexInterval,
    Map<String, dynamic>? inputData,
    Duration? initialDelay,
    Constraints? constraints,
    ExistingWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    String? tag,
  }
)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `frequency` | `Duration?` | How often to run (minimum: 15 minutes, default: 15 minutes) |
| `flexInterval` | `Duration?` | Flex period for task execution window |
| Other parameters | - | Same as `registerOneOffTask` |

### registerProcessingTask (iOS only)

Register a long-running iOS processing task.

```dart
Future<void> registerProcessingTask(
  String uniqueName,
  String taskName,
  {
    Duration? initialDelay,
    Map<String, dynamic>? inputData,
    Constraints? constraints,
  }
)
```

### executeTask

Handle task execution inside the callback dispatcher.

```dart
void executeTask(BackgroundTaskHandler backgroundTaskHandler)
```

**BackgroundTaskHandler typedef:**

```dart
typedef BackgroundTaskHandler = Future<bool> Function(
  String taskName,
  Map<String, dynamic>? inputData
);
```

### Task Cancellation

```dart
// Cancel all registered tasks
Future<void> cancelAll()

// Cancel tasks by tag
Future<void> cancelByTag(String tag)

// Cancel specific task by uniqueName
Future<void> cancelByUniqueName(String uniqueName)
```

### Task Management

```dart
// Check if periodic task is scheduled
Future<bool> isScheduledByUniqueName(String uniqueName)

// Debug: List un-executed tasks
Future<String> printScheduledTasks()
```

### Constants

```dart
// iOS Background Fetch event identifier
static const iOSBackgroundTask = 'iOSBackgroundTask'
```

---

## Constraints Class

Define operational restrictions for background tasks.

```dart
Constraints({
  NetworkType? networkType,
  bool? requiresBatteryNotLow,
  bool? requiresCharging,
  bool? requiresDeviceIdle,
  bool? requiresStorageNotLow,
})
```

| Property | Type | Platform | Description |
|----------|------|----------|-------------|
| `networkType` | `NetworkType?` | Both | Network connectivity requirement |
| `requiresBatteryNotLow` | `bool?` | Android | Task won't run in low battery mode |
| `requiresCharging` | `bool?` | Both | Device must be charging |
| `requiresDeviceIdle` | `bool?` | Android | Device must be inactive/idle |
| `requiresStorageNotLow` | `bool?` | Android | Sufficient storage required |

---

## Enums

### NetworkType

| Value | Description | Platform |
|-------|-------------|----------|
| `notRequired` | Network not required (default) | Both |
| `connected` | Any working network connection | Both |
| `metered` | Metered network required | Both |
| `unmetered` | Unmetered (WiFi) required | Android |
| `notRoaming` | Non-roaming network required | Android |
| `temporarilyUnmetered` | Currently unmetered but generally metered | Android 30+ |

### BackoffPolicy

| Value | Description |
|-------|-------------|
| `exponential` | Exponentially increase retry delay |
| `linear` | Linearly increase retry delay |

### ExistingWorkPolicy

| Value | Description |
|-------|-------------|
| `append` | Append new work as child of existing work |
| `keep` | Keep existing work, ignore new request |
| `replace` | Cancel existing work and replace |
| `update` | Update existing work with new specification |

### OutOfQuotaPolicy (Android only)

| Value | Description |
|-------|-------------|
| `runAsNonExpeditedWorkRequest` | Fallback to regular work request |
| `dropWorkRequest` | Drop expedited work request |

---

## Task Return Values

Return from `BackgroundTaskHandler`:

| Return | Meaning | Behavior |
|--------|---------|----------|
| `Future.value(true)` | Success | Task completed successfully |
| `Future.value(false)` | Retry | Task failed, should be retried |
| `Future.error(...)` | Error | Task failed with error |

**Retry Behavior:**
- **Android**: Retries automatically based on `backoffPolicy`
- **iOS**: Manual rescheduling required
