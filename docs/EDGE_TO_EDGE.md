# Edge-to-Edge Display Support

This document covers edge-to-edge display configuration for modern Android gesture navigation.

## Overview

Edge-to-edge display allows your app content to extend behind the system bars (status bar and navigation bar), providing a more immersive experience. This is especially important for:
- Modern Android devices with gesture navigation
- Devices with notches or camera cutouts
- Creating a seamless, full-screen experience

## Setup

Enable edge-to-edge in your `main.dart` after `initapp()`:

```dart
import 'package:flutter/services.dart';

void main() async {
  await initapp();

  // Enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}
```

## SafeArea Patterns

### Pattern 1: Screens With AppBar

For screens using `Scaffold` with an `AppBar`, the AppBar handles the top inset automatically. Use `SafeArea(top: false)` on the body:

```dart
Scaffold(
  appBar: AppBar(title: const Text('My Screen')),
  body: SafeArea(
    top: false, // AppBar handles top inset
    child: YourContent(),
  ),
)
```

**Example:** `lib/home/mpesa_messages_list.dart`

### Pattern 2: Screens Without AppBar

For screens without an AppBar (custom headers, full-screen content), wrap the entire content in a full `SafeArea`:

```dart
Material(
  child: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: YourContent(),
    ),
  ),
)
```

**Examples:**
- `lib/reports/reports_view.dart`
- `lib/spending_limits/pages/spend_limits_view.dart`

## Implementation Reference

| Screen | Pattern | SafeArea Config |
|--------|---------|-----------------|
| `MpesaMessageHomeView` | With AppBar | `SafeArea(top: false)` on body |
| `ReportsView` | Without AppBar | Full `SafeArea` wrapper |
| `SpendLimitsView` | Without AppBar | Full `SafeArea` wrapper |

## Adding SafeArea to New Screens

When creating new screens:

1. **Determine if the screen has an AppBar**
   - Yes → Use `SafeArea(top: false)` on the body
   - No → Wrap entire content in `SafeArea`

2. **Always protect the bottom**
   - Navigation gestures need space at the bottom
   - `SafeArea` handles this automatically

3. **Consider bottom sheets and FABs**
   - Bottom sheets should have their own SafeArea handling
   - FABs positioned above the navigation bar automatically

## Key Files

| File | Purpose |
|------|---------|
| `sms_transaction_parser_example/lib/main.dart` | Edge-to-edge SystemChrome configuration |
| `lib/home/mpesa_messages_list.dart` | Pattern 1 example (with AppBar) |
| `lib/reports/reports_view.dart` | Pattern 2 example (without AppBar) |
| `lib/spending_limits/pages/spend_limits_view.dart` | Pattern 2 example (without AppBar) |
