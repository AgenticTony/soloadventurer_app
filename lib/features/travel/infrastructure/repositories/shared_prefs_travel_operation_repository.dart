import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/travel_operation_repository.dart';
import '../../domain/models/base_travel_operation.dart';
import '../../domain/models/trip_planning_operation.dart';
import '../../domain/models/travel_note_operation.dart';

class SharedPrefsTravelOperationRepository
    implements TravelOperationRepository {
  final SharedPreferences _prefs;
  static const String _keyPrefix = 'travel_op_';
  static const String _pendingOpsKey = 'pending_ops';

  SharedPrefsTravelOperationRepository(this._prefs);

  @override
  Future<void> saveOperation(BaseTravelOperation operation) async {
    final String opKey = '$_keyPrefix${operation.id}';
    final String opJson = jsonEncode(operation.toJson());

    await _prefs.setString(opKey, opJson);

    // Update pending operations list
    final List<String> pendingOps = _prefs.getStringList(_pendingOpsKey) ?? [];
    if (!pendingOps.contains(operation.id)) {
      pendingOps.add(operation.id);
      await _prefs.setStringList(_pendingOpsKey, pendingOps);
    }
  }

  @override
  Future<List<BaseTravelOperation>> getPendingOperations() async {
    final List<String> pendingOps = _prefs.getStringList(_pendingOpsKey) ?? [];
    final List<BaseTravelOperation> operations = [];

    for (final String opId in pendingOps) {
      final String? opJson = _prefs.getString('$_keyPrefix$opId');
      if (opJson != null) {
        try {
          final Map<String, dynamic> opMap = jsonDecode(opJson);
          final operation = _deserializeOperation(opMap);
          if (operation != null) {
            operations.add(operation);
          }
        } catch (e) {
          // Log error and continue
        }
      }
    }

    return operations;
  }

  @override
  Future<List<BaseTravelOperation>> getOperationsByType(String type) async {
    final List<BaseTravelOperation> allOps = await getPendingOperations();
    return allOps.where((op) => op.type == type).toList();
  }

  @override
  Future<void> deleteOperation(String id) async {
    final String opKey = '$_keyPrefix$id';
    await _prefs.remove(opKey);

    // Remove from pending operations list
    final List<String> pendingOps = _prefs.getStringList(_pendingOpsKey) ?? [];
    pendingOps.remove(id);
    await _prefs.setStringList(_pendingOpsKey, pendingOps);
  }

  @override
  Future<List<BaseTravelOperation>> getOperationsForTrip(String tripId) async {
    final List<BaseTravelOperation> allOps = await getPendingOperations();
    return allOps.where((op) {
      final Map<String, dynamic> json = op.toJson();
      return json['tripId'] == tripId;
    }).toList();
  }

  @override
  Future<void> clearProcessedOperations() async {
    final List<String> pendingOps = _prefs.getStringList(_pendingOpsKey) ?? [];

    // Remove all operation data
    for (final String opId in pendingOps) {
      await _prefs.remove('$_keyPrefix$opId');
    }

    // Clear pending operations list
    await _prefs.setStringList(_pendingOpsKey, []);
  }

  BaseTravelOperation? _deserializeOperation(Map<String, dynamic> json) {
    final String type = json['type'] as String;
    try {
      switch (type) {
        case 'trip_planning':
          return TripPlanningOperation.fromJson(json) as BaseTravelOperation;
        case 'travel_note':
          return TravelNoteOperation.fromJson(json) as BaseTravelOperation;
        default:
          return BaseTravelOperation.fromJson(json);
      }
    } catch (e) {
      return null;
    }
  }
}
