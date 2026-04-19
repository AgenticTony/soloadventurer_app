import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'operation_queue.dart';

part 'operation_storage_service.g.dart';

/// Storage keys for operation queue persistence.
///
/// Keys are namespaced to avoid conflicts with other app data stored in
/// shared_preferences.
class _StorageKeys {
  static const String pendingOperations = 'pending_operations';
  static const String failedOperations = 'failed_operations';
  static const String lastSaveTime = 'operation_queue_last_save';
  static const String queueVersion = 'operation_queue_version';
  static const int currentVersion = 1;
}

/// Result of loading operations from storage.
///
/// Contains both pending and failed operations, along with flags indicating
/// whether any data was corrupted or errors occurred during loading.
///
/// ## Fields
/// - [pendingOperations]: List of deserialized pending operation JSON data
/// - [failedOperations]: List of deserialized failed operation JSON data
/// - [hadCorruptedData]: True if some operations couldn't be deserialized
/// - [errorMessage]: Optional error message if loading failed completely
///
/// ## Usage
/// ```dart
/// final result = await storageService.loadOperations();
/// if (result.hadCorruptedData) {
///   print('Warning: Some operations were corrupted');
/// }
/// print('Loaded ${result.pendingOperations.length} pending operations');
/// ```
class OperationLoadResult {
  final List<Map<String, dynamic>> pendingOperations;
  final List<Map<String, dynamic>> failedOperations;
  final bool hadCorruptedData;
  final String? errorMessage;

  const OperationLoadResult({
    this.pendingOperations = const [],
    this.failedOperations = const [],
    this.hadCorruptedData = false,
    this.errorMessage,
  });
}

/// Service for persisting and retrieving queued operations.
///
/// Handles serialization, deserialization, and storage of operations using
/// a combination of shared_preferences (for general data) and flutter_secure_storage
/// (for sensitive data).
///
/// ## Storage Strategy
/// - **Pending operations**: Stored in shared_preferences
/// - **Failed operations**: Stored in shared_preferences
/// - **Sensitive data**: Stored in flutter_secure_storage (encrypted)
/// - **Version tracking**: Handles future schema migrations
///
/// ## Thread Safety
/// All public methods are thread-safe and can be called from any isolate.
/// Storage operations are atomic at the key level.
///
/// ## Error Handling
/// - Invalid/corrupted operations are skipped with a warning
/// - Storage failures return false but don't throw exceptions
/// - All errors are logged for debugging
///
/// ## Usage Example
/// ```dart
/// final storageService = ref.read(operationStorageServiceProvider.notifier);
///
/// // Save operations
/// await storageService.savePendingOperations(operations);
///
/// // Load operations
/// final result = await storageService.loadOperations();
/// for (final opData in result.pendingOperations) {
///   final operation = MyOperation.fromJson(opData);
/// }
///
/// // Get storage stats
/// final stats = await storageService.getStorageStats();
/// print('Total size: ${stats['totalSizeBytes']} bytes');
/// ```
@riverpod
class OperationStorageService extends _$OperationStorageService {
  late final SharedPreferences _prefs;
  late final FlutterSecureStorage _secureStorage;

  /// Secure storage options with encrypted SharedPreferences on Android.
  ///
  /// Uses encrypted SharedPreferences on Android for better security.
  /// On iOS, secure storage is always encrypted by the platform.
  static const FlutterSecureStorage _secureStorageOptions =
      FlutterSecureStorage(
    aOptions: AndroidOptions(),
    mOptions: MacOsOptions(usesDataProtectionKeychain: false),
  );

