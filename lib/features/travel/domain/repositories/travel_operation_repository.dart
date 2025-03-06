import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/base_travel_operation.dart';
import '../models/trip_planning_operation.dart';
import '../models/travel_note_operation.dart';

/// Repository interface for managing travel operations storage
abstract class TravelOperationRepository {
  /// Store a travel operation
  Future<void> saveOperation(BaseTravelOperation operation);

  /// Get all pending operations
  Future<List<BaseTravelOperation>> getPendingOperations();

  /// Get operations by type
  Future<List<BaseTravelOperation>> getOperationsByType(String type);

  /// Delete an operation after it's been processed
  Future<void> deleteOperation(String id);

  /// Get operations for a specific trip
  Future<List<BaseTravelOperation>> getOperationsForTrip(String tripId);

  /// Clear all processed operations
  Future<void> clearProcessedOperations();
}
