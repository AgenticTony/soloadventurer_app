// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trusted_contacts_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TrustedContactsState {
  /// Loading indicator - always a field on State
  bool get isLoading => throw _privateConstructorUsedError;

  /// Whether an add operation is in progress
  bool get isAdding => throw _privateConstructorUsedError;

  /// Whether an update operation is in progress
  bool get isUpdating => throw _privateConstructorUsedError;

  /// Whether a remove operation is in progress
  bool get isRemoving => throw _privateConstructorUsedError;

  /// List of all trusted contacts
  List<TrustedContact> get contacts => throw _privateConstructorUsedError;

  /// Currently selected contact (for editing/viewing)
  TrustedContact? get selectedContact => throw _privateConstructorUsedError;

  /// Error message - always a field on State
  String? get error => throw _privateConstructorUsedError;

  /// Whether there are any trusted contacts (was a getter, now a field)
  bool get hasContacts => throw _privateConstructorUsedError;

  /// Whether operations are in progress (was a getter, now a field)
  bool get isProcessing => throw _privateConstructorUsedError;

  /// Count of contacts receiving emergency alerts (was a getter, now a field)
  int get emergencyContactsCount => throw _privateConstructorUsedError;

  /// Count of contacts with location sharing enabled (was a getter, now a field)
  int get locationSharingCount => throw _privateConstructorUsedError;

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrustedContactsStateCopyWith<TrustedContactsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrustedContactsStateCopyWith<$Res> {
  factory $TrustedContactsStateCopyWith(TrustedContactsState value,
          $Res Function(TrustedContactsState) then) =
      _$TrustedContactsStateCopyWithImpl<$Res, TrustedContactsState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isAdding,
      bool isUpdating,
      bool isRemoving,
      List<TrustedContact> contacts,
      TrustedContact? selectedContact,
      String? error,
      bool hasContacts,
      bool isProcessing,
      int emergencyContactsCount,
      int locationSharingCount});

  $TrustedContactCopyWith<$Res>? get selectedContact;
}

