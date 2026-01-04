# Rich Text Editor Components

A collection of rich text editor widgets built with `flutter_quill` for the SoloAdventurer travel journal feature.

## Features

- **Rich Text Formatting**: Bold, italic, underline, strikethrough
- **Headers**: H1, H2, H3 heading styles
- **Lists**: Ordered and unordered lists
- **Advanced**: Block quotes, code blocks, links
- **Responsive**: Adapts to different screen sizes
- **Customizable**: Multiple toolbar configurations available

## Components

### 1. RichTextEditor

A complete rich text editor with integrated toolbar.

#### Usage

```dart
RichTextEditor(
  initialContent: existingDeltaJson,
  placeholder: 'Start writing your journal entry...',
  onContentChanged: (content) {
    // Handle content changes
    // content is a Delta JSON string
  },
  minHeight: 200,
  enabled: true,
)
```

#### Parameters

- `initialContent` (String?): Initial content in Delta JSON format
- `onContentChanged` (ValueChanged<String>?): Callback when content changes
- `placeholder` (String): Placeholder text when empty
- `enabled` (bool): Whether editing is enabled
- `minHeight` (double): Minimum height of the editor
- `maxHeight` (double?): Maximum height (null for unbounded)
- `padding` (EdgeInsets): Padding around the editor

#### Methods

- `getContent()`: Returns current content as Delta JSON string
- `setContent(String)`: Sets editor content from Delta JSON
- `clear()`: Clears all content
- `isEmpty`: Returns true if editor has no content

### 2. EditorToolbar

A customizable standalone toolbar for custom layouts.

#### Usage

```dart
EditorToolbar(
  controller: quillController,
  enabled: true,
  showDividers: true,
  multiRows: false,
)
```

#### Customization

```dart
EditorToolbar(
  controller: controller,
  backgroundColor: Colors.grey[100],
  borderRadius: BorderRadius.circular(8),
  padding: EdgeInsets.all(16),
  showDividers: true,
  multiRows: false,
  alignment: WrapAlignment.center,
)
```

### 3. CompactEditorToolbar

A compact toolbar with only essential formatting options.

#### Features

- Bold, italic, underline
- Ordered and unordered lists
- Links
- Clear formatting

#### Usage

```dart
CompactEditorToolbar(
  controller: controller,
  enabled: true,
)
```

### 4. MinimalEditorToolbar

The simplest toolbar with basic formatting only.

#### Features

- Bold, italic
- Ordered and unordered lists

#### Usage

```dart
MinimalEditorToolbar(
  controller: controller,
  enabled: true,
  backgroundColor: Colors.white,
)
```

## Data Format

The editor uses Quill's Delta format for storing content. Delta is a JSON format that represents rich text documents.

### Example Delta JSON

```json
{
  "ops": [
    {"insert": "Travel Journal\n", "attributes": {"header": 1}},
    {"insert": "Today was "},
    {"insert": "amazing", "attributes": {"bold": true}},
    {"insert": "!\n"},
    {"insert": "  We visited the Eiffel Tower\n", "attributes": {"list": "bullet"}},
    {"insert": "  Had croissants for breakfast\n", "attributes": {"list": "bullet"}}
  ]
}
```

### Storage

Store the Delta JSON string directly in the database:

```dart
// Saving
final entry = JournalEntry(
  id: uuid.v4(),
  title: 'My Paris Adventure',
  content: deltaJsonString, // Store Delta JSON here
  entryDate: DateTime.now(),
  // ... other fields
);
```

### Retrieval and Display

```dart
// Loading
RichTextEditor(
  initialContent: entry.content, // Pass stored Delta JSON
)
```

## Integration Example

### Complete Example with Riverpod

```dart
class JournalEntryScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<JournalEntryScreen> createState() =>
      _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final _editorKey = GlobalKey<RichTextEditorState>();
  String _content = '';
  String _title = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Entry Title',
            ),
            onChanged: (value) => setState(() => _title = value),
          ),
          Expanded(
            child: RichTextEditor(
              placeholder: 'Write about your adventures...',
              onContentChanged: (content) {
                setState(() => _content = content);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveEntry() {
    if (_title.isEmpty || _content.isEmpty) return;

    ref.read(journalEntryProvider.notifier).createEntry(
      title: _title,
      content: _content,
      entryDate: DateTime.now(),
    );

    Navigator.of(context).pop();
  }
}
```

## Styling

The editor uses Material Design theming. Custom styles are defined in the widget:

- **Headings**: Primary color, bold
- **Paragraphs**: 16px, 1.5 line height
- **Quotes**: Italic, grey
- **Code**: Monospace, light grey background
- **Lists**: Bulleted and numbered

To customize, modify the `customStyles` parameter in the QuillEditor configuration.

## Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_quill: ^10.8.4
```

## Accessibility

- All toolbar buttons have semantic labels
- Editor supports screen readers
- Keyboard navigation is fully supported
- Proper focus management

## Performance Considerations

- Content is stored as compact Delta JSON
- Large documents are handled efficiently
- Debouncing may be added to `onContentChanged` if needed
- Consider pagination for very long entries

## Troubleshooting

### Content not loading

Ensure the Delta JSON is properly formatted:

```dart
try {
  final document = Document.fromJson(deltaJson);
  controller.document = document;
} catch (e) {
  // Handle invalid JSON
  controller.document = Document();
}
```

### Toolbar not showing

Check that the controller is properly initialized:

```dart
late final QuillController _controller;

@override
void initState() {
  super.initState();
  _controller = QuillController.basic();
}
```

### Keyboard not appearing

Ensure the editor is focused and `enabled` is true:

```dart
RichTextEditor(
  enabled: true,
  // The editor will handle focus automatically
)
```

## Future Enhancements

- [ ] Add image insertion from gallery
- [ ] Add camera capture directly
- [ ] Support for tables
- [ ] Auto-save drafts
- [ ] Undo/redo history visualization
- [ ] Word and character count
- [ ] Export to PDF/Markdown
- [ ] Collaborative editing support
