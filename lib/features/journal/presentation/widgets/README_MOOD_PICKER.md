# MoodPicker Widget

A comprehensive Flutter widget for selecting and displaying moods in journal entries with emoji support.

## Features

- **Predefined Mood Options**: 7 carefully selected moods covering common travel emotions
- **Emoji Integration**: Each mood has a corresponding emoji for visual representation
- **Two Display Modes**: Full grid view and compact button variant
- **Provider Integration**: Seamless integration with Riverpod state management
- **Material Design 3**: Follows latest Material Design guidelines
- **Responsive Grid**: Automatic grid layout with 3 columns
- **Visual Feedback**: Clear selection indicators with color-coded states
- **Accessibility**: Proper semantic labels and touch targets
- **Customizable**: Flexible styling and padding options

## Installation

No additional dependencies required beyond the existing project dependencies:
- `flutter_riverpod` (already in project)
- Flutter SDK (latest stable)

## Mood Options

The following predefined moods are available:

| ID | Label | Emoji | Description |
|----|-------|-------|-------------|
| `happy` | Happy | 😊 | Joyful and positive |
| `adventurous` | Adventurous | 🤩 | Excited and ready to explore |
| `tired` | Tired | 😴 | Exhausted or needing rest |
| `sad` | Sad | 😢 | Feeling down or melancholic |
| `calm` | Calm | 😌 | Peaceful and relaxed |
| `surprised` | Surprised | 😲 | Amazed or shocked |
| `grateful` | Grateful | 🥰 | Appreciative and thankful |

## Quick Start

### Basic Usage

The simplest way to use MoodPicker is with the journal entry creation provider:

```dart
import 'package:soloadventurer/features/journal/presentation/widgets/mood_picker.dart';

// In your widget tree
const MoodPicker()
```

This will automatically integrate with `journalEntryCreationProvider` and handle mood selection.

### Compact Button Variant

For inline usage, use the compact button variant:

```dart
MoodPickerButton(
  selectedMoodId: creationState.mood,
)
```

This displays a button that opens a bottom sheet with mood options.

### With Journal Entry Creation Screen

Here's how to integrate MoodPicker into the journal entry creation flow:

```dart
class CreateJournalEntryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationState = ref.watch(journalEntryCreationProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ... other form fields ...

            // Mood picker
            const MoodPicker(),

            // ... rest of the form ...
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### MoodPicker

Full-sized mood picker widget with grid layout.

#### Parameters

- `selectedMoodId` (`String?`): Currently selected mood ID (optional, auto-reads from provider)
- `padding` (`EdgeInsetsGeometry?`): Custom padding for the widget
- `isCompact` (`bool`): Whether to show in compact mode (default: `false`)

#### Example

```dart
const MoodPicker(
  padding: EdgeInsets.all(16),
)
```

### MoodPickerButton

Compact button variant that opens a bottom sheet.

#### Parameters

- `selectedMoodId` (`String?`): Currently selected mood ID
- `padding` (`EdgeInsetsGeometry?`): Custom button padding

#### Example

```dart
MoodPickerButton(
  selectedMoodId: creationState.mood,
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
)
```

### MoodOptions

Static class containing mood options and helper methods.

#### Properties

- `all` (`List<MoodOption>`): List of all predefined mood options

#### Methods

- `findById(String id)`: Find mood by ID
- `findByLabel(String label)`: Find mood by label (case-insensitive)

#### Examples

```dart
// Get all moods
final allMoods = MoodOptions.all;

// Find by ID
final happyMood = MoodOptions.findById('happy');

// Find by label
final sadMood = MoodOptions.findByLabel('Sad');

// Access mood properties
print(happyMood.id);       // 'happy'
print(happyMood.label);    // 'Happy'
print(happyMood.emoji);    // '😊'
```

### MoodOption

Represents a single mood option.

#### Properties

- `id` (`String`): Unique identifier
- `label` (`String`): Display label
- `emoji` (`String`): Emoji representation

## Integration with Provider

The MoodPicker automatically integrates with the `journalEntryCreationProvider`. When a user selects a mood, it calls:

```dart
ref.read(journalEntryCreationProvider.notifier).updateMood(moodId);
```

To access the selected mood in your code:

```dart
final creationState = ref.watch(journalEntryCreationProvider);
final selectedMoodId = creationState.mood;

if (selectedMoodId != null) {
  final mood = MoodOptions.findById(selectedMoodId);
  print('Selected mood: ${mood!.label} ${mood.emoji}');
}
```

## Displaying Selected Moods

To display a selected mood (similar to the detail screen):

```dart
Widget _buildMoodDisplay(BuildContext context, String? moodId) {
  if (moodId == null) return const SizedBox.shrink();

  final mood = MoodOptions.findById(moodId);
  if (mood == null) return const SizedBox.shrink();

  final theme = Theme.of(context);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(mood.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(mood.label, style: theme.textTheme.titleMedium),
      ],
    ),
  );
}
```

## Customization

### Custom Styling

The MoodPicker uses Material Design 3 theming. Customize appearance by modifying your app's theme:

```dart
ThemeData(
  // Customize primary color for selection states
  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    primaryContainer: Colors.blue.shade100,
  ),
)
```

### Custom Padding

```dart
// Full picker
const MoodPicker(
  padding: EdgeInsets.all(24),
)