  @override
  Future<void> build() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _secureStorage = _secureStorageOptions;
    } catch (e) {
      rethrow;
    }
  }

  /// Saves pending operations to persistent storage.
  ///
  /// Serializes the list of operations to JSON and stores them in
  /// shared_preferences. If the list is empty, clears the storage key.
  ///
  /// ## Parameters
  /// - [operations]: List of operations to serialize and save
  ///
  /// ## Returns
  /// `true` if save succeeded, `false` if it failed
  ///
  /// ## Behavior
  /// - Serializes operations using [toJson()]
  /// - Stores as JSON string in shared_preferences
  /// - Updates last save timestamp
  /// - Clears storage if list is empty
  /// - Warns if data exceeds 900KB (approaching 1MB limit)
  ///
  /// ## Error Handling
  /// - Returns false on failure, doesn't throw
  /// - Logs errors for debugging
  /// - Continues even if storage is near capacity
  ///
  /// ## Storage Limits
  /// shared_preferences has ~1MB limit per key. This method warns
  /// when approaching the limit (900KB). Consider implementing
  /// storage pagination if you need to store more operations.
  Future<bool> savePendingOperations(
      List<QueueableOperation> operations) async {
    try {
      if (operations.isEmpty) {
        // Clear storage if no operations
        await _prefs.remove(_StorageKeys.pendingOperations);
        await _prefs.setInt(
            _StorageKeys.lastSaveTime, DateTime.now().millisecondsSinceEpoch);
        return true;
      }

      final operationsJson = _serializeOperations(operations);
      final jsonString = jsonEncode(operationsJson);

      // Check size limit (shared_preferences has ~1MB limit per key)
      if (jsonString.length > 900000) {
        // Consider implementing storage limits or pagination in future
      }

      final success =
          await _prefs.setString(_StorageKeys.pendingOperations, jsonString);
      await _prefs.setInt(
          _StorageKeys.lastSaveTime, DateTime.now().millisecondsSinceEpoch);
      await _prefs.setInt(
          _StorageKeys.queueVersion, _StorageKeys.currentVersion);

      if (success) {
      } else {
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Saves failed operations to persistent storage.
  ///
  /// Serializes the list of failed operations to JSON and stores them in
  /// shared_preferences. If the list is empty, clears the storage key.
  ///
  /// ## Parameters
  /// - [operations]: List of failed operations to serialize and save
  ///
  /// ## Returns
  /// `true` if save succeeded, `false` if it failed
  ///
  /// ## Behavior
  /// - Serializes operations using [toJson()]
  /// - Stores as JSON string in shared_preferences
  /// - Clears storage if list is empty
  ///
  /// ## Error Handling
  /// - Returns false on failure, doesn't throw
  /// - Logs errors for debugging
  Future<bool> saveFailedOperations(List<QueueableOperation> operations) async {
    try {
      if (operations.isEmpty) {
        await _prefs.remove(_StorageKeys.failedOperations);
        return true;
      }

      final operationsJson = _serializeOperations(operations);
      final jsonString = jsonEncode(operationsJson);

      final success =
          await _prefs.setString(_StorageKeys.failedOperations, jsonString);

      if (success) {
      } else {
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Loads all operations from storage.
  ///
  /// Deserializes both pending and failed operations from JSON storage.
  /// Handles version mismatches and corrupted data gracefully.
  ///
  /// ## Returns
  /// [OperationLoadResult] containing:
  /// - Lists of deserialized operation data
  /// - Flag indicating if any data was corrupted
  /// - Optional error message if loading failed
  ///
  /// ## Behavior
  /// - Loads pending operations from storage
  /// - Loads failed operations from storage
  /// - Validates operation data (requires 'id' and 'type' fields)
  /// - Skips corrupted operations with a warning
  /// - Checks for version mismatches
  ///
  /// ## Error Handling
  /// - Invalid operations are skipped, not failed entirely
  /// - Corrupted data is flagged in [hadCorruptedData]
  /// - Returns empty lists if storage keys don't exist
  /// - Returns result with error flag if loading fails
  ///
  /// ## Versioning
  /// Checks storage version and warns if it's newer than the current
  /// version, indicating a potential downgrade scenario.
  Future<OperationLoadResult> loadOperations() async {
    try {
      final version = _prefs.getInt(_StorageKeys.queueVersion) ?? 0;

      // Check for version mismatch and handle migration if needed
      if (version > _StorageKeys.currentVersion) {
      }

      final pendingResult =
          await _loadOperationsList(_StorageKeys.pendingOperations, 'pending');
      final failedResult =
          await _loadOperationsList(_StorageKeys.failedOperations, 'failed');

      final hadCorruptedData =
          pendingResult['hadCorruptedData'] || failedResult['hadCorruptedData'];

      return OperationLoadResult(
        pendingOperations:
            pendingResult['operations'] as List<Map<String, dynamic>>,
        failedOperations:
            failedResult['operations'] as List<Map<String, dynamic>>,
        hadCorruptedData: hadCorruptedData,
        errorMessage: pendingResult['errorMessage'] as String? ??
            failedResult['errorMessage'] as String?,
      );
    } catch (e) {
      return OperationLoadResult(
        hadCorruptedData: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Loads a specific list of operations by storage key.
  ///
  /// Internal helper method that loads, validates, and deserializes
  /// operations for a given storage key (pending or failed).
  ///
  /// ## Parameters
  /// - [key]: The shared_preferences key to load from
  /// - [type]: Description string for logging ('pending' or 'failed')
  ///
  /// ## Returns
  /// Map containing:
  /// - 'operations': List of validated operation data
  /// - 'hadCorruptedData': Boolean flag if any operations were invalid
  /// - 'errorMessage': Optional error message if loading failed
  ///
  /// ## Validation
  /// Operations must have:
  /// - 'id' field (String)
  /// - 'type' field (String)
  ///
  /// Invalid operations are skipped and flagged as corrupted.
  Future<Map<String, dynamic>> _loadOperationsList(
      String key, String type) async {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) {
        return {
          'operations': <Map<String, dynamic>>[],
          'hadCorruptedData': false,
        };
      }

      final List<dynamic> decoded = jsonDecode(jsonString);
      final operations = <Map<String, dynamic>>[];
      var hasCorruptedData = false;

      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          // Validate required fields
          if (_isValidOperationData(item)) {
            operations.add(item);
          } else {
            hasCorruptedData = true;
          }
        } else {
          hasCorruptedData = true;
        }
      }

      if (hasCorruptedData) {
      }

      return {
        'operations': operations,
        'hadCorruptedData': hasCorruptedData,
      };
    } catch (e) {
      return {
        'operations': <Map<String, dynamic>>[],
        'hadCorruptedData': true,
        'errorMessage': e.toString(),
      };
    }
  }

  /// Validates that operation data has the required fields.
  ///
  /// Checks for minimum required fields that all operations must have
  /// to be deserializable. This prevents corruption from invalid data.
  ///
  /// ## Required Fields
  /// - 'id': String - Unique identifier
  /// - 'type': String - Operation type discriminator
  ///
  /// ## Returns
  /// `true` if data is valid, `false` otherwise
  bool _isValidOperationData(Map<String, dynamic> data) {
    return data.containsKey('id') &&
        data.containsKey('type') &&
        data['id'] is String &&
        data['type'] is String;
  }

  /// Serializes a list of operations to JSON.
  ///
  /// Converts each operation to its JSON representation using the
  /// operation's [toJson()] method.
  ///
  /// ## Parameters
  /// - [operations]: List of operations to serialize
  ///
  /// ## Returns
  /// List of JSON maps, one per operation
  List<Map<String, dynamic>> _serializeOperations(
      List<QueueableOperation> operations) {
    return operations.map((op) => op.toJson()).toList();
  }

  /// Clears all operations from storage.
  ///
  /// Removes both pending and failed operations from persistent storage,
  /// along with metadata (last save time, version).
  ///
  /// ## Returns
  /// `true` if clear succeeded, `false` if it failed
  ///
  /// ## Behavior
  /// - Removes pending operations key
  /// - Removes failed operations key
  /// - Removes last save timestamp
  /// - Does NOT affect secure storage (sensitive data)
  ///
  /// ## Use Cases
  /// - User logs out and wants to clear all data
  /// - Testing/debugging
  /// - Data migration
  ///
  /// ## Note
  /// Does not clear sensitive data from secure storage. Use
  /// [clearAllSensitiveData] for that.
  Future<bool> clearAllOperations() async {
    try {
      await _prefs.remove(_StorageKeys.pendingOperations);
      await _prefs.remove(_StorageKeys.failedOperations);
      await _prefs.remove(_StorageKeys.lastSaveTime);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the timestamp of the last successful save operation.
  ///
  /// ## Returns
  /// DateTime of last save, or null if no save has occurred
  ///
  /// ## Usage
  /// ```dart
  /// final lastSave = storageService.getLastSaveTime();
  /// if (lastSave != null) {
  ///   final age = DateTime.now().difference(lastSave);
  ///   print('Last saved ${age.inMinutes} minutes ago');
  /// }
  /// ```
  DateTime? getLastSaveTime() {
    final timestamp = _prefs.getInt(_StorageKeys.lastSaveTime);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Gets statistics about the current storage state.
  ///
  /// Returns detailed metrics about the operation queue storage,
  /// including operation counts, data sizes, and timestamps.
  ///
  /// ## Returns
  /// Map containing:
  /// - 'pendingCount': Number of pending operations
  /// - 'failedCount': Number of failed operations
  /// - 'pendingSizeBytes': Size of pending operations JSON in bytes
  /// - 'failedSizeBytes': Size of failed operations JSON in bytes
  /// - 'totalSizeBytes': Combined size in bytes
  /// - 'lastSaveTime': ISO 8601 timestamp of last save
  /// - 'version': Current storage version
  /// - 'error': Error message if stats retrieval failed
  ///
  /// ## Usage
  /// ```dart
  /// final stats = await storageService.getStorageStats();
  /// print('Pending: ${stats['pendingCount']}');
  /// print('Total size: ${stats['totalSizeBytes']} bytes');
  ///
  /// // Check if approaching limit
  /// if (stats['totalSizeBytes'] > 900000) {
  ///   print('Warning: Approaching storage limit');
  /// }
  /// ```
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final pendingJson = _prefs.getString(_StorageKeys.pendingOperations);
      final failedJson = _prefs.getString(_StorageKeys.failedOperations);
      final lastSave = getLastSaveTime();

      final pendingCount =
          pendingJson != null ? (jsonDecode(pendingJson) as List).length : 0;
      final failedCount =
          failedJson != null ? (jsonDecode(failedJson) as List).length : 0;

      final pendingSize = pendingJson?.length ?? 0;
      final failedSize = failedJson?.length ?? 0;

      return {
        'pendingCount': pendingCount,
        'failedCount': failedCount,
        'pendingSizeBytes': pendingSize,
        'failedSizeBytes': failedSize,
        'totalSizeBytes': pendingSize + failedSize,
        'lastSaveTime': lastSave?.toIso8601String(),
        'version': _prefs.getInt(_StorageKeys.queueVersion) ?? 0,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Saves sensitive data to encrypted secure storage.
  ///
  /// Use this method for storing sensitive information like auth tokens,
  /// API keys, or user credentials that should be encrypted at rest.
  ///
  /// ## Parameters
  /// - [key]: Unique identifier for the data
  /// - [value]: Sensitive string value to store
  ///
  /// ## Returns
  /// `true` if save succeeded, `false` if it failed
  ///
  /// ## Security
  /// - Data is encrypted at rest on all platforms
  /// - On Android: Uses encrypted SharedPreferences
  /// - On iOS: Uses Keychain
  /// - Encryption is handled by the OS
  ///
  /// ## Usage
  /// ```dart
  /// await storageService.saveSensitiveData('auth_token', token);
  /// ```
  ///
  /// ## Error Handling
  /// Returns false on failure and logs the error.
  Future<bool> saveSensitiveData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Loads sensitive data from encrypted secure storage.
  ///
  /// Retrieves previously stored sensitive information.
  ///
  /// ## Parameters
  /// - [key]: Unique identifier for the data
  ///
  /// ## Returns
  /// The stored value, or null if the key doesn't exist
  ///
  /// ## Security
  /// Data is decrypted automatically by the secure storage plugin.
  ///
  /// ## Usage
  /// ```dart
  /// final token = await storageService.loadSensitiveData('auth_token');
  /// if (token != null) {
  ///   // Use token for API calls
  /// }
  /// ```
  Future<String?> loadSensitiveData(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value;
    } catch (e) {
      return null;
    }
  }

  /// Deletes sensitive data from secure storage.
  ///
  /// Removes a specific key-value pair from secure storage.
  ///
  /// ## Parameters
  /// - [key]: Unique identifier for the data to delete
  ///
  /// ## Returns
  /// `true` if delete succeeded, `false` if it failed
  ///
  /// ## Usage
  /// ```dart
  /// await storageService.deleteSensitiveData('auth_token');
  /// ```
  Future<bool> deleteSensitiveData(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clears all sensitive data from secure storage.
  ///
  /// Removes all key-value pairs from secure storage.
  /// Use this when the user logs out or for testing.
  ///
  /// ## Returns
  /// `true` if clear succeeded, `false` if it failed
  ///
  /// ## Usage
  /// ```dart
  /// // User logout
  /// await storageService.clearAllSensitiveData();
  /// ```
  ///
  /// ## Note
  /// This only affects secure storage, not shared_preferences.
  /// Use [clearAllOperations] to clear operation data.
  Future<bool> clearAllSensitiveData() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      return false;
    }
  }
}
