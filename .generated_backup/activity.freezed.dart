// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Activity _$ActivityFromJson(Map<String, dynamic> json) {
  return _Activity.fromJson(json);
}

/// @nodoc
mixin _$Activity {
  /// Unique identifier for the activity
  String get id => throw _privateConstructorUsedError;

  /// ID of the trip this activity belongs to
  String get tripId => throw _privateConstructorUsedError;

  /// ID of the user who created this activity
  String get userId => throw _privateConstructorUsedError;

  /// Activity title or name
  String get title => throw _privateConstructorUsedError;

  /// Detailed description of the activity
  String? get description => throw _privateConstructorUsedError;

  /// Category of the activity
  ActivityCategory get category => throw _privateConstructorUsedError;

  /// Location name (e.g., restaurant name, museum name)
  String? get locationName => throw _privateConstructorUsedError;

  /// Physical address
  String? get address => throw _privateConstructorUsedError;

  /// Latitude coordinate
  double? get latitude => throw _privateConstructorUsedError;

  /// Longitude coordinate
  double? get longitude => throw _privateConstructorUsedError;

  /// Scheduled start date and time
  DateTime? get startDateTime => throw _privateConstructorUsedError;

  /// Scheduled end date and time
  DateTime? get endDateTime => throw _privateConstructorUsedError;

  /// Estimated cost for this activity
  double? get estimatedCost => throw _privateConstructorUsedError;

  /// Actual cost (if completed)
  double? get actualCost => throw _privateConstructorUsedError;

  /// Currency code for costs (e.g., USD, EUR)
  String? get currency => throw _privateConstructorUsedError;

  /// Booking confirmation code or reference number
  String? get confirmationNumber => throw _privateConstructorUsedError;

  /// Website URL related to this activity
  String? get websiteUrl => throw _privateConstructorUsedError;

  /// Phone number for reservations
  String? get phoneNumber => throw _privateConstructorUsedError;

  /// Activity notes or special instructions
  String? get notes => throw _privateConstructorUsedError;

  /// Whether this activity is completed
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Whether this activity is a high priority
  dynamic get isPriority => throw _privateConstructorUsedError;

  /// List of photo IDs associated with this activity
  List<String>? get photoIds => throw _privateConstructorUsedError;

  /// Tags for organizing and filtering activities
  List<String>? get tags => throw _privateConstructorUsedError;

  /// Date and time when the activity was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Date and time when the activity was last updated
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Activity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityCopyWith<Activity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityCopyWith<$Res> {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) then) =
      _$ActivityCopyWithImpl<$Res, Activity>;
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
class _$ActivityCopyWithImpl<$Res, $Val extends Activity>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ActivityCategory,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      startDateTime: freezed == startDateTime
          ? _value.startDateTime
          : startDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDateTime: freezed == endDateTime
          ? _value.endDateTime
          : endDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      estimatedCost: freezed == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as double?,
      actualCost: freezed == actualCost
          ? _value.actualCost
          : actualCost // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmationNumber: freezed == confirmationNumber
          ? _value.confirmationNumber
          : confirmationNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isPriority: freezed == isPriority
          ? _value.isPriority
          : isPriority // ignore: cast_nullable_to_non_nullable
              as dynamic,
      photoIds: freezed == photoIds
          ? _value.photoIds
          : photoIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityImplCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$$ActivityImplCopyWith(
          _$ActivityImpl value, $Res Function(_$ActivityImpl) then) =
      __$$ActivityImplCopyWithImpl<$Res>;
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
class __$$ActivityImplCopyWithImpl<$Res>
    extends _$ActivityCopyWithImpl<$Res, _$ActivityImpl>
    implements _$$ActivityImplCopyWith<$Res> {
  __$$ActivityImplCopyWithImpl(
      _$ActivityImpl _value, $Res Function(_$ActivityImpl) _then)
      : super(_value, _then);

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
    return _then(_$ActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ActivityCategory,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      startDateTime: freezed == startDateTime
          ? _value.startDateTime
          : startDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDateTime: freezed == endDateTime
          ? _value.endDateTime
          : endDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      estimatedCost: freezed == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as double?,
      actualCost: freezed == actualCost
          ? _value.actualCost
          : actualCost // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmationNumber: freezed == confirmationNumber
          ? _value.confirmationNumber
          : confirmationNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isPriority: freezed == isPriority ? _value.isPriority! : isPriority,
      photoIds: freezed == photoIds
          ? _value._photoIds
          : photoIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityImpl extends _Activity {
  const _$ActivityImpl(
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
        _tags = tags,
        super._();

  factory _$ActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityImplFromJson(json);

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

  @override
  String toString() {
    return 'Activity(id: $id, tripId: $tripId, userId: $userId, title: $title, description: $description, category: $category, locationName: $locationName, address: $address, latitude: $latitude, longitude: $longitude, startDateTime: $startDateTime, endDateTime: $endDateTime, estimatedCost: $estimatedCost, actualCost: $actualCost, currency: $currency, confirmationNumber: $confirmationNumber, websiteUrl: $websiteUrl, phoneNumber: $phoneNumber, notes: $notes, isCompleted: $isCompleted, isPriority: $isPriority, photoIds: $photoIds, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityImpl &&
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

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityImplCopyWith<_$ActivityImpl> get copyWith =>
      __$$ActivityImplCopyWithImpl<_$ActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityImplToJson(
      this,
    );
  }
}

abstract class _Activity extends Activity {
  const factory _Activity(
      {required final String id,
      required final String tripId,
      required final String userId,
      required final String title,
      final String? description,
      required final ActivityCategory category,
      final String? locationName,
      final String? address,
      final double? latitude,
      final double? longitude,
      final DateTime? startDateTime,
      final DateTime? endDateTime,
      final double? estimatedCost,
      final double? actualCost,
      final String? currency,
      final String? confirmationNumber,
      final String? websiteUrl,
      final String? phoneNumber,
      final String? notes,
      final bool isCompleted,
      final dynamic isPriority,
      final List<String>? photoIds,
      final List<String>? tags,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$ActivityImpl;
  const _Activity._() : super._();

  factory _Activity.fromJson(Map<String, dynamic> json) =
      _$ActivityImpl.fromJson;

  /// Unique identifier for the activity
  @override
  String get id;

  /// ID of the trip this activity belongs to
  @override
  String get tripId;

  /// ID of the user who created this activity
  @override
  String get userId;

  /// Activity title or name
  @override
  String get title;

  /// Detailed description of the activity
  @override
  String? get description;

  /// Category of the activity
  @override
  ActivityCategory get category;

  /// Location name (e.g., restaurant name, museum name)
  @override
  String? get locationName;

  /// Physical address
  @override
  String? get address;

  /// Latitude coordinate
  @override
  double? get latitude;

  /// Longitude coordinate
  @override
  double? get longitude;

  /// Scheduled start date and time
  @override
  DateTime? get startDateTime;

  /// Scheduled end date and time
  @override
  DateTime? get endDateTime;

  /// Estimated cost for this activity
  @override
  double? get estimatedCost;

  /// Actual cost (if completed)
  @override
  double? get actualCost;

  /// Currency code for costs (e.g., USD, EUR)
  @override
  String? get currency;

  /// Booking confirmation code or reference number
  @override
  String? get confirmationNumber;

  /// Website URL related to this activity
  @override
  String? get websiteUrl;

  /// Phone number for reservations
  @override
  String? get phoneNumber;

  /// Activity notes or special instructions
  @override
  String? get notes;

  /// Whether this activity is completed
  @override
  bool get isCompleted;

  /// Whether this activity is a high priority
  @override
  dynamic get isPriority;

  /// List of photo IDs associated with this activity
  @override
  List<String>? get photoIds;

  /// Tags for organizing and filtering activities
  @override
  List<String>? get tags;

  /// Date and time when the activity was created
  @override
  DateTime get createdAt;

  /// Date and time when the activity was last updated
  @override
  DateTime get updatedAt;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityImplCopyWith<_$ActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
