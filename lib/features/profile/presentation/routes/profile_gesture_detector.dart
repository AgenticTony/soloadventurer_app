import 'package:flutter/material.dart';

class ProfileGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeBack;
  final VoidCallback? onSwipeDown;
  final bool enableSwipeBack;
  final bool enableSwipeDown;

  const ProfileGestureDetector({
    super.key,
    required this.child,
    this.onSwipeBack,
    this.onSwipeDown,
    this.enableSwipeBack = true,
    this.enableSwipeDown = false,
  });

  @override
  State<ProfileGestureDetector> createState() => _ProfileGestureDetectorState();
}

class _ProfileGestureDetectorState extends State<ProfileGestureDetector> {
  static const double _minSwipeDistance = 50.0;
  static const double _minSwipeVelocity = 300.0;
  Offset? _startOffset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) => _startOffset = details.globalPosition,
      onVerticalDragStart: (details) => _startOffset = details.globalPosition,
      onHorizontalDragEnd:
          widget.enableSwipeBack ? _handleHorizontalDrag : null,
      onVerticalDragEnd: widget.enableSwipeDown ? _handleVerticalDrag : null,
      child: widget.child,
    );
  }

  void _handleHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == null || _startOffset == null) return;

    // Check if swipe was from left to right with sufficient velocity or distance
    final distance = details.velocity.pixelsPerSecond.dx;
    if (details.primaryVelocity! > _minSwipeVelocity ||
        (distance > 0 && distance.abs() > _minSwipeDistance)) {
      widget.onSwipeBack?.call();
    }
  }

  void _handleVerticalDrag(DragEndDetails details) {
    if (details.primaryVelocity == null || _startOffset == null) return;

    // Check if swipe was downward with sufficient velocity or distance
    final distance = details.velocity.pixelsPerSecond.dy;
    if (details.primaryVelocity! > _minSwipeVelocity ||
        (distance > 0 && distance.abs() > _minSwipeDistance)) {
      widget.onSwipeDown?.call();
    }
  }
}
