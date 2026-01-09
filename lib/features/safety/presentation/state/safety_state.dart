import 'package:equatable/equatable.dart';
import '../../domain/entities/safety_status.dart';
import '../../domain/entities/safety_alert.dart';

/// Overall safety state for the application
/// Manages current safety status, active alerts, and emergency information
class SafetyState extends Equatable {
  /// Whether safety data is currently loading
  final bool isLoading;

  /// Whether an operation is in progress
  final bool isProcessing;

  /// Current safety status of the user
  final SafetyStatus? currentStatus;

  /// List of recent safety alerts
  final List<SafetyAlert> recentAlerts;

  /// List of active (unresolved) safety alerts
  final List<SafetyAlert> activeAlerts;

  /// Count of trusted contacts
  final int trustedContactsCount;

  /// Error message if any operation failed
  final String? error;

  /// Whether there's an active emergency
  bool get hasActiveEmergency => activeAlerts.isNotEmpty;

  /// Whether the current status indicates danger
  bool get isInDanger =>
      currentStatus?.status == SafetyStatusType.emergency ||
      currentStatus?.status == SafetyStatusType.needHelp;

  /// Whether safety feature is initialized
  bool get isInitialized => currentStatus != null;

  const SafetyState({
    this.isLoading = false,
    this.isProcessing = false,
    this.currentStatus,
    this.recentAlerts = const [],
    this.activeAlerts = const [],
    this.trustedContactsCount = 0,
    this.error,
  });

  /// Creates initial safety state with default values
  factory SafetyState.initial() {
    return const SafetyState();
  }

  /// Creates a copy of this state with the given fields replaced
  SafetyState copyWith({
    bool? isLoading,
    bool? isProcessing,
    SafetyStatus? currentStatus,
    List<SafetyAlert>? recentAlerts,
    List<SafetyAlert>? activeAlerts,
    int? trustedContactsCount,
    String? error,
  }) {
    return SafetyState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      currentStatus: currentStatus ?? this.currentStatus,
      recentAlerts: recentAlerts ?? this.recentAlerts,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      trustedContactsCount: trustedContactsCount ?? this.trustedContactsCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isProcessing,
        currentStatus,
        recentAlerts,
        activeAlerts,
        trustedContactsCount,
        error,
      ];
}
