import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'security_manager.g.dart';

/// Manages security-related features like rate limiting and device tracking
@riverpod
class SecurityManager extends _$SecurityManager {
  late final SecureStorage _storage;
  late final DeviceInfoPlugin _deviceInfo;
  late final bool _isTest;
  static const _maxLoginAttempts = 5;
  static const _lockoutDuration = Duration(minutes: 1);
  static const _deviceIdKey = 'device_id';
  static const _lastLoginAttemptKey = 'last_login_attempt';
  static const _loginAttemptsKey = 'login_attempts';
  static const _knownDevicesKey = 'known_devices';
  static const _securityEventsKey = 'security_events';
  static const _rateLimitKey = 'rate_limit';
  static const _sensitiveEndpointsKey = 'sensitive_endpoints';
  static const _revokedTokensKey = 'revoked_tokens';

  // List of sensitive endpoints that require extra monitoring
  static const Set<String> _sensitiveEndpoints = {
    '/api/v1/users/profile',
    '/api/v1/payment/methods',
    '/api/v1/settings',
    // Add more sensitive endpoints as needed
  };

  @override
  SecurityManager build() {
    _storage = ref.watch(secureStorageProvider);
    _deviceInfo = DeviceInfoPlugin();
    _isTest = false;
    return this;
  }

  Future<void> write(String key, String value) => _storage.write(key, value);

  Future<String?> read(String key) => _storage.read(key);

  Future<void> delete(String key) => _storage.delete(key);

  Future<void> deleteAll() => _storage.deleteAll();

  Future<bool> containsKey(String key) => _storage.containsKey(key);

