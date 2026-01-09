// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, LocalTrip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _destinationMeta =
      const VerificationMeta('destination');
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
      'destination', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _budgetMeta = const VerificationMeta('budget');
  @override
  late final GeneratedColumn<int> budget = GeneratedColumn<int>(
      'budget', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _coverImageUrlMeta =
      const VerificationMeta('coverImageUrl');
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
      'cover_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _travelCompanionIdsMeta =
      const VerificationMeta('travelCompanionIds');
  @override
  late final GeneratedColumn<String> travelCompanionIds =
      GeneratedColumn<String>('travel_companion_ids', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hasPendingChangesMeta =
      const VerificationMeta('hasPendingChanges');
  @override
  late final GeneratedColumn<bool> hasPendingChanges = GeneratedColumn<bool>(
      'has_pending_changes', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_pending_changes" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        title,
        description,
        startDate,
        endDate,
        destination,
        latitude,
        longitude,
        status,
        budget,
        coverImageUrl,
        travelCompanionIds,
        createdAt,
        updatedAt,
        isSynced,
        hasPendingChanges,
        version,
        isDeleted,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(Insertable<LocalTrip> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
          _destinationMeta,
          destination.isAcceptableOrUnknown(
              data['destination']!, _destinationMeta));
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('budget')) {
      context.handle(_budgetMeta,
          budget.isAcceptableOrUnknown(data['budget']!, _budgetMeta));
    } else if (isInserting) {
      context.missing(_budgetMeta);
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
          _coverImageUrlMeta,
          coverImageUrl.isAcceptableOrUnknown(
              data['cover_image_url']!, _coverImageUrlMeta));
    }
    if (data.containsKey('travel_companion_ids')) {
      context.handle(
          _travelCompanionIdsMeta,
          travelCompanionIds.isAcceptableOrUnknown(
              data['travel_companion_ids']!, _travelCompanionIdsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('has_pending_changes')) {
      context.handle(
          _hasPendingChangesMeta,
          hasPendingChanges.isAcceptableOrUnknown(
              data['has_pending_changes']!, _hasPendingChangesMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTrip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTrip(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      destination: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destination'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      budget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}budget'])!,
      coverImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_image_url']),
      travelCompanionIds: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}travel_companion_ids']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      hasPendingChanges: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}has_pending_changes'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class LocalTrip extends DataClass implements Insertable<LocalTrip> {
  /// Primary key - matches server-generated trip ID
  final String id;

  /// User ID who owns this trip
  final String userId;

  /// Trip title
  final String title;

  /// Optional trip description
  final String? description;

  /// Trip start date
  final DateTime startDate;

  /// Trip end date
  final DateTime endDate;

  /// Destination name/location
  final String destination;

  /// Optional latitude coordinate
  final double? latitude;

  /// Optional longitude coordinate
  final double? longitude;

  /// Trip status (e.g., 'planning', 'ongoing', 'completed', 'cancelled')
  final String status;

  /// Budget amount
  final int budget;

  /// Optional cover image URL
  final String? coverImageUrl;

  /// List of travel companion IDs (stored as JSON array)
  final String? travelCompanionIds;

  /// Timestamp when trip was created on server
  final DateTime createdAt;

  /// Timestamp when trip was last updated on server
  final DateTime updatedAt;

  /// Whether this record has been synced with the server
  /// - false: Locally created/modified, pending sync
  /// - true: Successfully synced with server
  final bool isSynced;

  /// Whether this record has local modifications pending sync
  final bool hasPendingChanges;

  /// Version number for conflict resolution
  /// Incremented on each update from server
  final int version;

  /// Soft delete flag - true if deleted locally pending sync
  final bool isDeleted;

  /// Last successful sync timestamp
  final DateTime? lastSyncedAt;
  const LocalTrip(
      {required this.id,
      required this.userId,
      required this.title,
      this.description,
      required this.startDate,
      required this.endDate,
      required this.destination,
      this.latitude,
      this.longitude,
      required this.status,
      required this.budget,
      this.coverImageUrl,
      this.travelCompanionIds,
      required this.createdAt,
      required this.updatedAt,
      required this.isSynced,
      required this.hasPendingChanges,
      required this.version,
      required this.isDeleted,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['destination'] = Variable<String>(destination);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['status'] = Variable<String>(status);
    map['budget'] = Variable<int>(budget);
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    if (!nullToAbsent || travelCompanionIds != null) {
      map['travel_companion_ids'] = Variable<String>(travelCompanionIds);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['has_pending_changes'] = Variable<bool>(hasPendingChanges);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startDate: Value(startDate),
      endDate: Value(endDate),
      destination: Value(destination),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      status: Value(status),
      budget: Value(budget),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      travelCompanionIds: travelCompanionIds == null && nullToAbsent
          ? const Value.absent()
          : Value(travelCompanionIds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      hasPendingChanges: Value(hasPendingChanges),
      version: Value(version),
      isDeleted: Value(isDeleted),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalTrip.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTrip(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      destination: serializer.fromJson<String>(json['destination']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      status: serializer.fromJson<String>(json['status']),
      budget: serializer.fromJson<int>(json['budget']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      travelCompanionIds:
          serializer.fromJson<String?>(json['travelCompanionIds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      hasPendingChanges: serializer.fromJson<bool>(json['hasPendingChanges']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'destination': serializer.toJson<String>(destination),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'status': serializer.toJson<String>(status),
      'budget': serializer.toJson<int>(budget),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'travelCompanionIds': serializer.toJson<String?>(travelCompanionIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'hasPendingChanges': serializer.toJson<bool>(hasPendingChanges),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalTrip copyWith(
          {String? id,
          String? userId,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? startDate,
          DateTime? endDate,
          String? destination,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          String? status,
          int? budget,
          Value<String?> coverImageUrl = const Value.absent(),
          Value<String?> travelCompanionIds = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isSynced,
          bool? hasPendingChanges,
          int? version,
          bool? isDeleted,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalTrip(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        destination: destination ?? this.destination,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        status: status ?? this.status,
        budget: budget ?? this.budget,
        coverImageUrl:
            coverImageUrl.present ? coverImageUrl.value : this.coverImageUrl,
        travelCompanionIds: travelCompanionIds.present
            ? travelCompanionIds.value
            : this.travelCompanionIds,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalTrip copyWithCompanion(TripsCompanion data) {
    return LocalTrip(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      destination:
          data.destination.present ? data.destination.value : this.destination,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      status: data.status.present ? data.status.value : this.status,
      budget: data.budget.present ? data.budget.value : this.budget,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      travelCompanionIds: data.travelCompanionIds.present
          ? data.travelCompanionIds.value
          : this.travelCompanionIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      hasPendingChanges: data.hasPendingChanges.present
          ? data.hasPendingChanges.value
          : this.hasPendingChanges,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTrip(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('destination: $destination, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('status: $status, ')
          ..write('budget: $budget, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('travelCompanionIds: $travelCompanionIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('hasPendingChanges: $hasPendingChanges, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      title,
      description,
      startDate,
      endDate,
      destination,
      latitude,
      longitude,
      status,
      budget,
      coverImageUrl,
      travelCompanionIds,
      createdAt,
      updatedAt,
      isSynced,
      hasPendingChanges,
      version,
      isDeleted,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTrip &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.destination == this.destination &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.status == this.status &&
          other.budget == this.budget &&
          other.coverImageUrl == this.coverImageUrl &&
          other.travelCompanionIds == this.travelCompanionIds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.hasPendingChanges == this.hasPendingChanges &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class TripsCompanion extends UpdateCompanion<LocalTrip> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> destination;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String> status;
  final Value<int> budget;
  final Value<String?> coverImageUrl;
  final Value<String?> travelCompanionIds;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> hasPendingChanges;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.destination = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.status = const Value.absent(),
    this.budget = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.travelCompanionIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.hasPendingChanges = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String userId,
    required String title,
    this.description = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
    required String destination,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required String status,
    required int budget,
    this.coverImageUrl = const Value.absent(),
    this.travelCompanionIds = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.hasPendingChanges = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        title = Value(title),
        startDate = Value(startDate),
        endDate = Value(endDate),
        destination = Value(destination),
        status = Value(status),
        budget = Value(budget),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LocalTrip> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? destination,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? status,
    Expression<int>? budget,
    Expression<String>? coverImageUrl,
    Expression<String>? travelCompanionIds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? hasPendingChanges,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (destination != null) 'destination': destination,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (status != null) 'status': status,
      if (budget != null) 'budget': budget,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (travelCompanionIds != null)
        'travel_companion_ids': travelCompanionIds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (hasPendingChanges != null) 'has_pending_changes': hasPendingChanges,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<String>? destination,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String>? status,
      Value<int>? budget,
      Value<String?>? coverImageUrl,
      Value<String?>? travelCompanionIds,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isSynced,
      Value<bool>? hasPendingChanges,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return TripsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      travelCompanionIds: travelCompanionIds ?? this.travelCompanionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (budget.present) {
      map['budget'] = Variable<int>(budget.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (travelCompanionIds.present) {
      map['travel_companion_ids'] = Variable<String>(travelCompanionIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (hasPendingChanges.present) {
      map['has_pending_changes'] = Variable<bool>(hasPendingChanges.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('destination: $destination, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('status: $status, ')
          ..write('budget: $budget, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('travelCompanionIds: $travelCompanionIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('hasPendingChanges: $hasPendingChanges, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItinerariesTable extends Itineraries
    with TableInfo<$ItinerariesTable, LocalItinerary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItinerariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationPlaceIdMeta =
      const VerificationMeta('destinationPlaceId');
  @override
  late final GeneratedColumn<String> destinationPlaceId =
      GeneratedColumn<String>('destination_place_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationNameMeta =
      const VerificationMeta('destinationName');
  @override
  late final GeneratedColumn<String> destinationName = GeneratedColumn<String>(
      'destination_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationLatitudeMeta =
      const VerificationMeta('destinationLatitude');
  @override
  late final GeneratedColumn<double> destinationLatitude =
      GeneratedColumn<double>('destination_latitude', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _destinationLongitudeMeta =
      const VerificationMeta('destinationLongitude');
  @override
  late final GeneratedColumn<double> destinationLongitude =
      GeneratedColumn<double>('destination_longitude', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _destinationAirportCodeMeta =
      const VerificationMeta('destinationAirportCode');
  @override
  late final GeneratedColumn<String> destinationAirportCode =
      GeneratedColumn<String>('destination_airport_code', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _numberOfDaysMeta =
      const VerificationMeta('numberOfDays');
  @override
  late final GeneratedColumn<int> numberOfDays = GeneratedColumn<int>(
      'number_of_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isStarterMeta =
      const VerificationMeta('isStarter');
  @override
  late final GeneratedColumn<bool> isStarter = GeneratedColumn<bool>(
      'is_starter', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_starter" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _coverImageUrlMeta =
      const VerificationMeta('coverImageUrl');
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
      'cover_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _itemsCountMeta =
      const VerificationMeta('itemsCount');
  @override
  late final GeneratedColumn<int> itemsCount = GeneratedColumn<int>(
      'items_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _completedItemsCountMeta =
      const VerificationMeta('completedItemsCount');
  @override
  late final GeneratedColumn<int> completedItemsCount = GeneratedColumn<int>(
      'completed_items_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _completionPercentageMeta =
      const VerificationMeta('completionPercentage');
  @override
  late final GeneratedColumn<int> completionPercentage = GeneratedColumn<int>(
      'completion_percentage', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hasPendingChangesMeta =
      const VerificationMeta('hasPendingChanges');
  @override
  late final GeneratedColumn<bool> hasPendingChanges = GeneratedColumn<bool>(
      'has_pending_changes', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_pending_changes" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        destinationPlaceId,
        destinationName,
        destinationLatitude,
        destinationLongitude,
        destinationAirportCode,
        startDate,
        endDate,
        numberOfDays,
        isStarter,
        coverImageUrl,
        itemsCount,
        completedItemsCount,
        completionPercentage,
        createdAt,
        updatedAt,
        isSynced,
        hasPendingChanges,
        version,
        isDeleted,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'itineraries';
  @override
  VerificationContext validateIntegrity(Insertable<LocalItinerary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('destination_place_id')) {
      context.handle(
          _destinationPlaceIdMeta,
          destinationPlaceId.isAcceptableOrUnknown(
              data['destination_place_id']!, _destinationPlaceIdMeta));
    } else if (isInserting) {
      context.missing(_destinationPlaceIdMeta);
    }
    if (data.containsKey('destination_name')) {
      context.handle(
          _destinationNameMeta,
          destinationName.isAcceptableOrUnknown(
              data['destination_name']!, _destinationNameMeta));
    } else if (isInserting) {
      context.missing(_destinationNameMeta);
    }
    if (data.containsKey('destination_latitude')) {
      context.handle(
          _destinationLatitudeMeta,
          destinationLatitude.isAcceptableOrUnknown(
              data['destination_latitude']!, _destinationLatitudeMeta));
    } else if (isInserting) {
      context.missing(_destinationLatitudeMeta);
    }
    if (data.containsKey('destination_longitude')) {
      context.handle(
          _destinationLongitudeMeta,
          destinationLongitude.isAcceptableOrUnknown(
              data['destination_longitude']!, _destinationLongitudeMeta));
    } else if (isInserting) {
      context.missing(_destinationLongitudeMeta);
    }
    if (data.containsKey('destination_airport_code')) {
      context.handle(
          _destinationAirportCodeMeta,
          destinationAirportCode.isAcceptableOrUnknown(
              data['destination_airport_code']!, _destinationAirportCodeMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('number_of_days')) {
      context.handle(
          _numberOfDaysMeta,
          numberOfDays.isAcceptableOrUnknown(
              data['number_of_days']!, _numberOfDaysMeta));
    } else if (isInserting) {
      context.missing(_numberOfDaysMeta);
    }
    if (data.containsKey('is_starter')) {
      context.handle(_isStarterMeta,
          isStarter.isAcceptableOrUnknown(data['is_starter']!, _isStarterMeta));
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
          _coverImageUrlMeta,
          coverImageUrl.isAcceptableOrUnknown(
              data['cover_image_url']!, _coverImageUrlMeta));
    }
    if (data.containsKey('items_count')) {
      context.handle(
          _itemsCountMeta,
          itemsCount.isAcceptableOrUnknown(
              data['items_count']!, _itemsCountMeta));
    }
    if (data.containsKey('completed_items_count')) {
      context.handle(
          _completedItemsCountMeta,
          completedItemsCount.isAcceptableOrUnknown(
              data['completed_items_count']!, _completedItemsCountMeta));
    }
    if (data.containsKey('completion_percentage')) {
      context.handle(
          _completionPercentageMeta,
          completionPercentage.isAcceptableOrUnknown(
              data['completion_percentage']!, _completionPercentageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('has_pending_changes')) {
      context.handle(
          _hasPendingChangesMeta,
          hasPendingChanges.isAcceptableOrUnknown(
              data['has_pending_changes']!, _hasPendingChangesMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalItinerary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalItinerary(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      destinationPlaceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}destination_place_id'])!,
      destinationName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}destination_name'])!,
      destinationLatitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}destination_latitude'])!,
      destinationLongitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}destination_longitude'])!,
      destinationAirportCode: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}destination_airport_code']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      numberOfDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number_of_days'])!,
      isStarter: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_starter'])!,
      coverImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_image_url']),
      itemsCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}items_count'])!,
      completedItemsCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}completed_items_count'])!,
      completionPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}completion_percentage'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      hasPendingChanges: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}has_pending_changes'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ItinerariesTable createAlias(String alias) {
    return $ItinerariesTable(attachedDatabase, alias);
  }
}

class LocalItinerary extends DataClass implements Insertable<LocalItinerary> {
  /// Primary key - matches server-generated itinerary ID
  final String id;

  /// Optional user ID who owns this itinerary
  /// Null for itineraries created during onboarding before auth
  final String? userId;

  /// Itinerary name/title
  final String name;

  /// Destination place ID (from Google Places)
  final String destinationPlaceId;

  /// Destination name
  final String destinationName;

  /// Destination latitude
  final double destinationLatitude;

  /// Destination longitude
  final double destinationLongitude;

  /// Optional destination airport code
  final String? destinationAirportCode;

  /// Trip start date
  final DateTime startDate;

  /// Trip end date
  final DateTime endDate;

  /// Number of days in itinerary
  final int numberOfDays;

  /// Whether this is a starter itinerary (generated during onboarding)
  final bool isStarter;

  /// Optional cover image URL
  final String? coverImageUrl;

  /// Number of items in itinerary (cached for performance)
  final int itemsCount;

  /// Number of completed items (cached for performance)
  final int completedItemsCount;

  /// Completion percentage (0-100)
  final int completionPercentage;

  /// Timestamp when itinerary was created on server
  final DateTime createdAt;

  /// Timestamp when itinerary was last updated on server
  final DateTime? updatedAt;

  /// Whether this record has been synced with the server
  final bool isSynced;

  /// Whether this record has local modifications pending sync
  final bool hasPendingChanges;

  /// Version number for conflict resolution
  final int version;

  /// Soft delete flag - true if deleted locally pending sync
  final bool isDeleted;

  /// Last successful sync timestamp
  final DateTime? lastSyncedAt;
  const LocalItinerary(
      {required this.id,
      this.userId,
      required this.name,
      required this.destinationPlaceId,
      required this.destinationName,
      required this.destinationLatitude,
      required this.destinationLongitude,
      this.destinationAirportCode,
      required this.startDate,
      required this.endDate,
      required this.numberOfDays,
      required this.isStarter,
      this.coverImageUrl,
      required this.itemsCount,
      required this.completedItemsCount,
      required this.completionPercentage,
      required this.createdAt,
      this.updatedAt,
      required this.isSynced,
      required this.hasPendingChanges,
      required this.version,
      required this.isDeleted,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['name'] = Variable<String>(name);
    map['destination_place_id'] = Variable<String>(destinationPlaceId);
    map['destination_name'] = Variable<String>(destinationName);
    map['destination_latitude'] = Variable<double>(destinationLatitude);
    map['destination_longitude'] = Variable<double>(destinationLongitude);
    if (!nullToAbsent || destinationAirportCode != null) {
      map['destination_airport_code'] =
          Variable<String>(destinationAirportCode);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['number_of_days'] = Variable<int>(numberOfDays);
    map['is_starter'] = Variable<bool>(isStarter);
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    map['items_count'] = Variable<int>(itemsCount);
    map['completed_items_count'] = Variable<int>(completedItemsCount);
    map['completion_percentage'] = Variable<int>(completionPercentage);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['has_pending_changes'] = Variable<bool>(hasPendingChanges);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ItinerariesCompanion toCompanion(bool nullToAbsent) {
    return ItinerariesCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      name: Value(name),
      destinationPlaceId: Value(destinationPlaceId),
      destinationName: Value(destinationName),
      destinationLatitude: Value(destinationLatitude),
      destinationLongitude: Value(destinationLongitude),
      destinationAirportCode: destinationAirportCode == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAirportCode),
      startDate: Value(startDate),
      endDate: Value(endDate),
      numberOfDays: Value(numberOfDays),
      isStarter: Value(isStarter),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      itemsCount: Value(itemsCount),
      completedItemsCount: Value(completedItemsCount),
      completionPercentage: Value(completionPercentage),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSynced: Value(isSynced),
      hasPendingChanges: Value(hasPendingChanges),
      version: Value(version),
      isDeleted: Value(isDeleted),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalItinerary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalItinerary(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      destinationPlaceId:
          serializer.fromJson<String>(json['destinationPlaceId']),
      destinationName: serializer.fromJson<String>(json['destinationName']),
      destinationLatitude:
          serializer.fromJson<double>(json['destinationLatitude']),
      destinationLongitude:
          serializer.fromJson<double>(json['destinationLongitude']),
      destinationAirportCode:
          serializer.fromJson<String?>(json['destinationAirportCode']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      numberOfDays: serializer.fromJson<int>(json['numberOfDays']),
      isStarter: serializer.fromJson<bool>(json['isStarter']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      itemsCount: serializer.fromJson<int>(json['itemsCount']),
      completedItemsCount:
          serializer.fromJson<int>(json['completedItemsCount']),
      completionPercentage:
          serializer.fromJson<int>(json['completionPercentage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      hasPendingChanges: serializer.fromJson<bool>(json['hasPendingChanges']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'name': serializer.toJson<String>(name),
      'destinationPlaceId': serializer.toJson<String>(destinationPlaceId),
      'destinationName': serializer.toJson<String>(destinationName),
      'destinationLatitude': serializer.toJson<double>(destinationLatitude),
      'destinationLongitude': serializer.toJson<double>(destinationLongitude),
      'destinationAirportCode':
          serializer.toJson<String?>(destinationAirportCode),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'numberOfDays': serializer.toJson<int>(numberOfDays),
      'isStarter': serializer.toJson<bool>(isStarter),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'itemsCount': serializer.toJson<int>(itemsCount),
      'completedItemsCount': serializer.toJson<int>(completedItemsCount),
      'completionPercentage': serializer.toJson<int>(completionPercentage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'hasPendingChanges': serializer.toJson<bool>(hasPendingChanges),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalItinerary copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          String? name,
          String? destinationPlaceId,
          String? destinationName,
          double? destinationLatitude,
          double? destinationLongitude,
          Value<String?> destinationAirportCode = const Value.absent(),
          DateTime? startDate,
          DateTime? endDate,
          int? numberOfDays,
          bool? isStarter,
          Value<String?> coverImageUrl = const Value.absent(),
          int? itemsCount,
          int? completedItemsCount,
          int? completionPercentage,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSynced,
          bool? hasPendingChanges,
          int? version,
          bool? isDeleted,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalItinerary(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        name: name ?? this.name,
        destinationPlaceId: destinationPlaceId ?? this.destinationPlaceId,
        destinationName: destinationName ?? this.destinationName,
        destinationLatitude: destinationLatitude ?? this.destinationLatitude,
        destinationLongitude: destinationLongitude ?? this.destinationLongitude,
        destinationAirportCode: destinationAirportCode.present
            ? destinationAirportCode.value
            : this.destinationAirportCode,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        numberOfDays: numberOfDays ?? this.numberOfDays,
        isStarter: isStarter ?? this.isStarter,
        coverImageUrl:
            coverImageUrl.present ? coverImageUrl.value : this.coverImageUrl,
        itemsCount: itemsCount ?? this.itemsCount,
        completedItemsCount: completedItemsCount ?? this.completedItemsCount,
        completionPercentage: completionPercentage ?? this.completionPercentage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalItinerary copyWithCompanion(ItinerariesCompanion data) {
    return LocalItinerary(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      destinationPlaceId: data.destinationPlaceId.present
          ? data.destinationPlaceId.value
          : this.destinationPlaceId,
      destinationName: data.destinationName.present
          ? data.destinationName.value
          : this.destinationName,
      destinationLatitude: data.destinationLatitude.present
          ? data.destinationLatitude.value
          : this.destinationLatitude,
      destinationLongitude: data.destinationLongitude.present
          ? data.destinationLongitude.value
          : this.destinationLongitude,
      destinationAirportCode: data.destinationAirportCode.present
          ? data.destinationAirportCode.value
          : this.destinationAirportCode,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      numberOfDays: data.numberOfDays.present
          ? data.numberOfDays.value
          : this.numberOfDays,
      isStarter: data.isStarter.present ? data.isStarter.value : this.isStarter,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      itemsCount:
          data.itemsCount.present ? data.itemsCount.value : this.itemsCount,
      completedItemsCount: data.completedItemsCount.present
          ? data.completedItemsCount.value
          : this.completedItemsCount,
      completionPercentage: data.completionPercentage.present
          ? data.completionPercentage.value
          : this.completionPercentage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      hasPendingChanges: data.hasPendingChanges.present
          ? data.hasPendingChanges.value
          : this.hasPendingChanges,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalItinerary(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('destinationPlaceId: $destinationPlaceId, ')
          ..write('destinationName: $destinationName, ')
          ..write('destinationLatitude: $destinationLatitude, ')
          ..write('destinationLongitude: $destinationLongitude, ')
          ..write('destinationAirportCode: $destinationAirportCode, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('numberOfDays: $numberOfDays, ')
          ..write('isStarter: $isStarter, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('itemsCount: $itemsCount, ')
          ..write('completedItemsCount: $completedItemsCount, ')
          ..write('completionPercentage: $completionPercentage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('hasPendingChanges: $hasPendingChanges, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        userId,
        name,
        destinationPlaceId,
        destinationName,
        destinationLatitude,
        destinationLongitude,
        destinationAirportCode,
        startDate,
        endDate,
        numberOfDays,
        isStarter,
        coverImageUrl,
        itemsCount,
        completedItemsCount,
        completionPercentage,
        createdAt,
        updatedAt,
        isSynced,
        hasPendingChanges,
        version,
        isDeleted,
        lastSyncedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalItinerary &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.destinationPlaceId == this.destinationPlaceId &&
          other.destinationName == this.destinationName &&
          other.destinationLatitude == this.destinationLatitude &&
          other.destinationLongitude == this.destinationLongitude &&
          other.destinationAirportCode == this.destinationAirportCode &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.numberOfDays == this.numberOfDays &&
          other.isStarter == this.isStarter &&
          other.coverImageUrl == this.coverImageUrl &&
          other.itemsCount == this.itemsCount &&
          other.completedItemsCount == this.completedItemsCount &&
          other.completionPercentage == this.completionPercentage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.hasPendingChanges == this.hasPendingChanges &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ItinerariesCompanion extends UpdateCompanion<LocalItinerary> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> name;
  final Value<String> destinationPlaceId;
  final Value<String> destinationName;
  final Value<double> destinationLatitude;
  final Value<double> destinationLongitude;
  final Value<String?> destinationAirportCode;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<int> numberOfDays;
  final Value<bool> isStarter;
  final Value<String?> coverImageUrl;
  final Value<int> itemsCount;
  final Value<int> completedItemsCount;
  final Value<int> completionPercentage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> hasPendingChanges;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ItinerariesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.destinationPlaceId = const Value.absent(),
    this.destinationName = const Value.absent(),
    this.destinationLatitude = const Value.absent(),
    this.destinationLongitude = const Value.absent(),
    this.destinationAirportCode = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.numberOfDays = const Value.absent(),
    this.isStarter = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.itemsCount = const Value.absent(),
    this.completedItemsCount = const Value.absent(),
    this.completionPercentage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.hasPendingChanges = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItinerariesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String name,
    required String destinationPlaceId,
    required String destinationName,
    required double destinationLatitude,
    required double destinationLongitude,
    this.destinationAirportCode = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
    required int numberOfDays,
    this.isStarter = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.itemsCount = const Value.absent(),
    this.completedItemsCount = const Value.absent(),
    this.completionPercentage = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.hasPendingChanges = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        destinationPlaceId = Value(destinationPlaceId),
        destinationName = Value(destinationName),
        destinationLatitude = Value(destinationLatitude),
        destinationLongitude = Value(destinationLongitude),
        startDate = Value(startDate),
        endDate = Value(endDate),
        numberOfDays = Value(numberOfDays),
        createdAt = Value(createdAt);
  static Insertable<LocalItinerary> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? destinationPlaceId,
    Expression<String>? destinationName,
    Expression<double>? destinationLatitude,
    Expression<double>? destinationLongitude,
    Expression<String>? destinationAirportCode,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? numberOfDays,
    Expression<bool>? isStarter,
    Expression<String>? coverImageUrl,
    Expression<int>? itemsCount,
    Expression<int>? completedItemsCount,
    Expression<int>? completionPercentage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? hasPendingChanges,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (destinationPlaceId != null)
        'destination_place_id': destinationPlaceId,
      if (destinationName != null) 'destination_name': destinationName,
      if (destinationLatitude != null)
        'destination_latitude': destinationLatitude,
      if (destinationLongitude != null)
        'destination_longitude': destinationLongitude,
      if (destinationAirportCode != null)
        'destination_airport_code': destinationAirportCode,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (numberOfDays != null) 'number_of_days': numberOfDays,
      if (isStarter != null) 'is_starter': isStarter,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (itemsCount != null) 'items_count': itemsCount,
      if (completedItemsCount != null)
        'completed_items_count': completedItemsCount,
      if (completionPercentage != null)
        'completion_percentage': completionPercentage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (hasPendingChanges != null) 'has_pending_changes': hasPendingChanges,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItinerariesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<String>? name,
      Value<String>? destinationPlaceId,
      Value<String>? destinationName,
      Value<double>? destinationLatitude,
      Value<double>? destinationLongitude,
      Value<String?>? destinationAirportCode,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<int>? numberOfDays,
      Value<bool>? isStarter,
      Value<String?>? coverImageUrl,
      Value<int>? itemsCount,
      Value<int>? completedItemsCount,
      Value<int>? completionPercentage,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSynced,
      Value<bool>? hasPendingChanges,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ItinerariesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      destinationPlaceId: destinationPlaceId ?? this.destinationPlaceId,
      destinationName: destinationName ?? this.destinationName,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      destinationAirportCode:
          destinationAirportCode ?? this.destinationAirportCode,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      isStarter: isStarter ?? this.isStarter,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      itemsCount: itemsCount ?? this.itemsCount,
      completedItemsCount: completedItemsCount ?? this.completedItemsCount,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (destinationPlaceId.present) {
      map['destination_place_id'] = Variable<String>(destinationPlaceId.value);
    }
    if (destinationName.present) {
      map['destination_name'] = Variable<String>(destinationName.value);
    }
    if (destinationLatitude.present) {
      map['destination_latitude'] = Variable<double>(destinationLatitude.value);
    }
    if (destinationLongitude.present) {
      map['destination_longitude'] =
          Variable<double>(destinationLongitude.value);
    }
    if (destinationAirportCode.present) {
      map['destination_airport_code'] =
          Variable<String>(destinationAirportCode.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (numberOfDays.present) {
      map['number_of_days'] = Variable<int>(numberOfDays.value);
    }
    if (isStarter.present) {
      map['is_starter'] = Variable<bool>(isStarter.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (itemsCount.present) {
      map['items_count'] = Variable<int>(itemsCount.value);
    }
    if (completedItemsCount.present) {
      map['completed_items_count'] = Variable<int>(completedItemsCount.value);
    }
    if (completionPercentage.present) {
      map['completion_percentage'] = Variable<int>(completionPercentage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (hasPendingChanges.present) {
      map['has_pending_changes'] = Variable<bool>(hasPendingChanges.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItinerariesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('destinationPlaceId: $destinationPlaceId, ')
          ..write('destinationName: $destinationName, ')
          ..write('destinationLatitude: $destinationLatitude, ')
          ..write('destinationLongitude: $destinationLongitude, ')
          ..write('destinationAirportCode: $destinationAirportCode, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('numberOfDays: $numberOfDays, ')
          ..write('isStarter: $isStarter, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('itemsCount: $itemsCount, ')
          ..write('completedItemsCount: $completedItemsCount, ')
          ..write('completionPercentage: $completionPercentage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('hasPendingChanges: $hasPendingChanges, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItineraryItemsTable extends ItineraryItems
    with TableInfo<$ItineraryItemsTable, LocalItineraryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItineraryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itineraryIdMeta =
      const VerificationMeta('itineraryId');
  @override
  late final GeneratedColumn<String> itineraryId = GeneratedColumn<String>(
      'itinerary_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dayNumberMeta =
      const VerificationMeta('dayNumber');
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
      'day_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hasPendingChangesMeta =
      const VerificationMeta('hasPendingChanges');
  @override
  late final GeneratedColumn<bool> hasPendingChanges = GeneratedColumn<bool>(
      'has_pending_changes', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_pending_changes" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itineraryId,
        type,
        time,
        isCompleted,
        name,
        note,
        location,
        latitude,
        longitude,
        dayNumber,
        sortOrder,
        createdAt,
        updatedAt,
        isSynced,
        hasPendingChanges,
        version,
        isDeleted,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'itinerary_items';
  @override
  VerificationContext validateIntegrity(Insertable<LocalItineraryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('itinerary_id')) {
      context.handle(
          _itineraryIdMeta,
          itineraryId.isAcceptableOrUnknown(
              data['itinerary_id']!, _itineraryIdMeta));
    } else if (isInserting) {
      context.missing(_itineraryIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('day_number')) {
      context.handle(_dayNumberMeta,
          dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta));
    } else if (isInserting) {
      context.missing(_dayNumberMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('has_pending_changes')) {
      context.handle(
          _hasPendingChangesMeta,
          hasPendingChanges.isAcceptableOrUnknown(
              data['has_pending_changes']!, _hasPendingChangesMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalItineraryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalItineraryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itineraryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}itinerary_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      dayNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_number'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      hasPendingChanges: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}has_pending_changes'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ItineraryItemsTable createAlias(String alias) {
    return $ItineraryItemsTable(attachedDatabase, alias);
  }
}

class LocalItineraryItem extends DataClass
    implements Insertable<LocalItineraryItem> {
  /// Primary key - matches server-generated item ID
  final String id;

  /// Foreign key to parent itinerary
  final String itineraryId;

  /// Item type: flight_arrival, flight_departure, hotel_check_in,
  /// hotel_check_out, activity, lunch, dinner
  final String type;

  /// Item start/time
  final DateTime time;

  /// Whether this item is completed
  final bool isCompleted;

  /// Item name/title (for activities, meals, etc.)
  final String? name;

  /// Optional notes/details about the item
  final String? note;

  /// Optional location name
  final String? location;

  /// Optional location latitude
  final double? latitude;

  /// Optional location longitude
  final double? longitude;

  /// Day number in the itinerary (1-based)
  final int dayNumber;

  /// Sort order within the day
  final int sortOrder;

  /// Timestamp when item was created
  final DateTime createdAt;

  /// Timestamp when item was last updated
  final DateTime? updatedAt;

  /// Whether this record has been synced with the server
  final bool isSynced;

  /// Whether this record has local modifications pending sync
  final bool hasPendingChanges;

  /// Version number for conflict resolution
  final int version;

  /// Soft delete flag - true if deleted locally pending sync
  final bool isDeleted;

  /// Last successful sync timestamp
  final DateTime? lastSyncedAt;
  const LocalItineraryItem(
      {required this.id,
      required this.itineraryId,
      required this.type,
      required this.time,
      required this.isCompleted,
      this.name,
      this.note,
      this.location,
      this.latitude,
      this.longitude,
      required this.dayNumber,
      required this.sortOrder,
      required this.createdAt,
      this.updatedAt,
      required this.isSynced,
      required this.hasPendingChanges,
      required this.version,
      required this.isDeleted,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['itinerary_id'] = Variable<String>(itineraryId);
    map['type'] = Variable<String>(type);
    map['time'] = Variable<DateTime>(time);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['day_number'] = Variable<int>(dayNumber);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['has_pending_changes'] = Variable<bool>(hasPendingChanges);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ItineraryItemsCompanion toCompanion(bool nullToAbsent) {
    return ItineraryItemsCompanion(
      id: Value(id),
      itineraryId: Value(itineraryId),
      type: Value(type),
      time: Value(time),
      isCompleted: Value(isCompleted),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      dayNumber: Value(dayNumber),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSynced: Value(isSynced),
      hasPendingChanges: Value(hasPendingChanges),
      version: Value(version),
      isDeleted: Value(isDeleted),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalItineraryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalItineraryItem(
      id: serializer.fromJson<String>(json['id']),
      itineraryId: serializer.fromJson<String>(json['itineraryId']),
      type: serializer.fromJson<String>(json['type']),
      time: serializer.fromJson<DateTime>(json['time']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      name: serializer.fromJson<String?>(json['name']),
      note: serializer.fromJson<String?>(json['note']),
      location: serializer.fromJson<String?>(json['location']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      dayNumber: serializer.fromJson<int>(json['dayNumber']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      hasPendingChanges: serializer.fromJson<bool>(json['hasPendingChanges']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itineraryId': serializer.toJson<String>(itineraryId),
      'type': serializer.toJson<String>(type),
      'time': serializer.toJson<DateTime>(time),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'name': serializer.toJson<String?>(name),
      'note': serializer.toJson<String?>(note),
      'location': serializer.toJson<String?>(location),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'dayNumber': serializer.toJson<int>(dayNumber),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'hasPendingChanges': serializer.toJson<bool>(hasPendingChanges),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalItineraryItem copyWith(
          {String? id,
          String? itineraryId,
          String? type,
          DateTime? time,
          bool? isCompleted,
          Value<String?> name = const Value.absent(),
          Value<String?> note = const Value.absent(),
          Value<String?> location = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          int? dayNumber,
          int? sortOrder,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSynced,
          bool? hasPendingChanges,
          int? version,
          bool? isDeleted,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalItineraryItem(
        id: id ?? this.id,
        itineraryId: itineraryId ?? this.itineraryId,
        type: type ?? this.type,
        time: time ?? this.time,
        isCompleted: isCompleted ?? this.isCompleted,
        name: name.present ? name.value : this.name,
        note: note.present ? note.value : this.note,
        location: location.present ? location.value : this.location,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        dayNumber: dayNumber ?? this.dayNumber,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalItineraryItem copyWithCompanion(ItineraryItemsCompanion data) {
    return LocalItineraryItem(
      id: data.id.present ? data.id.value : this.id,
      itineraryId:
          data.itineraryId.present ? data.itineraryId.value : this.itineraryId,
      type: data.type.present ? data.type.value : this.type,
      time: data.time.present ? data.time.value : this.time,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
      location: data.location.present ? data.location.value : this.location,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      hasPendingChanges: data.hasPendingChanges.present
          ? data.hasPendingChanges.value
          : this.hasPendingChanges,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalItineraryItem(')
          ..write('id: $id, ')
          ..write('itineraryId: $itineraryId, ')
          ..write('type: $type, ')
          ..write('time: $time, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('location: $location, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('hasPendingChanges: $hasPendingChanges, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      itineraryId,
      type,
      time,
      isCompleted,
      name,
      note,
      location,
      latitude,
      longitude,
      dayNumber,
      sortOrder,
      createdAt,
      updatedAt,
      isSynced,
      hasPendingChanges,
      version,
      isDeleted,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalItineraryItem &&
          other.id == this.id &&
          other.itineraryId == this.itineraryId &&
          other.type == this.type &&
          other.time == this.time &&
          other.isCompleted == this.isCompleted &&
          other.name == this.name &&
          other.note == this.note &&
          other.location == this.location &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.dayNumber == this.dayNumber &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.hasPendingChanges == this.hasPendingChanges &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ItineraryItemsCompanion extends UpdateCompanion<LocalItineraryItem> {
  final Value<String> id;
  final Value<String> itineraryId;
  final Value<String> type;
  final Value<DateTime> time;
  final Value<bool> isCompleted;
  final Value<String?> name;
  final Value<String?> note;
  final Value<String?> location;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> dayNumber;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> hasPendingChanges;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ItineraryItemsCompanion({
    this.id = const Value.absent(),
    this.itineraryId = const Value.absent(),
    this.type = const Value.absent(),
    this.time = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.location = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.hasPendingChanges = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItineraryItemsCompanion.insert({
    required String id,
    required String itineraryId,
    required String type,
    required DateTime time,
    this.isCompleted = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.location = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required int dayNumber,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.hasPendingChanges = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itineraryId = Value(itineraryId),
        type = Value(type),
        time = Value(time),
        dayNumber = Value(dayNumber),
        createdAt = Value(createdAt);
  static Insertable<LocalItineraryItem> custom({
    Expression<String>? id,
    Expression<String>? itineraryId,
    Expression<String>? type,
    Expression<DateTime>? time,
    Expression<bool>? isCompleted,
    Expression<String>? name,
    Expression<String>? note,
    Expression<String>? location,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? dayNumber,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? hasPendingChanges,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itineraryId != null) 'itinerary_id': itineraryId,
      if (type != null) 'type': type,
      if (time != null) 'time': time,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (location != null) 'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (dayNumber != null) 'day_number': dayNumber,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (hasPendingChanges != null) 'has_pending_changes': hasPendingChanges,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItineraryItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? itineraryId,
      Value<String>? type,
      Value<DateTime>? time,
      Value<bool>? isCompleted,
      Value<String?>? name,
      Value<String?>? note,
      Value<String?>? location,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<int>? dayNumber,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSynced,
      Value<bool>? hasPendingChanges,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ItineraryItemsCompanion(
      id: id ?? this.id,
      itineraryId: itineraryId ?? this.itineraryId,
      type: type ?? this.type,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      name: name ?? this.name,
      note: note ?? this.note,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dayNumber: dayNumber ?? this.dayNumber,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itineraryId.present) {
      map['itinerary_id'] = Variable<String>(itineraryId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (hasPendingChanges.present) {
      map['has_pending_changes'] = Variable<bool>(hasPendingChanges.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItineraryItemsCompanion(')
          ..write('id: $id, ')
          ..write('itineraryId: $itineraryId, ')
          ..write('type: $type, ')
          ..write('time: $time, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('location: $location, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('hasPendingChanges: $hasPendingChanges, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalsTable extends Journals
    with TableInfo<$JournalsTable, LocalJournal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
      'trip_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryDateMeta =
      const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
      'entry_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
      'mood', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlsMeta =
      const VerificationMeta('imageUrls');
  @override
  late final GeneratedColumn<String> imageUrls = GeneratedColumn<String>(
      'image_urls', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hasPendingChangesMeta =
      const VerificationMeta('hasPendingChanges');
  @override
  late final GeneratedColumn<bool> hasPendingChanges = GeneratedColumn<bool>(
      'has_pending_changes', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_pending_changes" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tripId,
        userId,
        title,
        content,
        entryDate,
        mood,
        location,
        imageUrls,
        tags,
        createdAt,
        updatedAt,
        isSynced,
        hasPendingChanges,
        version,
        isDeleted,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journals';
  @override
  VerificationContext validateIntegrity(Insertable<LocalJournal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta,
          entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    }
    if (data.containsKey('mood')) {
      context.handle(
          _moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('image_urls')) {
      context.handle(_imageUrlsMeta,
          imageUrls.isAcceptableOrUnknown(data['image_urls']!, _imageUrlsMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('has_pending_changes')) {
      context.handle(
          _hasPendingChangesMeta,
          hasPendingChanges.isAcceptableOrUnknown(
              data['has_pending_changes']!, _hasPendingChangesMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalJournal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalJournal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      entryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}entry_date']),
      mood: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      imageUrls: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_urls']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      hasPendingChanges: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}has_pending_changes'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $JournalsTable createAlias(String alias) {
    return $JournalsTable(attachedDatabase, alias);
  }
}

class LocalJournal extends DataClass implements Insertable<LocalJournal> {
  /// Primary key - matches server-generated journal ID
  final String id;

  /// Foreign key to associated trip
  final String tripId;

  /// User ID who created this journal
  final String userId;

  /// Journal entry title
  final String title;

  /// Journal content/body text
  final String content;

  /// Optional journal entry date (defaults to createdAt)
  final DateTime? entryDate;

  /// Optional mood/feeling tag
  final String? mood;

  /// Optional location name where journal was written
  final String? location;

  /// List of attached image URLs (stored as JSON array)
  final String? imageUrls;

  /// Optional list of tags
  final String? tags;

  /// Timestamp when journal was created on server
  final DateTime createdAt;

  /// Timestamp when journal was last updated on server
  final DateTime updatedAt;

  /// Whether this record has been synced with the server
  final bool isSynced;

  /// Whether this record has local modifications pending sync
  final bool hasPendingChanges;

  /// Version number for conflict resolution
  final int version;

  /// Soft delete flag - true if deleted locally pending sync
  final bool isDeleted;

  /// Last successful sync timestamp
  final DateTime? lastSyncedAt;
  const LocalJournal(
      {required this.id,
      required this.tripId,
      required this.userId,
      required this.title,
      required this.content,
      this.entryDate,
      this.mood,
      this.location,
      this.imageUrls,
      this.tags,
      required this.createdAt,
      required this.updatedAt,
      required this.isSynced,
      required this.hasPendingChanges,
      required this.version,
      required this.isDeleted,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || entryDate != null) {
      map['entry_date'] = Variable<DateTime>(entryDate);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || imageUrls != null) {
      map['image_urls'] = Variable<String>(imageUrls);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['has_pending_changes'] = Variable<bool>(hasPendingChanges);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  JournalsCompanion toCompanion(bool nullToAbsent) {
    return JournalsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      userId: Value(userId),
      title: Value(title),
      content: Value(content),
      entryDate: entryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(entryDate),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      imageUrls: imageUrls == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrls),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      hasPendingChanges: Value(hasPendingChanges),
      version: Value(version),
      isDeleted: Value(isDeleted),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalJournal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalJournal(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      entryDate: serializer.fromJson<DateTime?>(json['entryDate']),
      mood: serializer.fromJson<String?>(json['mood']),
      location: serializer.fromJson<String?>(json['location']),
      imageUrls: serializer.fromJson<String?>(json['imageUrls']),
      tags: serializer.fromJson<String?>(json['tags']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      hasPendingChanges: serializer.fromJson<bool>(json['hasPendingChanges']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'entryDate': serializer.toJson<DateTime?>(entryDate),
      'mood': serializer.toJson<String?>(mood),
      'location': serializer.toJson<String?>(location),
      'imageUrls': serializer.toJson<String?>(imageUrls),
      'tags': serializer.toJson<String?>(tags),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'hasPendingChanges': serializer.toJson<bool>(hasPendingChanges),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalJournal copyWith(
          {String? id,
          String? tripId,
          String? userId,
          String? title,
          String? content,
          Value<DateTime?> entryDate = const Value.absent(),
          Value<String?> mood = const Value.absent(),
          Value<String?> location = const Value.absent(),
          Value<String?> imageUrls = const Value.absent(),
          Value<String?> tags = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isSynced,
          bool? hasPendingChanges,
          int? version,
          bool? isDeleted,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalJournal(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        content: content ?? this.content,
        entryDate: entryDate.present ? entryDate.value : this.entryDate,
        mood: mood.present ? mood.value : this.mood,
        location: location.present ? location.value : this.location,
        imageUrls: imageUrls.present ? imageUrls.value : this.imageUrls,
        tags: tags.present ? tags.value : this.tags,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalJournal copyWithCompanion(JournalsCompanion data) {
    return LocalJournal(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      mood: data.mood.present ? data.mood.value : this.mood,
      location: data.location.present ? data.location.value : this.location,
      imageUrls: data.imageUrls.present ? data.imageUrls.value : this.imageUrls,
      tags: data.tags.present ? data.tags.value : this.tags,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      hasPendingChanges: data.hasPendingChanges.present
          ? data.hasPendingChanges.value
          : this.hasPendingChanges,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalJournal(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('entryDate: $entryDate, ')
          ..write('mood: $mood, ')
          ..write('location: $location, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('hasPendingChanges: $hasPendingChanges, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tripId,
      userId,
      title,
      content,
      entryDate,
      mood,
      location,
      imageUrls,
      tags,
      createdAt,
      updatedAt,
      isSynced,
      hasPendingChanges,
      version,
      isDeleted,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalJournal &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.content == this.content &&
          other.entryDate == this.entryDate &&
          other.mood == this.mood &&
          other.location == this.location &&
          other.imageUrls == this.imageUrls &&
          other.tags == this.tags &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.hasPendingChanges == this.hasPendingChanges &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class JournalsCompanion extends UpdateCompanion<LocalJournal> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> content;
  final Value<DateTime?> entryDate;
  final Value<String?> mood;
  final Value<String?> location;
  final Value<String?> imageUrls;
  final Value<String?> tags;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> hasPendingChanges;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const JournalsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.mood = const Value.absent(),
    this.location = const Value.absent(),
    this.imageUrls = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.hasPendingChanges = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalsCompanion.insert({
    required String id,
    required String tripId,
    required String userId,
    required String title,
    required String content,
    this.entryDate = const Value.absent(),
    this.mood = const Value.absent(),
    this.location = const Value.absent(),
    this.imageUrls = const Value.absent(),
    this.tags = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.hasPendingChanges = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        userId = Value(userId),
        title = Value(title),
        content = Value(content),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LocalJournal> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? content,
    Expression<DateTime>? entryDate,
    Expression<String>? mood,
    Expression<String>? location,
    Expression<String>? imageUrls,
    Expression<String>? tags,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? hasPendingChanges,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (entryDate != null) 'entry_date': entryDate,
      if (mood != null) 'mood': mood,
      if (location != null) 'location': location,
      if (imageUrls != null) 'image_urls': imageUrls,
      if (tags != null) 'tags': tags,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (hasPendingChanges != null) 'has_pending_changes': hasPendingChanges,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String>? userId,
      Value<String>? title,
      Value<String>? content,
      Value<DateTime?>? entryDate,
      Value<String?>? mood,
      Value<String?>? location,
      Value<String?>? imageUrls,
      Value<String?>? tags,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isSynced,
      Value<bool>? hasPendingChanges,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return JournalsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      entryDate: entryDate ?? this.entryDate,
      mood: mood ?? this.mood,
      location: location ?? this.location,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (imageUrls.present) {
      map['image_urls'] = Variable<String>(imageUrls.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (hasPendingChanges.present) {
      map['has_pending_changes'] = Variable<bool>(hasPendingChanges.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('entryDate: $entryDate, ')
          ..write('mood: $mood, ')
          ..write('location: $location, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('hasPendingChanges: $hasPendingChanges, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
      'bio', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPublicMeta =
      const VerificationMeta('isPublic');
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
      'is_public', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_public" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _interestsMeta =
      const VerificationMeta('interests');
  @override
  late final GeneratedColumn<String> interests = GeneratedColumn<String>(
      'interests', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _preferencesMeta =
      const VerificationMeta('preferences');
  @override
  late final GeneratedColumn<String> preferences = GeneratedColumn<String>(
      'preferences', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastLoginAtMeta =
      const VerificationMeta('lastLoginAt');
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
      'last_login_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hasPendingChangesMeta =
      const VerificationMeta('hasPendingChanges');
  @override
  late final GeneratedColumn<bool> hasPendingChanges = GeneratedColumn<bool>(
      'has_pending_changes', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_pending_changes" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        username,
        displayName,
        bio,
        avatarUrl,
        isPublic,
        interests,
        preferences,
        createdAt,
        updatedAt,
        lastLoginAt,
        isSynced,
        hasPendingChanges,
        version,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<LocalUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('bio')) {
      context.handle(
          _bioMeta, bio.isAcceptableOrUnknown(data['bio']!, _bioMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('is_public')) {
      context.handle(_isPublicMeta,
          isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta));
    }
    if (data.containsKey('interests')) {
      context.handle(_interestsMeta,
          interests.isAcceptableOrUnknown(data['interests']!, _interestsMeta));
    }
    if (data.containsKey('preferences')) {
      context.handle(
          _preferencesMeta,
          preferences.isAcceptableOrUnknown(
              data['preferences']!, _preferencesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
          _lastLoginAtMeta,
          lastLoginAt.isAcceptableOrUnknown(
              data['last_login_at']!, _lastLoginAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('has_pending_changes')) {
      context.handle(
          _hasPendingChangesMeta,
          hasPendingChanges.isAcceptableOrUnknown(
              data['has_pending_changes']!, _hasPendingChangesMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      bio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bio']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      isPublic: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_public'])!,
      interests: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}interests']),
      preferences: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preferences']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      lastLoginAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_login_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      hasPendingChanges: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}has_pending_changes'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  /// Primary key - matches user ID from Cognito
  final String id;

  /// User's email address
  final String email;

  /// User's username
  final String username;

  /// Display name (may differ from username)
  final String displayName;

  /// Optional profile bio
  final String? bio;

  /// Optional avatar URL
  final String? avatarUrl;

  /// Whether profile is public
  final bool isPublic;

  /// List of interests (stored as JSON array)
  final String? interests;

  /// User preferences map (stored as JSON object)
  final String? preferences;

  /// Timestamp when user was created
  final DateTime createdAt;

  /// Timestamp when user was last updated
  final DateTime updatedAt;

  /// Last login timestamp
  final DateTime? lastLoginAt;

  /// Whether this record has been synced with the server
  final bool isSynced;

  /// Whether this record has local modifications pending sync
  final bool hasPendingChanges;

  /// Version number for conflict resolution
  final int version;

  /// Last successful sync timestamp
  final DateTime? lastSyncedAt;
  const LocalUser(
      {required this.id,
      required this.email,
      required this.username,
      required this.displayName,
      this.bio,
      this.avatarUrl,
      required this.isPublic,
      this.interests,
      this.preferences,
      required this.createdAt,
      required this.updatedAt,
      this.lastLoginAt,
      required this.isSynced,
      required this.hasPendingChanges,
      required this.version,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['username'] = Variable<String>(username);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['is_public'] = Variable<bool>(isPublic);
    if (!nullToAbsent || interests != null) {
      map['interests'] = Variable<String>(interests);
    }
    if (!nullToAbsent || preferences != null) {
      map['preferences'] = Variable<String>(preferences);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['has_pending_changes'] = Variable<bool>(hasPendingChanges);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      username: Value(username),
      displayName: Value(displayName),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      isPublic: Value(isPublic),
      interests: interests == null && nullToAbsent
          ? const Value.absent()
          : Value(interests),
      preferences: preferences == null && nullToAbsent
          ? const Value.absent()
          : Value(preferences),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      isSynced: Value(isSynced),
      hasPendingChanges: Value(hasPendingChanges),
      version: Value(version),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String>(json['displayName']),
      bio: serializer.fromJson<String?>(json['bio']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      interests: serializer.fromJson<String?>(json['interests']),
      preferences: serializer.fromJson<String?>(json['preferences']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      hasPendingChanges: serializer.fromJson<bool>(json['hasPendingChanges']),
      version: serializer.fromJson<int>(json['version']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String>(displayName),
      'bio': serializer.toJson<String?>(bio),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'isPublic': serializer.toJson<bool>(isPublic),
      'interests': serializer.toJson<String?>(interests),
      'preferences': serializer.toJson<String?>(preferences),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'hasPendingChanges': serializer.toJson<bool>(hasPendingChanges),
      'version': serializer.toJson<int>(version),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalUser copyWith(
          {String? id,
          String? email,
          String? username,
          String? displayName,
          Value<String?> bio = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent(),
          bool? isPublic,
          Value<String?> interests = const Value.absent(),
          Value<String?> preferences = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> lastLoginAt = const Value.absent(),
          bool? isSynced,
          bool? hasPendingChanges,
          int? version,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalUser(
        id: id ?? this.id,
        email: email ?? this.email,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        bio: bio.present ? bio.value : this.bio,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        isPublic: isPublic ?? this.isPublic,
        interests: interests.present ? interests.value : this.interests,
        preferences: preferences.present ? preferences.value : this.preferences,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
        isSynced: isSynced ?? this.isSynced,
        hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
        version: version ?? this.version,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalUser copyWithCompanion(UsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      username: data.username.present ? data.username.value : this.username,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      bio: data.bio.present ? data.bio.value : this.bio,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      interests: data.interests.present ? data.interests.value : this.interests,
      preferences:
          data.preferences.present ? data.preferences.value : this.preferences,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastLoginAt:
          data.lastLoginAt.present ? data.lastLoginAt.value : this.lastLoginAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      hasPendingChanges: data.hasPendingChanges.present
          ? data.hasPendingChanges.value
          : this.hasPendingChanges,
      version: data.version.present ? data.version.value : this.version,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('bio: $bio, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isPublic: $isPublic, ')
          ..write('interests: $interests, ')
          ..write('preferences: $preferences, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('hasPendingChanges: $hasPendingChanges, ')
          ..write('version: $version, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      email,
      username,
      displayName,
      bio,
      avatarUrl,
      isPublic,
      interests,
      preferences,
      createdAt,
      updatedAt,
      lastLoginAt,
      isSynced,
      hasPendingChanges,
      version,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.email == this.email &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.bio == this.bio &&
          other.avatarUrl == this.avatarUrl &&
          other.isPublic == this.isPublic &&
          other.interests == this.interests &&
          other.preferences == this.preferences &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastLoginAt == this.lastLoginAt &&
          other.isSynced == this.isSynced &&
          other.hasPendingChanges == this.hasPendingChanges &&
          other.version == this.version &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> username;
  final Value<String> displayName;
  final Value<String?> bio;
  final Value<String?> avatarUrl;
  final Value<bool> isPublic;
  final Value<String?> interests;
  final Value<String?> preferences;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastLoginAt;
  final Value<bool> isSynced;
  final Value<bool> hasPendingChanges;
  final Value<int> version;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.bio = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.interests = const Value.absent(),
    this.preferences = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.hasPendingChanges = const Value.absent(),
    this.version = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String username,
    required String displayName,
    this.bio = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.interests = const Value.absent(),
    this.preferences = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastLoginAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.hasPendingChanges = const Value.absent(),
    this.version = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        username = Value(username),
        displayName = Value(displayName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LocalUser> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? bio,
    Expression<String>? avatarUrl,
    Expression<bool>? isPublic,
    Expression<String>? interests,
    Expression<String>? preferences,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastLoginAt,
    Expression<bool>? isSynced,
    Expression<bool>? hasPendingChanges,
    Expression<int>? version,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (isPublic != null) 'is_public': isPublic,
      if (interests != null) 'interests': interests,
      if (preferences != null) 'preferences': preferences,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (hasPendingChanges != null) 'has_pending_changes': hasPendingChanges,
      if (version != null) 'version': version,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String>? username,
      Value<String>? displayName,
      Value<String?>? bio,
      Value<String?>? avatarUrl,
      Value<bool>? isPublic,
      Value<String?>? interests,
      Value<String?>? preferences,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? lastLoginAt,
      Value<bool>? isSynced,
      Value<bool>? hasPendingChanges,
      Value<int>? version,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPublic: isPublic ?? this.isPublic,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isSynced: isSynced ?? this.isSynced,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      version: version ?? this.version,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (interests.present) {
      map['interests'] = Variable<String>(interests.value);
    }
    if (preferences.present) {
      map['preferences'] = Variable<String>(preferences.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (hasPendingChanges.present) {
      map['has_pending_changes'] = Variable<bool>(hasPendingChanges.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('bio: $bio, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isPublic: $isPublic, ')
          ..write('interests: $interests, ')
          ..write('preferences: $preferences, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('hasPendingChanges: $hasPendingChanges, ')
          ..write('version: $version, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('normal'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxRetriesMeta =
      const VerificationMeta('maxRetries');
  @override
  late final GeneratedColumn<int> maxRetries = GeneratedColumn<int>(
      'max_retries', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastAttemptedAtMeta =
      const VerificationMeta('lastAttemptedAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptedAt =
      GeneratedColumn<DateTime>('last_attempted_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        operation,
        data,
        priority,
        retryCount,
        maxRetries,
        status,
        errorMessage,
        createdAt,
        lastAttemptedAt,
        completedAt,
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('max_retries')) {
      context.handle(
          _maxRetriesMeta,
          maxRetries.isAcceptableOrUnknown(
              data['max_retries']!, _maxRetriesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempted_at')) {
      context.handle(
          _lastAttemptedAtMeta,
          lastAttemptedAt.isAcceptableOrUnknown(
              data['last_attempted_at']!, _lastAttemptedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      maxRetries: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_retries'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastAttemptedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempted_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  /// Primary key - local unique identifier
  final int id;

  /// Entity type being synced (e.g., 'trip', 'journal', 'user')
  final String entityType;

  /// Entity ID that this operation applies to
  final String entityId;

  /// Operation type: 'create', 'update', 'delete'
  final String operation;

  /// Operation data payload (JSON encoded)
  /// Contains the full entity data for create/update operations
  final String data;

  /// Sync priority: 'high', 'normal', 'low'
  /// High priority: user-initiated actions
  /// Normal priority: background data
  /// Low priority: analytics, logging
  final String priority;

  /// Number of retry attempts
  final int retryCount;

  /// Maximum retry attempts before marking as failed
  final int maxRetries;

  /// Operation status: 'pending', 'processing', 'completed', 'failed'
  final String status;

  /// Error message if operation failed
  final String? errorMessage;

  /// Timestamp when operation was queued
  final DateTime createdAt;

  /// Timestamp when operation was last attempted
  final DateTime? lastAttemptedAt;

  /// Timestamp when operation completed or failed
  final DateTime? completedAt;

  /// Optional version for conflict resolution
  final int? version;
  const SyncQueueItem(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      required this.data,
      required this.priority,
      required this.retryCount,
      required this.maxRetries,
      required this.status,
      this.errorMessage,
      required this.createdAt,
      this.lastAttemptedAt,
      this.completedAt,
      this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['data'] = Variable<String>(data);
    map['priority'] = Variable<String>(priority);
    map['retry_count'] = Variable<int>(retryCount);
    map['max_retries'] = Variable<int>(maxRetries);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptedAt != null) {
      map['last_attempted_at'] = Variable<DateTime>(lastAttemptedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      data: Value(data),
      priority: Value(priority),
      retryCount: Value(retryCount),
      maxRetries: Value(maxRetries),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      lastAttemptedAt: lastAttemptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
    );
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      data: serializer.fromJson<String>(json['data']),
      priority: serializer.fromJson<String>(json['priority']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      maxRetries: serializer.fromJson<int>(json['maxRetries']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptedAt: serializer.fromJson<DateTime?>(json['lastAttemptedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      version: serializer.fromJson<int?>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'data': serializer.toJson<String>(data),
      'priority': serializer.toJson<String>(priority),
      'retryCount': serializer.toJson<int>(retryCount),
      'maxRetries': serializer.toJson<int>(maxRetries),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptedAt': serializer.toJson<DateTime?>(lastAttemptedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'version': serializer.toJson<int?>(version),
    };
  }

  SyncQueueItem copyWith(
          {int? id,
          String? entityType,
          String? entityId,
          String? operation,
          String? data,
          String? priority,
          int? retryCount,
          int? maxRetries,
          String? status,
          Value<String?> errorMessage = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> lastAttemptedAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          Value<int?> version = const Value.absent()}) =>
      SyncQueueItem(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        data: data ?? this.data,
        priority: priority ?? this.priority,
        retryCount: retryCount ?? this.retryCount,
        maxRetries: maxRetries ?? this.maxRetries,
        status: status ?? this.status,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
        lastAttemptedAt: lastAttemptedAt.present
            ? lastAttemptedAt.value
            : this.lastAttemptedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        version: version.present ? version.value : this.version,
      );
  SyncQueueItem copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      data: data.data.present ? data.data.value : this.data,
      priority: data.priority.present ? data.priority.value : this.priority,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      maxRetries:
          data.maxRetries.present ? data.maxRetries.value : this.maxRetries,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptedAt: data.lastAttemptedAt.present
          ? data.lastAttemptedAt.value
          : this.lastAttemptedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('priority: $priority, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptedAt: $lastAttemptedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entityType,
      entityId,
      operation,
      data,
      priority,
      retryCount,
      maxRetries,
      status,
      errorMessage,
      createdAt,
      lastAttemptedAt,
      completedAt,
      version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.data == this.data &&
          other.priority == this.priority &&
          other.retryCount == this.retryCount &&
          other.maxRetries == this.maxRetries &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.lastAttemptedAt == this.lastAttemptedAt &&
          other.completedAt == this.completedAt &&
          other.version == this.version);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> data;
  final Value<String> priority;
  final Value<int> retryCount;
  final Value<int> maxRetries;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptedAt;
  final Value<DateTime?> completedAt;
  final Value<int?> version;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.data = const Value.absent(),
    this.priority = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.version = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    required String data,
    this.priority = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    this.lastAttemptedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.version = const Value.absent(),
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        data = Value(data),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueItem> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? data,
    Expression<String>? priority,
    Expression<int>? retryCount,
    Expression<int>? maxRetries,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? version,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (data != null) 'data': data,
      if (priority != null) 'priority': priority,
      if (retryCount != null) 'retry_count': retryCount,
      if (maxRetries != null) 'max_retries': maxRetries,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptedAt != null) 'last_attempted_at': lastAttemptedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (version != null) 'version': version,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String>? data,
      Value<String>? priority,
      Value<int>? retryCount,
      Value<int>? maxRetries,
      Value<String>? status,
      Value<String?>? errorMessage,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastAttemptedAt,
      Value<DateTime?>? completedAt,
      Value<int?>? version}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
      completedAt: completedAt ?? this.completedAt,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (maxRetries.present) {
      map['max_retries'] = Variable<int>(maxRetries.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptedAt.present) {
      map['last_attempted_at'] = Variable<DateTime>(lastAttemptedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('priority: $priority, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptedAt: $lastAttemptedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTableTable extends SyncMetadataTable
    with TableInfo<$SyncMetadataTableTable, SyncMetadata> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncAttemptAtMeta =
      const VerificationMeta('lastSyncAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAttemptAt =
      GeneratedColumn<DateTime>('last_sync_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncStatusMeta =
      const VerificationMeta('lastSyncStatus');
  @override
  late final GeneratedColumn<String> lastSyncStatus = GeneratedColumn<String>(
      'last_sync_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncErrorMeta =
      const VerificationMeta('lastSyncError');
  @override
  late final GeneratedColumn<String> lastSyncError = GeneratedColumn<String>(
      'last_sync_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncTokenMeta =
      const VerificationMeta('syncToken');
  @override
  late final GeneratedColumn<String> syncToken = GeneratedColumn<String>(
      'sync_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pendingCountMeta =
      const VerificationMeta('pendingCount');
  @override
  late final GeneratedColumn<int> pendingCount = GeneratedColumn<int>(
      'pending_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _failedCountMeta =
      const VerificationMeta('failedCount');
  @override
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
      'failed_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        entityType,
        lastSyncedAt,
        lastSyncAttemptAt,
        lastSyncStatus,
        lastSyncError,
        syncToken,
        pendingCount,
        failedCount,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata_table';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetadata> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('last_sync_attempt_at')) {
      context.handle(
          _lastSyncAttemptAtMeta,
          lastSyncAttemptAt.isAcceptableOrUnknown(
              data['last_sync_attempt_at']!, _lastSyncAttemptAtMeta));
    }
    if (data.containsKey('last_sync_status')) {
      context.handle(
          _lastSyncStatusMeta,
          lastSyncStatus.isAcceptableOrUnknown(
              data['last_sync_status']!, _lastSyncStatusMeta));
    }
    if (data.containsKey('last_sync_error')) {
      context.handle(
          _lastSyncErrorMeta,
          lastSyncError.isAcceptableOrUnknown(
              data['last_sync_error']!, _lastSyncErrorMeta));
    }
    if (data.containsKey('sync_token')) {
      context.handle(_syncTokenMeta,
          syncToken.isAcceptableOrUnknown(data['sync_token']!, _syncTokenMeta));
    }
    if (data.containsKey('pending_count')) {
      context.handle(
          _pendingCountMeta,
          pendingCount.isAcceptableOrUnknown(
              data['pending_count']!, _pendingCountMeta));
    }
    if (data.containsKey('failed_count')) {
      context.handle(
          _failedCountMeta,
          failedCount.isAcceptableOrUnknown(
              data['failed_count']!, _failedCountMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncMetadata map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadata(
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      lastSyncAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_sync_attempt_at']),
      lastSyncStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_sync_status']),
      lastSyncError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_sync_error']),
      syncToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_token']),
      pendingCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pending_count'])!,
      failedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}failed_count'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncMetadataTableTable createAlias(String alias) {
    return $SyncMetadataTableTable(attachedDatabase, alias);
  }
}

class SyncMetadata extends DataClass implements Insertable<SyncMetadata> {
  /// Primary key - entity type name (e.g., 'trips', 'journals', 'users')
  final String entityType;

  /// Last successful sync timestamp for this entity type
  final DateTime? lastSyncedAt;

  /// Last sync attempt timestamp (may be successful or failed)
  final DateTime? lastSyncAttemptAt;

  /// Last sync status: 'success', 'failed', 'partial'
  final String? lastSyncStatus;

  /// Error message if last sync failed
  final String? lastSyncError;

  /// Version vector or token for incremental sync
  final String? syncToken;

  /// Number of pending operations for this entity type
  final int pendingCount;

  /// Number of failed operations for this entity type
  final int failedCount;

  /// Timestamp when metadata was last updated
  final DateTime updatedAt;
  const SyncMetadata(
      {required this.entityType,
      this.lastSyncedAt,
      this.lastSyncAttemptAt,
      this.lastSyncStatus,
      this.lastSyncError,
      this.syncToken,
      required this.pendingCount,
      required this.failedCount,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || lastSyncAttemptAt != null) {
      map['last_sync_attempt_at'] = Variable<DateTime>(lastSyncAttemptAt);
    }
    if (!nullToAbsent || lastSyncStatus != null) {
      map['last_sync_status'] = Variable<String>(lastSyncStatus);
    }
    if (!nullToAbsent || lastSyncError != null) {
      map['last_sync_error'] = Variable<String>(lastSyncError);
    }
    if (!nullToAbsent || syncToken != null) {
      map['sync_token'] = Variable<String>(syncToken);
    }
    map['pending_count'] = Variable<int>(pendingCount);
    map['failed_count'] = Variable<int>(failedCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataTableCompanion(
      entityType: Value(entityType),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      lastSyncAttemptAt: lastSyncAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAttemptAt),
      lastSyncStatus: lastSyncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncStatus),
      lastSyncError: lastSyncError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncError),
      syncToken: syncToken == null && nullToAbsent
          ? const Value.absent()
          : Value(syncToken),
      pendingCount: Value(pendingCount),
      failedCount: Value(failedCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncMetadata.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadata(
      entityType: serializer.fromJson<String>(json['entityType']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      lastSyncAttemptAt:
          serializer.fromJson<DateTime?>(json['lastSyncAttemptAt']),
      lastSyncStatus: serializer.fromJson<String?>(json['lastSyncStatus']),
      lastSyncError: serializer.fromJson<String?>(json['lastSyncError']),
      syncToken: serializer.fromJson<String?>(json['syncToken']),
      pendingCount: serializer.fromJson<int>(json['pendingCount']),
      failedCount: serializer.fromJson<int>(json['failedCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'lastSyncAttemptAt': serializer.toJson<DateTime?>(lastSyncAttemptAt),
      'lastSyncStatus': serializer.toJson<String?>(lastSyncStatus),
      'lastSyncError': serializer.toJson<String?>(lastSyncError),
      'syncToken': serializer.toJson<String?>(syncToken),
      'pendingCount': serializer.toJson<int>(pendingCount),
      'failedCount': serializer.toJson<int>(failedCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncMetadata copyWith(
          {String? entityType,
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          Value<DateTime?> lastSyncAttemptAt = const Value.absent(),
          Value<String?> lastSyncStatus = const Value.absent(),
          Value<String?> lastSyncError = const Value.absent(),
          Value<String?> syncToken = const Value.absent(),
          int? pendingCount,
          int? failedCount,
          DateTime? updatedAt}) =>
      SyncMetadata(
        entityType: entityType ?? this.entityType,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        lastSyncAttemptAt: lastSyncAttemptAt.present
            ? lastSyncAttemptAt.value
            : this.lastSyncAttemptAt,
        lastSyncStatus:
            lastSyncStatus.present ? lastSyncStatus.value : this.lastSyncStatus,
        lastSyncError:
            lastSyncError.present ? lastSyncError.value : this.lastSyncError,
        syncToken: syncToken.present ? syncToken.value : this.syncToken,
        pendingCount: pendingCount ?? this.pendingCount,
        failedCount: failedCount ?? this.failedCount,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncMetadata copyWithCompanion(SyncMetadataTableCompanion data) {
    return SyncMetadata(
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastSyncAttemptAt: data.lastSyncAttemptAt.present
          ? data.lastSyncAttemptAt.value
          : this.lastSyncAttemptAt,
      lastSyncStatus: data.lastSyncStatus.present
          ? data.lastSyncStatus.value
          : this.lastSyncStatus,
      lastSyncError: data.lastSyncError.present
          ? data.lastSyncError.value
          : this.lastSyncError,
      syncToken: data.syncToken.present ? data.syncToken.value : this.syncToken,
      pendingCount: data.pendingCount.present
          ? data.pendingCount.value
          : this.pendingCount,
      failedCount:
          data.failedCount.present ? data.failedCount.value : this.failedCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadata(')
          ..write('entityType: $entityType, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastSyncAttemptAt: $lastSyncAttemptAt, ')
          ..write('lastSyncStatus: $lastSyncStatus, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('syncToken: $syncToken, ')
          ..write('pendingCount: $pendingCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      entityType,
      lastSyncedAt,
      lastSyncAttemptAt,
      lastSyncStatus,
      lastSyncError,
      syncToken,
      pendingCount,
      failedCount,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadata &&
          other.entityType == this.entityType &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastSyncAttemptAt == this.lastSyncAttemptAt &&
          other.lastSyncStatus == this.lastSyncStatus &&
          other.lastSyncError == this.lastSyncError &&
          other.syncToken == this.syncToken &&
          other.pendingCount == this.pendingCount &&
          other.failedCount == this.failedCount &&
          other.updatedAt == this.updatedAt);
}

class SyncMetadataTableCompanion extends UpdateCompanion<SyncMetadata> {
  final Value<String> entityType;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> lastSyncAttemptAt;
  final Value<String?> lastSyncStatus;
  final Value<String?> lastSyncError;
  final Value<String?> syncToken;
  final Value<int> pendingCount;
  final Value<int> failedCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncMetadataTableCompanion({
    this.entityType = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastSyncAttemptAt = const Value.absent(),
    this.lastSyncStatus = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.syncToken = const Value.absent(),
    this.pendingCount = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataTableCompanion.insert({
    required String entityType,
    this.lastSyncedAt = const Value.absent(),
    this.lastSyncAttemptAt = const Value.absent(),
    this.lastSyncStatus = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.syncToken = const Value.absent(),
    this.pendingCount = const Value.absent(),
    this.failedCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : entityType = Value(entityType),
        updatedAt = Value(updatedAt);
  static Insertable<SyncMetadata> custom({
    Expression<String>? entityType,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? lastSyncAttemptAt,
    Expression<String>? lastSyncStatus,
    Expression<String>? lastSyncError,
    Expression<String>? syncToken,
    Expression<int>? pendingCount,
    Expression<int>? failedCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastSyncAttemptAt != null) 'last_sync_attempt_at': lastSyncAttemptAt,
      if (lastSyncStatus != null) 'last_sync_status': lastSyncStatus,
      if (lastSyncError != null) 'last_sync_error': lastSyncError,
      if (syncToken != null) 'sync_token': syncToken,
      if (pendingCount != null) 'pending_count': pendingCount,
      if (failedCount != null) 'failed_count': failedCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataTableCompanion copyWith(
      {Value<String>? entityType,
      Value<DateTime?>? lastSyncedAt,
      Value<DateTime?>? lastSyncAttemptAt,
      Value<String?>? lastSyncStatus,
      Value<String?>? lastSyncError,
      Value<String?>? syncToken,
      Value<int>? pendingCount,
      Value<int>? failedCount,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SyncMetadataTableCompanion(
      entityType: entityType ?? this.entityType,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastSyncAttemptAt: lastSyncAttemptAt ?? this.lastSyncAttemptAt,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      syncToken: syncToken ?? this.syncToken,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastSyncAttemptAt.present) {
      map['last_sync_attempt_at'] = Variable<DateTime>(lastSyncAttemptAt.value);
    }
    if (lastSyncStatus.present) {
      map['last_sync_status'] = Variable<String>(lastSyncStatus.value);
    }
    if (lastSyncError.present) {
      map['last_sync_error'] = Variable<String>(lastSyncError.value);
    }
    if (syncToken.present) {
      map['sync_token'] = Variable<String>(syncToken.value);
    }
    if (pendingCount.present) {
      map['pending_count'] = Variable<int>(pendingCount.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataTableCompanion(')
          ..write('entityType: $entityType, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastSyncAttemptAt: $lastSyncAttemptAt, ')
          ..write('lastSyncStatus: $lastSyncStatus, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('syncToken: $syncToken, ')
          ..write('pendingCount: $pendingCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $ItinerariesTable itineraries = $ItinerariesTable(this);
  late final $ItineraryItemsTable itineraryItems = $ItineraryItemsTable(this);
  late final $JournalsTable journals = $JournalsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $SyncMetadataTableTable syncMetadataTable =
      $SyncMetadataTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        trips,
        itineraries,
        itineraryItems,
        journals,
        users,
        syncQueue,
        syncMetadataTable
      ];
}

typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  required String id,
  required String userId,
  required String title,
  Value<String?> description,
  required DateTime startDate,
  required DateTime endDate,
  required String destination,
  Value<double?> latitude,
  Value<double?> longitude,
  required String status,
  required int budget,
  Value<String?> coverImageUrl,
  Value<String?> travelCompanionIds,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isSynced,
  Value<bool> hasPendingChanges,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> destination,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String> status,
  Value<int> budget,
  Value<String?> coverImageUrl,
  Value<String?> travelCompanionIds,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isSynced,
  Value<bool> hasPendingChanges,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get budget => $composableBuilder(
      column: $table.budget, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get travelCompanionIds => $composableBuilder(
      column: $table.travelCompanionIds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get budget => $composableBuilder(
      column: $table.budget, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get travelCompanionIds => $composableBuilder(
      column: $table.travelCompanionIds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get budget =>
      $composableBuilder(column: $table.budget, builder: (column) => column);

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => column);

  GeneratedColumn<String> get travelCompanionIds => $composableBuilder(
      column: $table.travelCompanionIds, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$TripsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TripsTable,
    LocalTrip,
    $$TripsTableFilterComposer,
    $$TripsTableOrderingComposer,
    $$TripsTableAnnotationComposer,
    $$TripsTableCreateCompanionBuilder,
    $$TripsTableUpdateCompanionBuilder,
    (LocalTrip, BaseReferences<_$AppDatabase, $TripsTable, LocalTrip>),
    LocalTrip,
    PrefetchHooks Function()> {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<String> destination = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> budget = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<String?> travelCompanionIds = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> hasPendingChanges = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TripsCompanion(
            id: id,
            userId: userId,
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            destination: destination,
            latitude: latitude,
            longitude: longitude,
            status: status,
            budget: budget,
            coverImageUrl: coverImageUrl,
            travelCompanionIds: travelCompanionIds,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            hasPendingChanges: hasPendingChanges,
            version: version,
            isDeleted: isDeleted,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime startDate,
            required DateTime endDate,
            required String destination,
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            required String status,
            required int budget,
            Value<String?> coverImageUrl = const Value.absent(),
            Value<String?> travelCompanionIds = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isSynced = const Value.absent(),
            Value<bool> hasPendingChanges = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TripsCompanion.insert(
            id: id,
            userId: userId,
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            destination: destination,
            latitude: latitude,
            longitude: longitude,
            status: status,
            budget: budget,
            coverImageUrl: coverImageUrl,
            travelCompanionIds: travelCompanionIds,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            hasPendingChanges: hasPendingChanges,
            version: version,
            isDeleted: isDeleted,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TripsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TripsTable,
    LocalTrip,
    $$TripsTableFilterComposer,
    $$TripsTableOrderingComposer,
    $$TripsTableAnnotationComposer,
    $$TripsTableCreateCompanionBuilder,
    $$TripsTableUpdateCompanionBuilder,
    (LocalTrip, BaseReferences<_$AppDatabase, $TripsTable, LocalTrip>),
    LocalTrip,
    PrefetchHooks Function()>;
typedef $$ItinerariesTableCreateCompanionBuilder = ItinerariesCompanion
    Function({
  required String id,
  Value<String?> userId,
  required String name,
  required String destinationPlaceId,
  required String destinationName,
  required double destinationLatitude,
  required double destinationLongitude,
  Value<String?> destinationAirportCode,
  required DateTime startDate,
  required DateTime endDate,
  required int numberOfDays,
  Value<bool> isStarter,
  Value<String?> coverImageUrl,
  Value<int> itemsCount,
  Value<int> completedItemsCount,
  Value<int> completionPercentage,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<bool> hasPendingChanges,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ItinerariesTableUpdateCompanionBuilder = ItinerariesCompanion
    Function({
  Value<String> id,
  Value<String?> userId,
  Value<String> name,
  Value<String> destinationPlaceId,
  Value<String> destinationName,
  Value<double> destinationLatitude,
  Value<double> destinationLongitude,
  Value<String?> destinationAirportCode,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<int> numberOfDays,
  Value<bool> isStarter,
  Value<String?> coverImageUrl,
  Value<int> itemsCount,
  Value<int> completedItemsCount,
  Value<int> completionPercentage,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<bool> hasPendingChanges,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$ItinerariesTableFilterComposer
    extends Composer<_$AppDatabase, $ItinerariesTable> {
  $$ItinerariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationPlaceId => $composableBuilder(
      column: $table.destinationPlaceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationName => $composableBuilder(
      column: $table.destinationName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get destinationLatitude => $composableBuilder(
      column: $table.destinationLatitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get destinationLongitude => $composableBuilder(
      column: $table.destinationLongitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationAirportCode => $composableBuilder(
      column: $table.destinationAirportCode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numberOfDays => $composableBuilder(
      column: $table.numberOfDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isStarter => $composableBuilder(
      column: $table.isStarter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemsCount => $composableBuilder(
      column: $table.itemsCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedItemsCount => $composableBuilder(
      column: $table.completedItemsCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completionPercentage => $composableBuilder(
      column: $table.completionPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$ItinerariesTableOrderingComposer
    extends Composer<_$AppDatabase, $ItinerariesTable> {
  $$ItinerariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationPlaceId => $composableBuilder(
      column: $table.destinationPlaceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationName => $composableBuilder(
      column: $table.destinationName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get destinationLatitude => $composableBuilder(
      column: $table.destinationLatitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get destinationLongitude => $composableBuilder(
      column: $table.destinationLongitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationAirportCode => $composableBuilder(
      column: $table.destinationAirportCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numberOfDays => $composableBuilder(
      column: $table.numberOfDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isStarter => $composableBuilder(
      column: $table.isStarter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemsCount => $composableBuilder(
      column: $table.itemsCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedItemsCount => $composableBuilder(
      column: $table.completedItemsCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completionPercentage => $composableBuilder(
      column: $table.completionPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ItinerariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItinerariesTable> {
  $$ItinerariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get destinationPlaceId => $composableBuilder(
      column: $table.destinationPlaceId, builder: (column) => column);

  GeneratedColumn<String> get destinationName => $composableBuilder(
      column: $table.destinationName, builder: (column) => column);

  GeneratedColumn<double> get destinationLatitude => $composableBuilder(
      column: $table.destinationLatitude, builder: (column) => column);

  GeneratedColumn<double> get destinationLongitude => $composableBuilder(
      column: $table.destinationLongitude, builder: (column) => column);

  GeneratedColumn<String> get destinationAirportCode => $composableBuilder(
      column: $table.destinationAirportCode, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get numberOfDays => $composableBuilder(
      column: $table.numberOfDays, builder: (column) => column);

  GeneratedColumn<bool> get isStarter =>
      $composableBuilder(column: $table.isStarter, builder: (column) => column);

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => column);

  GeneratedColumn<int> get itemsCount => $composableBuilder(
      column: $table.itemsCount, builder: (column) => column);

  GeneratedColumn<int> get completedItemsCount => $composableBuilder(
      column: $table.completedItemsCount, builder: (column) => column);

  GeneratedColumn<int> get completionPercentage => $composableBuilder(
      column: $table.completionPercentage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$ItinerariesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItinerariesTable,
    LocalItinerary,
    $$ItinerariesTableFilterComposer,
    $$ItinerariesTableOrderingComposer,
    $$ItinerariesTableAnnotationComposer,
    $$ItinerariesTableCreateCompanionBuilder,
    $$ItinerariesTableUpdateCompanionBuilder,
    (
      LocalItinerary,
      BaseReferences<_$AppDatabase, $ItinerariesTable, LocalItinerary>
    ),
    LocalItinerary,
    PrefetchHooks Function()> {
  $$ItinerariesTableTableManager(_$AppDatabase db, $ItinerariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItinerariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItinerariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItinerariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> destinationPlaceId = const Value.absent(),
            Value<String> destinationName = const Value.absent(),
            Value<double> destinationLatitude = const Value.absent(),
            Value<double> destinationLongitude = const Value.absent(),
            Value<String?> destinationAirportCode = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<int> numberOfDays = const Value.absent(),
            Value<bool> isStarter = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<int> itemsCount = const Value.absent(),
            Value<int> completedItemsCount = const Value.absent(),
            Value<int> completionPercentage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> hasPendingChanges = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItinerariesCompanion(
            id: id,
            userId: userId,
            name: name,
            destinationPlaceId: destinationPlaceId,
            destinationName: destinationName,
            destinationLatitude: destinationLatitude,
            destinationLongitude: destinationLongitude,
            destinationAirportCode: destinationAirportCode,
            startDate: startDate,
            endDate: endDate,
            numberOfDays: numberOfDays,
            isStarter: isStarter,
            coverImageUrl: coverImageUrl,
            itemsCount: itemsCount,
            completedItemsCount: completedItemsCount,
            completionPercentage: completionPercentage,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            hasPendingChanges: hasPendingChanges,
            version: version,
            isDeleted: isDeleted,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required String name,
            required String destinationPlaceId,
            required String destinationName,
            required double destinationLatitude,
            required double destinationLongitude,
            Value<String?> destinationAirportCode = const Value.absent(),
            required DateTime startDate,
            required DateTime endDate,
            required int numberOfDays,
            Value<bool> isStarter = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<int> itemsCount = const Value.absent(),
            Value<int> completedItemsCount = const Value.absent(),
            Value<int> completionPercentage = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> hasPendingChanges = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItinerariesCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            destinationPlaceId: destinationPlaceId,
            destinationName: destinationName,
            destinationLatitude: destinationLatitude,
            destinationLongitude: destinationLongitude,
            destinationAirportCode: destinationAirportCode,
            startDate: startDate,
            endDate: endDate,
            numberOfDays: numberOfDays,
            isStarter: isStarter,
            coverImageUrl: coverImageUrl,
            itemsCount: itemsCount,
            completedItemsCount: completedItemsCount,
            completionPercentage: completionPercentage,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            hasPendingChanges: hasPendingChanges,
            version: version,
            isDeleted: isDeleted,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItinerariesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItinerariesTable,
    LocalItinerary,
    $$ItinerariesTableFilterComposer,
    $$ItinerariesTableOrderingComposer,
    $$ItinerariesTableAnnotationComposer,
    $$ItinerariesTableCreateCompanionBuilder,
    $$ItinerariesTableUpdateCompanionBuilder,
    (
      LocalItinerary,
      BaseReferences<_$AppDatabase, $ItinerariesTable, LocalItinerary>
    ),
    LocalItinerary,
    PrefetchHooks Function()>;
typedef $$ItineraryItemsTableCreateCompanionBuilder = ItineraryItemsCompanion
    Function({
  required String id,
  required String itineraryId,
  required String type,
  required DateTime time,
  Value<bool> isCompleted,
  Value<String?> name,
  Value<String?> note,
  Value<String?> location,
  Value<double?> latitude,
  Value<double?> longitude,
  required int dayNumber,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<bool> hasPendingChanges,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ItineraryItemsTableUpdateCompanionBuilder = ItineraryItemsCompanion
    Function({
  Value<String> id,
  Value<String> itineraryId,
  Value<String> type,
  Value<DateTime> time,
  Value<bool> isCompleted,
  Value<String?> name,
  Value<String?> note,
  Value<String?> location,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> dayNumber,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<bool> hasPendingChanges,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$ItineraryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ItineraryItemsTable> {
  $$ItineraryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itineraryId => $composableBuilder(
      column: $table.itineraryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayNumber => $composableBuilder(
      column: $table.dayNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$ItineraryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItineraryItemsTable> {
  $$ItineraryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itineraryId => $composableBuilder(
      column: $table.itineraryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayNumber => $composableBuilder(
      column: $table.dayNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ItineraryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItineraryItemsTable> {
  $$ItineraryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itineraryId => $composableBuilder(
      column: $table.itineraryId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$ItineraryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItineraryItemsTable,
    LocalItineraryItem,
    $$ItineraryItemsTableFilterComposer,
    $$ItineraryItemsTableOrderingComposer,
    $$ItineraryItemsTableAnnotationComposer,
    $$ItineraryItemsTableCreateCompanionBuilder,
    $$ItineraryItemsTableUpdateCompanionBuilder,
    (
      LocalItineraryItem,
      BaseReferences<_$AppDatabase, $ItineraryItemsTable, LocalItineraryItem>
    ),
    LocalItineraryItem,
    PrefetchHooks Function()> {
  $$ItineraryItemsTableTableManager(
      _$AppDatabase db, $ItineraryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItineraryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItineraryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItineraryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itineraryId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> dayNumber = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> hasPendingChanges = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItineraryItemsCompanion(
            id: id,
            itineraryId: itineraryId,
            type: type,
            time: time,
            isCompleted: isCompleted,
            name: name,
            note: note,
            location: location,
            latitude: latitude,
            longitude: longitude,
            dayNumber: dayNumber,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            hasPendingChanges: hasPendingChanges,
            version: version,
            isDeleted: isDeleted,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itineraryId,
            required String type,
            required DateTime time,
            Value<bool> isCompleted = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            required int dayNumber,
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> hasPendingChanges = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItineraryItemsCompanion.insert(
            id: id,
            itineraryId: itineraryId,
            type: type,
            time: time,
            isCompleted: isCompleted,
            name: name,
            note: note,
            location: location,
            latitude: latitude,
            longitude: longitude,
            dayNumber: dayNumber,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            hasPendingChanges: hasPendingChanges,
            version: version,
            isDeleted: isDeleted,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItineraryItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItineraryItemsTable,
    LocalItineraryItem,
    $$ItineraryItemsTableFilterComposer,
    $$ItineraryItemsTableOrderingComposer,
    $$ItineraryItemsTableAnnotationComposer,
    $$ItineraryItemsTableCreateCompanionBuilder,
    $$ItineraryItemsTableUpdateCompanionBuilder,
    (
      LocalItineraryItem,
      BaseReferences<_$AppDatabase, $ItineraryItemsTable, LocalItineraryItem>
    ),
    LocalItineraryItem,
    PrefetchHooks Function()>;
typedef $$JournalsTableCreateCompanionBuilder = JournalsCompanion Function({
  required String id,
  required String tripId,
  required String userId,
  required String title,
  required String content,
  Value<DateTime?> entryDate,
  Value<String?> mood,
  Value<String?> location,
  Value<String?> imageUrls,
  Value<String?> tags,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isSynced,
  Value<bool> hasPendingChanges,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$JournalsTableUpdateCompanionBuilder = JournalsCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> userId,
  Value<String> title,
  Value<String> content,
  Value<DateTime?> entryDate,
  Value<String?> mood,
  Value<String?> location,
  Value<String?> imageUrls,
  Value<String?> tags,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isSynced,
  Value<bool> hasPendingChanges,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$JournalsTableFilterComposer
    extends Composer<_$AppDatabase, $JournalsTable> {
  $$JournalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrls => $composableBuilder(
      column: $table.imageUrls, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$JournalsTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalsTable> {
  $$JournalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrls => $composableBuilder(
      column: $table.imageUrls, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$JournalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalsTable> {
  $$JournalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get imageUrls =>
      $composableBuilder(column: $table.imageUrls, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$JournalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $JournalsTable,
    LocalJournal,
    $$JournalsTableFilterComposer,
    $$JournalsTableOrderingComposer,
    $$JournalsTableAnnotationComposer,
    $$JournalsTableCreateCompanionBuilder,
    $$JournalsTableUpdateCompanionBuilder,
    (LocalJournal, BaseReferences<_$AppDatabase, $JournalsTable, LocalJournal>),
    LocalJournal,
    PrefetchHooks Function()> {
  $$JournalsTableTableManager(_$AppDatabase db, $JournalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime?> entryDate = const Value.absent(),
            Value<String?> mood = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> imageUrls = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> hasPendingChanges = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JournalsCompanion(
            id: id,
            tripId: tripId,
            userId: userId,
            title: title,
            content: content,
            entryDate: entryDate,
            mood: mood,
            location: location,
            imageUrls: imageUrls,
            tags: tags,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            hasPendingChanges: hasPendingChanges,
            version: version,
            isDeleted: isDeleted,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            required String userId,
            required String title,
            required String content,
            Value<DateTime?> entryDate = const Value.absent(),
            Value<String?> mood = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> imageUrls = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isSynced = const Value.absent(),
            Value<bool> hasPendingChanges = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JournalsCompanion.insert(
            id: id,
            tripId: tripId,
            userId: userId,
            title: title,
            content: content,
            entryDate: entryDate,
            mood: mood,
            location: location,
            imageUrls: imageUrls,
            tags: tags,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            hasPendingChanges: hasPendingChanges,
            version: version,
            isDeleted: isDeleted,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JournalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $JournalsTable,
    LocalJournal,
    $$JournalsTableFilterComposer,
    $$JournalsTableOrderingComposer,
    $$JournalsTableAnnotationComposer,
    $$JournalsTableCreateCompanionBuilder,
    $$JournalsTableUpdateCompanionBuilder,
    (LocalJournal, BaseReferences<_$AppDatabase, $JournalsTable, LocalJournal>),
    LocalJournal,
    PrefetchHooks Function()>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String email,
  required String username,
  required String displayName,
  Value<String?> bio,
  Value<String?> avatarUrl,
  Value<bool> isPublic,
  Value<String?> interests,
  Value<String?> preferences,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> lastLoginAt,
  Value<bool> isSynced,
  Value<bool> hasPendingChanges,
  Value<int> version,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String> username,
  Value<String> displayName,
  Value<String?> bio,
  Value<String?> avatarUrl,
  Value<bool> isPublic,
  Value<String?> interests,
  Value<String?> preferences,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastLoginAt,
  Value<bool> isSynced,
  Value<bool> hasPendingChanges,
  Value<int> version,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bio => $composableBuilder(
      column: $table.bio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPublic => $composableBuilder(
      column: $table.isPublic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get interests => $composableBuilder(
      column: $table.interests, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferences => $composableBuilder(
      column: $table.preferences, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bio => $composableBuilder(
      column: $table.bio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPublic => $composableBuilder(
      column: $table.isPublic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get interests => $composableBuilder(
      column: $table.interests, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferences => $composableBuilder(
      column: $table.preferences, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<String> get interests =>
      $composableBuilder(column: $table.interests, builder: (column) => column);

  GeneratedColumn<String> get preferences => $composableBuilder(
      column: $table.preferences, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get hasPendingChanges => $composableBuilder(
      column: $table.hasPendingChanges, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    LocalUser,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (LocalUser, BaseReferences<_$AppDatabase, $UsersTable, LocalUser>),
    LocalUser,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> bio = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<bool> isPublic = const Value.absent(),
            Value<String?> interests = const Value.absent(),
            Value<String?> preferences = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastLoginAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> hasPendingChanges = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            username: username,
            displayName: displayName,
            bio: bio,
            avatarUrl: avatarUrl,
            isPublic: isPublic,
            interests: interests,
            preferences: preferences,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastLoginAt: lastLoginAt,
            isSynced: isSynced,
            hasPendingChanges: hasPendingChanges,
            version: version,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            required String username,
            required String displayName,
            Value<String?> bio = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<bool> isPublic = const Value.absent(),
            Value<String?> interests = const Value.absent(),
            Value<String?> preferences = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> lastLoginAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> hasPendingChanges = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            username: username,
            displayName: displayName,
            bio: bio,
            avatarUrl: avatarUrl,
            isPublic: isPublic,
            interests: interests,
            preferences: preferences,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastLoginAt: lastLoginAt,
            isSynced: isSynced,
            hasPendingChanges: hasPendingChanges,
            version: version,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    LocalUser,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (LocalUser, BaseReferences<_$AppDatabase, $UsersTable, LocalUser>),
    LocalUser,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  required String operation,
  required String data,
  Value<String> priority,
  Value<int> retryCount,
  Value<int> maxRetries,
  Value<String> status,
  Value<String?> errorMessage,
  required DateTime createdAt,
  Value<DateTime?> lastAttemptedAt,
  Value<DateTime?> completedAt,
  Value<int?> version,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> data,
  Value<String> priority,
  Value<int> retryCount,
  Value<int> maxRetries,
  Value<String> status,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime?> lastAttemptedAt,
  Value<DateTime?> completedAt,
  Value<int?> version,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptedAt => $composableBuilder(
      column: $table.lastAttemptedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptedAt => $composableBuilder(
      column: $table.lastAttemptedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptedAt => $composableBuilder(
      column: $table.lastAttemptedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueItem,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastAttemptedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> version = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            data: data,
            priority: priority,
            retryCount: retryCount,
            maxRetries: maxRetries,
            status: status,
            errorMessage: errorMessage,
            createdAt: createdAt,
            lastAttemptedAt: lastAttemptedAt,
            completedAt: completedAt,
            version: version,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String entityId,
            required String operation,
            required String data,
            Value<String> priority = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> lastAttemptedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> version = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            data: data,
            priority: priority,
            retryCount: retryCount,
            maxRetries: maxRetries,
            status: status,
            errorMessage: errorMessage,
            createdAt: createdAt,
            lastAttemptedAt: lastAttemptedAt,
            completedAt: completedAt,
            version: version,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueItem,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()>;
typedef $$SyncMetadataTableTableCreateCompanionBuilder
    = SyncMetadataTableCompanion Function({
  required String entityType,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> lastSyncAttemptAt,
  Value<String?> lastSyncStatus,
  Value<String?> lastSyncError,
  Value<String?> syncToken,
  Value<int> pendingCount,
  Value<int> failedCount,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SyncMetadataTableTableUpdateCompanionBuilder
    = SyncMetadataTableCompanion Function({
  Value<String> entityType,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> lastSyncAttemptAt,
  Value<String?> lastSyncStatus,
  Value<String?> lastSyncError,
  Value<String?> syncToken,
  Value<int> pendingCount,
  Value<int> failedCount,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SyncMetadataTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAttemptAt => $composableBuilder(
      column: $table.lastSyncAttemptAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastSyncStatus => $composableBuilder(
      column: $table.lastSyncStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastSyncError => $composableBuilder(
      column: $table.lastSyncError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncToken => $composableBuilder(
      column: $table.syncToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pendingCount => $composableBuilder(
      column: $table.pendingCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failedCount => $composableBuilder(
      column: $table.failedCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncMetadataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAttemptAt => $composableBuilder(
      column: $table.lastSyncAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSyncStatus => $composableBuilder(
      column: $table.lastSyncStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSyncError => $composableBuilder(
      column: $table.lastSyncError,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncToken => $composableBuilder(
      column: $table.syncToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pendingCount => $composableBuilder(
      column: $table.pendingCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failedCount => $composableBuilder(
      column: $table.failedCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncMetadataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAttemptAt => $composableBuilder(
      column: $table.lastSyncAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get lastSyncStatus => $composableBuilder(
      column: $table.lastSyncStatus, builder: (column) => column);

  GeneratedColumn<String> get lastSyncError => $composableBuilder(
      column: $table.lastSyncError, builder: (column) => column);

  GeneratedColumn<String> get syncToken =>
      $composableBuilder(column: $table.syncToken, builder: (column) => column);

  GeneratedColumn<int> get pendingCount => $composableBuilder(
      column: $table.pendingCount, builder: (column) => column);

  GeneratedColumn<int> get failedCount => $composableBuilder(
      column: $table.failedCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncMetadataTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetadataTableTable,
    SyncMetadata,
    $$SyncMetadataTableTableFilterComposer,
    $$SyncMetadataTableTableOrderingComposer,
    $$SyncMetadataTableTableAnnotationComposer,
    $$SyncMetadataTableTableCreateCompanionBuilder,
    $$SyncMetadataTableTableUpdateCompanionBuilder,
    (
      SyncMetadata,
      BaseReferences<_$AppDatabase, $SyncMetadataTableTable, SyncMetadata>
    ),
    SyncMetadata,
    PrefetchHooks Function()> {
  $$SyncMetadataTableTableTableManager(
      _$AppDatabase db, $SyncMetadataTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entityType = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<DateTime?> lastSyncAttemptAt = const Value.absent(),
            Value<String?> lastSyncStatus = const Value.absent(),
            Value<String?> lastSyncError = const Value.absent(),
            Value<String?> syncToken = const Value.absent(),
            Value<int> pendingCount = const Value.absent(),
            Value<int> failedCount = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataTableCompanion(
            entityType: entityType,
            lastSyncedAt: lastSyncedAt,
            lastSyncAttemptAt: lastSyncAttemptAt,
            lastSyncStatus: lastSyncStatus,
            lastSyncError: lastSyncError,
            syncToken: syncToken,
            pendingCount: pendingCount,
            failedCount: failedCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entityType,
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<DateTime?> lastSyncAttemptAt = const Value.absent(),
            Value<String?> lastSyncStatus = const Value.absent(),
            Value<String?> lastSyncError = const Value.absent(),
            Value<String?> syncToken = const Value.absent(),
            Value<int> pendingCount = const Value.absent(),
            Value<int> failedCount = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataTableCompanion.insert(
            entityType: entityType,
            lastSyncedAt: lastSyncedAt,
            lastSyncAttemptAt: lastSyncAttemptAt,
            lastSyncStatus: lastSyncStatus,
            lastSyncError: lastSyncError,
            syncToken: syncToken,
            pendingCount: pendingCount,
            failedCount: failedCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetadataTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetadataTableTable,
    SyncMetadata,
    $$SyncMetadataTableTableFilterComposer,
    $$SyncMetadataTableTableOrderingComposer,
    $$SyncMetadataTableTableAnnotationComposer,
    $$SyncMetadataTableTableCreateCompanionBuilder,
    $$SyncMetadataTableTableUpdateCompanionBuilder,
    (
      SyncMetadata,
      BaseReferences<_$AppDatabase, $SyncMetadataTableTable, SyncMetadata>
    ),
    SyncMetadata,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$ItinerariesTableTableManager get itineraries =>
      $$ItinerariesTableTableManager(_db, _db.itineraries);
  $$ItineraryItemsTableTableManager get itineraryItems =>
      $$ItineraryItemsTableTableManager(_db, _db.itineraryItems);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db, _db.journals);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$SyncMetadataTableTableTableManager get syncMetadataTable =>
      $$SyncMetadataTableTableTableManager(_db, _db.syncMetadataTable);
}
