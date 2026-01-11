// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Activity {
  /// Unique identifier for the activity
  String get id;

  /// ID of the trip this activity belongs to
  String get tripId;

  /// ID of the user who created this activity
  String get userId;

  /// Activity title or name
  String get title;

  /// Detailed description of the activity
  String? get description;

  /// Category of the activity
  ActivityCategory get category;

  /// Location name (e.g., restaurant name, museum name)
  String? get locationName;

  /// Physical address
  String? get address;

  /// Latitude coordinate
  double? get latitude;

  /// Longitude coordinate
  double? get longitude;

  /// Scheduled start date and time
  DateTime? get startDateTime;

  /// Scheduled end date and time
  DateTime? get endDateTime;

  /// Estimated cost for this activity
  double? get estimatedCost;

  /// Actual cost (if completed)
  double? get actualCost;

  /// Currency code for costs (e.g., USD, EUR)
  String? get currency;

  /// Booking confirmation code or reference number
  String? get confirmationNumber;

  /// Website URL related to this activity
  String? get websiteUrl;

  /// Phone number for reservations
  String? get phoneNumber;

  /// Activity notes or special instructions
  String? get notes;

  /// Whether this activity is completed
  bool get isCompleted;

  /// Whether this activity is a high priority
  dynamic get isPriority;

  /// List of photo IDs associated with this activity
  List<String>? get photoIds;

  /// Tags for organizing and filtering activities
  List<String>? get tags;

  /// Date and time when the activity was created
  DateTime get createdAt;

  /// Date and time when the activity was last updated
  DateTime get updatedAt;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActivityCopyWith<Activity> get copyWith =>
      _$ActivityCopyWithImpl<Activity>(this as Activity, _$identity);

  /// Serializes this Activity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Activity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.startDateTime, startDateTime) ||
                other.startDateTime == startDateTime) &&
            (identical(other.endDateTime, endDateTime) ||
                other.endDateTime == endDateTime) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.actualCost, actualCost) ||
                other.actualCost == actualCost) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.confirmationNumber, confirmationNumber) ||
                other.confirmationNumber == confirmationNumber) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            const DeepCollectionEquality()
                .equals(other.isPriority, isPriority) &&
            const DeepCollectionEquality().equals(other.photoIds, photoIds) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tripId,
        userId,
        title,
        description,
        category,
        locationName,
        address,
        latitude,
        longitude,
        startDateTime,
        endDateTime,
        estimatedCost,
        actualCost,
        currency,
        confirmationNumber,
        websiteUrl,
        phoneNumber,
        notes,
        isCompleted,
        const DeepCollectionEquality().hash(isPriority),
        const DeepCollectionEquality().hash(photoIds),
        const DeepCollectionEquality().hash(tags),
        createdAt,
        updatedAt
      ]);

  @override
  String toString() {
    return 'Activity(id: $id, tripId: $tripId, userId: $userId, title: $title, description: $description, category: $category, locationName: $locationName, address: $address, latitude: $latitude, longitude: $longitude, startDateTime: $startDateTime, endDateTime: $endDateTime, estimatedCost: $estimatedCost, actualCost: $actualCost, currency: $currency, confirmationNumber: $confirmationNumber, websiteUrl: $websiteUrl, phoneNumber: $phoneNumber, notes: $notes, isCompleted: $isCompleted, isPriority: $isPriority, photoIds: $photoIds, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $ActivityCopyWith<$Res> {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) _then) =
      _$ActivityCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String tripId,
      String userId,
      String title,
      String? description,
      ActivityCategory category,
      String? locationName,
      String? address,
      double? latitude,
      double? longitude,
      DateTime? startDateTime,
      DateTime? endDateTime,
      double? estimatedCost,
      double? actualCost,
      String? currency,
      String? confirmationNumber,
      String? websiteUrl,
      String? phoneNumber,
      String? notes,
      bool isCompleted,
      dynamic isPriority,
      List<String>? photoIds,
      List<String>? tags,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$ActivityCopyWithImpl<$Res> implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._self, this._then);

  final Activity _self;
  final $Res Function(Activity) _then;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? category = null,
    Object? locationName = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? startDateTime = freezed,
    Object? endDateTime = freezed,
    Object? estimatedCost = freezed,
    Object? actualCost = freezed,
    Object? currency = freezed,
    Object? confirmationNumber = freezed,
    Object? websiteUrl = freezed,
    Object? phoneNumber = freezed,
    Object? notes = freezed,
    Object? isCompleted = null,
    Object? isPriority = freezed,
    Object? photoIds = freezed,
    Object? tags = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as ActivityCategory,
      locationName: freezed == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      startDateTime: freezed == startDateTime
          ? _self.startDateTime
          : startDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDateTime: freezed == endDateTime
          ? _self.endDateTime
          : endDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      estimatedCost: freezed == estimatedCost
          ? _self.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as double?,
      actualCost: freezed == actualCost
          ? _self.actualCost
          : actualCost // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmationNumber: freezed == confirmationNumber
          ? _self.confirmationNumber
          : confirmationNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _self.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _self.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isPriority: freezed == isPriority
          ? _self.isPriority
          : isPriority // ignore: cast_nullable_to_non_nullable
              as dynamic,
      photoIds: freezed == photoIds
          ? _self.photoIds
          : photoIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [Activity].
