import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// A customizable toolbar for the rich text editor
///
/// Provides formatting options:
/// - Bold, italic, underline, strikethrough
/// - Headings (H1, H2, H3)
/// - Ordered and unordered lists
/// - Block quotes
/// - Code blocks
/// - Links
/// - Clear formatting
///
/// Can be used separately from the editor for custom layouts
class EditorToolbar extends StatelessWidget {
  /// Controller for the Quill editor
  final quill.QuillController controller;

  /// Whether the toolbar is enabled
  final bool enabled;

  /// Toolbar background color
  final Color? backgroundColor;

  /// Toolbar elevation
  final double elevation;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Padding around toolbar buttons
  final EdgeInsetsGeometry padding;

  /// Whether to show dividers between button groups
  final bool showDividers;

  /// Whether to arrange buttons in multiple rows
  final bool multiRows;

  /// Alignment of toolbar buttons
  final WrapAlignment alignment;

  const EditorToolbar({
    super.key,
    required this.controller,
    this.enabled = true,
    this.backgroundColor,
    this.elevation = 0,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 8,
    ),
    this.showDividers = true,
    this.multiRows = false,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return quill.QuillSimpleToolbar(
      controller: controller,
      config: quill.QuillSimpleToolbarConfig(
        showDividers: showDividers,
        showAlignmentButtons: false,
        showBackgroundColorButton: false,
        showClearFormat: true,
        showCodeBlock: true,
        showDirection: false,
        showFontFamily: false,
        showHeaderStyle: true,
        showIndent: false,
        showLineHeightButton: false,
        showLink: true,
        showListBullets: true,
        showListCheck: false,
        showListNumbers: true,
        showQuote: true,
        showSearchButton: false,
        showSmallButton: false,
        showStrikeThrough: true,
        showSubscript: false,
        showSuperscript: false,
        showUnderLineButton: true,
        multiRowsDisplay: multiRows,
        buttonOptions: quill.QuillSimpleToolbarButtonOptions(
          base: quill.QuillToolbarBaseButtonOptions(
            afterButtonPressed: () {
              // Unfocus keyboard after button press for better UX
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
          ),
        ),
      ),
    );
  }
}

/// A compact toolbar with limited formatting options
///
/// Shows only the most commonly used formatting options:
/// - Bold, italic, underline
/// - Lists
/// - Basic headings
class CompactEditorToolbar extends StatelessWidget {
  final quill.QuillController controller;
  final bool enabled;
  final Color? backgroundColor;

  const CompactEditorToolbar({
    super.key,
    required this.controller,
    this.enabled = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return quill.QuillSimpleToolbar(
      controller: controller,
      config: quill.QuillSimpleToolbarConfig(
        showDividers: false,
        showBoldButton: true,
        showItalicButton: true,
        showUnderLineButton: true,
        showStrikeThrough: false,
        showHeaderStyle: false,
        showListBullets: true,
        showListNumbers: true,
        showListCheck: false,
        showCodeBlock: false,
        showQuote: false,
        showLink: true,
        showClearFormat: true,
        multiRowsDisplay: false,
      ),
    );
  }
}

/// A minimal toolbar with only basic formatting
///
/// Shows only:
/// - Bold, italic
/// - Lists
class MinimalEditorToolbar extends StatelessWidget {
  final quill.QuillController controller;
  final bool enabled;
  final Color? backgroundColor;

  const MinimalEditorToolbar({
    super.key,
    required this.controller,
    this.enabled = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: quill.QuillSimpleToolbar(
        controller: controller,
        config: quill.QuillSimpleToolbarConfig(
          showDividers: false,
          showBoldButton: true,
          showItalicButton: true,
          showUnderLineButton: false,
          showStrikeThrough: false,
          showHeaderStyle: false,
          showListBullets: true,
          showListNumbers: true,
          showListCheck: false,
          showCodeBlock: false,
          showQuote: false,
          showLink: false,
          showClearFormat: false,
          multiRowsDisplay: false,
        ),
      ),
    );
  }
}
