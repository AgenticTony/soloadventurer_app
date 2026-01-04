# Offline-First Development Guide

## Overview

This guide provides comprehensive instructions for adding new features to the SoloAdventurer offline-first app. It builds upon the general [FEATURE_DEVELOPMENT.md](../FEATURE_DEVELOPMENT.md) guide and adds specific considerations for offline-first architecture.

## Table of Contents

- [When to Use Offline-First](#when-to-use-offline-first)
- [Offline-First Architecture Overview](#offline-first-architecture-overview)
- [Creating Syncable Entities](#creating-syncable-entities)
- [Implementing Offline-Aware Repositories](#implementing-offline-aware-repositories)
- [Adding Local Database Support](#adding-local-database-support)
- [Handling Conflicts](#handling-conflicts)
- [Testing Offline Features](#testing-offline-features)
- [Best Practices](#best-practices)
- [Common Pitfalls](#common-pitfalls)
- [Migration Guide](#migration-guide)

## When to Use Offline-First

### Use Offline-First When:

- **User-generated content**: Users create trips, journals, notes, etc.
- **Frequent offline scenarios**: Travelers in flights, remote areas, poor connectivity
- **Critical data**: Data that users need to access reliably (itinerary, bookings)
- **Slow networks**: Areas with slow mobile data where caching improves UX
- **Multi-device sync**: Users access data from phone, tablet, desktop

### Consider Regular API + Cache When:

- **Reference data**: Static data that rarely changes (country codes, currencies)
- **Real-time features**: Chat, live tracking that needs immediate server sync
- **Large media files**: Photos/videos that require special handling
- **Read-only content**: Content that users only consume, not create

## Offline-First Architecture Overview

The offline-first architecture extends the standard clean architecture with these key components:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐   │
│  │  Sync Status  │  │ Connectivity  │  │    Offline    │   │
│  │    Banner     │  │   Indicator   │  │    Banner     │   │
│  └───────────────┘  └───────────────┘  └───────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐   │
│  │ Sync Manager  │  │   Conflict    │  │ Connectivity  │   │
│  │               │  │   Resolver    │  │   Service     │   │
│  └───────────────┘  └───────────────┘  └───────────────┘   │
│  ┌───────────────┐  ┌───────────────┐                        │
│  │ Sync Queue    │  │ Offline-Aware │                        │
│  │   Service     │  │  Repositories │                        │
│  └───────────────┘  └───────────────┘                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐   │
│  │   Local DB    │  │  Sync Queue   │  │   Remote API  │   │
│  │  (Drift/SQL)  │  │   Repository  │  │   (GraphQL)   │   │
│  └───────────────┘  └───────────────┘  └───────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Local-First Reads**: Always read from local database first for instant UI
2. **Optimistic Writes**: Write to local database immediately, sync in background
3. **Transparent Sync**: Sync happens automatically without user intervention
4. **Conflict Resolution**: Gracefully handle concurrent edits
5. **User Trust**: Clear indicators of sync status and data safety

## Creating Syncable Entities

### Step 1: Define Domain Entity

Create your domain entity as usual in `features/your_feature/domain/entities/`:

```dart
// lib/features/your_feature/domain/entities/itinerary_item.dart
class ItineraryItem {
  final String id;
  final String tripId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final double? latitude;
  final double? longitude;
  final ItineraryItemType type;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ItineraryItem({
    required this.id,
    required this.tripId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.latitude,
    this.longitude,
    required this.type,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  // Validation
  bool get isValid {
    return id.isNotEmpty &&
        tripId.isNotEmpty &&
        title.isNotEmpty &&
        startTime.isBefore(endTime);
  }

  // CopyWith for immutability
  ItineraryItem copyWith({
    String? id,
    String? tripId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    double? latitude,
    double? longitude,
    ItineraryItemType? type,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ItineraryItemType {
  activity,
  transportation,
  accommodation,
  meal,
  other,
}
```

### Step 2: Create Local Database Model

Create a local model in `features/offline/data/models/`:

```dart
// lib/features/offline/data/models/local_itinerary_item_model.dart
import 'package:drift/drift.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/app_database.dart';
import 'package:soloadventurer/features/your_feature/domain/entities/itinerary_item.dart';

/// Local model for itinerary items with sync metadata
class LocalItineraryItemModel {
  final String id;
  final String tripId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final double? latitude;
  final double? longitude;
  final ItineraryItemType type;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync metadata fields
  final bool isSynced;
  final bool hasPendingChanges;
  final int version;
  final bool isDeleted;
  final DateTime? lastSyncedAt;

  const LocalItineraryItemModel({
    required this.id,
    required this.tripId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.latitude,
    this.longitude,
    required this.type,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.hasPendingChanges = false,
    this.version = 1,
    this.isDeleted = false,
    this.lastSyncedAt,
  });

  /// Convert from domain entity
  factory LocalItineraryItemModel.fromDomainEntity(ItineraryItem entity) {
    return LocalItineraryItemModel(
      id: entity.id,
      tripId: entity.tripId,
      title: entity.title,
      description: entity.description,
      startTime: entity.startTime,
      endTime: entity.endTime,
      location: entity.location,
      latitude: entity.latitude,
      longitude: entity.longitude,
      type: entity.type,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      // New entities start as unsynced
      isSynced: false,
      hasPendingChanges: true,
      version: 1,
      isDeleted: false,
      lastSyncedAt: null,
    );
  }

  /// Convert to domain entity
  ItineraryItem toDomainEntity() {
    return ItineraryItem(
      id: id,
      tripId: tripId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      latitude: latitude,
      longitude: longitude,
      type: type,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert from database entity
  factory LocalItineraryItemModel.fromDatabase(ItineraryItemTableData data) {
    return LocalItineraryItemModel(
      id: data.id,
      tripId: data.tripId,
      title: data.title,
      description: data.description,
      startTime: data.startTime,
      endTime: data.endTime,
      location: data.location,
      latitude: data.latitude,
      longitude: data.longitude,
      type: ItineraryItemType.values.firstWhere(
        (e) => e.name == data.type,
        orElse: () => ItineraryItemType.other,
      ),
      order: data.order,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isSynced: data.isSynced,
      hasPendingChanges: data.hasPendingChanges,
      version: data.version,
      isDeleted: data.isDeleted,
      lastSyncedAt: data.lastSyncedAt,
    );
  }

  /// Convert to database companion for inserts/updates
  ItineraryItemsCompanion toCompanion() {
    return ItineraryItemsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      title: Value(title),
      description: Value(description),
      startTime: Value(startTime),
      endTime: Value(endTime),
      location: Value(location),
      latitude: Value(latitude),
      longitude: Value(longitude),
      type: Value(type.name),
      order: Value(order),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      hasPendingChanges: Value(hasPendingChanges),
      version: Value(version),
      isDeleted: Value(isDeleted),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  /// Convert to JSON for sync queue
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.name,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
    };
  }
}
```

### Step 3: Define Database Table

Add the table to your Drift database:

```dart
// lib/features/offline/infrastructure/database/app_database.dart
@DataClassName('ItineraryItemTableData')
class ItineraryItems extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  TextColumn get location => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get type => text()();
  IntColumn get order => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync metadata
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get hasPendingChanges => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  // Indexes for performance
  @override
  List<Index> get indexes => [
        Index('idx_itinerary_items_trip_id', [tripId]),
        Index('idx_itinerary_items_sync_status', [isSynced, hasPendingChanges]),
        Index('idx_itinerary_items_deleted', [isDeleted]),
        Index('idx_itinerary_items_trip_active', [tripId, isDeleted]),
      ];
}
```

### Step 4: Create DAO

Create a Data Access Object for database operations:

```dart
// lib/features/offline/infrastructure/database/dao/itinerary_item_dao.dart
import 'package:soloadventurer/features/offline/infrastructure/database/app_database.dart';
import 'package:drift/drift.dart';

part 'itinerary_item_dao.g.dart';

@DriftAccessor(tables: [ItineraryItems])
class ItineraryItemDao extends DatabaseAccessor<AppDatabase> with _$ItineraryItemDaoMixin {
  ItineraryItemDao(AppDatabase db) : super(db);

  /// Get a single itinerary item by ID
  Future<ItineraryItemTableData?> getItineraryItemById(String id) {
    return (select(itineraryItems)
          ..where((tbl) => tbl.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get all itinerary items for a trip
  Future<List<ItineraryItemTableData>> getItineraryItemsByTripId(String tripId) {
    return (select(itineraryItems)
          ..where((tbl) => tbl.tripId.equals(tripId))
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.order)]))
        .get();
  }

  /// Get all unsynced items
  Future<List<ItineraryItemTableData>> getUnsyncedItems() {
    return (select(itineraryItems)
          ..where((tbl) => tbl.isSynced.equals(false))
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
  }

  /// Insert a new itinerary item
  Future<void> insertItineraryItem(ItineraryItemsCompanion item) {
    return into(itineraryItems).insert(item);
  }

  /// Update an existing itinerary item
  Future<bool> updateItineraryItem(ItineraryItemTableData item) {
    return update(itineraryItems).replace(item);
  }

  /// Soft delete an itinerary item
  Future<void> softDeleteItineraryItem(String id) {
    return (update(itineraryItems)..where((tbl) => tbl.id.equals(id)))
        .write(ItineraryItemsCompanion(
      isDeleted: const Value(true),
      hasPendingChanges: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Permanently delete an item (after sync)
  Future<void> permanentlyDeleteItineraryItem(String id) {
    return (delete(itineraryItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Get all items (including soft deleted)
  Future<List<ItineraryItemTableData>> getAllItineraryItems() {
    return select(itineraryItems).get();
  }
}
```

**IMPORTANT**: After creating the DAO, run the build runner to generate required files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Implementing Offline-Aware Repositories

### Step 1: Extend OfflineAwareRepository

Create your repository implementation:

```dart
// lib/features/your_feature/infrastructure/repositories/itinerary_item_repository_impl.dart
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';
import 'package:soloadventurer/features/offline/data/models/local_itinerary_item_model.dart';
import 'package:soloadventurer/features/offline/data/repositories/offline_aware_repository.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/itinerary_item_dao.dart';
import 'package:soloadventurer/features/your_feature/domain/entities/itinerary_item.dart';
import 'package:soloadventurer/features/your_feature/domain/repositories/itinerary_item_repository.dart';

/// Offline-aware implementation of [ItineraryItemRepository]
///
/// Extends [OfflineAwareRepository] to provide offline-first functionality:
/// - Reads from local database first
/// - Writes to local database immediately
/// - Queues mutations for sync when offline
/// - Syncs with server when online
class ItineraryItemRepositoryImpl extends OfflineAwareRepository<
    ItineraryItem,
    LocalItineraryItemModel,
    Map<String, dynamic>,
    Map<String, dynamic>> implements ItineraryItemRepository {
  final ItineraryItemDao _dao;
  final DioApiService _apiService;

  ItineraryItemRepositoryImpl({
    required ItineraryItemDao dao,
    required DioApiService apiService,
    required ConnectivityService connectivityService,
    required SyncQueueService syncQueueService,
    super.config,
  })  : _dao = dao,
        _apiService = apiService,
        super(
          connectivityService: connectivityService,
          syncQueueService: syncQueueService,
        );

  // ==============================================================================
  // OFFLINE-AWARE BASE REPOSITORY ABSTRACT METHODS
  // ==============================================================================

  @override
  String get entityType => 'itineraryItem';

  @override
  LocalItineraryItemModel entityToModel(ItineraryItem entity) {
    return LocalItineraryItemModel.fromDomainEntity(entity);
  }

  @override
  ItineraryItem modelToEntity(LocalItineraryItemModel model) {
    return model.toDomainEntity();
  }

  @override
  String getEntityId(ItineraryItem entity) => entity.id;

  @override
  String getModelId(LocalItineraryItemModel model) => model.id;

  @override
  Future<LocalItineraryItemModel?> readFromLocal(String id) async {
    try {
      final data = await _dao.getItineraryItemById(id);
      return data != null ? LocalItineraryItemModel.fromDatabase(data) : null;
    } catch (e) {
      debugPrint('❌ itineraryItem: Error reading from local: ${e.toString()}');
      throw CacheException(message: 'Failed to read itinerary item from cache');
    }
  }

  @override
  Future<LocalItineraryItemModel> writeToLocal(LocalItineraryItemModel model) async {
    try {
      final companion = model.toCompanion();
      final existing = await _dao.getItineraryItemById(model.id);

      if (existing != null) {
        await _dao.updateItineraryItem(
          ItineraryItemTableData(
            id: model.id,
            tripId: model.tripId,
            title: model.title,
            description: model.description,
            startTime: model.startTime,
            endTime: model.endTime,
            location: model.location,
            latitude: model.latitude,
            longitude: model.longitude,
            type: model.type.name,
            order: model.order,
            createdAt: model.createdAt,
            updatedAt: DateTime.now(),
            isSynced: model.isSynced,
            hasPendingChanges: true, // Mark as having pending changes
            version: model.version,
            isDeleted: model.isDeleted,
            lastSyncedAt: model.lastSyncedAt,
          ),
        );
        debugPrint('📝 itineraryItem: Updated in local database: ${model.id}');
      } else {
        await _dao.insertItineraryItem(companion);
        debugPrint('📝 itineraryItem: Inserted in local database: ${model.id}');
      }

      return model;
    } catch (e) {
      debugPrint('❌ itineraryItem: Error writing to local: ${e.toString()}');
      throw CacheException(message: 'Failed to write itinerary item to cache');
    }
  }

  @override
  Future<void> deleteFromLocal(String id) async {
    try {
      await _dao.softDeleteItineraryItem(id);
      debugPrint('📝 itineraryItem: Soft deleted in local database: $id');
    } catch (e) {
      debugPrint('❌ itineraryItem: Error deleting from local: ${e.toString()}');
      throw CacheException(message: 'Failed to delete itinerary item from cache');
    }
  }

  @override
  Future<List<LocalItineraryItemModel>> readAllFromLocal({String? userId}) async {
    try {
      // If tripId is provided as userId parameter (common pattern)
      if (userId != null) {
        final items = await _dao.getItineraryItemsByTripId(userId);
        return items.map((item) => LocalItineraryItemModel.fromDatabase(item)).toList();
      }
      // Otherwise get all items
      final items = await _dao.getAllItineraryItems();
      return items.map((item) => LocalItineraryItemModel.fromDatabase(item)).toList();
    } catch (e) {
      debugPrint('❌ itineraryItem: Error reading all from local: ${e.toString()}');
      throw CacheException(message: 'Failed to read itinerary items from cache');
    }
  }

  // ==============================================================================
  // REMOTE API OPERATIONS
  // ==============================================================================

  @override
  Future<ItineraryItem> executeRemoteCreate(Map<String, dynamic> model) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': r'''
            mutation CreateItineraryItem($input: ItineraryItemInput!) {
              createItineraryItem(input: $input) {
                id
                tripId
                title
                description
                startTime
                endTime
                location
                latitude
                longitude
                type
                order
                createdAt
                updatedAt
                version
              }
            }
          ''',
          'variables': {'input': model},
        },
      );

      if (response.data['errors'] != null) {
        final error = response.data['errors'][0];
        throw ServerException(message: error['message'] ?? 'Unknown error');
      }

      final data = response.data['data']['createItineraryItem'];
      return ItineraryItem(
        id: data['id'],
        tripId: data['tripId'],
        title: data['title'],
        description: data['description'],
        startTime: DateTime.parse(data['startTime']),
        endTime: DateTime.parse(data['endTime']),
        location: data['location'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        type: ItineraryItemType.values.firstWhere(
          (e) => e.name == data['type'],
          orElse: () => ItineraryItemType.other,
        ),
        order: data['order'],
        createdAt: DateTime.parse(data['createdAt']),
        updatedAt: DateTime.parse(data['updatedAt']),
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      debugPrint('❌ itineraryItem: Remote create failed: ${e.toString()}');
      throw ServerException(message: 'Failed to create itinerary item on server');
    }
  }

  @override
  Future<ItineraryItem> executeRemoteUpdate(String id, Map<String, dynamic> model) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': r'''
            mutation UpdateItineraryItem($id: ID!, $input: ItineraryItemInput!) {
              updateItineraryItem(id: $id, input: $input) {
                id
                tripId
                title
                description
                startTime
                endTime
                location
                latitude
                longitude
                type
                order
                createdAt
                updatedAt
                version
              }
            }
          ''',
          'variables': {'id': id, 'input': model},
        },
      );

      if (response.data['errors'] != null) {
        final error = response.data['errors'][0];
        throw ServerException(message: error['message'] ?? 'Unknown error');
      }

      final data = response.data['data']['updateItineraryItem'];
      return ItineraryItem(
        id: data['id'],
        tripId: data['tripId'],
        title: data['title'],
        description: data['description'],
        startTime: DateTime.parse(data['startTime']),
        endTime: DateTime.parse(data['endTime']),
        location: data['location'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        type: ItineraryItemType.values.firstWhere(
          (e) => e.name == data['type'],
          orElse: () => ItineraryItemType.other,
        ),
        order: data['order'],
        createdAt: DateTime.parse(data['createdAt']),
        updatedAt: DateTime.parse(data['updatedAt']),
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      debugPrint('❌ itineraryItem: Remote update failed: ${e.toString()}');
      throw ServerException(message: 'Failed to update itinerary item on server');
    }
  }

  @override
  Future<void> executeRemoteDelete(String id) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': r'''
            mutation DeleteItineraryItem($id: ID!) {
              deleteItineraryItem(id: $id) {
                id
                success
              }
            }
          ''',
          'variables': {'id': id},
        },
      );

      if (response.data['errors'] != null) {
        final error = response.data['errors'][0];
        throw ServerException(message: error['message'] ?? 'Unknown error');
      }

      if (!response.data['data']['deleteItineraryItem']['success']) {
        throw ServerException(message: 'Delete operation failed');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      debugPrint('❌ itineraryItem: Remote delete failed: ${e.toString()}');
      throw ServerException(message: 'Failed to delete itinerary item on server');
    }
  }

  @override
  Future<ItineraryItem> executeRemoteFetch(String id) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': r'''
            query GetItineraryItem($id: ID!) {
              itineraryItem(id: $id) {
                id
                tripId
                title
                description
                startTime
                endTime
                location
                latitude
                longitude
                type
                order
                createdAt
                updatedAt
                version
              }
            }
          ''',
          'variables': {'id': id},
        },
      );

      if (response.data['errors'] != null) {
        final error = response.data['errors'][0];
        throw ServerException(message: error['message'] ?? 'Unknown error');
      }

      final data = response.data['data']['itineraryItem'];
      return ItineraryItem(
        id: data['id'],
        tripId: data['tripId'],
        title: data['title'],
        description: data['description'],
        startTime: DateTime.parse(data['startTime']),
        endTime: DateTime.parse(data['endTime']),
        location: data['location'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        type: ItineraryItemType.values.firstWhere(
          (e) => e.name == data['type'],
          orElse: () => ItineraryItemType.other,
        ),
        order: data['order'],
        createdAt: DateTime.parse(data['createdAt']),
        updatedAt: DateTime.parse(data['updatedAt']),
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      debugPrint('❌ itineraryItem: Remote fetch failed: ${e.toString()}');
      throw ServerException(message: 'Failed to fetch itinerary item from server');
    }
  }

  @override
  Future<List<ItineraryItem>> executeRemoteFetchAll({String? userId}) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': r'''
            query GetItineraryItems($tripId: ID) {
              itineraryItems(tripId: $tripId) {
                id
                tripId
                title
                description
                startTime
                endTime
                location
                latitude
                longitude
                type
                order
                createdAt
                updatedAt
                version
              }
            }
          ''',
          'variables': {'tripId': userId},
        },
      );

      if (response.data['errors'] != null) {
        final error = response.data['errors'][0];
        throw ServerException(message: error['message'] ?? 'Unknown error');
      }

      final itemsData = response.data['data']['itineraryItems'] as List;
      return itemsData.map((data) {
        return ItineraryItem(
          id: data['id'],
          tripId: data['tripId'],
          title: data['title'],
          description: data['description'],
          startTime: DateTime.parse(data['startTime']),
          endTime: DateTime.parse(data['endTime']),
          location: data['location'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          type: ItineraryItemType.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => ItineraryItemType.other,
          ),
          order: data['order'],
          createdAt: DateTime.parse(data['createdAt']),
          updatedAt: DateTime.parse(data['updatedAt']),
        );
      }).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      debugPrint('❌ itineraryItem: Remote fetch all failed: ${e.toString()}');
      throw ServerException(message: 'Failed to fetch itinerary items from server');
    }
  }

  // ==============================================================================
  // CUSTOM METHODS FOR ITINERARY ITEMS
  // ==============================================================================

  /// Get all itinerary items for a specific trip
  Future<List<ItineraryItem>> getItemsByTripId(String tripId) async {
    final localModels = await readAllFromLocal(userId: tripId);
    return localModels.map(modelToEntity).toList();
  }

  /// Reorder items within a trip
  Future<void> reorderItems(String tripId, List<String> itemIdsInOrder) async {
    for (var i = 0; i < itemIdsInOrder.length; i++) {
      final itemId = itemIdsInOrder[i];
      final localModel = await readFromLocal(itemId);
      if (localModel != null) {
        final updatedModel = LocalItineraryItemModel(
          id: localModel.id,
          tripId: localModel.tripId,
          title: localModel.title,
          description: localModel.description,
          startTime: localModel.startTime,
          endTime: localModel.endTime,
          location: localModel.location,
          latitude: localModel.latitude,
          longitude: localModel.longitude,
          type: localModel.type,
          order: i,
          createdAt: localModel.createdAt,
          updatedAt: DateTime.now(),
          isSynced: localModel.isSynced,
          hasPendingChanges: true,
          version: localModel.version,
          isDeleted: localModel.isDeleted,
          lastSyncedAt: localModel.lastSyncedAt,
        );
        await writeToLocal(updatedModel);
      }
    }
  }
}
```

### Step 2: Register Dependencies

Add your DAO and repository to the offline module:

```dart
// lib/app/di/modules/offline_module.dart
class OfflineModule {
  static void registerDependencies(ServiceLocator sl) {
    // ... existing registrations ...

    // DAOs
    sl.registerFactory<ItineraryItemDao>(
      () => ItineraryItemDao(sl()),
    );

    // Repositories
    sl.registerFactory<ItineraryItemRepository>(
      () => ItineraryItemRepositoryImpl(
        dao: sl(),
        apiService: sl(),
        connectivityService: sl(),
        syncQueueService: sl(),
      ),
    );
  }
}
```

## Handling Conflicts

### Understanding Conflict Types

The offline-first architecture handles several types of conflicts:

1. **Concurrent Update**: Both client and server modified the same entity
2. **Delete-Modify**: Entity deleted on one side, modified on the other
3. **Duplicate Create**: Entity created offline but already exists on server
4. **Version Mismatch**: Client version doesn't match server version

### Default Resolution Strategy

By default, the system uses **Last Write Wins** based on the `updatedAt` timestamp:

```dart
ConflictResolutionStrategy.lastWriteWins
```

### Custom Conflict Resolution

For entities that need custom conflict resolution, extend the conflict resolver:

```dart
// lib/features/your_feature/domain/services/itinerary_conflict_resolver.dart
import 'package:soloadventurer/features/offline/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/your_feature/domain/entities/itinerary_item.dart';

class ItineraryConflictResolver extends ConflictResolver<ItineraryItem> {
  @override
  Future<ConflictResolutionResult> resolveConflict(
    Conflict conflict,
  ) async {
    switch (conflict.type) {
      case ConflictType.concurrentUpdate:
        return await _resolveConcurrentUpdate(conflict);

      case ConflictType.deleteModify:
        // For itinerary items, if deleted on server but modified locally,
        // prefer the local version (user is actively working on it)
        return ConflictResolutionResult(
          strategy: ConflictResolutionStrategy.clientWins,
          resolvedEntity: conflict.localEntity,
        );

      case ConflictType.duplicateCreate:
        // For duplicates, rename the local item
        final localItem = conflict.localEntity as ItineraryItem;
        final renamedItem = localItem.copyWith(
          title: '${localItem.title} (Copy)',
        );
        return ConflictResolutionResult(
          strategy: ConflictResolutionStrategy.manual,
          resolvedEntity: renamedItem,
        );

      default:
        return super.resolveConflict(conflict);
    }
  }

  Future<ConflictResolutionResult> _resolveConcurrentUpdate(
    Conflict conflict,
  ) async {
    final local = conflict.localEntity as ItineraryItem;
    final server = conflict.serverEntity as ItineraryItem;

    // Special logic: If both modified the order field,
    // merge them by using the most recent modification
    if (local.updatedAt.isAfter(server.updatedAt)) {
      return ConflictResolutionResult(
        strategy: ConflictResolutionStrategy.lastWriteWins,
        resolvedEntity: local,
      );
    } else {
      return ConflictResolutionResult(
        strategy: ConflictResolutionStrategy.lastWriteWins,
        resolvedEntity: server,
      );
    }
  }
}
```

Register your custom resolver:

```dart
// lib/app/di/modules/offline_module.dart
sl.registerFactory<ItineraryConflictResolver>(
  () => ItineraryConflictResolver(),
);
```

## Adding Local Database Support

### Migration Strategy

When adding new entities to the database, you need to create migrations:

```dart
// lib/features/offline/infrastructure/database/app_database.dart
@DriftDatabase(tables: [Trips, Journals, Users, SyncQueue, ItineraryItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2; // Increment version

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 && to >= 2) {
          // Add itinerary_items table
          await m.createTable(itineraryItems);
        }
      },
    );
  }
}
```

Run migrations after updating the database:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing Offline Features

### Unit Tests

Test your repository's offline behavior:

```dart
// test/features/your_feature/infrastructure/repositories/itinerary_item_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/itinerary_item_dao.dart';
import 'package:soloadventurer/features/your_feature/infrastructure/repositories/itinerary_item_repository_impl.dart';

class MockItineraryItemDao extends Mock implements ItineraryItemDao {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockSyncQueueService extends Mock implements SyncQueueService {}

void main() {
  late ItineraryItemRepositoryImpl repository;
  late MockItineraryItemDao mockDao;
  late MockConnectivityService mockConnectivity;
  late MockSyncQueueService mockSyncQueue;

  setUp(() {
    mockDao = MockItineraryItemDao();
    mockConnectivity = MockConnectivityService();
    mockSyncQueue = MockSyncQueueService();

    repository = ItineraryItemRepositoryImpl(
      dao: mockDao,
      apiService: mockApiService,
      connectivityService: mockConnectivity,
      syncQueueService: mockSyncQueue,
    );
  });

  group('ItineraryItemRepository - Offline Mode', () {
    test('should read from local database when offline', () async {
      // Arrange
      final localItem = LocalItineraryItemModel(
        id: '1',
        tripId: 'trip1',
        title: 'Test Activity',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        location: 'Paris',
        type: ItineraryItemType.activity,
        order: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockDao.getItineraryItemById('1'))
          .thenAnswer((_) async => localItem.toCompanion());
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityStatus.offline());

      // Act
      final result = await repository.getById('1');

      // Assert
      expect(result.id, '1');
      verify(mockDao.getItineraryItemById('1'));
      verifyNever(mockApiService.dio.post(any, data: anyNamed('data')));
    });

    test('should queue operation when creating while offline', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityStatus.offline());
      when(mockDao.getItineraryItemById(any))
          .thenAnswer((_) async => null);
      when(mockDao.insertItineraryItem(any))
          .thenAnswer((_) async {});

      // Act
      final createInput = {
        'tripId': 'trip1',
        'title': 'New Activity',
        'startTime': DateTime.now().toIso8601String(),
        'endTime': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'location': 'Paris',
        'type': 'activity',
        'order': 0,
      };

      final result = await repository.create(createInput);

      // Assert
      expect(result.executedImmediately, false);
      expect(result.isQueuedForSync, true);
      verify(mockDao.insertItineraryItem(any));
      verify(mockSyncQueue.enqueueOperation(any));
    });
  });
}
```

### Integration Tests

Test full offline-to-online sync flow:

```dart
// integration_test/offline_first_itinerary_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full offline-to-online sync flow', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MyApp());

      // 1. Create itinerary item while offline
      await tester.pumpAndSettle();

      // 2. Verify item is saved locally
      // 3. Go online
      // 4. Verify sync happens automatically
      // 5. Verify item appears on server
    });
  });
}
```

## Best Practices

### 1. Always Use OfflineAwareRepository

For all entities that users create or modify:

```dart
// ✅ Good - Extends OfflineAwareRepository
class MyRepositoryImpl extends OfflineAwareRepository<...> {
  // Automatic offline handling
}

// ❌ Bad - Direct API calls without offline support
class MyRepositoryImpl {
  Future<MyEntity> create(...) async {
    return await apiService.post(...); // Fails when offline
  }
}
```

### 2. Handle Sync Status in UI

Show sync status to users:

```dart
class ItineraryItemWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    return ListTile(
      title: Text(item.title),
      trailing: item.hasPendingChanges
          ? Icon(Icons.cloud_off, color: Colors.orange)
          : Icon(Icons.cloud_done, color: Colors.green),
    );
  }
}
```

### 3. Use Optimistic UI Updates

Update UI immediately, even when offline:

```dart
Future<void> createItineraryItem() async {
  // Show loading state
  state = AsyncValue.loading();

  // Repository handles optimistic update
  final result = await ref.read(itineraryItemRepositoryProvider).create(input);

  // Update UI immediately with result
  state = AsyncValue.data(result.data);

  // Sync happens in background
}
```

### 4. Handle Edge Cases

```dart
try {
  final result = await repository.create(input);
  if (result.isQueuedForSync) {
    // Show offline indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved locally. Will sync when online.')),
    );
  }
} on CacheException catch (e) {
  // Data not available offline
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('This content requires internet connection.')),
  );
} catch (e) {
  // Other errors
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('An error occurred: ${e.toString()}')),
  );
}
```

### 5. Test Offline Scenarios

Always test your features in these scenarios:

- Create while offline → Go online → Verify sync
- Update while offline → Go online → Verify sync
- Delete while offline → Go online → Verify sync
- Modify same item on multiple devices → Verify conflict resolution

### 6. Use Appropriate Sync Priority

```dart
await _syncQueueService.enqueueOperation(
  SyncOperationEntity(
    priority: isCriticalOperation
        ? SyncPriority.high
        : SyncPriority.normal,
    // ...
  ),
);
```

### 7. Clean Up Old Data

Periodically clean up old sync records:

```dart
Future<void> cleanupOldSyncRecords() async {
  await syncQueueDao.deleteCompletedOperationsOlderThan(
    DateTime.now().subtract(const Duration(days: 7)),
  );
}
```

## Common Pitfalls

### 1. Forgetting to Run Build Runner

**Problem**: After creating DAOs or models, `.g.dart` files aren't generated.

**Solution**: Always run after creating database classes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Not Handling Temporary IDs

**Problem**: Entities created offline have temporary IDs that conflict with server IDs.

**Solution**: The base repository handles this, but ensure your remote update uses the server ID:

```dart
// After successful remote create
final remoteEntity = await executeRemoteCreate(model);
// Update local database with server-assigned ID
await writeToLocal(entityToModel(remoteEntity));
```

### 3. Blocking UI on Sync

**Problem**: Waiting for sync to complete before updating UI.

**Solution**: Use optimistic updates:

```dart
// ❌ Bad - Blocks UI
await repository.create(input);
await syncManager.sync();
updateUI();

// ✅ Good - Optimistic update
final result = await repository.create(input);
updateUI(result.data); // Updates immediately
// Sync happens in background
```

### 4. Not Showing Sync Status

**Problem**: Users don't know if their data is synced.

**Solution**: Always show sync indicators:

```dart
Widget buildSyncIcon(bool isSynced, bool hasPendingChanges) {
  if (hasPendingChanges) {
    return Icon(Icons.sync, color: Colors.orange);
  } else if (isSynced) {
    return Icon(Icons.cloud_done, color: Colors.green);
  } else {
    return Icon(Icons.cloud_off, color: Colors.red);
  }
}
```

### 5. Ignoring Conflict Resolution

**Problem**: Assuming conflicts never happen.

**Solution**: Always handle conflicts:

```dart
try {
  final result = await syncManager.startSync();
  if (result.conflictsResolved > 0) {
    showConflictsResolvedDialog(result.conflicts);
  }
} on ConflictException catch (e) {
  showManualConflictResolutionDialog(e.conflicts);
}
```

### 6. Forgetting Soft Deletes

**Problem**: Deleting records immediately makes sync impossible.

**Solution**: Use soft deletes:

```dart
@override
Future<void> deleteFromLocal(String id) async {
  // Soft delete - mark as deleted, keep for sync
  await _dao.softDeleteItineraryItem(id);
}
```

### 7. Not Handling Large Data Sets

**Problem**: Fetching all records at once causes performance issues.

**Solution**: Use pagination:

```dart
Future<List<ItineraryItem>> getItemsByTripId(
  String tripId, {
  int limit = 50,
  int offset = 0,
}) async {
  return await _dao.getItineraryItemsByTripId(
    tripId,
    limit: limit,
    offset: offset,
  );
}
```

## Migration Guide

### Converting Existing Features to Offline-First

If you have an existing feature that needs offline support:

1. **Create local models** with sync metadata
2. **Add database table** with migration
3. **Create DAO** for database operations
4. **Extend OfflineAwareRepository** instead of regular repository
5. **Update UI** to show sync status
6. **Add tests** for offline behavior

### Example Migration

Before:

```dart
// Regular repository
class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _remoteDataSource;

  @override
  Future<Trip> getTrip(String id) async {
    return await _remoteDataSource.getTrip(id);
  }
}
```

After:

```dart
// Offline-aware repository
class TripRepositoryImpl extends OfflineAwareRepository<
    Trip, LocalTripModel, Map<String, dynamic>, Map<String, dynamic>>
    implements TripRepository {
  final TripDao _dao;
  final TripRemoteDataSource _remoteDataSource;

  @override
  Future<Trip> getById(String id) async {
    // Automatically handles local-first read
    return super.getById(id);
  }

  @override
  Future<Trip> executeRemoteFetch(String id) async {
    return await _remoteDataSource.getTrip(id);
  }

  // ... other methods
}
```

## Conclusion

The offline-first architecture in SoloAdventurer provides a robust foundation for building features that work seamlessly offline and online. By following the patterns in this guide, you can:

- Create syncable entities with local database support
- Implement offline-aware repositories with minimal code
- Handle conflicts gracefully
- Provide a great user experience regardless of connectivity

For more details, refer to:
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Overall architecture
- [OFFLINE_FIRST_ARCHITECTURE.md](../OFFLINE_FIRST_ARCHITECTURE.md) - Detailed offline-first implementation
- [FEATURE_DEVELOPMENT.md](../FEATURE_DEVELOPMENT.md) - General feature development guide
- [TESTING_PATTERNS.md](../TESTING_PATTERNS.md) - Testing guidelines

Remember to always test your offline features thoroughly and provide clear feedback to users about sync status. Happy coding! 🚀
