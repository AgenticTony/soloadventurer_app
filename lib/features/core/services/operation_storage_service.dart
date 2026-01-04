import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'operation_queue.dart';

part 'operation_storage_service.g.dart';

/// Storage keys for operation queue persistence
class _StorageKeys {
  static const String pendingOperations = 'pending_operations';
  static const String failedOperations = 'failed_operations';
  static const String lastSaveTime = 'operation_queue_last_save';
  static const String queueVersion = 'operation_queue_version';
  static const int currentVersion = 1;
}

/// Result of loading operations from storage
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

/// Service for persisting and retrieving queued operations
@riverpod
class OperationStorageService extends _$OperationStorageService {
  late final SharedPreferences _prefs;
  late final FlutterSecureStorage _secureStorage;
  static const FlutterSecureStorage _secureStorageOptions =
      FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  @override
  Future<void> build() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _secureStorage = _secureStorageOptions;
      debugPrint('OperationStorageService: Initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('OperationStorageService: Initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Save pending operations to persistent storage
  Future<bool> savePendingOperations(
      List<QueueableOperation> operations) async {
    try {
      if (operations.isEmpty) {
        // Clear storage if no operations
        await _prefs.remove(_StorageKeys.pendingOperations);
        await _prefs.setInt(_StorageKeys.lastSaveTime,
            DateTime.now().millisecondsSinceEpoch);
        debugPrint(
            'OperationStorageService: Cleared pending operations (empty list)');
        return true;
      }

      final operationsJson = _serializeOperations(operations);
      final jsonString = jsonEncode(operationsJson);

      // Check size limit (shared_preferences has ~1MB limit per key)
      if (jsonString.length > 900000) {
        debugPrint(
            'OperationStorageService: Warning - operations data is large: ${jsonString.length} bytes');
        // Consider implementing storage limits or pagination in future
      }

      final success = await _prefs.setString(
          _StorageKeys.pendingOperations, jsonString);
      await _prefs.setInt(
          _StorageKeys.lastSaveTime, DateTime.now().millisecondsSinceEpoch);
      await _prefs.setInt(_StorageKeys.queueVersion, _StorageKeys.currentVersion);

      if (success) {
        debugPrint(
            'OperationStorageService: Saved ${operations.length} pending operations');
      } else {
        debugPrint(
            'OperationStorageService: Failed to save pending operations');
      }

      return success;
    } catch (e, stackTrace) {
      debugPrint('OperationStorageService: Error saving pending operations: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Save failed operations to persistent storage
  Future<bool> saveFailedOperations(
      List<QueueableOperation> operations) async {
    try {
      if (operations.isEmpty) {
        await _prefs.remove(_StorageKeys.failedOperations);
        debugPrint(
            'OperationStorageService: Cleared failed operations (empty list)');
        return true;
      }

      final operationsJson = _serializeOperations(operations);
      final jsonString = jsonEncode(operationsJson);

      final success =
          await _prefs.setString(_StorageKeys.failedOperations, jsonString);

      if (success) {
        debugPrint(
            'OperationStorageService: Saved ${operations.length} failed operations');
      } else {
        debugPrint(
            'OperationStorageService: Failed to save failed operations');
      }

      return success;
    } catch (e, stackTrace) {
      debugPrint('OperationStorageService: Error saving failed operations: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Load all operations from storage
  Future<OperationLoadResult> loadOperations() async {
    try {
      final version = _prefs.getInt(_StorageKeys.queueVersion) ?? 0;
      debugPrint(
          'OperationStorageService: Loading operations (version: $version, current: ${_StorageKeys.currentVersion})');

      // Check for version mismatch and handle migration if needed
      if (version > _StorageKeys.currentVersion) {
        debugPrint(
            'OperationStorageService: Warning - storage version $version is newer than current ${_StorageKeys.currentVersion}');
      }

      final pendingResult = await _loadOperationsList(
          _StorageKeys.pendingOperations, 'pending');
      final failedResult = await _loadOperationsList(
          _StorageKeys.failedOperations, 'failed');

      final hadCorruptedData =
          pendingResult['hadCorruptedData'] || failedResult['hadCorruptedData'];

      debugPrint(
          'OperationStorageService: Loaded ${pendingResult['operations'].length} pending, ${failedResult['operations'].length} failed operations');

      return OperationLoadResult(
        pendingOperations: pendingResult['operations'] as List<Map<String, dynamic>>,
        failedOperations: failedResult['operations'] as List<Map<String, dynamic>>,
        hadCorruptedData: hadCorruptedData,
        errorMessage: pendingResult['errorMessage'] as String? ??
            failedResult['errorMessage'] as String?,
      );
    } catch (e, stackTrace) {
      debugPrint('OperationStorageService: Error loading operations: $e');
      debugPrint('Stack trace: $stackTrace');
      return OperationLoadResult(
        hadCorruptedData: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load a specific list of operations by key
  Future<Map<String, dynamic>> _loadOperationsList(
      String key, String type) async {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) {
        debugPrint('OperationStorageService: No $type operations found');
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
            debugPrint(
                'OperationStorageService: Skipping invalid $type operation: missing required fields');
            hasCorruptedData = true;
          }
        } else {
          debugPrint(
              'OperationStorageService: Skipping corrupted $type operation data');
          hasCorruptedData = true;
        }
      }

      if (hasCorruptedData) {
        debugPrint(
            'OperationStorageService: Warning - some $type operations were corrupted and skipped');
      }

      return {
        'operations': operations,
        'hadCorruptedData': hasCorruptedData,
      };
    } catch (e, stackTrace) {
      debugPrint(
          'OperationStorageService: Error loading $type operations: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'operations': <Map<String, dynamic>>[],
        'hadCorruptedData': true,
        'errorMessage': e.toString(),
      };
    }
  }

  /// Validate that operation data has required fields
  bool _isValidOperationData(Map<String, dynamic> data) {
    return data.containsKey('id') &&
        data.containsKey('type') &&
        data['id'] is String &&
        data['type'] is String;
  }

  /// Serialize operations to JSON list
  List<Map<String, dynamic>> _serializeOperations(
      List<QueueableOperation> operations) {
    return operations.map((op) => op.toJson()).toList();
  }

  /// Clear all operations from storage
  Future<bool> clearAllOperations() async {
    try {
      await _prefs.remove(_StorageKeys.pendingOperations);
      await _prefs.remove(_StorageKeys.failedOperations);
      await _prefs.remove(_StorageKeys.lastSaveTime);
      debugPrint('OperationStorageService: Cleared all operations');
      return true;
    } catch (e, stackTrace) {
      debugPrint('OperationStorageService: Error clearing operations: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get the last save time
  DateTime? getLastSaveTime() {
    final timestamp = _prefs.getInt(_StorageKeys.lastSaveTime);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final pendingJson = _prefs.getString(_StorageKeys.pendingOperations);
      final failedJson = _prefs.getString(_StorageKeys.failedOperations);
      final lastSave = getLastSaveTime();

      final pendingCount = pendingJson != null
          ? (jsonDecode(pendingJson) as List).length
          : 0;
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
    } catch (e, stackTrace) {
      debugPrint('OperationStorageService: Error getting storage stats: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'error': e.toString(),
      };
    }
  }

  /// Save sensitive operation data to secure storage
  Future<bool> saveSensitiveData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      debugPrint(
          'OperationStorageService: Saved sensitive data for key: $key');
      return true;
    } catch (e, stackTrace) {
      debugPrint(
          'OperationStorageService: Error saving sensitive data: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Load sensitive operation data from secure storage
  Future<String?> loadSensitiveData(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      debugPrint(
          'OperationStorageService: Loaded sensitive data for key: $key');
      return value;
    } catch (e, stackTrace) {
      debugPrint(
          'OperationStorageService: Error loading sensitive data: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Delete sensitive data from secure storage
  Future<bool> deleteSensitiveData(String key) async {
    try {
      await _secureStorage.delete(key: key);
      debugPrint(
          'OperationStorageService: Deleted sensitive data for key: $key');
      return true;
    } catch (e, stackTrace) {
      debugPrint(
          'OperationStorageService: Error deleting sensitive data: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Clear all sensitive data
  Future<bool> clearAllSensitiveData() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('OperationStorageService: Cleared all sensitive data');
      return true;
    } catch (e, stackTrace) {
      debugPrint(
          'OperationStorageService: Error clearing sensitive data: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }
}
