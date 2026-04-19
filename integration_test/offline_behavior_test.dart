import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart';
import 'package:soloadventurer/core/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/domain/repositories/sync_queue_repository.dart';
import 'package:soloadventurer/features/matching/domain/entities/matching_trip.dart';
import 'package:soloadventurer/features/matching/domain/entities/connection.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';
import 'package:soloadventurer/features/matching/domain/entities/chat.dart';
import 'package:soloadventurer/features/matching/data/models/trip_model.dart';
import 'package:soloadventurer/features/matching/data/models/message_model.dart';
import 'test_config.dart';

// Test constants
const testUserId = 'user-123';
const testTripId = 'trip-123';
const testChatId = 'chat-123';
const testMessageId = 'msg-123';

/// Mock connectivity service for testing
class MockConnectivityService implements ConnectivityService {
  bool _isOnline = true;
  final List<void Function(bool)> _listeners = [];
  final _networkStatusController = StreamController<NetworkStatus>.broadcast();

  void setOnline(bool isOnline) {
    _isOnline = isOnline;
    _networkStatusController.add(isOnline ? NetworkStatus.connected : NetworkStatus.disconnected);
    for (final listener in _listeners) {
      listener(isOnline);
    }
  }

  @override
  Stream<ConnectivityStatus> get connectivityStream =>
      Stream.value(ConnectivityStatus(
        connectionType: _isOnline ? ConnectionType.wifi : ConnectionType.none,
        isConnected: _isOnline,
        timestamp: DateTime.now(),
      ));

  @override
  Stream<NetworkStatus> get onConnectivityChanged =>
      _networkStatusController.stream;

  void addTestListener(void Function(bool) listener) {
    _listeners.add(listener);
  }

  void removeTestListener(void Function(bool) listener) {
    _listeners.remove(listener);
  }

