import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Manages security-related features like rate limiting and device tracking
abstract class SecurityManager {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
  Future<String> getDeviceId();
  Future<Map<String, dynamic>> getDeviceInfo();
  Future<void> checkLoginAttempts();
  Future<void> recordFailedLoginAttempt();
  Future<void> resetLoginAttempts();
  Future<void> registerDevice();
  Future<bool> isKnownDevice();
  Future<void> removeDevice(String deviceId);
  Future<List<Map<String, dynamic>>> getKnownDevices();
  Future<List<Map<String, dynamic>>> getSecurityEvents();
}

class SecurityManagerImpl implements SecurityManager {
  final SecureStorage _storage;
  final DeviceInfoPlugin _deviceInfo;
  final bool _isTest;
  static const _maxLoginAttempts = 5;
  static const _lockoutDuration = Duration(minutes: 1);
  static const _deviceIdKey = 'device_id';
  static const _lastLoginAttemptKey = 'last_login_attempt';
  static const _loginAttemptsKey = 'login_attempts';
  static const _knownDevicesKey = 'known_devices';
  static const _securityEventsKey = 'security_events';

  SecurityManagerImpl({
    required SecureStorage storage,
    DeviceInfoPlugin? deviceInfo,
    bool isTest = false,
  })  : _storage = storage,
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
        _isTest = isTest;

  @override
  Future<void> write(String key, String value) => _storage.write(key, value);

  @override
  Future<String?> read(String key) => _storage.read(key);

  @override
  Future<void> delete(String key) => _storage.delete(key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  @override
  Future<bool> containsKey(String key) => _storage.containsKey(key);

  @override
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

  @override
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

  @override
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

  @override
  Future<void> recordFailedLoginAttempt() async {
    final attempts = await _getLoginAttempts();
    await _storage.write(_loginAttemptsKey, (attempts + 1).toString());
    await _storage.write(
        _lastLoginAttemptKey, DateTime.now().toIso8601String());
    await _logSecurityEvent('failed_login_attempt');
  }

  @override
  Future<void> resetLoginAttempts() => _resetLoginAttempts();

  @override
  Future<void> registerDevice() async {
    final deviceInfo = await getDeviceInfo();
    final devices = await _getKnownDevices();
    devices.add(deviceInfo);
    await _storage.write(_knownDevicesKey, jsonEncode(devices));
    await _logSecurityEvent('device_registered', data: deviceInfo);
  }

  @override
  Future<bool> isKnownDevice() async {
    if (_isTest) {
      return true;
    }

    final deviceId = await getDeviceId();
    final devices = await _getKnownDevices();
    return devices.any((device) => device['device_id'] == deviceId);
  }

  @override
  Future<void> removeDevice(String deviceId) async {
    final devices = await _getKnownDevices();
    devices.removeWhere((device) => device['device_id'] == deviceId);
    await _storage.write(_knownDevicesKey, jsonEncode(devices));
    await _logSecurityEvent('device_removed', data: {'device_id': deviceId});
  }

  @override
  Future<List<Map<String, dynamic>>> getKnownDevices() => _getKnownDevices();

  @override
  Future<List<Map<String, dynamic>>> getSecurityEvents() async {
    final eventsJson = await _storage.read(_securityEventsKey);
    if (eventsJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(eventsJson));
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
}
