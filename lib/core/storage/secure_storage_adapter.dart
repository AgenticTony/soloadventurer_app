import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_adapter.g.dart';

/// Adapter interface for secure storage operations
///
/// This abstraction allows GetIt-based services to use Riverpod-provided
/// SecurityManager without creating circular dependencies.
abstract class SecureStorageAdapter {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
}

/// Implementation of SecureStorageAdapter that wraps SecurityManager
///
/// This class is registered in GetIt and obtains the actual SecurityManager
/// from Riverpod via a ProviderContainer that must be set before use.
class SecurityManagerAdapter implements SecureStorageAdapter {
  static SecurityManager? _cachedManager;

  /// Sets the SecurityManager instance (called during app initialization)
  static void setSecurityManager(SecurityManager manager) {
    _cachedManager = manager;
  }

  /// Gets the SecurityManager instance
  ///
  /// Throws [StateError] if the manager hasn't been set via [setSecurityManager]
  SecurityManager get _manager {
    if (_cachedManager == null) {
      throw StateError(
        'SecurityManager not initialized. Call SecurityManagerAdapter.setSecurityManager() '
        'during app initialization (typically in bootstrap.dart after provider container is created).',
      );
    }
    return _cachedManager!;
  }

  @override
  Future<void> write(String key, String value) => _manager.write(key, value);

  @override
  Future<String?> read(String key) => _manager.read(key);

  @override
  Future<void> delete(String key) => _manager.delete(key);

  @override
  Future<void> deleteAll() => _manager.deleteAll();

  @override
  Future<bool> containsKey(String key) => _manager.containsKey(key);

  /// Delegates to SecurityManager for device-related operations
  Future<String> getDeviceId() => _manager.getDeviceId();

  /// Delegates to SecurityManager for device info
  Future<Map<String, dynamic>> getDeviceInfo() => _manager.getDeviceInfo();

  /// Delegates to SecurityManager for login attempt checking
  Future<void> checkLoginAttempts() => _manager.checkLoginAttempts();

  /// Delegates to SecurityManager for recording failed attempts
  Future<void> recordFailedLoginAttempt() => _manager.recordFailedLoginAttempt();

  /// Delegates to SecurityManager for resetting login attempts
  Future<void> resetLoginAttempts() => _manager.resetLoginAttempts();

  /// Delegates to SecurityManager for device registration
  Future<void> registerDevice() => _manager.registerDevice();

  /// Delegates to SecurityManager for checking known devices
  Future<bool> isKnownDevice() => _manager.isKnownDevice();

  /// Delegates to SecurityManager for removing devices
  Future<void> removeDevice(String deviceId) => _manager.removeDevice(deviceId);

  /// Delegates to SecurityManager for getting known devices
  Future<List<Map<String, dynamic>>> getKnownDevices() => _manager.getKnownDevices();

  /// Delegates to SecurityManager for getting security events
  Future<List<Map<String, dynamic>>> getSecurityEvents() => _manager.getSecurityEvents();

  /// Delegates to SecurityManager for checking sensitive endpoints
  bool isSensitiveEndpoint(String endpoint) => _manager.isSensitiveEndpoint(endpoint);

  /// Delegates to SecurityManager for rate limiting
  Future<void> rateLimit(String userId, Duration duration) => _manager.rateLimit(userId, duration);

  /// Delegates to SecurityManager for token revocation
  Future<void> revokeToken(String tokenId) => _manager.revokeToken(tokenId);

  /// Delegates to SecurityManager for revoking all tokens
  Future<void> revokeAllTokens(String userId) => _manager.revokeAllTokens(userId);
}

/// Provider for SecurityManagerAdapter
///
/// This provider creates the adapter and initializes it with the
/// actual SecurityManager from Riverpod.
@riverpod
SecurityManagerAdapter securityManagerAdapter(Ref ref) {
  final manager = ref.watch(securityManagerProvider);
  SecurityManagerAdapter.setSecurityManager(manager);
  return SecurityManagerAdapter();
}