  Future<String> getDeviceId() async {
    if (_isTest) {
      return 'test-device-id';
    }

    final storedId = await _storage.read(_deviceIdKey);
    if (storedId != null) return storedId;

    final deviceId = await PlatformDeviceId.getDeviceId ?? 'unknown';
    await _storage.write(_deviceIdKey, deviceId);
    return deviceId;
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (_isTest) {
      return {
        'device_id': 'test-device-id',
        'timestamp': DateTime.now().toIso8601String(),
        'model': 'Test Model',
        'system_name': 'Test System',
        'system_version': '1.0.0',
        'name': 'Test Device',
      };
    }

    final deviceId = await getDeviceId();
    final baseInfo = {
      'device_id': deviceId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        ...baseInfo,
        'model': iosInfo.model,
        'system_name': iosInfo.systemName,
        'system_version': iosInfo.systemVersion,
        'name': iosInfo.name,
      };
    } else if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        ...baseInfo,
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'android_version': androidInfo.version.release,
        'security_patch': androidInfo.version.securityPatch,
      };
    }

    return baseInfo;
  }

  Future<void> checkLoginAttempts() async {
    final attempts = await _getLoginAttempts();
    final lastAttempt = await _getLastLoginAttempt();

    if (attempts >= _maxLoginAttempts) {
      if (lastAttempt != null &&
          DateTime.now().difference(lastAttempt) < _lockoutDuration) {
        final remainingTime =
            _lockoutDuration - DateTime.now().difference(lastAttempt);
        throw AuthException(
          'Too many login attempts. Please try again in ${remainingTime.inMinutes} minutes.',
        );
      } else {
        // Reset attempts after lockout period
        await _resetLoginAttempts();
      }
    }
  }

  Future<void> recordFailedLoginAttempt() async {
    final attempts = await _getLoginAttempts();
    await _storage.write(_loginAttemptsKey, (attempts + 1).toString());
    await _storage.write(
        _lastLoginAttemptKey, DateTime.now().toIso8601String());
    await _logSecurityEvent('failed_login_attempt');
  }

  Future<void> resetLoginAttempts() => _resetLoginAttempts();

  Future<void> registerDevice() async {
    final deviceInfo = await getDeviceInfo();
    final devices = await _getKnownDevices();
    devices.add(deviceInfo);
    await _storage.write(_knownDevicesKey, jsonEncode(devices));
    await _logSecurityEvent('device_registered', data: deviceInfo);
  }

  Future<bool> isKnownDevice() async {
    if (_isTest) {
      return true;
    }

    final deviceId = await getDeviceId();
    final devices = await _getKnownDevices();
    return devices.any((device) => device['device_id'] == deviceId);
  }

  Future<void> removeDevice(String deviceId) async {
    final devices = await _getKnownDevices();
    devices.removeWhere((device) => device['device_id'] == deviceId);
    await _storage.write(_knownDevicesKey, jsonEncode(devices));
    await _logSecurityEvent('device_removed', data: {'device_id': deviceId});
  }

  Future<List<Map<String, dynamic>>> getKnownDevices() => _getKnownDevices();

  Future<List<Map<String, dynamic>>> getSecurityEvents() async {
    final eventsJson = await _storage.read(_securityEventsKey);
    if (eventsJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(eventsJson));
  }

  /// Check if an endpoint is considered sensitive
  bool isSensitiveEndpoint(String endpoint) {
    return _sensitiveEndpoints.contains(endpoint);
  }

  /// Apply rate limiting to a user
  Future<void> rateLimit(String userId, Duration duration) async {
    final rateLimits = await _getRateLimits();
    rateLimits[userId] = DateTime.now().add(duration).toIso8601String();
    await _storage.write(_rateLimitKey, jsonEncode(rateLimits));
    await _logSecurityEvent('rate_limit_applied', data: {
      'user_id': userId,
      'duration': duration.inMinutes,
    });
  }

  /// Revoke a specific token
  Future<void> revokeToken(String tokenId) async {
    final revokedTokens = await _getRevokedTokens();
    revokedTokens.add({
      'token_id': tokenId,
      'revoked_at': DateTime.now().toIso8601String(),
    });
    await _storage.write(_revokedTokensKey, jsonEncode(revokedTokens));
    await _logSecurityEvent('token_revoked', data: {'token_id': tokenId});
  }

  /// Revoke all tokens for a user
  Future<void> revokeAllTokens(String userId) async {
    final revokedTokens = await _getRevokedTokens();
    revokedTokens.add({
      'user_id': userId,
      'revoked_at': DateTime.now().toIso8601String(),
      'all_tokens': true,
    });
    await _storage.write(_revokedTokensKey, jsonEncode(revokedTokens));
    await _logSecurityEvent('all_tokens_revoked', data: {'user_id': userId});
  }

  Future<void> _logSecurityEvent(String eventType,
      {Map<String, dynamic>? data}) async {
    final events = await getSecurityEvents();
    events.add({
      'type': eventType,
      'timestamp': DateTime.now().toIso8601String(),
      'device_id': await getDeviceId(),
      if (data != null) 'data': data,
    });
    // Keep only last 100 events
    if (events.length > 100) {
      events.removeRange(0, events.length - 100);
    }
    await _storage.write(_securityEventsKey, jsonEncode(events));
  }

  Future<int> _getLoginAttempts() async {
    final attempts = await _storage.read(_loginAttemptsKey);
    return attempts == null ? 0 : int.parse(attempts);
  }

  Future<DateTime?> _getLastLoginAttempt() async {
    final lastAttempt = await _storage.read(_lastLoginAttemptKey);
    return lastAttempt == null ? null : DateTime.parse(lastAttempt);
  }

  Future<void> _resetLoginAttempts() async {
    await _storage.delete(_loginAttemptsKey);
    await _storage.delete(_lastLoginAttemptKey);
  }

  Future<List<Map<String, dynamic>>> _getKnownDevices() async {
    final devicesJson = await _storage.read(_knownDevicesKey);
    if (devicesJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(devicesJson));
  }

  Future<Map<String, String>> _getRateLimits() async {
    final limitsJson = await _storage.read(_rateLimitKey);
    if (limitsJson == null) return {};
    return Map<String, String>.from(jsonDecode(limitsJson));
  }

  Future<List<Map<String, dynamic>>> _getRevokedTokens() async {
    final tokensJson = await _storage.read(_revokedTokensKey);
    if (tokensJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(tokensJson));
  }
}
