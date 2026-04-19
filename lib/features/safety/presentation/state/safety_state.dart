import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/safety_status.dart';
import '../../domain/entities/safety_alert.dart';

part 'safety_state.freezed.dart';

/// Overall safety state for the application.
///
/// Riverpod 3.0 Compliant:
/// - Uses @freezed with sealed class as required by Freezed 3.2.x with Dart 3.10
/// - Loading/error handled by AsyncNotifier/AsyncValue, NOT state fields
@freezed
sealed class SafetyState with _$SafetyState {
  const SafetyState._();
  const factory SafetyState({
    /// Whether an operation is in progress
    @Default(false) bool isProcessing,

    /// Current safety status of the user
    SafetyStatus? currentStatus,

    /// List of recent safety alerts
    @Default([]) List<SafetyAlert> recentAlerts,

    /// List of active (unresolved) safety alerts
    @Default([]) List<SafetyAlert> activeAlerts,

    /// Count of trusted contacts
    @Default(0) int trustedContactsCount,
  }) = _SafetyState;

  factory SafetyState.initial() => const SafetyState();

  /// Whether there's an active emergency
  bool get hasActiveEmergency => activeAlerts.isNotEmpty;

  /// Whether the current status indicates danger
  bool get isInDanger =>
      currentStatus?.status == SafetyStatusType.emergency ||
      currentStatus?.status == SafetyStatusType.needHelp;

  /// Whether safety feature is initialized
  bool get isInitialized => currentStatus != null;
}
