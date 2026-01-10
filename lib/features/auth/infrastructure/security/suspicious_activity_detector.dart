import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../features/core/infrastructure/monitoring/aws_cloudwatch_monitoring.dart';
import '../../../../features/core/domain/services/logging_service.dart';
import '../../../../core/security/security_manager.dart';
import '../logging/token_audit_logger.dart';
import '../utils/fixed_size_queue.dart';

part 'suspicious_activity_detector.g.dart';

/// Detects and logs suspicious activity patterns related to authentication and API usage
@riverpod
class SuspiciousActivityDetector extends _$SuspiciousActivityDetector {
  late final SecurityManager _securityManager;
  late final LoggingService _tokenAuditLogger;
  late final AwsCloudWatchMonitoring _monitoring;

  // Thresholds for suspicious activity detection
  static const int _loginAttemptThreshold = 5;
  static const int _locationChangeThreshold = 10; // Increased for travel app
  static const Duration _locationTimeWindow = Duration(hours: 24);
  static const double _impossibleSpeedThreshold = 1000.0;
  static const int _tokenRefreshThreshold =
      20; // Increased for travel scenarios
  static const Duration _tokenRefreshWindow = Duration(hours: 1);
  static const int _concurrentUsageThreshold =
      3; // Increased for multi-device travelers
  static const int _requestRateThreshold =
      300; // Increased for active app usage
  static const Duration _rateLimitDuration = Duration(minutes: 5);
  static const int _sensitiveEndpointThreshold =
      20; // Increased for travel documentation
  static const Duration _sensitiveEndpointWindow = Duration(hours: 1);

  // History tracking for various activities
  final Map<String, FixedSizeQueue<DateTime>> _loginAttemptHistory = {};
  final Map<String, FixedSizeQueue<_LocationEntry>> _locationHistory = {};
  final Map<String, FixedSizeQueue<DateTime>> _tokenRefreshHistory = {};
  final Map<String, int> _concurrentUsageHistory = {};
  final Map<String, FixedSizeQueue<DateTime>> _requestRateHistory = {};
  final Map<String, FixedSizeQueue<DateTime>> _sensitiveEndpointHistory = {};

