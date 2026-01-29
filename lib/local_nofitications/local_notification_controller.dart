import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_utils/flutter_utils.dart';

import 'package:get/get.dart';

/// Notification category ID for WorkManager-triggered notifications
const String workManagerNotificationCategoryId = 'SISITECH_WORK_TRIGGER';

/// Action ID for executing work from notification
const String workManagerExecuteActionId = 'EXECUTE_WORK';

/// Action ID for dismissing notification
const String workManagerDismissActionId = 'DISMISS';

class LocalNotificationController extends SuperController {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Function(NotificationResponse)? notificationTapBackground;

  /// Callback for iOS notification responses in foreground
  Function(NotificationResponse)? onNotificationResponse;

  /// List of Darwin notification categories for iOS action buttons
  List<DarwinNotificationCategory>? iosNotificationCategories;

  LocalNotificationController({
    required this.notificationTapBackground,
    this.onNotificationResponse,
    this.iosNotificationCategories,
  });

  Rx<bool> permissionGranted = Rx(false);
  Rx<int> counter = Rx(0);

  /// Get the notifications plugin instance for external use
  static FlutterLocalNotificationsPlugin get notificationsPlugin =>
      _notificationsPlugin;

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onHidden() {}

  /// Build the default WorkManager notification categories for iOS
  static List<DarwinNotificationCategory> buildWorkManagerCategories() {
    return [
      DarwinNotificationCategory(
        workManagerNotificationCategoryId,
        actions: [
          DarwinNotificationAction.plain(
            workManagerExecuteActionId,
            'Run Now',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            workManagerDismissActionId,
            'Dismiss',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
    ];
  }

  initializeLocalNotifications({
    String defaultIcon = "@mipmap/ic_launcher",
    bool requestIOSPermissionsOnInit = true,
  }) async {
    // Android initialization settings
    final androidSettings = AndroidInitializationSettings(defaultIcon);

    // iOS initialization settings with notification categories
    final allCategories = <DarwinNotificationCategory>[
      ...buildWorkManagerCategories(),
      ...?iosNotificationCategories,
    ];

    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: requestIOSPermissionsOnInit,
      requestBadgePermission: requestIOSPermissionsOnInit,
      requestSoundPermission: requestIOSPermissionsOnInit,
      notificationCategories: allCategories,
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        dprint("Notification response: ${notificationResponse.payload}");
        dprint("Action ID: ${notificationResponse.actionId}");

        // Call the foreground response handler if provided
        if (onNotificationResponse != null) {
          onNotificationResponse!(notificationResponse);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Request permissions based on platform
    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    } else if (Platform.isIOS) {
      if (requestIOSPermissionsOnInit) {
        await _requestIOSPermissions();
      }
    }
  }

  Future<void> _requestAndroidPermissions() async {
    final bool granted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;
    permissionGranted.value = granted;
    dprint("Android notification permission: $granted");

    if (!granted) {
      dprint("Requesting Android notification permission.");
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final requestedPermission =
          await androidImplementation?.requestNotificationsPermission();
      permissionGranted.value = requestedPermission ?? false;
      dprint("Android permission after request: $requestedPermission");
    }
  }

  Future<void> _requestIOSPermissions() async {
    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation == null) {
      dprint("iOS notification implementation not available");
      return;
    }

    final granted = await iosImplementation.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    permissionGranted.value = granted ?? false;
    dprint("iOS notification permission: ${permissionGranted.value}");
  }

  /// Request iOS permissions manually (useful if requestIOSPermissionsOnInit was false)
  Future<bool> requestIOSPermissions() async {
    if (!Platform.isIOS) return false;
    await _requestIOSPermissions();
    return permissionGranted.value;
  }

  Future<void> showBasicNotification(
    int id,
    String? title,
    String? body,
    NotificationDetails notificationDetails, {
    dynamic payload,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
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
