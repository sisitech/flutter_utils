# Flutter Workmanager

Flutter Workmanager enables executing Dart code in the background, even when the app is closed. It wraps native background task systems on both Android (WorkManager) and iOS (Background Tasks) platforms.

## Platform Support

| Platform | Status | Details |
|----------|--------|---------|
| Android | Full | Native WorkManager support |
| iOS | Full | Background Fetch + BGTaskScheduler APIs |
| macOS | Planned | Future NSBackgroundActivityScheduler support |
| Web | Unsupported | No background execution available |
| Windows/Linux | Unsupported | No background task APIs |

## Use Cases

- Data synchronization with remote APIs
- Reliable file uploads in the background
- Removing outdated files and cached data
- Checking for incoming messages and notifications
- Database optimization and maintenance tasks

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  workmanager: ^0.9.0+3
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Create Callback Dispatcher

The callback dispatcher must be a **top-level function** with the `@pragma('vm:entry-point')` annotation:

```dart
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case "data_sync":
        await syncDataWithServer();
        break;
      case "cleanup":
        await cleanupCache();
        break;
    }
    return Future.value(true);
  });
}
```

### 2. Initialize in main()

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Shows notifications for debugging
  );
  runApp(MyApp());
}
```

### 3. Register Tasks

```dart
// One-time task
Workmanager().registerOneOffTask(
  "sync-task",
  "data_sync",
  initialDelay: Duration(seconds: 10),
);

// Periodic task (minimum 15 minutes)
Workmanager().registerPeriodicTask(
  "cleanup-task",
  "cleanup",
  frequency: Duration(hours: 1),
);
```

## Task Return Values

- `Future.value(true)` - Success, task completed
- `Future.value(false)` - Retry, task failed and should be retried
- `Future.error(...)` - Failed, error occurred

## Key Limitations

- **Minimum periodic frequency**: 15 minutes (Android requirement)
- **iOS execution time**: 30-second limit for background tasks
- **Valid inputData types**: `int`, `bool`, `double`, `String`, and their lists
- **Background isolation**: Tasks run in separate isolate, initialize dependencies inside task

## Documentation

- [Android Setup](android_setup.md) - Android-specific configuration
- [iOS Setup](ios_setup.md) - iOS-specific configuration
- [API Reference](api_reference.md) - Complete API documentation
- [Examples](examples.md) - Practical code examples

## Resources

- [Official Package](https://pub.dev/packages/workmanager)
- [GitHub Repository](https://github.com/fluttercommunity/flutter_workmanager)
- [API Documentation](https://pub.dev/documentation/workmanager/latest/)