  @override
  SuspiciousActivityDetector build() {
    _securityManager = ref.watch(securityManagerProvider);
    _tokenAuditLogger = ref.watch(tokenAuditLoggerProvider);
    _monitoring = ref.watch(awsCloudWatchMonitoringProvider);
    return this;
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Calculate speed between two points in km/h
  double _calculateSpeed(_LocationEntry prev, _LocationEntry curr) {
    final double distance = _calculateDistance(
      prev.latitude,
      prev.longitude,
      curr.latitude,
      curr.longitude,
    );
    final double hours =
        curr.timestamp.difference(prev.timestamp).inSeconds / 3600;

    // Avoid division by zero
    if (hours == 0) return double.infinity;
    return distance / hours;
  }

  /// Detect suspicious login patterns
  void detectSuspiciousLogins({
    required String userId,
    required DateTime loginAttemptTime,
    required String location,
    required double latitude,
    required double longitude,
  }) {
    // Track login attempts
    _loginAttemptHistory.putIfAbsent(
      userId,
      () => FixedSizeQueue<DateTime>(_loginAttemptThreshold),
    );
    final loginAttempts = _loginAttemptHistory[userId];
    if (loginAttempts != null) {
      loginAttempts.add(loginAttemptTime);

      if (loginAttempts.length == _loginAttemptThreshold) {
        _tokenAuditLogger.logTokenEvent(
          event: 'suspicious_login_attempts',
          status: 'high',
          metadata: {
            'user_id': userId,
            'attempts': _loginAttemptThreshold,
            'timeframe': loginAttempts.first.difference(loginAttempts.last).inMinutes,
          },
        );
      }
    }

    // Track location changes with time and coordinates
    _locationHistory.putIfAbsent(
      userId,
      () => FixedSizeQueue<_LocationEntry>(_locationChangeThreshold),
    );

    final newLocation = _LocationEntry(
      location: location,
      latitude: latitude,
      longitude: longitude,
      timestamp: loginAttemptTime,
    );

    final locations = _locationHistory[userId];
    if (locations == null) return;

    // Check for impossible travel speeds if we have previous locations
    if (locations.isNotEmpty) {
      final prevLocation = locations.last;
      final speed = _calculateSpeed(prevLocation, newLocation);

      if (speed > _impossibleSpeedThreshold) {
        _tokenAuditLogger.logTokenEvent(
          event: 'impossible_travel_detected',
          status: 'critical',
          metadata: {
            'user_id': userId,
            'previous_location': prevLocation.location,
            'previous_timestamp': prevLocation.timestamp.toIso8601String(),
            'new_location': location,
            'new_timestamp': loginAttemptTime.toIso8601String(),
            'calculated_speed': speed,
            'threshold_speed': _impossibleSpeedThreshold,
          },
        );

        // This is a strong indicator of account compromise
        _securityManager.revokeAllTokens(userId);
        return;
      }
    }

    locations.add(newLocation);

    // Check for rapid location changes within time window
    final locationChangesInWindow = locations
        .toList()
        .where((entry) =>
            loginAttemptTime.difference(entry.timestamp).abs() <=
            _locationTimeWindow)
        .toList();

    final uniqueLocationsInWindow =
        locationChangesInWindow.map((entry) => entry.location).toSet();

    if (uniqueLocationsInWindow.length >= _locationChangeThreshold) {
      _tokenAuditLogger.logTokenEvent(
        event: 'rapid_location_changes',
        status: 'medium', // Reduced severity for travelers
        metadata: {
          'user_id': userId,
          'unique_locations': uniqueLocationsInWindow.toList(),
          'time_window_hours': _locationTimeWindow.inHours,
          'first_location_time':
              locationChangesInWindow.first.timestamp.toIso8601String(),
          'latest_location_time':
              locationChangesInWindow.last.timestamp.toIso8601String(),
        },
      );

      // Instead of immediate token revocation, flag for review
      _monitoring.recordMetric(
        'RapidLocationChanges',
        1.0,
        dimensions: {
          'UserId': userId,
          'LocationCount': uniqueLocationsInWindow.length.toString(),
          'TimeWindowHours': _locationTimeWindow.inHours.toString(),
        },
      );
    }
  }

  /// Detect suspicious token usage patterns
  void detectSuspiciousTokenUsage({
    required String userId,
    required String tokenId,
    required DateTime refreshTime,
  }) {
    // Track token refreshes with time window
    _tokenRefreshHistory.putIfAbsent(
      tokenId,
      () => FixedSizeQueue<DateTime>(_tokenRefreshThreshold),
    );
    final tokenRefreshes = _tokenRefreshHistory[tokenId];
    if (tokenRefreshes == null) return;

    tokenRefreshes.add(refreshTime);

    final refreshesInWindow = tokenRefreshes
        .where(
            (time) => refreshTime.difference(time).abs() <= _tokenRefreshWindow)
        .length;

    if (refreshesInWindow >= _tokenRefreshThreshold) {
      _tokenAuditLogger.logTokenEvent(
        event: 'suspicious_token_refreshes',
        status: 'high',
        metadata: {
          'user_id': userId,
          'token_id': tokenId,
          'refresh_count': refreshesInWindow,
          'time_window_hours': _tokenRefreshWindow.inHours,
        },
      );
    }

    // Track concurrent usage
    final currentUsage = _concurrentUsageHistory.update(
      tokenId,
      (value) => value + 1,
      ifAbsent: () => 1,
    );

    if (currentUsage >= _concurrentUsageThreshold) {
      _tokenAuditLogger.logTokenEvent(
        event: 'concurrent_token_usage',
        status: 'high', // Reduced from critical for multi-device scenarios
        metadata: {
          'user_id': userId,
          'token_id': tokenId,
          'concurrent_uses': currentUsage,
        },
      );

      // Monitor instead of immediate revocation
      _monitoring.recordMetric(
        'ConcurrentTokenUsage',
        1.0,
        dimensions: {
          'UserId': userId,
          'TokenId': tokenId,
          'ConcurrentUses': currentUsage.toString(),
        },
      );
    }
  }

  /// Detect suspicious API usage patterns
  void detectSuspiciousApiUsage({
    required String userId,
    required String endpoint,
    required DateTime requestTime,
  }) {
    // Track request rate with sliding window
    _requestRateHistory.putIfAbsent(
      userId,
      () => FixedSizeQueue<DateTime>(_requestRateThreshold),
    );
    final requestHistory = _requestRateHistory[userId];
    if (requestHistory == null) return;

    requestHistory.add(requestTime);

    final requestsInWindow = requestHistory
        .where(
            (time) => requestTime.difference(time).abs() <= _rateLimitDuration)
        .length;

    if (requestsInWindow >= _requestRateThreshold) {
      _tokenAuditLogger.logTokenEvent(
        event: 'suspicious_request_rate',
        status: 'high',
        metadata: {
          'user_id': userId,
          'request_count': requestsInWindow,
          'timeframe_minutes': _rateLimitDuration.inMinutes,
        },
      );

      // Apply rate limiting
      _securityManager.rateLimit(userId, _rateLimitDuration);
    }

    // Track sensitive endpoint access with time window
    if (_securityManager.isSensitiveEndpoint(endpoint)) {
      _sensitiveEndpointHistory.putIfAbsent(
        userId,
        () => FixedSizeQueue<DateTime>(_sensitiveEndpointThreshold),
      );
      final sensitiveHistory = _sensitiveEndpointHistory[userId];
      if (sensitiveHistory == null) return;

      sensitiveHistory.add(requestTime);

      final sensitiveAccessesInWindow = sensitiveHistory
          .where((time) =>
              requestTime.difference(time).abs() <= _sensitiveEndpointWindow)
          .length;

      if (sensitiveAccessesInWindow >= _sensitiveEndpointThreshold) {
        _tokenAuditLogger.logTokenEvent(
          event: 'suspicious_sensitive_endpoint_access',
          status: 'high', // Reduced from critical for travel scenarios
          metadata: {
            'user_id': userId,
            'endpoint': endpoint,
            'access_count': sensitiveAccessesInWindow,
            'time_window_hours': _sensitiveEndpointWindow.inHours,
          },
        );

        // Log for review instead of immediate token revocation
        _monitoring.recordMetric(
          'HighSensitiveEndpointAccess',
          1.0,
          dimensions: {
            'UserId': userId,
            'Endpoint': endpoint,
            'AccessCount': sensitiveAccessesInWindow.toString(),
          },
        );
      }
    }
  }

  /// Reset tracking history for a user
  void resetHistory(String userId) {
    _loginAttemptHistory.remove(userId);
    _locationHistory.remove(userId);
    _requestRateHistory.remove(userId);
    _sensitiveEndpointHistory.remove(userId);
  }

  /// Reset tracking history for a token
  void resetTokenHistory(String tokenId) {
    _tokenRefreshHistory.remove(tokenId);
    _concurrentUsageHistory.remove(tokenId);
  }
}

/// Represents a location entry with coordinates and timestamp
class _LocationEntry {
  final String location;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  _LocationEntry({
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}
