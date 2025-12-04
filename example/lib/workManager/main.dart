import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_utils/workmanager/controller.dart';
import 'package:flutter_utils/workmanager/utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';

const backgroundConter = "BACKGROUND_COUNTER";

List<BackgroundWorkManagerTask> tasks = [
  BackgroundWorkManagerTask(
    uniqueName: 'main_task',
    name: 'one_off_main_task',
    type: BackgroundWorkManagerTaskType.oneOff,
    frequency: Duration(minutes: 15),
    initialDelay: Duration(seconds: 2),
    removeAndCleanupTasks: true,
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
      print(DateTime.now());
      await Future.delayed(Duration(seconds: 7));
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
      await GetStorage.init();
    },
  );
}

Future<void> initalizeNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initalizeNotifications();
  var workManSerializer = Get.put(BackgroundWorkManagerController(
    callbackDispatcher: callbackDispatcher,
    tasks: tasks,
    isInDebugMode: true,
  ));

  await workManSerializer.cancelAll();
  await workManSerializer.registerTasks();
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
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Text("Hello Adae"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