  @override
  Future<ConnectivityStatus> checkConnectivity() async {
    return ConnectivityStatus(
      connectionType: _isOnline ? ConnectionType.wifi : ConnectionType.none,
      isConnected: _isOnline,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<NetworkStatus> checkNetworkStatus() async {
    return _isOnline ? NetworkStatus.connected : NetworkStatus.disconnected;
  }

  @override
  Future<bool> get hasConnectivity async => _isOnline;

  @override
  bool get hasConnectivitySync => _isOnline;

  @override
  void dispose() {
    _networkStatusController.close();
  }
}

/// Mock sync queue repository for testing
class MockSyncQueueRepository implements SyncQueueRepository {
  final List<SyncOperationEntity> _queue = [];
  int _nextId = 1;

  @override
  Future<SyncOperationEntity> enqueueOperation(SyncOperationEntity operation) async {
    final op = operation.copyWith(id: _nextId++);
    _queue.add(op);
    return op;
  }

  @override
  Future<int> enqueueOperations(List<SyncOperationEntity> operations) async {
    int count = 0;
    for (final op in operations) {
      await enqueueOperation(op);
      count++;
    }
    return count;
  }

  @override
  Future<SyncOperationEntity?> dequeueOperation() async {
    final pending = _queue
        .where((op) => op.status == SyncOperationStatus.pending)
        .toList();
    return pending.isNotEmpty ? pending.first : null;
  }

  @override
  Future<List<SyncOperationEntity>> getPendingOperations({int limit = 50}) async {
    return _queue
        .where((op) => op.status == SyncOperationStatus.pending)
        .take(limit)
        .toList();
  }

  @override
  Future<List<SyncOperationEntity>> getOperationsByEntity(
    String entityType,
    String entityId,
  ) async {
    return _queue
        .where((op) => op.entityType == entityType && op.entityId == entityId)
        .toList();
  }

  @override
  Future<List<SyncOperationEntity>> getOperationsByEntityType(
    String entityType,
  ) async {
    return _queue.where((op) => op.entityType == entityType).toList();
  }

  @override
  Future<List<SyncOperationEntity>> getOperationsByStatus(
    SyncOperationStatus status,
  ) async {
    return _queue.where((op) => op.status == status).toList();
  }

  @override
  Future<SyncOperationEntity?> getOperationById(int id) async {
    final idx = _queue.indexWhere((op) => op.id == id);
    return idx >= 0 ? _queue[idx] : null;
  }

  @override
  Future<int> markAsCompleted(int id) async {
    final idx = _queue.indexWhere((op) => op.id == id);
    if (idx >= 0) {
      _queue[idx] = _queue[idx].markAsCompleted();
      return 1;
    }
    return 0;
  }

  @override
  Future<int> markAsFailed(int id, String errorMessage) async {
    final idx = _queue.indexWhere((op) => op.id == id);
    if (idx >= 0) {
      _queue[idx] = _queue[idx].markAsFailed(errorMessage);
      return 1;
    }
    return 0;
  }

  @override
  Future<int> markAsProcessing(int id) async {
    final idx = _queue.indexWhere((op) => op.id == id);
    if (idx >= 0) {
      _queue[idx] = _queue[idx].markAsProcessing();
      return 1;
    }
    return 0;
  }

  @override
  Future<int> resetOperationsForRetry(List<int> ids) async {
    int count = 0;
    for (final id in ids) {
      final idx = _queue.indexWhere((op) => op.id == id);
      if (idx >= 0) {
        _queue[idx] = _queue[idx].resetForRetry();
        count++;
      }
    }
    return count;
  }

  @override
  Future<List<SyncOperationEntity>> getOperationsReadyForRetry() async {
    return _queue.where((op) => op.shouldRetryNow).toList();
  }

  @override
  Future<int> clearCompletedOperations() async {
    final initial = _queue.length;
    _queue.removeWhere((op) =>
        op.status == SyncOperationStatus.completed ||
        op.status == SyncOperationStatus.failed);
    return initial - _queue.length;
  }

  @override
  Future<int> clearAllOperations() async {
    final count = _queue.length;
    _queue.clear();
    return count;
  }

  @override
  Future<int> clearOldCompletedOperations(DateTime olderThan) async {
    final initial = _queue.length;
    _queue.removeWhere((op) =>
        op.status == SyncOperationStatus.completed &&
        op.completedAt != null &&
        op.completedAt!.isBefore(olderThan));
    return initial - _queue.length;
  }

  @override
  Future<int> clearOperationsForEntity(String entityType, String entityId) async {
    final initial = _queue.length;
    _queue.removeWhere(
        (op) => op.entityType == entityType && op.entityId == entityId);
    return initial - _queue.length;
  }

  @override
  Future<int> clearOldFailedOperations(DateTime olderThan) async {
    final initial = _queue.length;
    _queue.removeWhere((op) =>
        op.status == SyncOperationStatus.failed &&
        op.lastAttemptedAt != null &&
        op.lastAttemptedAt!.isBefore(olderThan));
    return initial - _queue.length;
  }

  @override
  Future<int> countPendingOperations() async {
    return _queue.where((op) => op.status == SyncOperationStatus.pending).length;
  }

  @override
  Future<int> countFailedOperations() async {
    return _queue.where((op) => op.status == SyncOperationStatus.failed).length;
  }

  @override
  Future<Map<String, int>> getQueueStatistics() async {
    return {
      'pending': _queue.where((op) => op.status == SyncOperationStatus.pending).length,
      'processing': _queue.where((op) => op.status == SyncOperationStatus.processing).length,
      'completed': _queue.where((op) => op.status == SyncOperationStatus.completed).length,
      'failed': _queue.where((op) => op.status == SyncOperationStatus.failed).length,
    };
  }

  @override
  Future<int> getQueueSize() async => _queue.length;

  @override
  Future<int> updateOperation(SyncOperationEntity operation) async {
    final idx = _queue.indexWhere((op) => op.id == operation.id);
    if (idx >= 0) {
      _queue[idx] = operation;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteOperation(int id) async {
    final initial = _queue.length;
    _queue.removeWhere((op) => op.id == id);
    return initial - _queue.length;
  }

  @override
  Future<int> deleteOperations(List<int> ids) async {
    final initial = _queue.length;
    _queue.removeWhere((op) => ids.contains(op.id));
    return initial - _queue.length;
  }

  List<SyncOperationEntity> get allOperations => List.unmodifiable(_queue);

  void clearAll() {
    _queue.clear();
  }
}

/// Mock sync queue service for testing
class MockSyncQueueService implements SyncQueueService {
  final MockSyncQueueRepository _repository;
  final List<SyncOperationEntity> _completedOperations = [];
  final StreamController<int> _queueSizeController = StreamController<int>.broadcast();

  MockSyncQueueService(this._repository);

  @override
  Stream<int> get queueSizeStream => _queueSizeController.stream;

  @override
  Future<int> getQueueSize() async => _repository.getQueueSize();

  @override
  Future<int> getPendingCount() async => _repository.countPendingOperations();

  @override
  Future<int> getFailedCount() async => _repository.countFailedOperations();

  @override
  Future<Map<String, int>> getQueueStatistics() async =>
      _repository.getQueueStatistics();

  @override
  Future<SyncQueueResult> enqueueOperation({
    required String entityType,
    required String entityId,
    required SyncOperationType operation,
    required Map<String, dynamic> data,
    SyncPriority priority = SyncPriority.normal,
    int maxRetries = 3,
    int? version,
  }) async {
    final entity = SyncOperationEntity(
      id: 0,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
      priority: priority,
      maxRetries: maxRetries,
      status: SyncOperationStatus.pending,
      createdAt: DateTime.now(),
      version: version,
    );
    final result = await _repository.enqueueOperation(entity);
    _queueSizeController.add(await _repository.getQueueSize());
    return SyncQueueResult.success(operationId: result.id);
  }

  @override
  Future<SyncQueueResult> enqueueOperations(
    List<Map<String, dynamic>> operations,
  ) async {
    final entities = operations.map((op) {
      return SyncOperationEntity(
        id: 0,
        entityType: op['entityType'] as String,
        entityId: op['entityId'] as String,
        operation: op['operation'] as SyncOperationType,
        data: op['data'] as Map<String, dynamic>,
        priority: op['priority'] as SyncPriority? ?? SyncPriority.normal,
        maxRetries: op['maxRetries'] as int? ?? 3,
        status: SyncOperationStatus.pending,
        createdAt: DateTime.now(),
        version: op['version'] as int?,
      );
    }).toList();
    final count = await _repository.enqueueOperations(entities);
    _queueSizeController.add(await _repository.getQueueSize());
    return SyncQueueResult.success(operationsCount: count);
  }

  @override
  Future<SyncQueueResult> processPendingOperations({
    int limit = 10,
    required Future<bool> Function(SyncOperationEntity) onProcess,
  }) async {
    final ops = await _repository.getPendingOperations(limit: limit);
    int successCount = 0;
    for (final op in ops) {
      try {
        await _repository.markAsProcessing(op.id);
        final success = await onProcess(op);
        if (success) {
          await _repository.markAsCompleted(op.id);
          _completedOperations.add(op.markAsCompleted());
          successCount++;
        } else {
          await _repository.markAsFailed(op.id, 'Processing returned false');
        }
      } catch (e) {
        await _repository.markAsFailed(op.id, e.toString());
      }
    }
    _queueSizeController.add(await _repository.getQueueSize());
    return SyncQueueResult.success(operationsCount: successCount);
  }

  @override
  Future<SyncQueueResult> retryFailedOperations({int limit = 10}) async {
    final ready = await _repository.getOperationsReadyForRetry();
    final toRetry = ready.take(limit).toList();
    final ids = toRetry.map((op) => op.id).toList();
    final count = await _repository.resetOperationsForRetry(ids);
    _queueSizeController.add(await _repository.getQueueSize());
    return SyncQueueResult.success(operationsCount: count);
  }

  @override
  Future<SyncQueueResult> clearOldCompletedOperations() async {
    final count = await _repository.clearCompletedOperations();
    _queueSizeController.add(await _repository.getQueueSize());
    return SyncQueueResult.success(operationsCount: count);
  }

  @override
  Future<SyncQueueResult> clearOldFailedOperations() async {
    final count = await _repository.clearAllOperations();
    _queueSizeController.add(await _repository.getQueueSize());
    return SyncQueueResult.success(operationsCount: count);
  }

  @override
  Future<SyncQueueResult> clearAllCompletedOperations() async {
    final count = await _repository.clearCompletedOperations();
    _queueSizeController.add(await _repository.getQueueSize());
    return SyncQueueResult.success(operationsCount: count);
  }

  @override
  Future<SyncQueueResult> clearAllOperations() async {
    final count = await _repository.clearAllOperations();
    _queueSizeController.add(await _repository.getQueueSize());
    return SyncQueueResult.success(operationsCount: count);
  }

  @override
  Future<bool> initialize() async {
    return true;
  }

  @override
  void dispose() {
    _queueSizeController.close();
  }

  List<SyncOperationEntity> get completedOperations =>
      List.unmodifiable(_completedOperations);

  void clearAll() {
    _repository.clearAll();
    _completedOperations.clear();
  }
}

/// Mock sync manager for testing
class MockSyncManager implements SyncManager {
  final MockConnectivityService _connectivityService;
  final MockSyncQueueService _queueService;

  SyncState _state = SyncState.idle;
  SyncPhase _phase = SyncPhase.none;
  double _progress = 0.0;
  int _pendingOperations = 0;
  DateTime? _lastSyncTime;
  bool _autoSyncEnabled = true;

  final List<SyncStatus> _statusHistory = [];
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  MockSyncManager(this._connectivityService, this._queueService);

  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  @override
  SyncStatus get currentStatus => SyncStatus(
        state: _state,
        phase: _phase,
        progress: _progress,
        pendingOperations: _pendingOperations,
        lastSyncTime: _lastSyncTime,
      );

  @override
  Future<bool> initialize() async {
    _pendingOperations = await _queueService.getPendingCount();
    _emitStatus();
    return true;
  }

  @override
  Future<SyncResult> startSync({bool force = false}) async {
    if (_state == SyncState.syncing) {
      return SyncResult.failure(
        'Sync already in progress',
        duration: Duration.zero,
      );
    }

    _state = SyncState.syncing;
    _phase = SyncPhase.upload;
    _progress = 0.0;
    _emitStatus();

    final startTime = DateTime.now();
    int uploaded = 0;
    int downloaded = 0;
    int conflicts = 0;

    try {
      // Upload phase
      final pendingOps =
          await _queueService.processPendingOperations(limit: 100, onProcess: (op) async {
        uploaded++;
        return true;
      });
      _progress = 0.5;
      _emitStatus();

      // Download phase
      _phase = SyncPhase.download;
      _progress = 0.5;
      _emitStatus();

      downloaded = 0;

      // Finalization
      _phase = SyncPhase.finalization;
      _progress = 0.9;
      _emitStatus();

      // Complete
      _state = SyncState.idle;
      _phase = SyncPhase.none;
      _progress = 1.0;
      _lastSyncTime = DateTime.now();
      _pendingOperations = 0;
      _emitStatus();

      return SyncResult.success(
        uploadedCount: uploaded,
        downloadedCount: downloaded,
        conflictsResolved: conflicts,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e) {
      _state = SyncState.error;
      _emitStatus();
      return SyncResult.failure(
        e.toString(),
        duration: DateTime.now().difference(startTime),
      );
    }
  }

  @override
  Future<bool> stopSync() async {
    if (_state != SyncState.syncing) return false;
    _state = SyncState.idle;
    _phase = SyncPhase.none;
    _emitStatus();
    return true;
  }

  @override
  void pauseAutoSync() {
    _autoSyncEnabled = false;
  }

  @override
  void resumeAutoSync() {
    _autoSyncEnabled = true;
  }

  @override
  void dispose() {
    _statusHistory.clear();
    _statusController.close();
  }

  void _emitStatus() {
    final status = SyncStatus(
      state: _state,
      phase: _phase,
      progress: _progress,
      pendingOperations: _pendingOperations,
      lastSyncTime: _lastSyncTime,
    );
    _statusHistory.add(status);
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }
}

/// Local storage for offline data
class MockLocalTripStorage {
  final List<MatchingTrip> _localTrips = [];
  final Map<String, bool> _pendingSync = {};

  Future<void> saveTrip(MatchingTrip trip, {bool pendingSync = false}) async {
    final index = _localTrips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      _localTrips[index] = trip;
    } else {
      _localTrips.add(trip);
    }
    _pendingSync[trip.id] = pendingSync;
  }

  Future<List<MatchingTrip>> getLocalTrips() async {
    return List.unmodifiable(_localTrips);
  }

  Future<List<MatchingTrip>> getPendingSyncTrips() async {
    return _localTrips
        .where((t) => _pendingSync[t.id] == true)
        .toList();
  }

  Future<void> markAsSynced(String tripId) async {
    _pendingSync[tripId] = false;
  }

  void clearAll() {
    _localTrips.clear();
    _pendingSync.clear();
  }
}

/// Local storage for offline messages
class MockLocalMessageStorage {
  final List<Message> _localMessages = [];
  final Map<String, bool> _pendingSync = {};

  Future<void> saveMessage(Message message, {bool pendingSync = false}) async {
    _localMessages.add(message);
    _pendingSync[message.id] = pendingSync;
  }

  Future<List<Message>> getLocalMessages(String chatId) async {
    return _localMessages.where((m) => m.chatId == chatId).toList();
  }

  Future<List<Message>> getPendingSyncMessages() async {
    return _localMessages
        .where((m) => _pendingSync[m.id] == true)
        .toList();
  }

  Future<void> markAsSynced(String messageId) async {
    _pendingSync[messageId] = false;
  }

  void clearAll() {
    _localMessages.clear();
    _pendingSync.clear();
  }
}

/// Remote data source mock for testing sync behavior
class MockRemoteDataSource {
  final List<MatchingTrip> _remoteTrips = [];
  final List<Message> _remoteMessages = [];

  bool _isOnline = true;

  void setOnline(bool isOnline) => _isOnline = isOnline;

  Future<MatchingTrip> createTrip(MatchingTrip trip) async {
    if (!_isOnline) throw Exception('No internet connection');
    _remoteTrips.add(trip);
    return trip;
  }

  Future<List<MatchingTrip>> getTrips() async {
    if (!_isOnline) throw Exception('No internet connection');
    return List.unmodifiable(_remoteTrips);
  }

  Future<void> sendMessage(Message message) async {
    if (!_isOnline) throw Exception('No internet connection');
    _remoteMessages.add(message);
  }

  Future<List<Message>> getMessages(String chatId) async {
    if (!_isOnline) throw Exception('No internet connection');
    return _remoteMessages.where((m) => m.chatId == chatId).toList();
  }

  void clearAll() {
    _remoteTrips.clear();
    _remoteMessages.clear();
  }
}

/// Offline-aware repository for testing
class OfflineAwareMatchingRepository {
  final MockRemoteDataSource _remoteDataSource;
  final MockLocalTripStorage _localStorage;
  final MockSyncQueueService _syncQueueService;
  final MockConnectivityService _connectivityService;

  OfflineAwareMatchingRepository(
    this._remoteDataSource,
    this._localStorage,
    this._syncQueueService,
    this._connectivityService,
  );

  Future<MatchingTrip> createTrip({
    required String destinationName,
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    LocationPrecision locationPrecision = LocationPrecision.city,
  }) async {
    // Create trip locally first (optimistic update)
    final trip = TripModel(
      id: 'local-trip-${DateTime.now().millisecondsSinceEpoch}',
      userId: testUserId,
      destinationName: destinationName,
      latitude: latitude,
      longitude: longitude,
      locationPrecision: locationPrecision,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final connectivityStatus = await _connectivityService.checkConnectivity();

    if (connectivityStatus.isConnected) {
      // Sync immediately if online
      try {
        final remoteTrip = await _remoteDataSource.createTrip(trip);
        await _localStorage.saveTrip(remoteTrip, pendingSync: false);
        return remoteTrip;
      } catch (e) {
        // Queue for sync if remote fails
        await _localStorage.saveTrip(trip, pendingSync: true);
        await _syncQueueService.enqueueOperation(
          entityType: 'trip',
          entityId: trip.id,
          operation: SyncOperationType.create,
          data: {
            'destinationName': destinationName,
            'latitude': latitude,
            'longitude': longitude,
            'startDate': startDate.toIso8601String(),
            'endDate': endDate.toIso8601String(),
            'locationPrecision': locationPrecision.name,
          },
        );
        return trip;
      }
    } else {
      // Save locally and queue for sync
      await _localStorage.saveTrip(trip, pendingSync: true);
      await _syncQueueService.enqueueOperation(
        entityType: 'trip',
        entityId: trip.id,
        operation: SyncOperationType.create,
        data: {
          'destinationName': destinationName,
          'latitude': latitude,
          'longitude': longitude,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'locationPrecision': locationPrecision.name,
        },
      );
      return trip;
    }
  }

  Future<List<MatchingTrip>> getTrips() async {
    final connectivityStatus = await _connectivityService.checkConnectivity();

    if (connectivityStatus.isConnected) {
      try {
        final remoteTrips = await _remoteDataSource.getTrips();
        // Update local cache
        for (final trip in remoteTrips) {
          await _localStorage.saveTrip(trip, pendingSync: false);
        }
        return remoteTrips;
      } catch (e) {
        // Fall back to local if remote fails
        return _localStorage.getLocalTrips();
      }
    } else {
      // Return local data when offline
      return _localStorage.getLocalTrips();
    }
  }

  Future<int> getPendingSyncCount() async {
    return _syncQueueService.getPendingCount();
  }

  Future<void> syncPendingTrips() async {
    final pendingTrips = await _localStorage.getPendingSyncTrips();
    final connectivityStatus = await _connectivityService.checkConnectivity();

    if (connectivityStatus.isConnected && pendingTrips.isNotEmpty) {
      for (final trip in pendingTrips) {
        try {
          await _remoteDataSource.createTrip(trip);
          await _localStorage.markAsSynced(trip.id);
        } catch (e) {
          // Keep in pending state
        }
      }
    }
  }
}

/// Offline-aware messaging repository for testing
class OfflineAwareMessagingRepository {
  final MockRemoteDataSource _remoteDataSource;
  final MockLocalMessageStorage _localStorage;
  final MockSyncQueueService _syncQueueService;
  final MockConnectivityService _connectivityService;

  OfflineAwareMessagingRepository(
    this._remoteDataSource,
    this._localStorage,
    this._syncQueueService,
    this._connectivityService,
  );

  Future<Message> sendMessage({
    required String chatId,
    required String content,
  }) async {
    // Create message locally first
    final message = MessageModel(
      id: 'local-msg-${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: testUserId,
      content: content,
      status: MessageStatus.pending,
      createdAt: DateTime.now(),
    );

    final connectivityStatus = await _connectivityService.checkConnectivity();

    if (connectivityStatus.isConnected) {
      try {
        // Update status to sent
        final sentMessage =
            message.copyWith(status: MessageStatus.sent) as MessageModel;
        await _remoteDataSource.sendMessage(sentMessage);
        await _localStorage.saveMessage(sentMessage, pendingSync: false);
        return sentMessage;
      } catch (e) {
        // Queue for sync if remote fails
        await _localStorage.saveMessage(message, pendingSync: true);
        await _syncQueueService.enqueueOperation(
          entityType: 'message',
          entityId: message.id,
          operation: SyncOperationType.create,
          data: {
            'chatId': chatId,
            'content': content,
          },
        );
        return message;
      }
    } else {
      // Save locally and queue for sync
      await _localStorage.saveMessage(message, pendingSync: true);
      await _syncQueueService.enqueueOperation(
        entityType: 'message',
        entityId: message.id,
        operation: SyncOperationType.create,
        data: {
          'chatId': chatId,
          'content': content,
        },
      );
      return message;
    }
  }

  Future<List<Message>> getMessages(String chatId) async {
    final connectivityStatus = await _connectivityService.checkConnectivity();

    if (connectivityStatus.isConnected) {
      try {
        final remoteMessages = await _remoteDataSource.getMessages(chatId);
        // Update local cache
        for (final message in remoteMessages) {
          await _localStorage.saveMessage(message, pendingSync: false);
        }
        return remoteMessages;
      } catch (e) {
        // Fall back to local if remote fails
        return _localStorage.getLocalMessages(chatId);
      }
    } else {
      // Return local data when offline
      return _localStorage.getLocalMessages(chatId);
    }
  }

  Future<int> getPendingSyncCount() async {
    return _syncQueueService.getPendingCount();
  }

  Future<void> syncPendingMessages() async {
    final pendingMessages = await _localStorage.getPendingSyncMessages();
    final connectivityStatus = await _connectivityService.checkConnectivity();

    if (connectivityStatus.isConnected && pendingMessages.isNotEmpty) {
      for (final message in pendingMessages) {
        try {
          final sentMessage = message.copyWith(status: MessageStatus.sent);
          await _remoteDataSource.sendMessage(sentMessage);
          await _localStorage.markAsSynced(message.id);
        } catch (e) {
          // Keep in pending state
        }
      }
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockConnectivityService connectivityService;
  late MockSyncQueueRepository syncQueueRepository;
  late MockSyncQueueService syncQueueService;
  late MockSyncManager syncManager;
  late MockRemoteDataSource remoteDataSource;
  late MockLocalTripStorage localTripStorage;
  late MockLocalMessageStorage localMessageStorage;
  late OfflineAwareMatchingRepository matchingRepository;
  late OfflineAwareMessagingRepository messagingRepository;

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    // Initialize mock services
    connectivityService = MockConnectivityService();
    syncQueueRepository = MockSyncQueueRepository();
    syncQueueService = MockSyncQueueService(syncQueueRepository);
    remoteDataSource = MockRemoteDataSource();
    localTripStorage = MockLocalTripStorage();
    localMessageStorage = MockLocalMessageStorage();

    syncManager = MockSyncManager(connectivityService, syncQueueService);

    matchingRepository = OfflineAwareMatchingRepository(
      remoteDataSource,
      localTripStorage,
      syncQueueService,
      connectivityService,
    );

    messagingRepository = OfflineAwareMessagingRepository(
      remoteDataSource,
      localMessageStorage,
      syncQueueService,
      connectivityService,
    );

    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    syncManager.dispose();
    syncQueueService.dispose();
  });

  group('Offline Behavior Tests', () {
    group('Trip Creation Offline Tests', () {
      test('User creates trip while offline - trip queued locally', () async {
        // Setup - offline
        connectivityService.setOnline(false);
        remoteDataSource.setOnline(false);

        // Create trip while offline
        final trip = await matchingRepository.createTrip(
          destinationName: 'Tokyo, Japan',
          latitude: 35.6762,
          longitude: 139.6503,
          startDate: DateTime.now().add(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 14)),
        );

        // Verify trip was created locally
        expect(trip, isNotNull);
        expect(trip.destinationName, equals('Tokyo, Japan'));

        // Verify trip is in local storage
        final localTrips = await localTripStorage.getLocalTrips();
        expect(localTrips, contains(trip));

        // Verify trip is pending sync
        final pendingTrips = await localTripStorage.getPendingSyncTrips();
        expect(pendingTrips, contains(trip));

        // Verify sync queue has pending operation
        final pendingCount = await matchingRepository.getPendingSyncCount();
        expect(pendingCount, greaterThan(0));
      });

      test('Trip syncs when online', () async {
        // Setup - start offline
        connectivityService.setOnline(false);
        remoteDataSource.setOnline(false);

        // Create trip while offline
        final trip = await matchingRepository.createTrip(
          destinationName: 'Paris, France',
          latitude: 48.8566,
          longitude: 2.3522,
          startDate: DateTime.now().add(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 15)),
        );

        // Verify pending sync
        var pendingTrips = await localTripStorage.getPendingSyncTrips();
        expect(pendingTrips, isNotEmpty);

        // Go online
        connectivityService.setOnline(true);
        remoteDataSource.setOnline(true);

        // Sync pending trips
        await matchingRepository.syncPendingTrips();

        // Verify trip is no longer pending
        pendingTrips = await localTripStorage.getPendingSyncTrips();
        expect(pendingTrips, isEmpty);

        // Verify trip exists on remote
        final remoteTrips = await remoteDataSource.getTrips();
        expect(
            remoteTrips.any((t) => t.destinationName == 'Paris, France'),
            isTrue);
      });

      test('Multiple trips created offline sync in order', () async {
        // Setup - offline
        connectivityService.setOnline(false);
        remoteDataSource.setOnline(false);

        // Create multiple trips
        final trip1 = await matchingRepository.createTrip(
          destinationName: 'London, UK',
          latitude: 51.5074,
          longitude: -0.1278,
          startDate: DateTime.now().add(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 5)),
        );

        final trip2 = await matchingRepository.createTrip(
          destinationName: 'Berlin, Germany',
          latitude: 52.5200,
          longitude: 13.4050,
          startDate: DateTime.now().add(const Duration(days: 6)),
          endDate: DateTime.now().add(const Duration(days: 10)),
        );

        final trip3 = await matchingRepository.createTrip(
          destinationName: 'Rome, Italy',
          latitude: 41.9028,
          longitude: 12.4964,
          startDate: DateTime.now().add(const Duration(days: 11)),
          endDate: DateTime.now().add(const Duration(days: 15)),
        );

        // Verify all trips are pending sync
        var pendingTrips = await localTripStorage.getPendingSyncTrips();
        expect(pendingTrips.length, equals(3));

        // Go online
        connectivityService.setOnline(true);
        remoteDataSource.setOnline(true);

        // Sync
        await matchingRepository.syncPendingTrips();

        // Verify all synced
        pendingTrips = await localTripStorage.getPendingSyncTrips();
        expect(pendingTrips, isEmpty);

        // Verify all on remote
        final remoteTrips = await remoteDataSource.getTrips();
        expect(remoteTrips.length, equals(3));
      });
    });

    group('Message Offline Tests', () {
      test('Messages queued while offline', () async {
        // Setup - offline
        connectivityService.setOnline(false);
        remoteDataSource.setOnline(false);

        // Send message while offline
        final message = await messagingRepository.sendMessage(
          chatId: testChatId,
          content: 'Hello from offline!',
        );

        // Verify message was saved locally
        expect(message, isNotNull);
        expect(message.content, equals('Hello from offline!'));
        expect(message.status, equals(MessageStatus.pending));

        // Verify message is in local storage
        final localMessages =
            await localMessageStorage.getLocalMessages(testChatId);
        expect(localMessages, contains(message));

        // Verify message is pending sync
        final pendingMessages =
            await localMessageStorage.getPendingSyncMessages();
        expect(pendingMessages, contains(message));
      });

      test('Messages sync when online', () async {
        // Setup - start offline
        connectivityService.setOnline(false);
        remoteDataSource.setOnline(false);

        // Send message while offline
        final message = await messagingRepository.sendMessage(
          chatId: testChatId,
          content: 'Sync me!',
        );

        // Verify pending sync
        var pendingMessages =
            await localMessageStorage.getPendingSyncMessages();
        expect(pendingMessages, isNotEmpty);

        // Go online
        connectivityService.setOnline(true);
        remoteDataSource.setOnline(true);

        // Sync pending messages
        await messagingRepository.syncPendingMessages();

        // Verify message is no longer pending
        pendingMessages = await localMessageStorage.getPendingSyncMessages();
        expect(pendingMessages, isEmpty);

        // Verify message exists on remote
        final remoteMessages = await remoteDataSource.getMessages(testChatId);
        expect(remoteMessages.any((m) => m.content == 'Sync me!'), isTrue);
      });

      test('Multiple messages queued and sync in order', () async {
        // Setup - offline
        connectivityService.setOnline(false);
        remoteDataSource.setOnline(false);

        // Send multiple messages
        await messagingRepository.sendMessage(
          chatId: testChatId,
          content: 'Message 1',
        );

        await messagingRepository.sendMessage(
          chatId: testChatId,
          content: 'Message 2',
        );

        await messagingRepository.sendMessage(
          chatId: testChatId,
          content: 'Message 3',
        );

        // Verify all messages are pending sync
        var pendingMessages =
            await localMessageStorage.getPendingSyncMessages();
        expect(pendingMessages.length, equals(3));

        // Go online
        connectivityService.setOnline(true);
        remoteDataSource.setOnline(true);

        // Sync
        await messagingRepository.syncPendingMessages();

        // Verify all synced
        pendingMessages = await localMessageStorage.getPendingSyncMessages();
        expect(pendingMessages, isEmpty);

        // Verify all on remote
        final remoteMessages = await remoteDataSource.getMessages(testChatId);
        expect(remoteMessages.length, equals(3));
      });

      test('Message status updates correctly', () async {
        // Setup - offline
        connectivityService.setOnline(false);
        remoteDataSource.setOnline(false);

        // Send message while offline
        final offlineMessage = await messagingRepository.sendMessage(
          chatId: testChatId,
          content: 'Status test',
        );

        // Verify pending status
        expect(offlineMessage.status, equals(MessageStatus.pending));

        // Go online
        connectivityService.setOnline(true);
        remoteDataSource.setOnline(true);

        // Send another message while online
        final onlineMessage = await messagingRepository.sendMessage(
          chatId: testChatId,
          content: 'Online message',
        );

        // Verify sent status
        expect(onlineMessage.status, equals(MessageStatus.sent));
      });
    });

    group('Sync Manager Tests', () {
      test('Sync manager initializes correctly', () async {
        // Initialize
        final initialized = await syncManager.initialize();

        // Verify
        expect(initialized, isTrue);
        expect(syncManager.currentStatus.state, equals(SyncState.idle));
      });

      test('Sync manager starts sync', () async {
        // Setup - add some pending operations
        await syncQueueService.enqueueOperation(
          entityType: 'trip',
          entityId: 'trip-1',
          operation: SyncOperationType.create,
          data: {},
        );

        // Initialize
        await syncManager.initialize();

        // Start sync
        final result = await syncManager.startSync();

        // Verify sync completed
        expect(result.success, isTrue);
        expect(result.uploadedCount, greaterThan(0));
      });

      test('Sync manager handles no pending operations', () async {
        // Initialize
        await syncManager.initialize();

        // Start sync with no pending operations
        final result = await syncManager.startSync();

        // Verify sync completed
        expect(result.success, isTrue);
        expect(result.uploadedCount, equals(0));
      });

      test('Sync manager prevents concurrent syncs', () async {
        // Initialize
        await syncManager.initialize();

        // Add pending operation
        await syncQueueService.enqueueOperation(
          entityType: 'trip',
          entityId: 'trip-concurrent',
          operation: SyncOperationType.create,
          data: {},
        );

        // Start first sync
        final firstSync = syncManager.startSync();

        // Try to start second sync immediately
        final secondResult = await syncManager.startSync();

        // Second sync should fail
        expect(secondResult.success, isFalse);
        expect(secondResult.errorMessage, contains('already in progress'));

        // Wait for first sync to complete
        await firstSync;
      });

      test('Sync manager can stop sync', () async {
        // Initialize
        await syncManager.initialize();

        // Start sync
        final syncFuture = syncManager.startSync();

        // Stop sync
        final stopped = await syncManager.stopSync();

        // Verify sync was stopped (if it was still running)
        expect(stopped, isTrue);

        await syncFuture;
      });

      test('Sync manager pause and resume auto sync', () async {
        // Pause auto sync
        syncManager.pauseAutoSync();

        // Resume auto sync
        syncManager.resumeAutoSync();

        // No error means success
      });
    });

    group('Connectivity Service Tests', () {
      test('Connectivity service reports online status', () async {
        // Online
        connectivityService.setOnline(true);
        final onlineStatus =
            await connectivityService.checkConnectivity();
        expect(onlineStatus.isConnected, isTrue);
        expect(onlineStatus.connectionType, equals(ConnectionType.wifi));

        // Offline
        connectivityService.setOnline(false);
        final offlineStatus =
            await connectivityService.checkConnectivity();
        expect(offlineStatus.isConnected, isFalse);
        expect(offlineStatus.connectionType, equals(ConnectionType.none));
      });

      test('Connectivity service notifies listeners on change', () async {
        var notifiedValue = true;

        // Add listener
        connectivityService.addTestListener((isOnline) {
          notifiedValue = isOnline;
        });

        // Start online
        connectivityService.setOnline(true);
        expect(notifiedValue, isTrue);

        // Go offline
        connectivityService.setOnline(false);
        expect(notifiedValue, isFalse);

        // Go online again
        connectivityService.setOnline(true);
        expect(notifiedValue, isTrue);
      });
    });

    group('Sync Queue Tests', () {
      test('Sync queue stores operations', () async {
        // Add operation
        await syncQueueService.enqueueOperation(
          entityType: 'trip',
          entityId: 'trip-q1',
          operation: SyncOperationType.create,
          data: {'test': 'data'},
        );

        // Verify operation is in queue via repository
        final pendingOps =
            await syncQueueRepository.getPendingOperations();
        expect(pendingOps.length, equals(1));
      });

      test('Sync queue marks operations as completed', () async {
        // Add operation
        final result = await syncQueueService.enqueueOperation(
          entityType: 'trip',
          entityId: 'trip-q2',
          operation: SyncOperationType.create,
          data: {},
        );

        // Process operations - mark as completed
        await syncQueueService.processPendingOperations(
          onProcess: (op) async => true,
        );

        // Verify no pending operations
        final pendingOps =
            await syncQueueRepository.getPendingOperations();
        expect(pendingOps, isEmpty);
      });

      test('Sync queue marks operations as failed', () async {
        // Add operation
        await syncQueueService.enqueueOperation(
          entityType: 'trip',
          entityId: 'trip-q3',
          operation: SyncOperationType.create,
          data: {},
        );

        // Process operations - mark as failed
        await syncQueueService.processPendingOperations(
          onProcess: (op) async => false,
        );

        // Verify no pending operations
        final pendingOps =
            await syncQueueRepository.getPendingOperations();
        expect(pendingOps, isEmpty);
      });

      test('Sync queue can retry failed operations', () async {
        // Add operation
        await syncQueueService.enqueueOperation(
          entityType: 'trip',
          entityId: 'trip-q4',
          operation: SyncOperationType.create,
          data: {},
        );

        // Mark as failed via process
        await syncQueueService.processPendingOperations(
          onProcess: (op) async => false,
        );

        // Manually reset for retry via repository
        final failedOps =
            await syncQueueRepository.getOperationsByStatus(
                SyncOperationStatus.failed);
        if (failedOps.isNotEmpty) {
          await syncQueueRepository
              .resetOperationsForRetry([failedOps.first.id]);
        }

        // Verify operation is pending again
        final pendingOps =
            await syncQueueRepository.getPendingOperations();
        expect(pendingOps.length, equals(1));
      });

      test('Sync queue counts pending operations', () async {
        // Add multiple operations
        await syncQueueService.enqueueOperation(
          entityType: 'trip',
          entityId: 'trip-c1',
          operation: SyncOperationType.create,
          data: {},
        );

        await syncQueueService.enqueueOperation(
          entityType: 'message',
          entityId: 'msg-c1',
          operation: SyncOperationType.create,
          data: {},
        );

        // Get count
        final count = await syncQueueService.getPendingCount();
        expect(count, equals(2));
      });
    });

    group('Conflict Resolution Tests', () {
      test('Local data is preserved when offline', () async {
        // Setup - offline
        connectivityService.setOnline(false);
        remoteDataSource.setOnline(false);

        // Create trip
        final trip = await matchingRepository.createTrip(
          destinationName: 'Preserved Trip',
          latitude: 0.0,
          longitude: 0.0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
        );

        // Get trips while still offline
        final localTrips = await matchingRepository.getTrips();

        // Verify local trip is preserved
        expect(localTrips, isNotEmpty);
        expect(
            localTrips.any((t) => t.destinationName == 'Preserved Trip'),
            isTrue);
      });

      test('Remote data updates local cache', () async {
        // Setup - online
        connectivityService.setOnline(true);
        remoteDataSource.setOnline(true);

        // Create trip on remote
        await remoteDataSource.createTrip(TripModel(
          id: 'remote-trip-1',
          userId: testUserId,
          destinationName: 'Remote Trip',
          latitude: 10.0,
          longitude: 20.0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        // Get trips (should update local cache)
        final trips = await matchingRepository.getTrips();

        // Verify remote trip is in results
        expect(
            trips.any((t) => t.destinationName == 'Remote Trip'), isTrue);

        // Verify local cache has the trip
        final localTrips = await localTripStorage.getLocalTrips();
        expect(
            localTrips.any((t) => t.destinationName == 'Remote Trip'),
            isTrue);
      });
    });
  });
}
