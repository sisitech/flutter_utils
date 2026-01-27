# Android Setup

Android uses the native WorkManager API for background task execution. Most setup is handled automatically by the plugin.

## Requirements

- Minimum SDK: Configured in your `android/app/build.gradle`
- Target SDK: 33+ recommended

## Configuration

### AndroidManifest.xml

No special configuration is required. The plugin automatically handles WorkManager registration.

Basic manifest structure (`android/app/src/main/AndroidManifest.xml`):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourapp.example">

    <application
        android:label="Your App"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

### build.gradle (app-level)

Ensure your `android/app/build.gradle` has proper configuration:

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace = "com.yourapp.example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId = "com.yourapp.example"
        minSdk = flutter.minSdkVersion
        targetSdk = 33
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}

flutter {
    source = "../.."
}
```

## Android-Specific Constraints

Android supports additional constraints not available on iOS:

| Constraint | Description |
|------------|-------------|
| `requiresBatteryNotLow` | Task won't run if device is in low battery mode |
| `requiresDeviceIdle` | Device must be inactive/idle |
| `requiresStorageNotLow` | Sufficient storage must be available |

### NetworkType Options (Android-specific)

| Value | Description |
|-------|-------------|
| `unmetered` | Requires WiFi connection |
| `notRoaming` | Requires non-roaming network |
| `temporarilyUnmetered` | Network currently unmetered but generally metered (Android 30+) |

## Debugging

### View Scheduled Jobs

```bash
# List all scheduled jobs for your app
adb shell dumpsys jobscheduler | grep yourapp

# Detailed job information
adb shell dumpsys jobscheduler yourapp

# View WorkManager logs
adb logcat | grep WorkManager
```

### Common Issues

1. **Battery Optimization**: Some devices aggressively kill background tasks
   - Solution: Ask users to disable battery optimization for your app

2. **Doze Mode**: Android limits background execution when device is idle
   - Solution: Use appropriate constraints and accept delays

3. **App Standby**: Apps in standby have limited background execution
   - Solution: Ensure your app is actively used or has appropriate permissions

4. **Android 12+ Restrictions**: Stricter background execution limits
   - Solution: Use WorkManager constraints appropriately

## Best Practices

1. **Use constraints wisely**: Don't require more than necessary
2. **Handle failures gracefully**: Tasks may be delayed or rescheduled
3. **Keep tasks short**: Long-running tasks may be killed
4. **Test on multiple devices**: Background behavior varies by manufacturer
5. **Log extensively**: Add logging to track task execution in production
