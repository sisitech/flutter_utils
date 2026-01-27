# Wavvy Wallet Design System

## Table of Contents
- [Theme Configuration](#theme-configuration)
- [Color System](#color-system)
- [Typography](#typography)
- [Component Styling](#component-styling)
- [Effects](#effects)
- [Layout](#layout)
- [Navigation](#navigation)

## Theme Configuration

The app uses a custom theme system built on top of Material 3 with the following key characteristics:

### Base Theme
- Uses `flex_color_scheme` package
- Default scheme: `FlexScheme.indigo`
- Surface mode: `FlexSurfaceMode.levelSurfacesLowScaffold`
- Blend level: 15
- Font family: Montserrat (Google Fonts)

### Material 3 Settings
- Uses Material 3 (`useMaterial3: true`)
- Swaps legacy on Material 3 (`swapLegacyOnMaterial3: true`)
- Comfortable platform density

## Color System

### Primary Colors
- Primary color with opacity variations (0.05 to 0.3)
- Secondary color with opacity variations
- Tertiary color with opacity variations
- Surface colors with opacity variations

### Gradients

#### Primary to Secondary Gradient
```dart
LinearGradient(
  colors: [
    theme.colorScheme.primary,
    theme.colorScheme.secondary,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

#### Faded Primary Gradient
```dart
LinearGradient(
  colors: [
    theme.colorScheme.primary.withValues(alpha: 0.15),
    theme.colorScheme.primary.withValues(alpha: 0.05),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

## Typography

### Font Family
- Primary font: Montserrat
- Text styles follow Material 3 typography scale
- Common text opacity: 0.7 for secondary text

### Text Styles
- Headlines: Bold weight
- Body text: Regular weight
- Labels: Medium weight
- Secondary text: 70% opacity

## Component Styling

### Cards
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16.0),
    boxShadow: [
      BoxShadow(
        color: theme.shadowColor.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: theme.colorScheme.primary.withValues(alpha: 0.2),
      width: 1.5,
    ),
  ),
)
```

### Dialogs
- Border radius: 16.0
- Elevation: 2
- Background: Surface color
- Common padding: 24.0

### Buttons
- Border radius: 12.0
- Gradient backgrounds
- Icon + text combinations
- Common padding: 12.0 vertical

## Effects

### Glassmorphism
```dart
Container(
  decoration: BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: theme.shadowColor.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
    border: Border.all(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      width: 1,
    ),
  ),
)
```

### Animations

#### Scale Animation
```dart
TweenAnimationBuilder<double>(
  tween: Tween<double>(begin: 0.95, end: 1.0),
  duration: const Duration(milliseconds: 800),
  curve: Curves.easeOutBack,
  builder: (context, value, child) {
    return Transform.scale(
      scale: value,
      child: child,
    );
  },
  child: // Your widget
)
```

#### Fade Animation
```dart
TweenAnimationBuilder<double>(
  tween: Tween<double>(begin: 0, end: 1),
  duration: Duration(milliseconds: 800),
  curve: Curves.easeOut,
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: child,
    );
  },
  child: // Your widget
)
```

## Layout

### Spacing
- Common padding: 16.0, 24.0
- Common margin: 8.0, 16.0
- Common gap: 12.0

### Border Radius
- Cards: 16.0
- Buttons: 12.0
- Dialogs: 16.0
- Menu items: 8.0

## Navigation

### Bottom Navigation Bar
- Elevation: 2
- Opacity: 0.95
- Selected label color: Primary
- Unselected label color: OnSurface

### App Bar
- Background: Surface color
- Title style: Title large with onPrimary color
- Icon theme: onPrimary color

## Usage Examples

### Creating a Card with Glassmorphism
```dart
Container(
  margin: const EdgeInsets.all(16.0),
  padding: const EdgeInsets.all(24.0),
  decoration: BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(16.0),
    boxShadow: [
      BoxShadow(
        color: theme.shadowColor.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
    border: Border.all(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      width: 1,
    ),
  ),
  child: // Your content
)
```

### Creating a Gradient Button
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.0),
    gradient: LinearGradient(
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: theme.colorScheme.primary.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
    ),
    child: Text(
      'Button Text',
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
``` 