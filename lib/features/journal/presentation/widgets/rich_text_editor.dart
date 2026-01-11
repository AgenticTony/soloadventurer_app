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
  late final quill.QuillSimpleToolbarConfigurations _toolbarConfig;

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

  quill.QuillSimpleToolbarConfigurations _createToolbarConfig() {
    return quill.QuillSimpleToolbarConfigurations(
      // Show formatting options
      showDividers: true,
      showAlignment: false,
      showBackgroundColor: false,
      showClearFormat: true,
      showCodeBlock: true,
      showDirection: false,
      showFontFamily: false,
      showHeaderStyle: true,
      showIndent: false,
      showLineHeight: false,
      showLink: true,
      showListBullets: true,
      showListChecklists: false,
      showListNumbers: true,
      showQuote: true,
      showSearchButton: false,
      showSmallButton: false,
      showStrikeThrough: true,
      showSubscript: false,
      showSuperscript: false,
      showUnderline: true,
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
  Map<String, dynamic> _parseDeltaJson(String jsonString) {
    if (jsonString.startsWith('{') && jsonString.endsWith('}')) {
      // Direct JSON object
      return {'document': jsonString};
    }
    // Already formatted
    return {'document': jsonString};
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
  bool get isEmpty => _controller.document.isEmpty;

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
            configurations: _toolbarConfig,
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
              configurations: quill.QuillEditorConfigurations(
                placeholder: widget.placeholder,
                readOnly: !widget.enabled,
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
                    const quill.VerticalSpacing(16, 8),
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
                    const quill.VerticalSpacing(12, 6),
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
                    const quill.VerticalSpacing(8, 4),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                  lists: quill.DefaultTextBlockStyle(
                    const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                    const quill.VerticalSpacing(0, 4),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                  quote: quill.DefaultTextBlockStyle(
                    TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    const quill.VerticalSpacing(8, 4),
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
                    const quill.VerticalSpacing(8, 4),
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
