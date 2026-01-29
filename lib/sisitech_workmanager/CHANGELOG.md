# Changelog

All notable changes to the sisitech_workmanager module.

## [1.0.0] - 2026-01-29

### Features

- **Cross-Platform Background Task Scheduling**
  - Android: Native WorkManager integration for reliable background execution
  - iOS: Notification-triggered approach for background tasks (works around iOS restrictions)

- **Task Types**
  - OneOff tasks: Single execution with optional initial delay
  - Periodic tasks: Recurring execution at specified intervals
  - NotificationTriggered tasks: iOS-specific scheduled notifications that trigger task execution

- **iOS Notification System**
  - Automatic notification scheduling with configurable queue size
  - Action buttons (Run Now / Dismiss) on notifications
  - Support for interval-based, daily, and weekly scheduling
  - Automatic rescheduling after task execution
  - Handles app launch from terminated state via notification tap

- **Task Status Tracking**
  - Real-time status monitoring with GetX reactive state
  - Execution history (last 10 runs per task)
  - Success/failure counts
  - Next scheduled run tracking
  - Pause/resume/cancel controls

- **UI Components**
  - `BackgroundTaskManagerWidget` for task management interface
  - Displays task status, history, and controls

### Dependencies

- workmanager: ^0.9.0
- flutter_local_notifications: ^18.0.1
- shared_preferences: ^2.2.0
- get: ^4.6.5
- get_storage: ^2.0.3 (optional)
- timezone: ^0.9.2
- flutter_timezone: ^3.0.1
- path_provider: ^2.1.0

### Platform Requirements

- **Android**: minSdkVersion 21+
- **iOS**: iOS 10.0+ (for notification actions)

### Known Issues

See [features/improvements.md](features/improvements.md) for tracked issues and planned improvements.
