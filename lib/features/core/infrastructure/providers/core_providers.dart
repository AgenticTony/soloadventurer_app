import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';
import 'package:soloadventurer/features/core/infrastructure/device/device_info_service.dart';
import 'package:soloadventurer/features/core/infrastructure/logging/logging_service_impl.dart';

/// Provider for the logging service
final loggingServiceProvider = Provider<LoggingService>((ref) {
  return LoggingServiceImpl();
});

/// Provider for DeviceInfoPlugin
final deviceInfoPluginProvider = Provider<DeviceInfoPlugin>((ref) {
  return DeviceInfoPlugin();
});

/// Provider for DeviceInfoService
final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  final deviceInfo = ref.watch(deviceInfoPluginProvider);
  final logger = ref.watch(loggingServiceProvider);
  
  return DeviceInfoService(
    deviceInfo: deviceInfo,
    logger: logger,
  );
});
