import 'package:flutter/material.dart';

/// A widget that provides consistent vertical spacing.
///
/// Usage:
/// ```dart
/// Column(
///   children: [
///     Text('Hello'),
///     VerticalSpacing.medium(),  // 16px gap
///     Text('World'),
///   ],
/// )
/// ```
class VerticalSpacing extends StatelessWidget {
  /// The height of the spacing in logical pixels
  final double height;

  /// Creates vertical spacing with a custom height
  const VerticalSpacing(this.height, {super.key});

  /// Extra small spacing (4px)
  const VerticalSpacing.xs({super.key}) : height = 4;

  /// Small spacing (8px)
  const VerticalSpacing.small({super.key}) : height = 8;

  /// Medium spacing (16px) - default
  const VerticalSpacing.medium({super.key}) : height = 16;

  /// Large spacing (24px)
  const VerticalSpacing.large({super.key}) : height = 24;

  /// Extra large spacing (32px)
  const VerticalSpacing.xl({super.key}) : height = 32;

  /// Extra extra large spacing (48px)
  const VerticalSpacing.xxl({super.key}) : height = 48;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// A widget that provides consistent horizontal spacing.
///
/// Usage:
/// ```dart
/// Row(
///   children: [
///     Icon(Icons.star),
///     HorizontalSpacing.small(),  // 8px gap
///     Text('Rating'),
///   ],
/// )
/// ```
class HorizontalSpacing extends StatelessWidget {
  /// The width of the spacing in logical pixels
  final double width;

  /// Creates horizontal spacing with a custom width
  const HorizontalSpacing(this.width, {super.key});

  /// Extra small spacing (4px)
  const HorizontalSpacing.xs({super.key}) : width = 4;

  /// Small spacing (8px)
  const HorizontalSpacing.small({super.key}) : width = 8;

  /// Medium spacing (16px)
  const HorizontalSpacing.medium({super.key}) : width = 16;

  /// Large spacing (24px)
  const HorizontalSpacing.large({super.key}) : width = 24;

  /// Extra large spacing (32px)
  const HorizontalSpacing.xl({super.key}) : width = 32;

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}

/// Common spacing constants for use with EdgeInsets, SizedBox, etc.
///
/// Usage:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(Spacing.medium),
///   child: Text('Hello'),
/// )
/// ```
abstract class Spacing {
  Spacing._();

  /// 4px
  static const double xs = 4;

  /// 8px
  static const double small = 8;

  /// 12px
  static const double smallMedium = 12;

  /// 16px
  static const double medium = 16;

  /// 20px
  static const double mediumLarge = 20;

  /// 24px
  static const double large = 24;

  /// 32px
  static const double xl = 32;

  /// 48px
  static const double xxl = 48;

  /// 64px
  static const double xxxl = 64;
}
