import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_utils/sisitech_workmanager/controller.dart';
import 'package:flutter_utils/sisitech_workmanager/task_manager_widget.dart';
import 'package:flutter_utils/sisitech_workmanager/utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const backgroundConter = "BACKGROUND_COUNTER";

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
  BackgroundWorkManagerTask(
    uniqueName: 'main_task',
    name: 'one_off_main_task',
    type: BackgroundWorkManagerTaskType.oneOff,
    frequency: Duration(minutes: 15),
    initialDelay: Duration(seconds: 2),
    removeAndCleanupTasks: false,
    executeFunction: (
      BackgroundWorkManagerTask task,
      Map<String, dynamic>? inputData,
    ) async {
      print("DAAAMM... got herer...");
      final storage = GetStorage();
      int count = storage.read<int>(backgroundConter) ?? 0;
      print(
          "Native called Bkaco background COUNT: $count TASK: $task"); //simpleTask will be emitted here.
      await storage.write(backgroundConter, count + 1);
      print(DateTime.now());
      await Future.delayed(Duration(seconds: 7));
      return Future.value(true);
    },
  ),
  BackgroundWorkManagerTask(
    uniqueName: 'main_task_two',
    name: 'one_off_main_task_wto',
    type: BackgroundWorkManagerTaskType.periodic,
    frequency: Duration(minutes: 15),
    initialDelay: Duration(seconds: 2),
    executeFunction: (
      BackgroundWorkManagerTask task,
      Map<String, dynamic>? inputData,
    ) async {
      print("DAAAMM... got herer...");
      final storage = GetStorage();
      int count = storage.read<int>(backgroundConter) ?? 0;
      print(
          "Native called Bkaco background COUNT: $count TASK: $task"); //simpleTask will be emitted here.
      await storage.write(backgroundConter, count + 1);

      // Show notification with updated count
      await showTaskNotification(count + 1);

      print(DateTime.now());
      await Future.delayed(Duration(minutes: 1));
      return Future.value(true);
    },
  ),
  BackgroundWorkManagerTask(
    uniqueName: 'main_task_three',
    name: 'one_off_main_task_three',
    type: BackgroundWorkManagerTaskType.oneOff,
    frequency: Duration(minutes: 15),
    initialDelay: Duration(seconds: 2),
    executeFunction: (
      BackgroundWorkManagerTask task,
      Map<String, dynamic>? inputData,
    ) async {
      print("DAAAMM... got herer...");
      final storage = GetStorage();
      int count = storage.read<int>(backgroundConter) ?? 0;
      print(
          "Native called Bkaco background COUNT: $count TASK: $task"); //simpleTask will be emitted here.
      await storage.write(backgroundConter, count + 1);
      print(DateTime.now());
      await Future.delayed(Duration(seconds: 7));
      return Future.value(true);
    },
  ),
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

Future<void> initalizeNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // For task's own data storage (backgroundConter)
  await initalizeNotifications();

  var workManController = Get.put(BackgroundWorkManagerController(
    callbackDispatcher: callbackDispatcher,
    tasks: tasks,
    isInDebugMode: true,
  ));

  await workManController.initializeBackgroundWorkManager();
  await workManController.registerTasks();
  await workManController.loadTaskStatuses();

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
                      'Background Counter:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Obx(() {
                      final storage = GetStorage();
                      int count = storage.read<int>(backgroundConter) ?? 0;
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
