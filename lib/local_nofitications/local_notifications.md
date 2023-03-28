# Local Notifications

## Installation

Add `flutter_local_notifications: ^13.0.0` to your `pubspec.yaml`

## Android setup

In the `android/app/build.gradle`

```config

android {
  defaultConfig {
    multiDexEnabled true
    minSdkVersion 16
    targetSdkVersion 33 // Important. Fails to request permission on android 13
  }

  compileOptions {
    // Flag to enable support for the new language APIs
    coreLibraryDesugaringEnabled true
    // Sets Java compatibility to Java 8
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
  }
}

dependencies {
  coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.1.5'
  implementation 'androidx.window:window:1.0.0'
  implementation 'androidx.window:window-java:1.0.0'
}
```

In  `android/build.gradle`

```config

buildscript {
   ...

    dependencies {
        classpath 'com.android.tools.build:gradle:4.2.2'
        ...
    }


```

## Dart Setup

1. Create a background callback handler

```dart
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}
```

2. In the main initialize the LocalNotificationController and pass the previously created function

```dart
 var notificationCont = Get.put(LocalNotificationController(
      notificationTapBackground: notificationTapBackground));

  await notificationCont.initializeLocalNotifications();

```

### Setup Done

## Sending Notification

Uses the `FlutterLocalNotificationsPlugin.show`, so pass any arguments as defined on their documentation [here](https://pub.dev/packages/flutter_local_notifications)
Example

```dart

var notCont =
                                Get.find<LocalNotificationController>();
                            notCont.counter.value = notCont.counter.value + 1;
                            const AndroidNotificationDetails
                                androidNotificationDetails =
                                AndroidNotificationDetails('B0', 'Basic',
                                    channelDescription:
                                        'For testing purposes nothing more',
                                    importance: Importance.max,
                                    priority: Priority.high,
                                    ticker: 'ticker');
                            const NotificationDetails notificationDetails =
                                NotificationDetails(
                              android: androidNotificationDetails,
                            );
                            notCont.showBasicNotification(
                                notCont.counter.value,
                                "Hello ${notCont.counter.value}",
                                "THis is the body",
                                notificationDetails);
```
