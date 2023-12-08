import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_utils/flutter_utils.dart';

import 'package:get/get.dart';

class LocalNotificationController extends SuperController {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Function(NotificationResponse)? notificationTapBackground;

  LocalNotificationController({required this.notificationTapBackground});

  Rx<bool> permissionGranted = Rx(false);
  Rx<int> counter = Rx(0);
  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // initializeLocalNotifications();
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  initializeLocalNotifications(
      {String defaultIcon = "@mipmap/ic_launcher"}) async {
    if (!Platform.isAndroid) {
      dprint("Ignoring non android platfroms");
      return;
    }
    // Initialization  setting for android
    InitializationSettings initializationSettingsAndroid =
        InitializationSettings(
      android: AndroidInitializationSettings(defaultIcon),
    );

    _notificationsPlugin.initialize(
      initializationSettingsAndroid,
      // to handle event when we receive notification
      // onSelectNotification: (details) {
      // },
    );

    await _notificationsPlugin.initialize(
      initializationSettingsAndroid,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        dprint(notificationResponse.payload);
        dprint(notificationResponse);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _isAndroidPermissionGranted();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      permissionGranted.value = granted;
      dprint("The permission is $granted");
      if (!granted) {
        dprint("Trying to gain permission.");
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final bool? granted = await androidImplementation?.requestPermission();
        permissionGranted.value = granted ?? false;

        dprint("Got the permission is $granted");
      }
    }
  }

  Future<void> showBasicNotification(int id, String? title, String? body,
      NotificationDetails notificationDetails,
      {dynamic payload}) async {
    if (!Platform.isAndroid) {
      dprint("Ignoring non android platfroms");
      return;
    }
    await _notificationsPlugin.show(id, title, body, notificationDetails,
        payload: payload);
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }
}
