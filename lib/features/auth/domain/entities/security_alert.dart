import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_alert.freezed.dart';
part 'security_alert.g.dart';

/// Severity levels for security alerts
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

/// Types of security alerts
enum AlertType {
  failedTokenRefresh,
  suspiciousActivity,
  concurrentDeviceUsage,
  rateLimitViolation,
  tokenRevocation,
}

/// Represents a security alert in the system
@freezed
class SecurityAlert with _$SecurityAlert {
  const factory SecurityAlert({
    required AlertType type,
    required AlertSeverity severity,
    required String message,
    required DateTime timestamp,
    required String userId,
    Map<String, dynamic>? metadata,
  }) = _SecurityAlert;

  factory SecurityAlert.fromJson(Map<String, dynamic> json) =>
      _$SecurityAlertFromJson(json);
}
