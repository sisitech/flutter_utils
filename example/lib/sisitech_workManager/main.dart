import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_utils/local_nofitications/local_notification_controller.dart';
import 'package:flutter_utils/sisitech_workmanager/controller.dart';
import 'package:flutter_utils/sisitech_workmanager/ios_notification_scheduler.dart';
import 'package:flutter_utils/sisitech_workmanager/task_manager_widget.dart';
import 'package:flutter_utils/sisitech_workmanager/utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

const backgroundConter = "BACKGROUND_COUNTER";
const demoCountKey = "DEMO_COUNT";

/// Global plugin instance for consistent access
final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Helper to show notification in background isolate
Future<void> showTaskNotification(int count) async {
  final plugin = FlutterLocalNotificationsPlugin();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  final initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

  await plugin.initialize(initSettings);

  await plugin.show(
    0,
    'Periodic Task Executed',
    'Count: $count',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'periodic_task_channel',
        'Periodic Tasks',
        importance: Importance.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
}

List<BackgroundWorkManagerTask> tasks = [
  // Unified periodic task - works on both iOS and Android!
  // iOS: Uses notification-triggered approach automatically
  // Android: Uses standard Workmanager periodic task
  BackgroundWorkManagerTask(
    uniqueName: 'notification_demo_task',
    name: 'notification_demo',
    type: BackgroundWorkManagerTaskType.periodic,
    frequency: const Duration(minutes: 1), // Used for both platforms!
    iosNotificationTitle: 'Demo Task Ready',
    iosNotificationBody: 'Tap to create a file',
    executeFunction: (task, inputData) async {
      final storage = GetStorage();
      int count = storage.read<int>(demoCountKey) ?? 0;
      count++;
      await storage.write(demoCountKey, count);

      // Use Downloads on macOS, Documents on iOS
      Directory dir;
      if (Platform.isMacOS) {
        dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      final file = File('${dir.path}/demo_task_$count.txt');
      await file.writeAsString('Execution #$count at ${DateTime.now()}');
      print('Created file: ${file.path}');
      return true;
    },
  ),
  // One-off task - runs once after initial delay
  BackgroundWorkManagerTask(
    uniqueName: 'one_off_demo_task',
    name: 'one_off_demo',
    type: BackgroundWorkManagerTaskType.oneOff,
    initialDelay: const Duration(seconds: 10),
    executeFunction: (task, inputData) async {
      final storage = GetStorage();
      int count = storage.read<int>('ONE_OFF_COUNT') ?? 0;
      count++;
      await storage.write('ONE_OFF_COUNT', count);

      // Use Downloads on macOS, Documents on iOS
      Directory dir;
      if (Platform.isMacOS) {
        dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      final file = File('${dir.path}/one_off_task_$count.txt');
      await file.writeAsString('One-off execution #$count at ${DateTime.now()}');
      print('Created one-off file: ${file.path}');
      return true;
    },
  ),
  // Commented out existing tasks for testing
  // BackgroundWorkManagerTask(
  //   uniqueName: 'main_task',
  //   name: 'one_off_main_task',
  //   type: BackgroundWorkManagerTaskType.oneOff,
  //   frequency: Duration(minutes: 15),
  //   initialDelay: Duration(seconds: 2),
  //   removeAndCleanupTasks: false,
  //   executeFunction: (
  //     BackgroundWorkManagerTask task,
  //     Map<String, dynamic>? inputData,
  //   ) async {
  //     print("DAAAMM... got herer...");
  //     final storage = GetStorage();
  //     int count = storage.read<int>(backgroundConter) ?? 0;
  //     print(
  //         "Native called Bkaco background COUNT: $count TASK: $task"); //simpleTask will be emitted here.
  //     await storage.write(backgroundConter, count + 1);
  //     print(DateTime.now());
  //     await Future.delayed(Duration(seconds: 7));
  //     return Future.value(true);
  //   },
  // ),
  // BackgroundWorkManagerTask(
  //   uniqueName: 'main_task_two',
  //   name: 'one_off_main_task_wto',
  //   type: BackgroundWorkManagerTaskType.periodic,
  //   frequency: Duration(minutes: 15),
  //   initialDelay: Duration(seconds: 2),
  //   executeFunction: (
  //     BackgroundWorkManagerTask task,
  //     Map<String, dynamic>? inputData,
  //   ) async {
  //     print("DAAAMM... got herer...");
  //     final storage = GetStorage();
  //     int count = storage.read<int>(backgroundConter) ?? 0;
  //     print(
  //         "Native called Bkaco background COUNT: $count TASK: $task"); //simpleTask will be emitted here.
  //     await storage.write(backgroundConter, count + 1);

  //     // Show notification with updated count
  //     await showTaskNotification(count + 1);

  //     print(DateTime.now());
  //     await Future.delayed(Duration(minutes: 1));
  //     return Future.value(true);
  //   },
  // ),
  // BackgroundWorkManagerTask(
  //   uniqueName: 'main_task_three',
  //   name: 'one_off_main_task_three',
  //   type: BackgroundWorkManagerTaskType.oneOff,
  //   frequency: Duration(minutes: 15),
  //   initialDelay: Duration(seconds: 2),
  //   executeFunction: (
  //     BackgroundWorkManagerTask task,
  //     Map<String, dynamic>? inputData,
  //   ) async {
  //     print("DAAAMM... got herer...");
  //     final storage = GetStorage();
  //     int count = storage.read<int>(backgroundConter) ?? 0;
  //     print(
  //         "Native called Bkaco background COUNT: $count TASK: $task"); //simpleTask will be emitted here.
  //     await storage.write(backgroundConter, count + 1);
  //     print(DateTime.now());
  //     await Future.delayed(Duration(seconds: 7));
  //     return Future.value(true);
  //   },
  // ),
];

@pragma('vm:entry-point')
void callbackDispatcher() async {
  return getCallbackDispathcer(
    tasks,
    commonTasksInitalizations: () async {
      // SharedPreferences doesn't need explicit init
      await GetStorage
          .init(); // Only if your task uses GetStorage for other data
    },
  );
}

/// Handle notification response (foreground)
void _onNotificationResponse(NotificationResponse response) async {
  print('Notification tapped: ${response.payload}');
  print('Action ID: ${response.actionId}');

  // Handle WorkManager notifications
  final handled = await WorkManagerNotificationHandler.handleIfWorkManager(
    response,
    tasks,
    commonTasksInitalizations: () async {
      await GetStorage.init();
    },
  );

  if (handled) {
    print('WorkManager notification handled');
    // Refresh the UI after task execution
    if (Get.isRegistered<BackgroundWorkManagerController>()) {
      Get.find<BackgroundWorkManagerController>().refreshStatuses();
    }
  }
}

/// Handle notification response (background) - must be top-level function
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) async {
  print('Background notification tapped: ${response.payload}');

  // Initialize GetStorage for background
  await GetStorage.init();

  // Handle WorkManager notifications
  await WorkManagerNotificationHandler.handleIfWorkManager(
    response,
    tasks,
    commonTasksInitalizations: () async {
      await GetStorage.init();
    },
  );
}

Future<void> initalizeNotifications() async {
  print('initalizeNotifications: Starting...');

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

  print('initalizeNotifications: Initializing plugin...');
  await _notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _onNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
  );
  print('initalizeNotifications: Plugin initialized');

  // Request iOS permissions
  if (Platform.isIOS) {
    print('initalizeNotifications: Requesting iOS permissions...');
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    print('initalizeNotifications: iOS permissions requested');
  }

  print('initalizeNotifications: Complete');
}

/// Handle notification that launched the app (from terminated state)
/// MUST be called AFTER full initialization (controllers registered, tasks registered)
Future<void> _handleLaunchNotification() async {
  print('_handleLaunchNotification: Starting check...');
  // Use the global plugin instance that was already initialized
  final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();

  print('_handleLaunchNotification: didNotificationLaunchApp = ${launchDetails?.didNotificationLaunchApp}');

  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final response = launchDetails!.notificationResponse;
    print('_handleLaunchNotification: response = $response');
    print('_handleLaunchNotification: payload = ${response?.payload}');
    print('_handleLaunchNotification: actionId = ${response?.actionId}');

    if (response != null) {
      print('_handleLaunchNotification: Calling handler...');
      // AWAIT the handler to ensure task completes before app continues
      await _handleNotificationResponseAsync(response);
      print('_handleLaunchNotification: Handler completed');
    }
  } else {
    print('_handleLaunchNotification: App was NOT launched by notification');
  }
}

