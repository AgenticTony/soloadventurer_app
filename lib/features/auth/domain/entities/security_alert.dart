import 'package:equatable/equatable.dart';

/// Severity levels for security alerts
enum AlertSeverity {
  low,
  medium,
  high,
  critical;

  String toJson() {
    return name;
  }

  static AlertSeverity fromJson(String value) {
    return AlertSeverity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AlertSeverity.medium,
    );
  }
}

/// Types of security alerts
enum AlertType {
  failedTokenRefresh,
  suspiciousActivity,
  concurrentDeviceUsage,
  rateLimitViolation,
  tokenRevocation;

  String toJson() {
    return name;
  }

  static AlertType fromJson(String value) {
    return AlertType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AlertType.suspiciousActivity,
    );
  }
}

/// Represents a security alert in the system
class SecurityAlert extends Equatable {
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final String userId;
  final Map<String, dynamic>? metadata;

  const SecurityAlert({
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.userId,
    this.metadata,
  });

  /// Creates a SecurityAlert from JSON
  factory SecurityAlert.fromJson(Map<String, dynamic> json) {
    return SecurityAlert(
      type: AlertType.fromJson(json['type'] as String),
      severity: AlertSeverity.fromJson(json['severity'] as String),
      message: json['message'] as String,
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'] as String)
          : json['timestamp'] as DateTime,
      userId: json['userId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts SecurityAlert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'severity': severity.toJson(),
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Creates a copy of this alert with the given fields replaced
  SecurityAlert copyWith({
    AlertType? type,
    AlertSeverity? severity,
    String? message,
    DateTime? timestamp,
    String? userId,
    Map<String, dynamic>? metadata,
    bool clearMetadata = false,
  }) {
    return SecurityAlert(
      type: type ?? this.type,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
    );
  }

  @override
  List<Object?> get props => [
        type,
        severity,
        message,
        timestamp,
        userId,
        metadata,
      ];

  @override
  String toString() {
    return 'SecurityAlert{'
        'type: $type, '
        'severity: $severity, '
        'message: $message, '
        'timestamp: $timestamp, '
        'userId: $userId'
        '}';
  }
}