/// @nodoc
class _$TrustedContactsStateCopyWithImpl<$Res,
        $Val extends TrustedContactsState>
    implements $TrustedContactsStateCopyWith<$Res> {
  _$TrustedContactsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isAdding = null,
    Object? isUpdating = null,
    Object? isRemoving = null,
    Object? contacts = null,
    Object? selectedContact = freezed,
    Object? error = freezed,
    Object? hasContacts = null,
    Object? isProcessing = null,
    Object? emergencyContactsCount = null,
    Object? locationSharingCount = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isAdding: null == isAdding
          ? _value.isAdding
          : isAdding // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isRemoving: null == isRemoving
          ? _value.isRemoving
          : isRemoving // ignore: cast_nullable_to_non_nullable
              as bool,
      contacts: null == contacts
          ? _value.contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<TrustedContact>,
      selectedContact: freezed == selectedContact
          ? _value.selectedContact
          : selectedContact // ignore: cast_nullable_to_non_nullable
              as TrustedContact?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasContacts: null == hasContacts
          ? _value.hasContacts
          : hasContacts // ignore: cast_nullable_to_non_nullable
              as bool,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyContactsCount: null == emergencyContactsCount
          ? _value.emergencyContactsCount
          : emergencyContactsCount // ignore: cast_nullable_to_non_nullable
              as int,
      locationSharingCount: null == locationSharingCount
          ? _value.locationSharingCount
          : locationSharingCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrustedContactCopyWith<$Res>? get selectedContact {
    if (_value.selectedContact == null) {
      return null;
    }

    return $TrustedContactCopyWith<$Res>(_value.selectedContact!, (value) {
      return _then(_value.copyWith(selectedContact: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrustedContactsStateImplCopyWith<$Res>
    implements $TrustedContactsStateCopyWith<$Res> {
  factory _$$TrustedContactsStateImplCopyWith(_$TrustedContactsStateImpl value,
          $Res Function(_$TrustedContactsStateImpl) then) =
      __$$TrustedContactsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isAdding,
      bool isUpdating,
      bool isRemoving,
      List<TrustedContact> contacts,
      TrustedContact? selectedContact,
      String? error,
      bool hasContacts,
      bool isProcessing,
      int emergencyContactsCount,
      int locationSharingCount});

  @override
  $TrustedContactCopyWith<$Res>? get selectedContact;
}

/// @nodoc
class __$$TrustedContactsStateImplCopyWithImpl<$Res>
    extends _$TrustedContactsStateCopyWithImpl<$Res, _$TrustedContactsStateImpl>
    implements _$$TrustedContactsStateImplCopyWith<$Res> {
  __$$TrustedContactsStateImplCopyWithImpl(_$TrustedContactsStateImpl _value,
      $Res Function(_$TrustedContactsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isAdding = null,
    Object? isUpdating = null,
    Object? isRemoving = null,
    Object? contacts = null,
    Object? selectedContact = freezed,
    Object? error = freezed,
    Object? hasContacts = null,
    Object? isProcessing = null,
    Object? emergencyContactsCount = null,
    Object? locationSharingCount = null,
  }) {
    return _then(_$TrustedContactsStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isAdding: null == isAdding
          ? _value.isAdding
          : isAdding // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isRemoving: null == isRemoving
          ? _value.isRemoving
          : isRemoving // ignore: cast_nullable_to_non_nullable
              as bool,
      contacts: null == contacts
          ? _value._contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<TrustedContact>,
      selectedContact: freezed == selectedContact
          ? _value.selectedContact
          : selectedContact // ignore: cast_nullable_to_non_nullable
              as TrustedContact?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasContacts: null == hasContacts
          ? _value.hasContacts
          : hasContacts // ignore: cast_nullable_to_non_nullable
              as bool,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyContactsCount: null == emergencyContactsCount
          ? _value.emergencyContactsCount
          : emergencyContactsCount // ignore: cast_nullable_to_non_nullable
              as int,
      locationSharingCount: null == locationSharingCount
          ? _value.locationSharingCount
          : locationSharingCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$TrustedContactsStateImpl extends _TrustedContactsState {
  const _$TrustedContactsStateImpl(
      {this.isLoading = false,
      this.isAdding = false,
      this.isUpdating = false,
      this.isRemoving = false,
      final List<TrustedContact> contacts = const [],
      this.selectedContact,
      this.error,
      this.hasContacts = false,
      this.isProcessing = false,
      this.emergencyContactsCount = 0,
      this.locationSharingCount = 0})
      : _contacts = contacts,
        super._();

  /// Loading indicator - always a field on State
  @override
  @JsonKey()
  final bool isLoading;

  /// Whether an add operation is in progress
  @override
  @JsonKey()
  final bool isAdding;

  /// Whether an update operation is in progress
  @override
  @JsonKey()
  final bool isUpdating;

  /// Whether a remove operation is in progress
  @override
  @JsonKey()
  final bool isRemoving;

  /// List of all trusted contacts
  final List<TrustedContact> _contacts;

  /// List of all trusted contacts
  @override
  @JsonKey()
  List<TrustedContact> get contacts {
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contacts);
  }

  /// Currently selected contact (for editing/viewing)
  @override
  final TrustedContact? selectedContact;

  /// Error message - always a field on State
  @override
  final String? error;

  /// Whether there are any trusted contacts (was a getter, now a field)
  @override
  @JsonKey()
  final bool hasContacts;

  /// Whether operations are in progress (was a getter, now a field)
  @override
  @JsonKey()
  final bool isProcessing;

  /// Count of contacts receiving emergency alerts (was a getter, now a field)
  @override
  @JsonKey()
  final int emergencyContactsCount;

  /// Count of contacts with location sharing enabled (was a getter, now a field)
  @override
  @JsonKey()
  final int locationSharingCount;

  @override
  String toString() {
    return 'TrustedContactsState(isLoading: $isLoading, isAdding: $isAdding, isUpdating: $isUpdating, isRemoving: $isRemoving, contacts: $contacts, selectedContact: $selectedContact, error: $error, hasContacts: $hasContacts, isProcessing: $isProcessing, emergencyContactsCount: $emergencyContactsCount, locationSharingCount: $locationSharingCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrustedContactsStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isAdding, isAdding) ||
                other.isAdding == isAdding) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isRemoving, isRemoving) ||
                other.isRemoving == isRemoving) &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            (identical(other.selectedContact, selectedContact) ||
                other.selectedContact == selectedContact) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.hasContacts, hasContacts) ||
                other.hasContacts == hasContacts) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.emergencyContactsCount, emergencyContactsCount) ||
                other.emergencyContactsCount == emergencyContactsCount) &&
            (identical(other.locationSharingCount, locationSharingCount) ||
                other.locationSharingCount == locationSharingCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isAdding,
      isUpdating,
      isRemoving,
      const DeepCollectionEquality().hash(_contacts),
      selectedContact,
      error,
      hasContacts,
      isProcessing,
      emergencyContactsCount,
      locationSharingCount);

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrustedContactsStateImplCopyWith<_$TrustedContactsStateImpl>
      get copyWith =>
          __$$TrustedContactsStateImplCopyWithImpl<_$TrustedContactsStateImpl>(
              this, _$identity);
}

abstract class _TrustedContactsState extends TrustedContactsState {
  const factory _TrustedContactsState(
      {final bool isLoading,
      final bool isAdding,
      final bool isUpdating,
      final bool isRemoving,
      final List<TrustedContact> contacts,
      final TrustedContact? selectedContact,
      final String? error,
      final bool hasContacts,
      final bool isProcessing,
      final int emergencyContactsCount,
      final int locationSharingCount}) = _$TrustedContactsStateImpl;
  const _TrustedContactsState._() : super._();

  /// Loading indicator - always a field on State
  @override
  bool get isLoading;

  /// Whether an add operation is in progress
  @override
  bool get isAdding;

  /// Whether an update operation is in progress
  @override
  bool get isUpdating;

  /// Whether a remove operation is in progress
  @override
  bool get isRemoving;

  /// List of all trusted contacts
  @override
  List<TrustedContact> get contacts;

  /// Currently selected contact (for editing/viewing)
  @override
  TrustedContact? get selectedContact;

  /// Error message - always a field on State
  @override
  String? get error;

  /// Whether there are any trusted contacts (was a getter, now a field)
  @override
  bool get hasContacts;

  /// Whether operations are in progress (was a getter, now a field)
  @override
  bool get isProcessing;

  /// Count of contacts receiving emergency alerts (was a getter, now a field)
  @override
  int get emergencyContactsCount;

  /// Count of contacts with location sharing enabled (was a getter, now a field)
  @override
  int get locationSharingCount;

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrustedContactsStateImplCopyWith<_$TrustedContactsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
