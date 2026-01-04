import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// A read-only viewer for rich text content in journal entries
///
/// Displays formatted content stored in Delta JSON format from Quill editor.
/// This widget is read-only and optimized for viewing rather than editing.
class RichTextViewer extends StatelessWidget {
  /// Content in Delta JSON format
  final String content;

  /// Padding around the viewer
  final EdgeInsets padding;

  /// Whether to show a border
  final bool showBorder;

  /// Background color
  final Color? backgroundColor;

  /// Text style for the content
  final TextStyle? textStyle;

  const RichTextViewer({
    super.key,
    required this.content,
    this.padding = const EdgeInsets.all(16),
    this.showBorder = false,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Parse Delta JSON content
    quill.Document document;
    try {
      document = quill.Document.fromJson(_parseDeltaJson(content));
    } catch (e) {
      // If parsing fails, show plain text
      return Container(
        padding: padding,
        decoration: showBorder
            ? BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Text(
          content,
          style: textStyle ?? theme.textTheme.bodyLarge,
        ),
      );
    }

    final controller = quill.QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    return Container(
      padding: padding,
      decoration: showBorder
          ? BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: backgroundColor,
            )
          : null,
      child: quill.QuillEditor.basic(
        controller: controller,
        readOnly: true,
        configurations: quill.QuillEditorConfigurations(
          padding: EdgeInsets.zero,
          customStyles: DefaultStyles(
            paragraph: DefaultTextBlockStyle(
              textStyle ?? theme.textTheme.bodyLarge!,
              const VerticalSpacing(0, 0),
              const VerticalSpacing(0, 0),
              null,
            ),
            h1: DefaultTextBlockStyle(
              theme.textTheme.headlineMedium!,
              const VerticalSpacing(16, 8),
              const VerticalSpacing(0, 0),
              null,
            ),
            h2: DefaultTextBlockStyle(
              theme.textTheme.titleLarge!,
              const VerticalSpacing(12, 6),
              const VerticalSpacing(0, 0),
              null,
            ),
            h3: DefaultTextBlockStyle(
              theme.textTheme.titleMedium!,
              const VerticalSpacing(8, 4),
              const VerticalSpacing(0, 0),
              null,
            ),
            lists: DefaultTextBlockStyle(
              theme.textTheme.bodyLarge!,
              const VerticalSpacing(0, 4),
              const VerticalSpacing(0, 0),
              null,
            ),
            quote: DefaultTextBlockStyle(
              theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              const VerticalSpacing(8, 4),
              const VerticalSpacing(0, 0),
              null,
            ),
            code: DefaultTextBlockStyle(
              TextStyle(
                fontFamily: 'monospace',
                fontSize: theme.textTheme.bodyMedium?.fontSize,
                color: theme.colorScheme.primary,
              ),
              const VerticalSpacing(8, 4),
              const VerticalSpacing(0, 0),
              BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Parse Delta JSON string into a Map
  /// Handles both JSON string and already parsed formats
  Map<String, dynamic> _parseDeltaJson(String jsonString) {
    if (jsonString.startsWith('{') && jsonString.endsWith('}')) {
      // Direct JSON object - wrap in document format expected by Quill
      return {'document': jsonString};
    }
    // Already formatted or plain text
    return {'document': jsonString};
  }
}
