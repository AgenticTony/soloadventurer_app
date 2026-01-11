import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/widgets/spacing.dart';

/// A rich text editor widget for journal entries
///
/// Supports:
/// - Bold, italic, underline, strikethrough
/// - Headings (H1, H2, H3)
/// - Ordered and unordered lists
/// - Block quotes
/// - Code blocks
/// - Links
class RichTextEditor extends ConsumerStatefulWidget {
  /// Initial content in Delta JSON format
  final String? initialContent;

  /// Callback when content changes
  final ValueChanged<String>? onContentChanged;

  /// Placeholder text when editor is empty
  final String placeholder;

  /// Whether the editor is enabled
  final bool enabled;

  /// Minimum height for the editor
  final double minHeight;

  /// Maximum height for the editor (null for unbounded)
  final double? maxHeight;

  /// Padding around the editor
  final EdgeInsets padding;

  const RichTextEditor({
    super.key,
    this.initialContent,
    this.onContentChanged,
    this.placeholder = 'Start writing your journal entry...',
    this.enabled = true,
    this.minHeight = 200,
    this.maxHeight,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  ConsumerState<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends ConsumerState<RichTextEditor> {
  late final quill.QuillController _controller;
  late final quill.QuillSimpleToolbarConfig _toolbarConfig;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _toolbarConfig = _createToolbarConfig();
  }

  void _initializeController() {
    // Load initial content if provided
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      try {
        final document = quill.Document.fromJson(
          _parseDeltaJson(widget.initialContent!),
        );
        _controller = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // If parsing fails, create empty document
        _controller = quill.QuillController.basic();
      }
    } else {
      _controller = quill.QuillController.basic();
    }

    // Listen to content changes
    _controller.addListener(_onControllerChanged);
  }

  quill.QuillSimpleToolbarConfig _createToolbarConfig() {
    return quill.QuillSimpleToolbarConfig(
      // Show formatting options
      showDividers: true,
      showClearFormat: true,
      showCodeBlock: true,
      showDirection: false,
      showFontFamily: false,
      showHeaderStyle: true,
      showIndent: false,
      showLink: true,
      showListBullets: true,
      showListNumbers: true,
      showQuote: true,
      showSearchButton: false,
      showSmallButton: false,
      showStrikeThrough: true,
      showSubscript: false,
      showSuperscript: false,
      multiRowsDisplay: false,
      toolbarIconAlignment: WrapAlignment.start,
    );
  }

  void _onControllerChanged() {
    if (widget.onContentChanged != null) {
      final deltaJson = _controller.document.toDelta().toJson();
      widget.onContentChanged!(deltaJson.toString());
    }
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

  /// Get the current content as Delta JSON string
  String getContent() {
    return _controller.document.toDelta().toJson().toString();
  }

  /// Set the content of the editor
  void setContent(String deltaJson) {
    try {
      final document = quill.Document.fromJson(
        _parseDeltaJson(deltaJson),
      );
      _controller.document = document;
    } catch (e) {
      // If parsing fails, clear the document
      _controller.document = quill.Document();
    }
  }

  /// Clear the editor content
  void clear() {
    _controller.document = quill.Document();
  }

  /// Check if the editor is empty
  bool get isEmpty => _controller.document.isEmpty();

  @override
  void didUpdateWidget(RichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update content if initialContent changes externally
    if (widget.initialContent != oldWidget.initialContent &&
        widget.initialContent != null) {
      setContent(widget.initialContent!);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        if (widget.enabled)
          quill.QuillSimpleToolbar(
            controller: _controller,
            config: _toolbarConfig,
          ),

        // Editor
        Expanded(
          child: Container(
            constraints: BoxConstraints(
              minHeight: widget.minHeight,
              maxHeight: widget.maxHeight ?? double.infinity,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                color: theme.dividerColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: widget.padding,
            child: quill.QuillEditor.basic(
              controller: _controller,
              config: quill.QuillEditorConfig(
                placeholder: widget.placeholder,
                autoFocus: false,
                expands: false,
                padding: EdgeInsets.zero,
                customStyles: quill.DefaultStyles(
                  paragraph: quill.DefaultTextBlockStyle(
                    const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                    const quill.HorizontalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                  h1: quill.DefaultTextBlockStyle(
                    TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      height: 1.3,
                    ),
                    const quill.HorizontalSpacing(16, 8),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                  h2: quill.DefaultTextBlockStyle(
                    TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      height: 1.3,
                    ),
                    const quill.HorizontalSpacing(12, 6),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                  h3: quill.DefaultTextBlockStyle(
                    const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    const quill.HorizontalSpacing(8, 4),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                  lists: quill.DefaultListBlockStyle(
                    const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                    const quill.HorizontalSpacing(0, 4),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    null,
                    null,
                  ),
                  quote: quill.DefaultTextBlockStyle(
                    TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    const quill.HorizontalSpacing(8, 4),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                  code: quill.DefaultTextBlockStyle(
                    TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      backgroundColor: Colors.grey[200],
                      color: Colors.black87,
                    ),
                    const quill.HorizontalSpacing(8, 4),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
