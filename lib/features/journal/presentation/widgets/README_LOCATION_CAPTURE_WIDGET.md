# Location Capture Widget

A comprehensive Flutter widget for capturing and displaying location data in journal entry creation. Provides automatic location capture with user-friendly UI and error handling.

## Features

- ✅ Automatic location capture with loading states
- ✅ Visual display of captured location (coordinates, accuracy)
- ✅ Update and remove location functionality
- ✅ Accuracy indicator with color coding
- ✅ Error handling with user-friendly messages
- ✅ Compact and full display modes
- ✅ Simple inline button variant for minimal UI
- ✅ Full Material Design 3 integration
- ✅ Theme-aware styling

## Usage

### Basic Widget

```dart
import 'package:soloadventurer/features/journal/presentation/widgets/location_capture_widget.dart';

// In your journal entry creation screen
class CreateJournalEntryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Other form fields...

            // Location capture widget
            LocationCaptureWidget(),

            // Other form fields...
          ],
        ),
      ),
    );
  }
}
```

### Compact Mode

For smaller spaces or inline display:

```dart
LocationCaptureWidget(
  isCompact: true,
  padding: EdgeInsets.all(8),
)
```

### Simple Button

For a minimal button that doesn't show details inline:

```dart
// In app bar or toolbar
AppBar(
  title: Text('Create Entry'),
  actions: [
    LocationCaptureButton(
      label: 'Add location',
      capturedIcon: Icons.location_on,
      uncapturedIcon: Icons.location_on_outlined,
    ),
  ],
),
```

### With Custom Padding

```dart
LocationCaptureWidget(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
)
```

## Widget Behavior

### Initial State (No Location Set)

- Shows "Capture Current Location" button
- Displays helper text explaining the purpose
- Button is centered with prominent styling

### Capturing State

- Shows loading spinner
- Disables user interaction
- Displays "Capturing location..." message

### Location Set

- Shows location details card with:
  - Coordinates (latitude, longitude)
  - Location name (if available)
  - Accuracy indicator with color coding
  - "Added" badge
- Two action buttons:
  - "Update Location" - Capture new location
  - "Remove" - Clear location data

### Error States

- Shows error container with icon
- Displays error message
- Close button to dismiss error
- Handles:
  - Permission denied
  - Location service disabled
  - Poor accuracy
  - Capture timeout
  - Generic errors

## Accuracy Indicator

The widget provides visual feedback on location accuracy:

| Accuracy | Color | Icon | Label |
|----------|-------|------|-------|
| ≤ 10m | Green | Check circle | Good |
| ≤ 50m | Green | Check | Good |
| ≤ 100m | Orange | Info | Fair |
| > 100m | Red | Warning | Poor |

## Integration Example

### Full Journal Entry Creation Screen

```dart
class CreateJournalEntryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationState = ref.watch(journalEntryCreationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('New Journal Entry'),
        actions: [
          // Simple location button in app bar
          LocationCaptureButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title field
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: creationState.error?.contains('title') == true
                    ? 'Title is required'
                    : null,
              ),
              onChanged: ref
                  .read(journalEntryCreationProvider.notifier)
                  .updateTitle,
            ),

            SizedBox(height: 16),

            // Date picker
            // ...

            SizedBox(height: 16),

            // Rich text editor
            // ...

            SizedBox(height: 16),

            // Full location widget in form
            LocationCaptureWidget(),

            SizedBox(height: 16),

            // Mood selector
            // ...

            SizedBox(height: 16),

            // Favorite toggle
            // ...

            // Save button
            ElevatedButton(
              onPressed: creationState.isValid && !creationState.isSaving
                  ? () async {
                      final success = await ref
                          .read(journalEntryCreationProvider.notifier)
                          .saveEntry();
                      if (success && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    }
                  : null,
              child: creationState.isSaving
                  ? CircularProgressIndicator()
                  : Text('Save Entry'),
            ),

            // Show global errors
            if (creationState.error != null)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  creationState.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

## Provider Integration

The widget integrates with `JournalEntryCreationNotifier` which provides:

### State

- `latitude: double?` - Captured latitude
- `longitude: double?` - Captured longitude
- `locationAccuracy: double?` - Accuracy in meters
- `locationName: String?` - Human-readable name
- `isCapturingLocation: bool` - Currently capturing
- `error: String?` - Error message if any

### Methods

- `captureCurrentLocation()` - Capture device location
- `clearLocation()` - Remove location data
- `updateLocation(...)` - Manually set location

## Customization

### Custom Styling

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.blue),
  ),
  child: LocationCaptureWidget(
    padding: EdgeInsets.zero,
  ),
)
```

