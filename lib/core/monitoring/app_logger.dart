import 'package:flutter/foundation.dart';

/// Lightweight debug logger that auto-guards on kDebugMode.
///
/// Replaces raw `debugPrint()` calls. All methods are no-ops in release
/// builds, so callers don't need their own `if (kDebugMode)` wrapper.
///
/// ```dart
/// // Before:
/// debugPrint('✅ Something happened');
///
/// // After:
/// AppLogger.d('Something happened');
/// ```
///
/// Migration of existing debugPrint calls is incremental — new code
/// should use AppLogger exclusively.
abstract final class AppLogger {
  /// Original debugPrint callback before override
  static final DebugPrintCallback _originalDebugPrint = debugPrint;

  /// Override Flutter's global [debugPrint] to be a no-op in release mode.
  ///
  /// Call once during app bootstrap (before `runApp`). This silences ALL
  /// unguarded `debugPrint` calls across the entire app in release builds.
  /// In debug mode, output passes through normally.
  ///
  /// ```dart
  /// void main() {
  ///   AppLogger.installGlobalGuard();
  ///   // ...
  /// }
  /// ```
  static void installGlobalGuard() {
    if (kReleaseMode) {
      debugPrint = (String? message, {int? wrapWidth}) {
        // No-op in release builds
      };
    }
  }

  /// Restore the original debugPrint behavior.
  static void uninstallGlobalGuard() {
    debugPrint = _originalDebugPrint;
  }

  /// Debug-level message. No-op in release.
  static void d(String message) {
    if (kDebugMode) debugPrint(message);
  }

  /// Warning-level message. No-op in release.
  static void w(String message) {
    if (kDebugMode) debugPrint('⚠️ $message');
  }

  /// Error-level message. No-op in release.
  static void e(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('❌ $message');
      if (error != null) debugPrint('   $error');
    }
  }

  /// Success-level message. No-op in release.
  static void s(String message) {
    if (kDebugMode) debugPrint('✅ $message');
  }
}
