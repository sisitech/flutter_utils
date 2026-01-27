# iOS Setup

iOS uses BGTaskScheduler and Background Fetch APIs for background task execution. Additional configuration is required.

## Requirements

- iOS 14.0 or later recommended
- Physical device for testing (simulators don't support background execution)

## Setup Options

Choose based on your use case:

### Option A: Background Fetch (Simplest)

Best for non-critical data updates happening once daily.

**Info.plist** (`ios/Runner/Info.plist`):

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
</array>
```

No AppDelegate configuration needed. The system determines when to run.

### Option B: BGTaskScheduler (Processing Tasks)

Best for file uploads and complex operations with 30-second execution limit.

**Info.plist**:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>

<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
</array>
```

**AppDelegate.swift** (`ios/Runner/AppDelegate.swift`):

```swift
import UIKit
import Flutter
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Register background processing task
        WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "com.yourapp.processing")

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

### Option C: Periodic Tasks

Best for regular tasks with custom frequency (15+ minute minimum).

**Info.plist** (same as Option B):

```xml
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>

<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
</array>
```

**AppDelegate.swift**:

```swift
import UIKit
import Flutter
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Register periodic task
        WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "com.yourapp.periodic")

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

## Complete Info.plist Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>

    <key>CFBundleDisplayName</key>
    <string>Your App</string>

    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>

    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>

    <key>CFBundleName</key>
    <string>your_app</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>

    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>

    <key>LSRequiresIPhoneOS</key>
    <true/>

    <!-- Background Modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>processing</string>
    </array>

    <!-- Task Identifiers (for BGTaskScheduler) -->
    <key>BGTaskSchedulerPermittedIdentifiers</key>
    <array>
        <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    </array>

    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>

    <key>UIMainStoryboardFile</key>
    <string>Main</string>

    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
```

## Podfile Configuration

Ensure your `ios/Podfile` is properly configured:

```ruby
platform :ios, '14.0'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist."
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

## iOS Limitations

| Limitation | Details |
|------------|---------|
| Execution Time | 30-second maximum per task |
| Frequency | System determines optimal timing |
| Testing | Physical device required |
| Background Refresh | Must be enabled in iOS Settings |

## Debugging

### Xcode Debug Menu

1. Open Xcode and run your app
2. Go to **Debug > Simulate Background Fetch**
3. This triggers an immediate background fetch for testing

### Check Background Refresh Status

In your app, you can check if background refresh is enabled:

```dart
// Users must enable Background App Refresh in iOS Settings
// Settings > General > Background App Refresh
```

### Common Issues

1. **Simulator doesn't work**: Use physical device for testing
2. **Tasks never run**: Check "Background App Refresh" is enabled in iOS Settings
3. **Tasks killed early**: Keep execution under 30 seconds
4. **Inconsistent scheduling**: iOS controls when tasks actually run based on usage patterns

## Best Practices

1. **Keep tasks under 30 seconds**: iOS will kill longer-running tasks
2. **Test on physical devices**: Simulators don't support background execution
3. **Handle completion properly**: Always call completion handler
4. **Check user settings**: Background App Refresh can be disabled by user
5. **Design for unreliability**: iOS may delay or skip tasks based on system conditions