// Button variant
MoodPickerButton(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
)
```

### Standalone Usage

For custom state management without the provider:

```dart
class MyCustomMoodPicker extends StatefulWidget {
  @override
  State<MyCustomMoodPicker> createState() => _MyCustomMoodPickerState();
}

class _MyCustomMoodPickerState extends State<MyCustomMoodPicker> {
  String? _selectedMoodId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: MoodOptions.all.map((mood) {
        final isSelected = mood.id == _selectedMoodId;
        return InkWell(
          onTap: () => setState(() => _selectedMoodId = mood.id),
          child: Chip(
            label: Text('${mood.emoji} ${mood.label}'),
            selected: isSelected,
            onDeleted: isSelected
                ? () => setState(() => _selectedMoodId = null)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
```

## Advanced Usage

### Adding Custom Moods

To add custom moods, extend the `MoodOptions` class:

```dart
class CustomMoodOptions extends MoodOptions {
  static const excited = MoodOption(
    id: 'excited',
    label: 'Excited',
    emoji: '🎉',
  );

  static const List<MoodOption> allCustom = [
    ...MoodOptions.all,
    excited,
  ];
}
```

### Mood Persistence

The mood is automatically saved with the journal entry in the database through the existing provider integration. No additional persistence code is needed.

### Mood Analytics

To track mood usage across journal entries:

```dart
// Query journal entries grouped by mood
final entriesByMood = await repository.getEntriesGroupedByMood();

// Get most common mood
final mostCommon = entriesByMood.entries
    .reduce((a, b) => a.value.length > b.value.length ? a : b);
print('Most common mood: ${mostCommon.key}');
```

## Best Practices

1. **Always provide a clear option**: Users should be able to select no mood (clear selection)
2. **Use consistent placement**: Place mood picker in a consistent location in forms
3. **Provide visual feedback**: Selected moods should be visually distinct
4. **Keep moods simple**: Use the predefined moods rather than custom ones for consistency
5. **Display emoji prominently**: Emojis are the primary visual identifier for moods
6. **Respect user preferences**: Remember previously selected moods (if applicable)

## Testing

```dart
testWidgets('MoodPicker updates provider on selection', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: const MoodPicker(),
    ),
  );

  // Tap on happy mood
  await tester.tap(find.text('Happy'));
  await tester.pump();

  // Verify mood was updated in provider
  final container = testerProviderContainer();
  final creationState = container.read(journalEntryCreationProvider);
  expect(creationState.mood, equals('happy'));
});

testWidgets('MoodPickerButton opens bottom sheet', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: MoodPickerButton(),
        ),
      ),
    ),
  );

  // Tap the button
  await tester.tap(find.byType(MoodPickerButton));
  await tester.pumpAndSettle();

  // Verify bottom sheet opened
  expect(find.text('How are you feeling?'), findsOneWidget);
});
```

## Troubleshooting

### Mood not updating in provider

**Issue**: Selecting a mood doesn't update the journal entry creation state.

**Solution**: Ensure the widget is wrapped in a `ProviderScope` and you're watching the provider:

```dart
final creationState = ref.watch(journalEntryCreationProvider);
```

### Emoji not displaying

**Issue**: Emojis appear as boxes or question marks.

**Solution**: Ensure your device's font supports emojis. Most modern devices do, but older devices may not.

### Layout issues

**Issue**: Mood grid appears cramped or has poor spacing.

**Solution**: Adjust the container padding or use the compact button variant:

```dart
const MoodPicker(
  padding: EdgeInsets.all(24), // Increase padding
)
```

## Related Components

- `CreateJournalEntryScreen`: Main screen for creating journal entries
- `JournalEntryDetailScreen`: Displays selected moods in entries
- `journal_entry_providers.dart`: State management for mood selection
- Location picker widget (`location_picker_widget.dart`): Similar pattern for location selection

## Future Enhancements

Potential improvements for future versions:

- [ ] Custom mood creation (user-defined moods)
- [ ] Mood history and trends
- [ ] Mood-based entry filtering
- [ ] Animated mood transitions
- [ ] Multiple mood selection per entry
- [ ] Mood suggestions based on entry content
- [ ] Integration with health apps for mood correlation

## License

This component is part of the SoloAdventurer project and follows the same license terms.

## Contributing

When contributing to the MoodPicker:

1. Follow existing code style and patterns
2. Add comprehensive documentation for new features
3. Include examples for any new functionality
4. Test on multiple screen sizes
5. Ensure accessibility compliance
6. Update this README with any API changes

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the example file: `mood_picker_example.dart`
3. Consult the main project documentation
4. Check existing issues in the project repository