extension ActivityPatterns on Activity {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Activity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Activity() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Activity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Activity():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Activity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Activity() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String tripId,
            String userId,
            String title,
            String? description,
            ActivityCategory category,
            String? locationName,
            String? address,
            double? latitude,
            double? longitude,
            DateTime? startDateTime,
            DateTime? endDateTime,
            double? estimatedCost,
            double? actualCost,
            String? currency,
            String? confirmationNumber,
            String? websiteUrl,
            String? phoneNumber,
            String? notes,
            bool isCompleted,
            dynamic isPriority,
            List<String>? photoIds,
            List<String>? tags,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Activity() when $default != null:
        return $default(
            _that.id,
            _that.tripId,
            _that.userId,
            _that.title,
            _that.description,
            _that.category,
            _that.locationName,
            _that.address,
            _that.latitude,
            _that.longitude,
            _that.startDateTime,
            _that.endDateTime,
            _that.estimatedCost,
            _that.actualCost,
            _that.currency,
            _that.confirmationNumber,
            _that.websiteUrl,
            _that.phoneNumber,
            _that.notes,
            _that.isCompleted,
            _that.isPriority,
            _that.photoIds,
            _that.tags,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String tripId,
            String userId,
            String title,
            String? description,
            ActivityCategory category,
            String? locationName,
            String? address,
            double? latitude,
            double? longitude,
            DateTime? startDateTime,
            DateTime? endDateTime,
            double? estimatedCost,
            double? actualCost,
            String? currency,
            String? confirmationNumber,
            String? websiteUrl,
            String? phoneNumber,
            String? notes,
            bool isCompleted,
            dynamic isPriority,
            List<String>? photoIds,
            List<String>? tags,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Activity():
        return $default(
            _that.id,
            _that.tripId,
            _that.userId,
            _that.title,
            _that.description,
            _that.category,
            _that.locationName,
            _that.address,
            _that.latitude,
            _that.longitude,
            _that.startDateTime,
            _that.endDateTime,
            _that.estimatedCost,
            _that.actualCost,
            _that.currency,
            _that.confirmationNumber,
            _that.websiteUrl,
            _that.phoneNumber,
            _that.notes,
            _that.isCompleted,
            _that.isPriority,
            _that.photoIds,
            _that.tags,
            _that.createdAt,
            _that.updatedAt);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String tripId,
            String userId,
            String title,
            String? description,
            ActivityCategory category,
            String? locationName,
            String? address,
            double? latitude,
            double? longitude,
            DateTime? startDateTime,
            DateTime? endDateTime,
            double? estimatedCost,
            double? actualCost,
            String? currency,
            String? confirmationNumber,
            String? websiteUrl,
            String? phoneNumber,
            String? notes,
            bool isCompleted,
            dynamic isPriority,
            List<String>? photoIds,
            List<String>? tags,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Activity() when $default != null:
        return $default(
            _that.id,
            _that.tripId,
            _that.userId,
            _that.title,
            _that.description,
            _that.category,
            _that.locationName,
            _that.address,
            _that.latitude,
            _that.longitude,
            _that.startDateTime,
            _that.endDateTime,
            _that.estimatedCost,
            _that.actualCost,
            _that.currency,
            _that.confirmationNumber,
            _that.websiteUrl,
            _that.phoneNumber,
            _that.notes,
            _that.isCompleted,
            _that.isPriority,
            _that.photoIds,
            _that.tags,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Activity implements Activity {
  const _Activity(
      {required this.id,
      required this.tripId,
      required this.userId,
      required this.title,
      this.description,
      required this.category,
      this.locationName,
      this.address,
      this.latitude,
      this.longitude,
      this.startDateTime,
      this.endDateTime,
      this.estimatedCost,
      this.actualCost,
      this.currency,
      this.confirmationNumber,
      this.websiteUrl,
      this.phoneNumber,
      this.notes,
      this.isCompleted = false,
      this.isPriority = false,
      final List<String>? photoIds,
      final List<String>? tags,
      required this.createdAt,
      required this.updatedAt})
      : _photoIds = photoIds,
        _tags = tags;
  factory _Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  /// Unique identifier for the activity
  @override
  final String id;

  /// ID of the trip this activity belongs to
  @override
  final String tripId;

  /// ID of the user who created this activity
  @override
  final String userId;

  /// Activity title or name
  @override
  final String title;

  /// Detailed description of the activity
  @override
  final String? description;

  /// Category of the activity
  @override
  final ActivityCategory category;

  /// Location name (e.g., restaurant name, museum name)
  @override
  final String? locationName;

  /// Physical address
  @override
  final String? address;

  /// Latitude coordinate
  @override
  final double? latitude;

  /// Longitude coordinate
  @override
  final double? longitude;

  /// Scheduled start date and time
  @override
  final DateTime? startDateTime;

  /// Scheduled end date and time
  @override
  final DateTime? endDateTime;

  /// Estimated cost for this activity
  @override
  final double? estimatedCost;

  /// Actual cost (if completed)
  @override
  final double? actualCost;

  /// Currency code for costs (e.g., USD, EUR)
  @override
  final String? currency;

  /// Booking confirmation code or reference number
  @override
  final String? confirmationNumber;

  /// Website URL related to this activity
  @override
  final String? websiteUrl;

  /// Phone number for reservations
  @override
  final String? phoneNumber;

  /// Activity notes or special instructions
  @override
  final String? notes;

  /// Whether this activity is completed
  @override
  @JsonKey()
  final bool isCompleted;

  /// Whether this activity is a high priority
  @override
  @JsonKey()
  final dynamic isPriority;

  /// List of photo IDs associated with this activity
  final List<String>? _photoIds;

  /// List of photo IDs associated with this activity
  @override
  List<String>? get photoIds {
    final value = _photoIds;
    if (value == null) return null;
    if (_photoIds is EqualUnmodifiableListView) return _photoIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Tags for organizing and filtering activities
  final List<String>? _tags;

  /// Tags for organizing and filtering activities
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Date and time when the activity was created
  @override
  final DateTime createdAt;

  /// Date and time when the activity was last updated
  @override
  final DateTime updatedAt;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActivityCopyWith<_Activity> get copyWith =>
      __$ActivityCopyWithImpl<_Activity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ActivityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Activity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.startDateTime, startDateTime) ||
                other.startDateTime == startDateTime) &&
            (identical(other.endDateTime, endDateTime) ||
                other.endDateTime == endDateTime) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.actualCost, actualCost) ||
                other.actualCost == actualCost) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.confirmationNumber, confirmationNumber) ||
                other.confirmationNumber == confirmationNumber) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            const DeepCollectionEquality()
                .equals(other.isPriority, isPriority) &&
            const DeepCollectionEquality().equals(other._photoIds, _photoIds) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tripId,
        userId,
        title,
        description,
        category,
        locationName,
        address,
        latitude,
        longitude,
        startDateTime,
        endDateTime,
        estimatedCost,
        actualCost,
        currency,
        confirmationNumber,
        websiteUrl,
        phoneNumber,
        notes,
        isCompleted,
        const DeepCollectionEquality().hash(isPriority),
        const DeepCollectionEquality().hash(_photoIds),
        const DeepCollectionEquality().hash(_tags),
        createdAt,
        updatedAt
      ]);

  @override
  String toString() {
    return 'Activity(id: $id, tripId: $tripId, userId: $userId, title: $title, description: $description, category: $category, locationName: $locationName, address: $address, latitude: $latitude, longitude: $longitude, startDateTime: $startDateTime, endDateTime: $endDateTime, estimatedCost: $estimatedCost, actualCost: $actualCost, currency: $currency, confirmationNumber: $confirmationNumber, websiteUrl: $websiteUrl, phoneNumber: $phoneNumber, notes: $notes, isCompleted: $isCompleted, isPriority: $isPriority, photoIds: $photoIds, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$ActivityCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$ActivityCopyWith(_Activity value, $Res Function(_Activity) _then) =
      __$ActivityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String tripId,
      String userId,
      String title,
      String? description,
      ActivityCategory category,
      String? locationName,
      String? address,
      double? latitude,
      double? longitude,
      DateTime? startDateTime,
      DateTime? endDateTime,
      double? estimatedCost,
      double? actualCost,
      String? currency,
      String? confirmationNumber,
      String? websiteUrl,
      String? phoneNumber,
      String? notes,
      bool isCompleted,
      dynamic isPriority,
      List<String>? photoIds,
      List<String>? tags,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$ActivityCopyWithImpl<$Res> implements _$ActivityCopyWith<$Res> {
  __$ActivityCopyWithImpl(this._self, this._then);

  final _Activity _self;
  final $Res Function(_Activity) _then;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? category = null,
    Object? locationName = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? startDateTime = freezed,
    Object? endDateTime = freezed,
    Object? estimatedCost = freezed,
    Object? actualCost = freezed,
    Object? currency = freezed,
    Object? confirmationNumber = freezed,
    Object? websiteUrl = freezed,
    Object? phoneNumber = freezed,
    Object? notes = freezed,
    Object? isCompleted = null,
    Object? isPriority = freezed,
    Object? photoIds = freezed,
    Object? tags = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_Activity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as ActivityCategory,
      locationName: freezed == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      startDateTime: freezed == startDateTime
          ? _self.startDateTime
          : startDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDateTime: freezed == endDateTime
          ? _self.endDateTime
          : endDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      estimatedCost: freezed == estimatedCost
          ? _self.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as double?,
      actualCost: freezed == actualCost
          ? _self.actualCost
          : actualCost // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmationNumber: freezed == confirmationNumber
          ? _self.confirmationNumber
          : confirmationNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _self.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _self.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isPriority: freezed == isPriority
          ? _self.isPriority
          : isPriority // ignore: cast_nullable_to_non_nullable
              as dynamic,
      photoIds: freezed == photoIds
          ? _self._photoIds
          : photoIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
