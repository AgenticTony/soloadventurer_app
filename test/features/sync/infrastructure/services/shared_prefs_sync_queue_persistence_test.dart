import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/shared_prefs_sync_queue_persistence.dart';

@GenerateMocks([SharedPreferences])
import 'shared_prefs_sync_queue_persistence_test.mocks.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late SharedPrefsSyncQueuePersistence persistence;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    persistence = SharedPrefsSyncQueuePersistence(mockPrefs);
  });

  group('SharedPrefsSyncQueuePersistence', () {
    test('should save operations correctly', () async {
      // Arrange
      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test Trip'},
      );

      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);

      // Act
      final result = await persistence.saveQueue([operation]);

      // Assert
      expect(result.success, true);
      expect(result.operationCount, 1);
      verify(mockPrefs.setString('sync_queue_op_op1', any));
      verify(mockPrefs.setStringList('sync_queue_operations', ['op1']));
    });

    test('should load operations correctly', () async {
      // Arrange
      final operation = SyncOperation.create(
        id: 'op1',
        entityType: SyncEntityType.trip,
        data: const {'title': 'Test Trip'},
      );

      when(mockPrefs.getStringList('sync_queue_operations'))
          .thenReturn(['op1']);
      when(mockPrefs.getString('sync_queue_op_op1'))
          .thenReturn(jsonEncode(operation.toJson()));

      // Act
      final loaded = await persistence.loadQueue();

      // Assert
      expect(loaded.length, 1);
      expect(loaded[0].id, 'op1');
      expect(loaded[0].entityType, SyncEntityType.trip);
    });

    test('should return empty list when no operations exist', () async {
      // Arrange
      when(mockPrefs.getStringList('sync_queue_operations')).thenReturn(null);

      // Act
      final loaded = await persistence.loadQueue();

      // Assert
      expect(loaded, isEmpty);
    });

    test('should clear all operations', () async {
      // Arrange
      when(mockPrefs.getStringList('sync_queue_operations'))
          .thenReturn(['op1', 'op2']);
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);

      // Act
      final result = await persistence.clearQueue();

      // Assert
      expect(result.success, true);
      verify(mockPrefs.remove('sync_queue_op_op1'));
      verify(mockPrefs.remove('sync_queue_op_op2'));
      verify(mockPrefs.remove('sync_queue_operations'));
    });

    test('should check for persisted operations', () async {
      // Arrange
      when(mockPrefs.getStringList('sync_queue_operations'))
          .thenReturn(['op1']);

      // Act
      final hasOperations = await persistence.hasPersistedOperations();

      // Assert
      expect(hasOperations, true);
    });

    test('should return false when no operations exist', () async {
      // Arrange
      when(mockPrefs.getStringList('sync_queue_operations')).thenReturn(null);

      // Act
      final hasOperations = await persistence.hasPersistedOperations();

      // Assert
      expect(hasOperations, false);
    });

    test('should get operation count', () async {
      // Arrange
      when(mockPrefs.getStringList('sync_queue_operations'))
          .thenReturn(['op1', 'op2', 'op3']);

      // Act
      final count = await persistence.getOperationCount();

      // Assert
      expect(count, 3);
    });

    test('should remove specific operation', () async {
      // Arrange
      when(mockPrefs.getStringList('sync_queue_operations'))
          .thenReturn(['op1', 'op2']);
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);
      when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);

      // Act
      final removed = await persistence.removeOperation('op1');

      // Assert
      expect(removed, true);
      verify(mockPrefs.remove('sync_queue_op_op1'));
      verify(mockPrefs.setStringList('sync_queue_operations', ['op2']));
    });

    test('should handle corrupted data gracefully', () async {
      // Arrange
      when(mockPrefs.getStringList('sync_queue_operations'))
          .thenReturn(['op1', 'op2']);
      when(mockPrefs.getString('sync_queue_op_op1')).thenReturn('invalid json');
      when(mockPrefs.getString('sync_queue_op_op2')).thenReturn(null);
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);
      when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);

      // Act
      final loaded = await persistence.loadQueue();

      // Assert
      expect(loaded, isEmpty);
      verify(mockPrefs.remove('sync_queue_op_op1'));
      verify(mockPrefs.remove('sync_queue_op_op2'));
    });
  });
}
