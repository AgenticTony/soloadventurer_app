import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/safety_status.dart';
import '../../domain/entities/safety_alert.dart';
import '../../domain/entities/trusted_contact.dart';
import '../../domain/entities/check_in.dart';

part 'safety_data.freezed.dart';
part 'safety_data.g.dart';

/// Data class for safety feature state
@freezed
class SafetyData with _$SafetyData {

  const factory SafetyData({
    /// Current safety status of the user
    SafetyStatus? currentStatus,

    /// List of trusted contacts
    @Default([]) List<TrustedContact> contacts,

    /// List of recent check-ins
    @Default([]) List<CheckIn> checkIns,

    /// List of recent safety alerts
    @Default([]) List<SafetyAlert> recentAlerts,

    /// List of active (unresolved) safety alerts
    @Default([]) List<SafetyAlert> activeAlerts,

    /// Currently selected check-in (for viewing)
    CheckIn? selectedCheckIn,

    /// Currently selected alert (for viewing)
    SafetyAlert? selectedAlert,
  }) = _SafetyData;

  factory SafetyData.fromJson(Map<String, dynamic> json) =>
      _$SafetyDataFromJson(json);

  // Private constructor for freezed
  const SafetyData._();
}

/// Extension on [SafetyData] for computed properties
extension SafetyDataExtension on SafetyData {
  /// Whether there's an active emergency
  bool get hasActiveEmergency => activeAlerts.isNotEmpty;

  /// Whether the current status indicates danger
  bool get isInDanger =>
      currentStatus?.status == SafetyStatusType.emergency ||
      currentStatus?.status == SafetyStatusType.needHelp;

  /// Whether safety feature is initialized
  bool get isInitialized => currentStatus != null;

  /// Whether there are trusted contacts set up
  bool get hasContacts => contacts.isNotEmpty;

  /// Count of active alerts
  int get activeAlertsCount => activeAlerts.length;

  /// Count of missed check-ins
  int get missedCheckInsCount => checkIns
      .where((checkIn) => checkIn.status == CheckInStatus.missed)
      .length;

  /// Most recent alert (if any)
  SafetyAlert? get mostRecentAlert {
    if (recentAlerts.isEmpty) return null;
    final sorted = List<SafetyAlert>.from(recentAlerts);
    sorted.sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
    return sorted.first;
  }
}
