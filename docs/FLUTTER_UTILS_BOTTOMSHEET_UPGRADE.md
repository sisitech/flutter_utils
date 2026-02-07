# Flutter Utils: DraggableScrollableSheet Upgrade Guide

This document provides implementation instructions for upgrading `getBottomSheetScaffold` in the `flutter_utils` repository to use `DraggableScrollableSheet` instead of fixed-height containers.

## Current Implementation Issues

The current `getBottomSheetScaffold` in `lib/widgets/global_widgets.dart` (lines 136-193) has limitations:

1. **Fixed Height**: Uses a hardcoded `MediaQuery.of(context).size.height * 0.85` height
2. **No Drag-to-Resize**: Users cannot drag to expand/collapse the sheet
3. **Scroll Conflicts**: `SingleChildScrollView` inside fixed container can cause nested scroll issues
4. **No ScrollController Access**: Children cannot coordinate scrolling with the sheet drag behavior

## Target File

**Repository:** `flutter_utils`
**File:** `lib/widgets/global_widgets.dart`
**Function:** `getBottomSheetScaffold`

## New Implementation

Replace the existing `getBottomSheetScaffold` function with this implementation:

```dart
Widget getBottomSheetScaffold(
  BuildContext context, {
  String? title,
  String? subtitle,
  List<Widget>? children,
  Widget Function(BuildContext context, ScrollController scrollController)? childBuilder,
  Widget? leading,
  Widget? trailing,
  Color? bgColor,
  Color? handleBarColor,
  double? handleBarWidth,
  bool showHandle = true,
  double initialChildSize = 0.5,
  double minChildSize = 0.25,
  double maxChildSize = 0.85,
  bool expand = true,
  bool snap = false,
  List<double>? snapSizes,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return DraggableScrollableSheet(
    initialChildSize: initialChildSize,
    minChildSize: minChildSize,
    maxChildSize: maxChildSize,
    expand: expand,
    snap: snap,
    snapSizes: snapSizes,
    builder: (context, scrollController) {
      return Container(
        decoration: BoxDecoration(
          color: bgColor ?? colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            if (showHandle)
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: handleBarWidth ?? 40,
                height: 4,
                decoration: BoxDecoration(
                  color: handleBarColor ?? colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            // Title section
            if (title != null || leading != null || trailing != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    if (leading != null) leading,
                    if (leading != null) const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing,
                  ],
                ),
              ),
            // Content - use childBuilder if provided, otherwise wrap children in ListView
            Expanded(
              child: childBuilder != null
                  ? childBuilder(context, scrollController)
                  : ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: children ?? [],
                    ),
            ),
          ],
        ),
      );
    },
  );
}
```

## Parameter Reference

### Existing Parameters (Maintained)
| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | `String?` | Header title text |
| `subtitle` | `String?` | Header subtitle text |
| `children` | `List<Widget>?` | Content widgets (backwards compatible) |
| `leading` | `Widget?` | Leading widget in header |
| `trailing` | `Widget?` | Trailing widget in header |
| `bgColor` | `Color?` | Background color |
| `handleBarColor` | `Color?` | Drag handle color |
| `handleBarWidth` | `double?` | Drag handle width |
| `showHandle` | `bool` | Whether to show drag handle |

### New Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `childBuilder` | `Widget Function(BuildContext, ScrollController)?` | `null` | Builder that provides scroll controller for coordinated scrolling |
| `initialChildSize` | `double` | `0.5` | Initial height as fraction of parent (0.0-1.0) |
| `minChildSize` | `double` | `0.25` | Minimum height when dragged down |
| `maxChildSize` | `double` | `0.85` | Maximum height when dragged up |
| `expand` | `bool` | `true` | Whether to expand to fill available space |
| `snap` | `bool` | `false` | Whether to snap to snap sizes |
| `snapSizes` | `List<double>?` | `null` | Sizes to snap to (requires `snap: true`) |

## Migration Guide

