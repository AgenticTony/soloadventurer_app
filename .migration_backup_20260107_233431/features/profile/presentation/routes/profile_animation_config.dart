import 'package:flutter/material.dart';

class ProfileAnimationConfig {
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Curve reverseCurve;
  final bool enableTransition;

  const ProfileAnimationConfig({
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.reverseCurve = Curves.easeInOut,
    this.enableTransition = true,
  });

  static const ProfileAnimationConfig standard = ProfileAnimationConfig();

  static const ProfileAnimationConfig fast = ProfileAnimationConfig(
    duration: Duration(milliseconds: 200),
    reverseDuration: Duration(milliseconds: 200),
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  static const ProfileAnimationConfig slow = ProfileAnimationConfig(
    duration: Duration(milliseconds: 500),
    reverseDuration: Duration(milliseconds: 500),
    curve: Curves.easeInOutCubic,
    reverseCurve: Curves.easeInOutCubic,
  );

  static const ProfileAnimationConfig disabled = ProfileAnimationConfig(
    enableTransition: false,
  );

  ProfileAnimationConfig copyWith({
    Duration? duration,
    Duration? reverseDuration,
    Curve? curve,
    Curve? reverseCurve,
    bool? enableTransition,
  }) {
    return ProfileAnimationConfig(
      duration: duration ?? this.duration,
      reverseDuration: reverseDuration ?? this.reverseDuration,
      curve: curve ?? this.curve,
      reverseCurve: reverseCurve ?? this.reverseCurve,
      enableTransition: enableTransition ?? this.enableTransition,
    );
  }
}

class ProfileTransitionBuilder {
  static Widget buildTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required ProfileAnimationConfig config,
    Offset? beginOffset,
  }) {
    if (!config.enableTransition) return child;

    final begin = beginOffset ?? const Offset(0.0, 0.05);
    const end = Offset.zero;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: config.curve),
    );

    final offsetAnimation = animation.drive(tween);
    final fadeAnimation = animation.drive(
      CurveTween(curve: config.curve),
    );

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}
