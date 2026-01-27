import 'utils.dart';

/// Storage key for task status persistence (used with SharedPreferences)
const taskStatusStorageName = "BackgroundTaskStatus";

/// Represents the execution history of a single task run
class TaskExecutionRecord {
  final DateTime executedAt;
  final bool success;
  final String? errorMessage;
  final Duration duration;

  TaskExecutionRecord({
    required this.executedAt,
    required this.success,
    this.errorMessage,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'executedAt': executedAt.toIso8601String(),
        'success': success,
        'errorMessage': errorMessage,
        'duration': duration.inMilliseconds,
      };

  factory TaskExecutionRecord.fromJson(Map<String, dynamic> json) {
    return TaskExecutionRecord(
      executedAt: DateTime.parse(json['executedAt'] as String),
      success: json['success'] as bool,
      errorMessage: json['errorMessage'] as String?,
      duration: Duration(milliseconds: json['duration'] as int),
    );
  }

  TaskExecutionRecord copyWith({
    DateTime? executedAt,
    bool? success,
    String? errorMessage,
    Duration? duration,
  }) {
    return TaskExecutionRecord(
      executedAt: executedAt ?? this.executedAt,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      duration: duration ?? this.duration,
    );
  }
}

/// Represents the current status and history of a background task
class BackgroundTaskStatus {
  final String uniqueName;
  final String name;
  final BackgroundWorkManagerTaskType type;
  final bool isRegistered;
  final DateTime? registeredAt;
  final DateTime? lastExecutedAt;
  final DateTime? nextScheduledRun;
  final int executionCount;
  final int successCount;
  final int failureCount;
  final List<TaskExecutionRecord> history;
  final bool isPaused;
  final Duration? frequency;
  final bool isRunning;

  BackgroundTaskStatus({
    required this.uniqueName,
    required this.name,
    required this.type,
    this.isRegistered = false,
    this.registeredAt,
    this.lastExecutedAt,
    this.nextScheduledRun,
    this.executionCount = 0,
    this.successCount = 0,
    this.failureCount = 0,
    this.history = const [],
    this.isPaused = false,
    this.frequency,
    this.isRunning = false,
  });

  /// Create from a BackgroundWorkManagerTask
  factory BackgroundTaskStatus.fromTask(BackgroundWorkManagerTask task) {
    return BackgroundTaskStatus(
      uniqueName: task.uniqueName,
      name: task.name,
      type: task.type,
      frequency: task.frequency,
    );
  }

  Map<String, dynamic> toJson() => {
        'uniqueName': uniqueName,
        'name': name,
        'type': type.name,
        'isRegistered': isRegistered,
        'registeredAt': registeredAt?.toIso8601String(),
        'lastExecutedAt': lastExecutedAt?.toIso8601String(),
        'nextScheduledRun': nextScheduledRun?.toIso8601String(),
        'executionCount': executionCount,
        'successCount': successCount,
        'failureCount': failureCount,
        'history': history.map((e) => e.toJson()).toList(),
        'isPaused': isPaused,
        'frequency': frequency?.inMilliseconds,
        'isRunning': isRunning,
      };

  factory BackgroundTaskStatus.fromJson(Map<String, dynamic> json) {
    return BackgroundTaskStatus(
      uniqueName: json['uniqueName'] as String,
      name: json['name'] as String,
      type: BackgroundWorkManagerTaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BackgroundWorkManagerTaskType.oneOff,
      ),
      isRegistered: json['isRegistered'] as bool? ?? false,
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'] as String)
          : null,
      lastExecutedAt: json['lastExecutedAt'] != null
          ? DateTime.parse(json['lastExecutedAt'] as String)
          : null,
      nextScheduledRun: json['nextScheduledRun'] != null
          ? DateTime.parse(json['nextScheduledRun'] as String)
          : null,
      executionCount: json['executionCount'] as int? ?? 0,
      successCount: json['successCount'] as int? ?? 0,
      failureCount: json['failureCount'] as int? ?? 0,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) =>
                  TaskExecutionRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isPaused: json['isPaused'] as bool? ?? false,
      frequency: json['frequency'] != null
          ? Duration(milliseconds: json['frequency'] as int)
          : null,
      isRunning: json['isRunning'] as bool? ?? false,
    );
  }

  BackgroundTaskStatus copyWith({
    String? uniqueName,
    String? name,
    BackgroundWorkManagerTaskType? type,
    bool? isRegistered,
    DateTime? registeredAt,
    DateTime? lastExecutedAt,
    DateTime? nextScheduledRun,
    int? executionCount,
    int? successCount,
    int? failureCount,
    List<TaskExecutionRecord>? history,
    bool? isPaused,
    Duration? frequency,
    bool? isRunning,
  }) {
    return BackgroundTaskStatus(
      uniqueName: uniqueName ?? this.uniqueName,
      name: name ?? this.name,
      type: type ?? this.type,
      isRegistered: isRegistered ?? this.isRegistered,
      registeredAt: registeredAt ?? this.registeredAt,
      lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
      nextScheduledRun: nextScheduledRun ?? this.nextScheduledRun,
      executionCount: executionCount ?? this.executionCount,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      history: history ?? this.history,
      isPaused: isPaused ?? this.isPaused,
      frequency: frequency ?? this.frequency,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  /// Add an execution record and return updated status
  /// Keeps only the last 10 records
  BackgroundTaskStatus addExecutionRecord(TaskExecutionRecord record) {
    final newHistory = [...history, record];
    if (newHistory.length > 10) {
      newHistory.removeRange(0, newHistory.length - 10);
    }

    return copyWith(
      lastExecutedAt: record.executedAt,
      executionCount: executionCount + 1,
      successCount: record.success ? successCount + 1 : successCount,
      failureCount: record.success ? failureCount : failureCount + 1,
      history: newHistory,
      nextScheduledRun: type == BackgroundWorkManagerTaskType.periodic &&
              frequency != null
          ? record.executedAt.add(frequency!)
          : null,
    );
  }

  /// Mark task as registered
  BackgroundTaskStatus markRegistered() {
    return copyWith(
      isRegistered: true,
      registeredAt: DateTime.now(),
      isPaused: false,
    );
  }

  /// Mark task as paused
  BackgroundTaskStatus markPaused() {
    return copyWith(
      isPaused: true,
      isRegistered: false,
    );
  }

  /// Mark task as unregistered
  BackgroundTaskStatus markUnregistered() {
    return copyWith(
      isRegistered: false,
    );
  }

  /// Mark task as currently running
  BackgroundTaskStatus markRunning() {
    return copyWith(
      isRunning: true,
    );
  }

  /// Mark task as finished running
  BackgroundTaskStatus markFinished() {
    return copyWith(
      isRunning: false,
    );
  }
}
