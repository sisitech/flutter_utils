# WorkManager Improvements & Issues

Analysis of iOS and Android WorkManager implementations.

---

## Critical Issues

### 1. Dual State Management Systems
**Location:** `utils.dart` + `controller.dart`
**Problem:** Two separate storage keys track tasks:
- `tasksStorageName` ("BackgroundTasks") - legacy duplicate detection
- `taskStatusStorageName` ("BackgroundTaskStatus") - current status

**Risk:** Re-registration fails, orphaned entries, inconsistent state
**Fix:** Consolidate to single storage system using `taskStatusStorageName`

---

### 2. SharedPreferences Race Conditions
**Location:** All status update functions
**Problem:** Pattern `reload() → read → modify → write` is not atomic. Cross-isolate writes can be lost.

**Affected functions:**
- `_updateTaskNotificationStatus`
- `_handleDismiss`
- `_markTaskRunning`
- `_trackTaskExecution`
- `_updateNotificationStatus`

**Fix:** Implement optimistic locking or use a single-writer pattern

---

### 3. Mutable Task Objects
**Location:** `utils.dart` lines 29-33, `controller.dart` line 180
**Problem:** `BackgroundWorkManagerTask` fields like `cancelPrevious` are mutated at runtime
```dart
task.cancelPrevious = true;  // Mutates shared object!
```
**Fix:** Make all task fields `final`, use `copyWith()` pattern

---

## High Priority Issues

### 4. Redundant Stored Fields
**Location:** `models.dart`
**Problem:** These fields are stored but should be derived:
- `scheduledNotificationIds` - derivable from `uniqueName` + hash
- `remainingNotifications` - should equal `scheduledNotificationIds.length`
- `scheduleConfig` - should come from task definition

**Fix:** Remove from storage, compute on demand

---

### 5. Incomplete Cleanup on Pause vs Cancel
**Location:** `controller.dart` lines 149-160
**Problem:** `pauseTask()` doesn't clear iOS notification state like `cancelTask()` does
**Fix:** Align cleanup logic between pause and cancel

---

### 6. Hash Collision in Notification IDs
**Location:** `ios_notification_scheduler.dart` line 230
**Problem:** `uniqueName.hashCode.abs() % 100000` - only 100K unique hashes
**Risk:** Multiple tasks can collide, canceling wrong notifications
**Fix:** Use better hash (SHA256 truncated) or include task index in hash input

---

### 7. Fire-and-Forget iOS OneOff Tasks
**Location:** `utils.dart` line 381
**Problem:** `_executeOneOffTaskIOS(task)` is unawaited, status tracking races
**Fix:** Await execution or use proper async tracking

---

## Medium Priority Issues

### 8. Silent Error Handling
**Location:** Multiple `catch (e) { dprint(...) }` blocks
**Problem:** Errors logged but not propagated - callers think operation succeeded
**Fix:** Rethrow or return Result type

---

### 9. Weekly Scheduling Bug
**Location:** `ios_notification_scheduler.dart` lines 212-218
**Problem:** Weekday adjustment loop can add 1-6 extra days
**Fix:** Calculate correct weekday offset mathematically

---

### 10. Timezone Not Refreshed
**Location:** `ios_notification_scheduler.dart` line 32
**Problem:** `_timezoneInitialized` set once, never updated if user changes timezone
**Fix:** Refresh timezone on each scheduling operation or listen for system changes

---

### 11. Task Lookup Returns Null
**Location:** `controller.dart` lines 106, 164, 190
**Problem:** If task definition removed but still scheduled, lookup fails, cleanup incomplete
**Fix:** Store task config in status, don't rely on runtime task list

---

### 12. Validation Gaps in IOSNotificationScheduleConfig
**Location:** `models.dart` lines 32-35
**Problem:** Allows both `intervalMinutes` AND `hour/minute` to be set (conflicting)
**Fix:** XOR validation - one or the other, not both

---

## Low Priority / Tech Debt

### 13. History Limit Not Enforced on Load
**Location:** `models.dart` `fromJson()`
**Problem:** Truncation only on add, not on deserialize
**Fix:** Truncate in `fromJson()`

---

### 14. Hardcoded Constants
**Location:** Throughout
- `notificationIdBase = 900000`
- `notificationQueueSize = 5`
- `maxIndex = 20`
- `history limit = 10`
- `% 100000` hash modulo

**Fix:** Make configurable via constructor or config object

---

### 15. DST Transition Edge Cases
**Location:** `_calculateNextScheduleDate`
**Problem:** Adding `Duration(days: 1)` doesn't account for DST
**Fix:** Use calendar-aware date arithmetic

---

## Status

| # | Issue | Priority | Status |
|---|-------|----------|--------|
| 1 | Dual state management | Critical | Pending |
| 2 | SharedPreferences race | Critical | Pending |
| 3 | Mutable task objects | Critical | Pending |
| 4 | Redundant stored fields | High | In Progress (scheduledNotificationIds removed) |
| 5 | Pause vs cancel cleanup | High | Pending |
| 6 | Hash collision | High | Pending |
| 7 | Fire-and-forget iOS | High | Pending |
| 8 | Silent error handling | Medium | Pending |
| 9 | Weekly scheduling bug | Medium | Pending |
| 10 | Timezone not refreshed | Medium | Pending |
| 11 | Task lookup null | Medium | Pending |
| 12 | Config validation | Medium | Pending |
| 13 | History limit on load | Low | Pending |
| 14 | Hardcoded constants | Low | Pending |
| 15 | DST edge cases | Low | Pending |
