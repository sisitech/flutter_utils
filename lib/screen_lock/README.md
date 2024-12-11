# Screen Lock

## Usage

1. Initialize the `ScreenLockController` in the main.dart

- Define your lock Options
```dart
ScreenLockOptions(
  // Digits for authentication, if needed.
  promptOnStart: false, // We can manually trigger authentication if desired
  maxTries: 3,
  onMaxTriesExceeded: () {
    Get.back();
    Get.snackbar('Error', 'Maximum authentication attempts exceeded!');
  },
  // Create password configuration
  createTitle: const Text('Set a new Passcode'),
  createConfirmTitle: const Text('Confirm your Passcode'),
  createCancelButton: const Icon(Icons.arrow_back),
  createCanCancel: true,
  createDigits: 4,
  createMaxRetries: 3,
  createRetryDelay: const Duration(seconds: 5),

  // Authentication configuration
  authTitle: const Text('Enter your passcode'),
  authCancelButton: const Icon(Icons.arrow_back),
  authMaxRetries: 3,
  authCanCancel: true,
  authRetryDelay: const Duration(seconds: 5),
  onLock: ()async {
    Get.toNamed("/");
  },
  authFooter: ElevatedButton.icon(
      onPressed: () {
        print("Gount back");
        var cnt = Get.find<ScreenLockController>();
        cnt.clearStorage();
        Get.back();
      },
      icon: const Icon(Icons.question_mark),
      label: const Text('Forgot passcode?')),
);
```

```dart
  var controller = Get.put(ScreenLockController(options: lockOptions));

```


2. Wrap the component to be locked with `BaseScreenLockPage`

```dart
 home: const BaseScreenLockPage(
        child: ScreenLockSamplePage(),
      ),
```

TO lock 

```dart

var controller = Get.find<ScreenLockController>();
controller.lock()
```

