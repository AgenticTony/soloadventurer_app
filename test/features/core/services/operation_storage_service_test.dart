import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:soloadventurer/features/auth/infrastructure/providers/secure_storage_provider.dart';
import 'package:soloadventurer/features/core/providers/operation_queue_provider.dart';
import 'package:soloadventurer/features/core/services/operation_queue.dart';

@GenerateMocks([SharedPreferences, FlutterSecureStorage])
import 'operation_storage_service_test.mocks.dart';

void main() {
  group('OperationStorageService', () {
    late MockSharedPreferences mockPrefs;
    late MockFlutterSecureStorage mockSecureStorage;
    late ProviderContainer container;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      mockSecureStorage = MockFlutterSecureStorage();

      // Set up mocks for SharedPreferences.getInstance()
      SharedPreferences.setMockInitialValues({});

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          secureStorageProvider.overrideWithValue(mockSecureStorage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Save Operations', () {
      test('should save pending operations successfully', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.savePendingOperations([]);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setString('pending_operations', any));
        verify(mockPrefs.setInt('operation_queue_last_save', any));
      });

      test('should clear storage when saving empty operation list', () async {
        // Arrange
        when(mockPrefs.remove('pending_operations'))
            .thenAnswer((_) async => true);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.savePendingOperations([]);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.remove('pending_operations'));
      });

      test('should save failed operations successfully', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.saveFailedOperations([]);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setString('failed_operations', any));
      });

      test('should handle large operation data', () async {
        // Arrange
        final operations = List.generate(
          100,
          (i) => _createMockOperation('id_$i', 'type_$i'),
        );
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.savePendingOperations(operations);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setString('pending_operations', any));
      });

      test('should handle save errors gracefully', () async {
        // Arrange
        when(mockPrefs.setString(any, any))
            .thenThrow(Exception('Storage error'));
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.savePendingOperations([]);

        // Assert
        expect(result, isFalse);
      });
    });

    group('Load Operations', () {
      test('should load pending operations successfully', () async {
        // Arrange
        final operationsJson = [
          {
            'id': 'op1',
            'type': 'trip_planning',
            'priority': 2,
            'requiresNetwork': true,
          },
          {
            'id': 'op2',
            'type': 'location_update',
            'priority': 1,
            'requiresNetwork': true,
          },
        ];
        when(mockPrefs.getString('pending_operations')).thenReturn(
            '[${operationsJson.map((e) => _jsonEncode(e)).join(',')}]');
        when(mockPrefs.getString('failed_operations')).thenReturn(null);
        when(mockPrefs.getInt('operation_queue_version')).thenReturn(1);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.loadOperations();

        // Assert
        expect(result.pendingOperations.length, 2);
        expect(result.pendingOperations[0]['id'], 'op1');
        expect(result.pendingOperations[1]['id'], 'op2');
        expect(result.hadCorruptedData, isFalse);
      });

      test('should handle missing operations data', () async {
        // Arrange
        when(mockPrefs.getString('pending_operations')).thenReturn(null);
        when(mockPrefs.getString('failed_operations')).thenReturn(null);
        when(mockPrefs.getInt('operation_queue_version')).thenReturn(0);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.loadOperations();

        // Assert
        expect(result.pendingOperations, isEmpty);
        expect(result.failedOperations, isEmpty);
        expect(result.hadCorruptedData, isFalse);
      });

      test('should handle corrupted data gracefully', () async {
        // Arrange
        when(mockPrefs.getString('pending_operations'))
            .thenReturn('invalid json{{{');
        when(mockPrefs.getString('failed_operations')).thenReturn(null);
        when(mockPrefs.getInt('operation_queue_version')).thenReturn(1);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.loadOperations();

        // Assert
        expect(result.pendingOperations, isEmpty);
        expect(result.hadCorruptedData, isTrue);
        expect(result.errorMessage, isNotNull);
      });

      test('should skip operations with missing required fields', () async {
        // Arrange
        final operationsJson = [
          {
            'id': 'op1',
            'type': 'trip_planning',
            'priority': 2,
          },
          {
            // Missing 'type' field - should be skipped
            'id': 'op2',
            'priority': 1,
          },
          {
            // Missing 'id' field - should be skipped
            'type': 'location_update',
          },
        ];
        when(mockPrefs.getString('pending_operations')).thenReturn(
            '[${operationsJson.map((e) => _jsonEncode(e)).join(',')}]');
        when(mockPrefs.getString('failed_operations')).thenReturn(null);
        when(mockPrefs.getInt('operation_queue_version')).thenReturn(1);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.loadOperations();

        // Assert
        expect(result.pendingOperations.length, 1);
        expect(result.pendingOperations[0]['id'], 'op1');
        expect(result.hadCorruptedData, isTrue);
      });

      test('should handle version mismatch', () async {
        // Arrange
        when(mockPrefs.getString('pending_operations')).thenReturn('[]');
        when(mockPrefs.getString('failed_operations')).thenReturn(null);
        when(mockPrefs.getInt('operation_queue_version')).thenReturn(999);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.loadOperations();

        // Assert
        expect(result.pendingOperations, isEmpty);
        // Should still load but log warning about version mismatch
      });
    });

    group('Clear Operations', () {
      test('should clear all operations successfully', () async {
        // Arrange
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.clearAllOperations();

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.remove('pending_operations'));
        verify(mockPrefs.remove('failed_operations'));
        verify(mockPrefs.remove('operation_queue_last_save'));
      });

      test('should handle clear errors gracefully', () async {
        // Arrange
        when(mockPrefs.remove(any)).thenThrow(Exception('Clear error'));
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.clearAllOperations();

        // Assert
        expect(result, isFalse);
      });
    });

    group('Storage Statistics', () {
      test('should return accurate storage statistics', () async {
        // Arrange
        const pendingJson =
            '[{"id":"op1","type":"test"},{"id":"op2","type":"test"}]';
        const failedJson = '[{"id":"op3","type":"test"}]';
        when(mockPrefs.getString('pending_operations')).thenReturn(pendingJson);
        when(mockPrefs.getString('failed_operations')).thenReturn(failedJson);
        when(mockPrefs.getInt('operation_queue_last_save_time'))
            .thenReturn(1640000000000);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final stats = await service.getStorageStats();

        // Assert
        expect(stats['pendingCount'], 2);
        expect(stats['failedCount'], 1);
        expect(stats['totalSizeBytes'], greaterThan(0));
        expect(stats['lastSaveTime'], isNotNull);
      });

      test('should handle empty storage statistics', () async {
        // Arrange
        when(mockPrefs.getString('pending_operations')).thenReturn(null);
        when(mockPrefs.getString('failed_operations')).thenReturn(null);
        when(mockPrefs.getInt('operation_queue_last_save_time'))
            .thenReturn(null);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final stats = await service.getStorageStats();

        // Assert
        expect(stats['pendingCount'], 0);
        expect(stats['failedCount'], 0);
        expect(stats['totalSizeBytes'], 0);
        expect(stats['lastSaveTime'], isNull);
      });
    });

    group('Secure Storage', () {
      test('should save sensitive data successfully', () async {
        // Arrange
        when(mockSecureStorage.write(key: any, value: any))
            .thenAnswer((_) async => Future.value());
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result =
            await service.saveSensitiveData('test_key', 'test_value');

        // Assert
        expect(result, isTrue);
        verify(mockSecureStorage.write(key: 'test_key', value: 'test_value'));
      });

      test('should load sensitive data successfully', () async {
        // Arrange
        when(mockSecureStorage.read(key: any))
            .thenAnswer((_) async => 'test_value');
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.loadSensitiveData('test_key');

        // Assert
        expect(result, 'test_value');
        verify(mockSecureStorage.read(key: 'test_key'));
      });

      test('should delete sensitive data successfully', () async {
        // Arrange
        when(mockSecureStorage.delete(key: any))
            .thenAnswer((_) async => Future.value());
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.deleteSensitiveData('test_key');

        // Assert
        expect(result, isTrue);
        verify(mockSecureStorage.delete(key: 'test_key'));
      });

      test('should clear all sensitive data successfully', () async {
        // Arrange
        when(mockSecureStorage.deleteAll())
            .thenAnswer((_) async => Future.value());
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = await service.clearAllSensitiveData();

        // Assert
        expect(result, isTrue);
        verify(mockSecureStorage.deleteAll());
      });

      test('should handle secure storage errors gracefully', () async {
        // Arrange
        when(mockSecureStorage.write(key: any, value: any))
            .thenThrow(Exception('Secure storage error'));
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result =
            await service.saveSensitiveData('test_key', 'test_value');

        // Assert
        expect(result, isFalse);
      });
    });

    group('Last Save Time', () {
      test('should return null if no save time exists', () async {
        // Arrange
        when(mockPrefs.getInt('operation_queue_last_save_time'))
            .thenReturn(null);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = service.getLastSaveTime();

        // Assert
        expect(result, isNull);
      });

      test('should return valid DateTime if save time exists', () async {
        // Arrange
        const timestamp = 1640000000000;
        when(mockPrefs.getInt('operation_queue_last_save_time'))
            .thenReturn(timestamp);
        final service =
            container.read(operationStorageServiceProvider.notifier);

        // Act
        final result = service.getLastSaveTime();

        // Assert
        expect(result, isNotNull);
        expect(result!.millisecondsSinceEpoch, timestamp);
      });
    });
  });
}

// Helper function to create mock operations
QueueableOperation _createMockOperation(String id, String type) {
  return _MockQueueableOperation(id, type);
}

// Helper function to encode JSON
String _jsonEncode(Map<String, dynamic> map) {
  return '{${map.entries.map((e) => '"${e.key}":"${e.value}"').join(',')}}';
}

// Mock implementation of QueueableOperation for testing
class _MockQueueableOperation implements QueueableOperation {
  @override
  final String id;

  @override
  final String type;

  @override
  int get priority => 1;

  @override
  bool get requiresNetwork => true;

  @override
  int get attemptCount => 0;

  @override
  DateTime? get createdAt => DateTime.now();

  @override
  String? get deduplicationKey => 'test_$id';

  @override
  DateTime? get lastAttempt => null;

  @override
  String? get lastError => null;

  @override
  int get maxRetries => 3;

  _MockQueueableOperation(this.id, this.type);

  @override
  Future<void> execute() async {
    // Mock implementation
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'priority': priority,
      'requiresNetwork': requiresNetwork,
    };
  }
}