/// Async version of notification handler that can be awaited
Future<void> _handleNotificationResponseAsync(NotificationResponse response) async {
  print('_handleNotificationResponseAsync: Starting...');
  print('_handleNotificationResponseAsync: payload = ${response.payload}');

  // Handle WorkManager notifications
  final handled = await WorkManagerNotificationHandler.handleIfWorkManager(
    response,
    tasks,
    commonTasksInitalizations: () async {
      await GetStorage.init();
    },
  );

  print('_handleNotificationResponseAsync: handled = $handled');

  if (handled) {
    print('_handleNotificationResponseAsync: WorkManager notification handled successfully');
    // Refresh the UI after task execution
    if (Get.isRegistered<BackgroundWorkManagerController>()) {
      Get.find<BackgroundWorkManagerController>().refreshStatuses();
    }
  } else {
    print('_handleNotificationResponseAsync: Not a WorkManager notification');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('main: WidgetsFlutterBinding initialized');

  await GetStorage.init(); // For task's own data storage (backgroundConter)
  print('main: GetStorage initialized');

  await initalizeNotifications();
  print('main: Notifications initialized');

  // Early check - can we see launch details right after init?
  final earlyCheck = await _notificationsPlugin.getNotificationAppLaunchDetails();
  print('main: Early launch check - didNotificationLaunchApp = ${earlyCheck?.didNotificationLaunchApp}');
  if (earlyCheck?.didNotificationLaunchApp ?? false) {
    print('main: Early check payload = ${earlyCheck?.notificationResponse?.payload}');
  }

  var workManController = Get.put(BackgroundWorkManagerController(
    callbackDispatcher: callbackDispatcher,
    tasks: tasks,
    isInDebugMode: true,
  ));

  await workManController.initializeBackgroundWorkManager();
  await workManController.registerTasks();
  await workManController.loadTaskStatuses();

  print('main: Controller initialized and tasks registered');

  // CRITICAL: Check launch notification AFTER full initialization
  // This ensures controllers and tasks are registered before handling the tap
  await _handleLaunchNotification();

  print('main: Launch notification check complete, starting app...');
  runApp(const MyAppBackground());
}

class MyAppBackground extends StatelessWidget {
  const MyAppBackground({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BackgroundWorkManagerController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshStatuses(),
            tooltip: 'Refresh task statuses',
          ),
        ],
      ),
      body: Column(
        children: [
          // Counter display
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Demo Task Count:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Obx(() {
                      final storage = GetStorage();
                      int count = storage.read<int>(demoCountKey) ?? 0;
                      return Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          // Task Manager Widget
          const Expanded(
            child: BackgroundTaskManagerWidget(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await controller.cancelAll();
          await controller.registerTasks();
          Get.snackbar('Tasks', 'Re-registered all tasks');
        },
        tooltip: 'Re-register all tasks',
        child: const Icon(Icons.restart_alt),
      ),
    );
  }
}
