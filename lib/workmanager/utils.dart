import 'package:workmanager/workmanager.dart';

enum BackgroundWorkManagerTaskType { oneOff, periodic }

/// Represents a single background task and implements / copies all the fields
/// required when starting a `oneOff` or `periodic` task.
///
class BackgroundWorkManagerTask {
  /// Required by workmanager and must be unique across your tasks
  final String uniqueName;

  /// The name that is sent to callback dispatcher
  final String name;

  /// Useful only for `periodic` type and must be greater than
  /// 15 minutes as required on android
  final Duration? frequency;
  Duration initialDelay;
  final BackgroundWorkManagerTaskType type;
  final String? tag;
  Map<String, dynamic>? inputData;
  ExistingWorkPolicy? existingWorkPolicy;
  Constraints? constraints;
  BackoffPolicy? backoffPolicy;
  Duration backoffPolicyDelay;
  OutOfQuotaPolicy? outOfQuotaPolicy;

  /// Function executed by the callback dispatcher
  /// Make sure all the required plugins are loaded in
  /// the `commonTasksInitalizations` or within this function
  final Future<bool> Function(
    BackgroundWorkManagerTask task,
    Map<String, dynamic>? inputData,
  ) executeFunction;

  BackgroundWorkManagerTask({
    required this.uniqueName,
    required this.name,
    required this.type,
    this.backoffPolicyDelay = Duration.zero,
    this.initialDelay = Duration.zero,
    this.existingWorkPolicy,
    this.outOfQuotaPolicy,
    this.backoffPolicy,
    this.constraints,
    this.inputData,
    this.tag,
    required this.executeFunction,
    this.frequency,
  });

  Future<void> cancel() async {
    return Workmanager().cancelByUniqueName(uniqueName);
  }

  Future<void> register() async {
    return registerTask(this);
  }
}

/// Used to generate the main callbackDispatcher
/// and map the execute functions based on the name
/// Call the `commonTasksInitalizations` if provided
///
/// **Parameters**
/// - [tasks]: A list of `BackgroundWorkManagerTask` tasks
/// - [commonTasksInitalizations]: A function to initialize the required libraries for all the tasks
///
/// **Example Usage**:
/// ``` dart
/// @pragma('vm:entry-point')
/// void callbackDispatcher() async {
///  return getCallbackDispathcer(
///   tasks,
///   commonTasksInitalizations: () async {
///     await GetStorage.init();
///   },
/// );
/// }
@pragma('vm:entry-point')
void getCallbackDispathcer(
  List<BackgroundWorkManagerTask> tasks, {
  Future<void> Function()? commonTasksInitalizations,
}) {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      var task =
          tasks.where((element) => element.name == taskName).singleOrNull;
      if (task == null) return Future.value(true);

      if (commonTasksInitalizations != null) {
        await commonTasksInitalizations!();
      }
      var res = await task.executeFunction(task, inputData);
      return Future.value(res);
    } catch (e) {
      return Future.value(false);
    }
  });
}

Future<void> registerTask(BackgroundWorkManagerTask task) async {
  await task.cancel();
  if (task.type == BackgroundWorkManagerTaskType.oneOff) {
    Workmanager().registerOneOffTask(
      task.uniqueName,
      task.name,
      initialDelay: task.initialDelay,
      inputData: task.inputData,
      existingWorkPolicy: task.existingWorkPolicy,
      constraints: task.constraints,
      backoffPolicy: task.backoffPolicy,
      tag: task.tag,
      backoffPolicyDelay: task.backoffPolicyDelay,
    );
  } else if (task.type == BackgroundWorkManagerTaskType.periodic) {
    Workmanager().registerPeriodicTask(
      task.uniqueName,
      task.name,
      frequency: task.frequency,
      initialDelay: task.initialDelay,
      inputData: task.inputData,
      existingWorkPolicy: task.existingWorkPolicy,
      constraints: task.constraints,
      backoffPolicy: task.backoffPolicy,
      tag: task.tag,
      backoffPolicyDelay: task.backoffPolicyDelay,
    );
  }
}
