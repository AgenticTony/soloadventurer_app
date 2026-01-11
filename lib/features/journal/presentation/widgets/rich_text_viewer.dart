import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:soloadventurer/core/widgets/spacing.dart';

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
        config: quill.QuillEditorConfig(
          padding: EdgeInsets.zero,
          customStyles: quill.DefaultStyles(
            paragraph: quill.DefaultTextBlockStyle(
              textStyle ?? theme.textTheme.bodyLarge!,
              const quill.HorizontalSpacing(0, 0),
              const quill.VerticalSpacing(0, 0),
              const quill.VerticalSpacing(0, 0),
              null,
            ),
            h1: quill.DefaultTextBlockStyle(
              theme.textTheme.headlineMedium!,
              const quill.HorizontalSpacing(16, 8),
              const quill.VerticalSpacing(0, 0),
              const quill.VerticalSpacing(0, 0),
              null,
            ),
            h2: quill.DefaultTextBlockStyle(
              theme.textTheme.titleLarge!,
              const quill.HorizontalSpacing(12, 6),
              const quill.VerticalSpacing(0, 0),
              const quill.VerticalSpacing(0, 0),
              null,
            ),
            h3: quill.DefaultTextBlockStyle(
              theme.textTheme.titleMedium!,
              const quill.HorizontalSpacing(8, 4),
              const quill.VerticalSpacing(0, 0),
              const quill.VerticalSpacing(0, 0),
              null,
            ),
            lists: quill.DefaultListBlockStyle(
              theme.textTheme.bodyLarge!,
              const quill.HorizontalSpacing(0, 4),
              const quill.VerticalSpacing(0, 0),
              const quill.VerticalSpacing(0, 0),
              null,
              null,
            ),
            quote: quill.DefaultTextBlockStyle(
              theme.textTheme.bodyMedium!.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              const quill.HorizontalSpacing(8, 4),
              const quill.VerticalSpacing(0, 0),
              const quill.VerticalSpacing(0, 0),
              null,
            ),
            code: quill.DefaultTextBlockStyle(
              TextStyle(
                fontFamily: 'monospace',
                fontSize: theme.textTheme.bodyMedium?.fontSize,
                color: theme.colorScheme.primary,
              ),
              const quill.HorizontalSpacing(8, 4),
              const quill.VerticalSpacing(0, 0),
              const quill.VerticalSpacing(0, 0),
              null,
            ),
          ),
        ),
      ),
    );
  }

  /// Parse Delta JSON string
  /// Returns a List of delta operations as expected by Document.fromJson
  List<dynamic> _parseDeltaJson(String jsonString) {
    if (jsonString.startsWith('{') && jsonString.endsWith('}')) {
      // Direct JSON object - needs to be wrapped in a list format
      // Delta format is [{"insert": "text"}] or similar
      try {
        final decoded = jsonDecode(jsonString);
        if (decoded is Map) {
          return [decoded];
        }
        return decoded as List<dynamic>;
      } catch (_) {
        return [{'insert': jsonString}];
      }
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded as List<dynamic>;
      }
      if (decoded is Map) {
        return [decoded];
      }
      return [{'insert': jsonString}];
    } catch (_) {
      return [{'insert': jsonString}];
    }
  }
}
