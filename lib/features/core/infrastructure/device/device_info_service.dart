import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

/// Service for retrieving device information
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo;
  final LoggingService _logger;
  
  /// Creates a new [DeviceInfoService]
  DeviceInfoService({
    required DeviceInfoPlugin deviceInfo,
    required LoggingService logger,
  }) : 
    _deviceInfo = deviceInfo,
    _logger = logger;
  
  /// Gets a unique device identifier
  /// This is used for device-specific encryption
  Future<String> getDeviceId() async {
    try {
      // Try to get the platform device ID first
      String? deviceId = await PlatformDeviceId.getDeviceId;
      
      if (deviceId != null && deviceId.isNotEmpty) {
        return deviceId;
      }
      
      // Fallback to device-specific identifiers
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios_device';
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        return macOsInfo.systemGUID ?? 'unknown_macos_device';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return linuxInfo.machineId ?? 'unknown_linux_device';
      } else {
        // Web or other platforms
        return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get device ID',
        error: e,
        stackTrace: stackTrace,
      );
      // Fallback to a timestamp-based ID
      return 'fallback_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  /// Gets detailed device information for logging/debugging
  Future<Map<String, dynamic>> getDeviceDetails() async {
    try {
      final Map<String, dynamic> deviceData = <String, dynamic>{};
      
      if (kIsWeb) {
        deviceData['platform'] = 'web';
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceData['browserName'] = webInfo.browserName.name;
        deviceData['appVersion'] = webInfo.appVersion;
        deviceData['userAgent'] = webInfo.userAgent;
      } else if (Platform.isAndroid) {
        deviceData['platform'] = 'android';
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData['device'] = androidInfo.device;
        deviceData['manufacturer'] = androidInfo.manufacturer;
        deviceData['model'] = androidInfo.model;
        deviceData['version'] = androidInfo.version.release;
        deviceData['sdkInt'] = androidInfo.version.sdkInt;
      } else if (Platform.isIOS) {
        deviceData['platform'] = 'ios';
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData['name'] = iosInfo.name;
        deviceData['model'] = iosInfo.model;
        deviceData['systemName'] = iosInfo.systemName;
        deviceData['systemVersion'] = iosInfo.systemVersion;
      } else if (Platform.isMacOS) {
        deviceData['platform'] = 'macos';
        final macOsInfo = await _deviceInfo.macOsInfo;
        deviceData['computerName'] = macOsInfo.computerName;
        deviceData['hostName'] = macOsInfo.hostName;
        deviceData['model'] = macOsInfo.model;
        deviceData['osRelease'] = macOsInfo.osRelease;
      } else if (Platform.isWindows) {
        deviceData['platform'] = 'windows';
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceData['computerName'] = windowsInfo.computerName;
        deviceData['numberOfCores'] = windowsInfo.numberOfCores;
        deviceData['systemMemoryInMegabytes'] = windowsInfo.systemMemoryInMegabytes;
      } else if (Platform.isLinux) {
        deviceData['platform'] = 'linux';
        final linuxInfo = await _deviceInfo.linuxInfo;
        deviceData['name'] = linuxInfo.name;
        deviceData['version'] = linuxInfo.version;
        deviceData['prettyName'] = linuxInfo.prettyName;
      } else {
        deviceData['platform'] = 'unknown';
      }
      
      return deviceData;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get device details',
        error: e,
        stackTrace: stackTrace,
      );
      return {'platform': 'unknown', 'error': e.toString()};
    }
  }
}
