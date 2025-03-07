import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/travel/domain/models/base_travel_operation.dart';
import 'package:soloadventurer/features/travel/infrastructure/repositories/shared_prefs_travel_operation_repository.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late SharedPrefsTravelOperationRepository repository;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    repository = SharedPrefsTravelOperationRepository(mockPrefs);
  });

  group('SharedPrefsTravelOperationRepository', () {
    const testOpId = 'test-op-1';
    const testTripId = 'test-trip-1';

    final testOperation = BaseTravelOperation(
      id: testOpId,
      type: 'trip_planning',
      timestamp: DateTime.now(),
      data: {
        'tripId': testTripId,
        'planningType': 'create',
        'changes': {'name': 'Test Trip'},
      },
    );

    test('saveOperation should store operation and update pending list',
        () async {
      // Arrange
      when(() => mockPrefs.getStringList('pending_ops')).thenReturn([]);
      when(() => mockPrefs.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockPrefs.setStringList(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await repository.saveOperation(testOperation);

      // Assert
      verify(() => mockPrefs.setString('travel_op_$testOpId', any())).called(1);
      verify(() => mockPrefs.setStringList('pending_ops', [testOpId]))
          .called(1);
    });

    test('getPendingOperations should return all pending operations', () async {
      // Arrange
      when(() => mockPrefs.getStringList('pending_ops')).thenReturn([testOpId]);
      when(() => mockPrefs.getString('travel_op_$testOpId'))
          .thenReturn(jsonEncode(testOperation.toJson()));

      // Act
      final operations = await repository.getPendingOperations();

      // Assert
      expect(operations.length, 1);
      expect(operations.first.id, testOpId);
      expect(operations.first.type, 'trip_planning');
    });

    test('deleteOperation should remove operation and update pending list',
        () async {
      // Arrange
      when(() => mockPrefs.getStringList('pending_ops')).thenReturn([testOpId]);
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
      when(() => mockPrefs.setStringList(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await repository.deleteOperation(testOpId);

      // Assert
      verify(() => mockPrefs.remove('travel_op_$testOpId')).called(1);
      verify(() => mockPrefs.setStringList('pending_ops', [])).called(1);
    });

    test('getOperationsForTrip should return trip-specific operations',
        () async {
      // Arrange
      when(() => mockPrefs.getStringList('pending_ops')).thenReturn([testOpId]);
      when(() => mockPrefs.getString('travel_op_$testOpId'))
          .thenReturn(jsonEncode(testOperation.toJson()));

      // Act
      final operations = await repository.getOperationsForTrip(testTripId);

      // Assert
      expect(operations.length, 1);
      expect(operations.first.id, testOpId);
      expect(operations.first.data['tripId'], testTripId);
    });

    test('clearProcessedOperations should remove all operations', () async {
      // Arrange
      when(() => mockPrefs.getStringList('pending_ops')).thenReturn([testOpId]);
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
      when(() => mockPrefs.setStringList(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await repository.clearProcessedOperations();

      // Assert
      verify(() => mockPrefs.remove('travel_op_$testOpId')).called(1);
      verify(() => mockPrefs.setStringList('pending_ops', [])).called(1);
    });

    test('should handle deserialization errors gracefully', () async {
      // Arrange
      when(() => mockPrefs.getStringList('pending_ops')).thenReturn([testOpId]);
      when(() => mockPrefs.getString('travel_op_$testOpId'))
          .thenReturn('invalid json');

      // Act
      final operations = await repository.getPendingOperations();

      // Assert
      expect(operations, isEmpty);
    });
  });
}