### Custom Error Handling

```dart
// Watch for errors and show custom UI
class MyCustomLocationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<JournalEntryCreationState>(
      journalEntryCreationProvider,
      (previous, next) {
        if (next.error?.contains('location') == true) {
          // Custom error handling
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Location Error'),
              content: Text(next.error!),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(journalEntryCreationProvider.notifier).clearError();
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      },
    );

    return LocationCaptureWidget();
  }
}
```

## Error Messages

The widget handles and displays these common errors:

| Error | Message | Action |
|-------|---------|--------|
| Permission denied | "Location permission denied" | User needs to grant permission in settings |
| Service disabled | "Location service is disabled" | User needs to enable location services |
| Poor accuracy | "Location accuracy is poor" | Suggests moving to open area or retry |
| Timeout | "Location capture failed" | Generic capture failure |
| Other | "Failed to capture location" | Shows error details |

## Best Practices

1. **Place prominently**: Add the widget where users will easily find it
2. **Show both modes**: Consider using both the button and full widget in different contexts
3. **Handle errors**: Always check for and handle location errors
4. **Provide feedback**: The widget automatically shows loading states
5. **Respect privacy**: Always provide option to remove location
6. **Test permissions**: Test on both Android and iOS with various permission states

## Platform Considerations

### Android
- Requires location permissions in AndroidManifest.xml
- May require enabling location services
- Background location requires additional permission (Android 10+)

### iOS
- Requires location usage descriptions in Info.plist
- User may grant "When in Use" or "Always" permission
- May require user to enable location in system settings

## Accessibility

- Semantic labels for screen readers
- Loading states announced
- Error messages announced
- Touch targets sized appropriately (48x48 minimum)
- Color not the only indicator (icons and text used)

## Future Enhancements

- [ ] Map preview of captured location
- [ ] Manual location picker on a map
- [ ] Location name autocomplete
- [ ] Altitude and speed display
- [ ] Location history for the entry
- [ ] Reverse geocoding integration (coordinates → address)

## Related Components

- **LocationService** - Backend service for location capture
- **JournalEntryCreationNotifier** - State management provider
- **CreateJournalEntryScreen** - Main creation screen
- **Rich Text Editor** - Another component in the creation flow

## Troubleshooting

### Widget not capturing location
- Ensure permissions are granted
- Check if location service is enabled
- Test on physical device (simulator may have issues)

### Poor accuracy shown
- Move near a window or go outside
- Try again with better GPS signal
- Consider using cached location if acceptable

### Error not clearing
- Ensure `clearError()` is being called
- Check if error contains "location" substring
- Verify provider is being watched correctly

## Performance

- Location capture takes 5-15 seconds typically
- Loading state prevents duplicate captures
- Accuracy check prevents storing poor location data
- Widget rebuilds optimized with ConsumerWidget

## Testing

```dart
// Test location capture
testWidgets('captures location when button pressed', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        journalEntryCreationProvider.overrideWith((ref) {
          return MockJournalEntryCreationNotifier();
        }),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: LocationCaptureWidget(),
        ),
      ),
    ),
  );

  // Tap capture button
  await tester.tap(find.text('Capture Current Location'));
  await tester.pump();

  // Verify capturing state
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Contributing

When modifying the widget:
1. Maintain Material Design 3 guidelines
2. Ensure all error states are handled
3. Test on both light and dark themes
4. Verify accessibility with screen reader
5. Update this README with new features