### Scenario 1: Simple Content (No Changes Required)

Existing code using `children` continues to work:

```dart
// Before and After - No changes needed
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => getBottomSheetScaffold(
    context,
    title: 'Settings',
    children: [
      ListTile(title: Text('Option 1')),
      ListTile(title: Text('Option 2')),
    ],
  ),
);
```

### Scenario 2: Custom Sizing

Add sizing parameters:

```dart
// After - With custom sizing
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => getBottomSheetScaffold(
    context,
    title: 'Full Screen Sheet',
    initialChildSize: 0.7,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    children: [/* widgets */],
  ),
);
```

### Scenario 3: Coordinated Scrolling with childBuilder

Use `childBuilder` when you need the scroll controller for lists:

```dart
// After - Using childBuilder for coordinated scrolling
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => getBottomSheetScaffold(
    context,
    title: 'Transactions',
    initialChildSize: 0.6,
    maxChildSize: 0.95,
    childBuilder: (context, scrollController) {
      return ListView.builder(
        controller: scrollController, // Required for drag-to-scroll coordination
        itemCount: transactions.length,
        itemBuilder: (context, index) => TransactionTile(transactions[index]),
      );
    },
  ),
);
```

### Scenario 4: Snap Behavior

Enable snapping to predefined sizes:

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => getBottomSheetScaffold(
    context,
    title: 'Expandable Sheet',
    initialChildSize: 0.4,
    minChildSize: 0.2,
    maxChildSize: 0.9,
    snap: true,
    snapSizes: [0.4, 0.7, 0.9],
    children: [/* widgets */],
  ),
);
```

## Important Notes

### showModalBottomSheet Configuration

When using `DraggableScrollableSheet`, ensure the modal is configured correctly:

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,  // Required for DraggableScrollableSheet
  useSafeArea: true,         // Recommended
  backgroundColor: Colors.transparent, // Let sheet handle its own background
  builder: (context) => getBottomSheetScaffold(context, ...),
);
```

### Handling Keyboard

For bottom sheets with text fields, wrap content appropriately:

```dart
childBuilder: (context, scrollController) {
  return SingleChildScrollView(
    controller: scrollController,
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Column(children: [/* form fields */]),
  );
},
```

## Testing Instructions

1. **Basic Functionality Test**
   - Open a bottom sheet with `children` parameter
   - Verify it displays correctly
   - Drag handle up/down to resize

2. **childBuilder Test**
   - Open a bottom sheet with `childBuilder` and a `ListView`
   - Scroll the list - it should coordinate with drag behavior
   - When at top of list, dragging down should shrink the sheet

3. **Sizing Test**
   - Test `initialChildSize: 0.3` - should open at 30% height
   - Test `maxChildSize: 0.95` - should expand to 95%
   - Test `minChildSize: 0.1` - should collapse to 10%

4. **Snap Test**
   - Set `snap: true` with `snapSizes: [0.3, 0.6, 0.9]`
   - Drag and release - should snap to nearest size

5. **Backwards Compatibility**
   - Test existing callers without any changes
   - Should work identically to before (with default sizing)

## Example: Complete Usage in sms_transaction_parser

```dart
// In lib/mpesa_sync/widgets/expenses_details_popup.dart

void showExpensesBottomSheet(BuildContext context, List<MpesaMessage> expenses) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => getBottomSheetScaffold(
      context,
      title: 'Expenses',
      subtitle: '${expenses.length} transactions',
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      trailing: IconButton(
        icon: Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
      childBuilder: (context, scrollController) {
        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            return MpesaMessageCard(message: expenses[index]);
          },
        );
      },
    ),
  );
}
```

## Related Files

- `flutter_utils/lib/widgets/global_widgets.dart` - Main file to modify
- `sms_transaction_parser/lib/mpesa_sync/widgets/` - Example consumers
- `sms_transaction_parser/docs/EXPENSES_BOTTOM_SHEET_IMPLEMENTATION.md` - Related implementation
