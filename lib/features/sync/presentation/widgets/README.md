# Conflict Resolution UI Widgets

This directory contains Flutter widgets for displaying and resolving sync conflicts in the SoloAdventurer app.

## Overview

The conflict resolution UI provides a user-friendly way to handle data synchronization conflicts that occur when the same entity is modified on multiple devices.

## Widgets

### 1. ConflictResolutionDialog

A modal dialog that displays detailed information about a conflict and allows the user to choose how to resolve it.

**Features:**
- Side-by-side comparison of local and remote versions
- Visual severity indicators
- Entity information display
- Three resolution options:
  - Keep Local: Retain the local version
  - Keep Remote: Use the remote version
  - Merge: Combine versions (optional, when `canMerge=true`)
- Responsive design (side-by-side on large screens, stacked on small screens)

**Usage:**
```dart
final choice = await ConflictResolutionDialog.show(
  context: context,
  conflict: conflictInfo,
  canMerge: true, // Optional: show merge option
);

if (choice != null) {
  switch (choice) {
    case ManualResolutionChoice.keepLocal:
      // Handle keep local
      break;
    case ManualResolutionChoice.keepRemote:
      // Handle keep remote
      break;
    case ManualResolutionChoice.customMerge:
      // Handle merge
      break;
  }
}
```

### 2. ConflictComparisonView

A side-by-side comparison widget that displays the differences between local and remote versions of a conflicted entity.

**Features:**
- Visual comparison cards with color-coded borders
- Version metadata display:
  - Version number
  - Last modified timestamp (relative time)
  - Device ID
  - Data hash
- Data field comparison (up to 10 fields)
- Responsive layout
- Truncation for long values

**Usage:**
```dart
ConflictComparisonView(
  conflict: conflictInfo,
)
```

### 3. ConflictListView

A scrollable list view for displaying multiple conflicts.

**Features:**
- Card-based layout for each conflict
- Severity-based color coding
- Quick access to conflict details
- Optional auto-resolve button
- Empty state when no conflicts exist
- Conflict summary with timestamps

**Usage:**
```dart
ConflictListView(
  conflicts: conflictList,
  onConflictSelected: (conflict) {
    // Navigate to resolution dialog
  },
  onAutoResolve: () {
    // Auto-resolve low-severity conflicts
  },
  canAutoResolve: true,
)
```

### 4. ConflictBanner

A dismissible banner widget for alerting users about a single conflict.

**Features:**
- Compact alert design
- Severity-based styling
- Quick resolve button
- Optional dismiss action
- Conflict description

**Usage:**
```dart
ConflictBanner(
  conflict: conflictInfo,
  onResolve: () {
    // Show resolution dialog
  },
  onDismiss: () {
    // Dismiss banner
  },
  isDismissible: true,
)
```

### 5. MultipleConflictsBanner

A banner widget for alerting users about multiple conflicts.

**Features:**
- Shows count and severity breakdown
- Gradient background
- View all action
- Optional dismiss action

**Usage:**
```dart
MultipleConflictsBanner(
  conflicts: conflictList,
  onViewAll: () {
    // Navigate to conflict list
  },
  onDismiss: () {
    // Dismiss banner
  },
  isDismissible: true,
)
```

## Design Patterns

### Responsive Design

All widgets are designed to work on various screen sizes:
- **Small screens (< 500px)**: Vertical stacking
- **Large screens (>= 500px)**: Side-by-side layout

### Material 3 Design

- Uses Material 3 components and theming
- Follows app color scheme (primary, secondary, error colors)
- Proper elevation and border radius
- Accessible contrast ratios

### Severity-Based Styling

Visual indicators based on conflict severity:
- **Low (Orange)**: Warning icons, orange accents
- **Medium (Deep Orange)**: Error icons, deep orange accents
- **High (Red)**: Dangerous icons, error color scheme

## Integration with Domain Layer

These widgets integrate seamlessly with the conflict detection and resolution domain models:

- `ConflictInfo`: Contains all conflict information
- `EntityVersion`: Version metadata for display
- `ConflictType`: Determines icon and messaging
- `ConflictSeverity`: Determines color coding and urgency
- `ManualResolutionChoice`: User's resolution selection

## Example Integration

See `conflict_widgets_example.dart` for complete integration examples including:

1. **Basic usage**: Simple conflict resolution
2. **Multiple conflicts**: Handling several conflicts at once
3. **Full workflow**: Integration with sync services

## Testing

Widget tests are provided in:
- `test/features/sync/presentation/widgets/conflict_resolution_dialog_test.dart`
- `test/features/sync/presentation/widgets/conflict_comparison_view_test.dart`

Run tests with:
```bash
flutter test test/features/sync/presentation/widgets/
```

## Accessibility

All widgets include:
- Semantic labels for screen readers
- Proper contrast ratios
- Touch target sizes (minimum 44x44 for interactive elements)
- Focus management for keyboard navigation

## Performance Considerations

- Lists use `ListView.separated` for efficiency
- Data fields are limited to 10 items to prevent overflow
- Long values are truncated with ellipsis
- Widgets are const where possible for optimal rebuild performance
