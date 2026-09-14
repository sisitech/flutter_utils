# flutter_utils — Wavvy UX upstream

**Repo:** `sisitech/flutter_utils`  
**Wavvy pin today:** `3c09e7e`  
**Local reference (do not commit from pub-cache):**  
`~/.pub-cache/git/flutter_utils-3c09e7e936c98065004dbd9b57557e89eccf06b9/`

Please branch from latest `main`, apply the changes below, open a PR, and send back the **merge commit SHA** so Wavvy can bump `pubspec.yaml`.

---

## Summary

| Area | Change |
|------|--------|
| Bottom nav | `showBottomBar` to hide/show bar |
| Screen lock setup | Left-align Biometric/Password chooser + sticky Set Up Later |
| Product tour | Panel text uses `onPrimaryContainer` |
| AppBar helper | Bold title in `buildAppBar` |

---

## 1. Bottom navigation — `showBottomBar`

### `lib/bottom_navigation/bottom_controller.dart`

Add:

```dart
final showBottomBar = true.obs;
```

### `lib/bottom_navigation/bottom_navigation.dart`

In `SistchLayoutWithDrawerBottomNavigation`, only build the bar when shown:

```dart
bottomNavigationBar: bottomNavigationController.showBottomBar.value
    ? BottomNavigationBar(
        // existing properties unchanged
      )
    : null,
```

**Consumer (Wavvy):** sets `showBottomBar.value = false` during SMS import; restores `true` when done.

---

## 2. Screen lock setup UI

### `lib/screen_lock/widgets/screenlock.dart`

In `BaseScreenLockPage`, for `!controller.isSetupDone.value`:

**Replace** the centered Scaffold with:

- Scroll body, padding `EdgeInsets.fromLTRB(20, 24, 20, 16)`, `crossAxisAlignment: start`
- 56×56 mark: `Icons.lock_outline`, primary @ 0.12 alpha, radius 14
- Title: `title ?? "Secure Your App"` — `headlineSmall`, `w800`, `letterSpacing: -0.8`, start-aligned
- Subtitle: muted `bodyMedium` (alpha 0.55, fontSize 13, height 1.5). Default:
  `"Protect your financial data with a screen lock. Choose your preferred authentication method."`
- Full-width Biometric (if available) + Password buttons: left-aligned label/icon, radius 12, `surfaceContainerHighest`, elevation 0
- Sticky footer: left **Set Up Later** → `clearTriggerScreenLockSetup()` (same behavior as today)

Keep existing `buildPasswordCreationLock` / controller wiring. Do not change unlock/authenticated branches unless required to compile.

---

## 3. Product tour contrast

### `lib/product_tour/product_tour.dart` (`_TourOverlay`)

- Prefer `Theme.of(context)` over `Get.theme` alone
- Icon / step / title / description color: `colorScheme.onPrimaryContainer`
- Divider: `onPrimaryContainer.withValues(alpha: 0.4)`

---

## 4. Bold AppBar title

### `lib/widgets/global_widgets.dart` (`buildAppBar`)

```dart
Text(
  title,
  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
)
```

---

## Suggested PR

**Title:** `Wavvy UX: showBottomBar, screen lock setup layout, tour/AppBar polish`

**Acceptance**

1. `showBottomBar = false` hides bottom bar; `true` restores it
2. Screen lock setup is left-aligned with Biometric/Password + sticky Set Up Later
3. Tour panel text readable on primary-container background
4. `buildAppBar` titles are bold

**After merge:** reply with merge SHA for Wavvy `ref:` bump.

**Tip:** fastest path is copy the dirty files from the pub-cache folder listed above into a real clone.
