import UIKit
import Flutter
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register WorkManager for iOS background tasks
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }

    // Set notification center delegate for tap handling
    // This enables flutter_local_notifications to receive notification taps
    // when the app is launched from terminated state
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
