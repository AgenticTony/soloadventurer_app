// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trusted_contacts_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrustedContactsState {
  /// Whether an add operation is in progress
  bool get isAdding;

  /// Whether an update operation is in progress
  bool get isUpdating;

  /// Whether a remove operation is in progress
  bool get isRemoving;

  /// List of all trusted contacts
  List<TrustedContact> get contacts;

  /// Currently selected contact (for editing/viewing)
  TrustedContact? get selectedContact;

  /// Whether there are any trusted contacts
  bool get hasContacts;

  /// Whether operations are in progress
  bool get isProcessing;

  /// Count of contacts receiving emergency alerts
  int get emergencyContactsCount;

  /// Count of contacts with location sharing enabled
  int get locationSharingCount;

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TrustedContactsStateCopyWith<TrustedContactsState> get copyWith =>
      _$TrustedContactsStateCopyWithImpl<TrustedContactsState>(
          this as TrustedContactsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TrustedContactsState &&
            (identical(other.isAdding, isAdding) ||
                other.isAdding == isAdding) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isRemoving, isRemoving) ||
                other.isRemoving == isRemoving) &&
            const DeepCollectionEquality().equals(other.contacts, contacts) &&
            (identical(other.selectedContact, selectedContact) ||
                other.selectedContact == selectedContact) &&
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
      isAdding,
      isUpdating,
      isRemoving,
      const DeepCollectionEquality().hash(contacts),
      selectedContact,
      hasContacts,
      isProcessing,
      emergencyContactsCount,
      locationSharingCount);

  @override
  String toString() {
    return 'TrustedContactsState(isAdding: $isAdding, isUpdating: $isUpdating, isRemoving: $isRemoving, contacts: $contacts, selectedContact: $selectedContact, hasContacts: $hasContacts, isProcessing: $isProcessing, emergencyContactsCount: $emergencyContactsCount, locationSharingCount: $locationSharingCount)';
  }
}

/// @nodoc
abstract mixin class $TrustedContactsStateCopyWith<$Res> {
  factory $TrustedContactsStateCopyWith(TrustedContactsState value,
          $Res Function(TrustedContactsState) _then) =
      _$TrustedContactsStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isAdding,
      bool isUpdating,
      bool isRemoving,
      List<TrustedContact> contacts,
      TrustedContact? selectedContact,
      bool hasContacts,
      bool isProcessing,
      int emergencyContactsCount,
      int locationSharingCount});

  $TrustedContactCopyWith<$Res>? get selectedContact;
}

/// @nodoc
class _$TrustedContactsStateCopyWithImpl<$Res>
    implements $TrustedContactsStateCopyWith<$Res> {
  _$TrustedContactsStateCopyWithImpl(this._self, this._then);

  final TrustedContactsState _self;
  final $Res Function(TrustedContactsState) _then;

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isAdding = null,
    Object? isUpdating = null,
    Object? isRemoving = null,
    Object? contacts = null,
    Object? selectedContact = freezed,
    Object? hasContacts = null,
    Object? isProcessing = null,
    Object? emergencyContactsCount = null,
    Object? locationSharingCount = null,
  }) {
    return _then(_self.copyWith(
      isAdding: null == isAdding
          ? _self.isAdding
          : isAdding // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isRemoving: null == isRemoving
          ? _self.isRemoving
          : isRemoving // ignore: cast_nullable_to_non_nullable
              as bool,
      contacts: null == contacts
          ? _self.contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<TrustedContact>,
      selectedContact: freezed == selectedContact
          ? _self.selectedContact
          : selectedContact // ignore: cast_nullable_to_non_nullable
              as TrustedContact?,
      hasContacts: null == hasContacts
          ? _self.hasContacts
          : hasContacts // ignore: cast_nullable_to_non_nullable
              as bool,
      isProcessing: null == isProcessing
          ? _self.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyContactsCount: null == emergencyContactsCount
          ? _self.emergencyContactsCount
          : emergencyContactsCount // ignore: cast_nullable_to_non_nullable
              as int,
      locationSharingCount: null == locationSharingCount
          ? _self.locationSharingCount
          : locationSharingCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrustedContactCopyWith<$Res>? get selectedContact {
    if (_self.selectedContact == null) {
      return null;
    }

    return $TrustedContactCopyWith<$Res>(_self.selectedContact!, (value) {
      return _then(_self.copyWith(selectedContact: value));
    });
  }
}

/// Adds pattern-matching-related methods to [TrustedContactsState].
extension TrustedContactsStatePatterns on TrustedContactsState {
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
    TResult Function(_TrustedContactsState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TrustedContactsState() when $default != null:
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
    TResult Function(_TrustedContactsState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrustedContactsState():
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
    TResult? Function(_TrustedContactsState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrustedContactsState() when $default != null:
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
            bool isAdding,
            bool isUpdating,
            bool isRemoving,
            List<TrustedContact> contacts,
            TrustedContact? selectedContact,
            bool hasContacts,
            bool isProcessing,
            int emergencyContactsCount,
            int locationSharingCount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TrustedContactsState() when $default != null:
        return $default(
            _that.isAdding,
            _that.isUpdating,
            _that.isRemoving,
            _that.contacts,
            _that.selectedContact,
            _that.hasContacts,
            _that.isProcessing,
            _that.emergencyContactsCount,
            _that.locationSharingCount);
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
            bool isAdding,
            bool isUpdating,
            bool isRemoving,
            List<TrustedContact> contacts,
            TrustedContact? selectedContact,
            bool hasContacts,
            bool isProcessing,
            int emergencyContactsCount,
            int locationSharingCount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrustedContactsState():
        return $default(
            _that.isAdding,
            _that.isUpdating,
            _that.isRemoving,
            _that.contacts,
            _that.selectedContact,
            _that.hasContacts,
            _that.isProcessing,
            _that.emergencyContactsCount,
            _that.locationSharingCount);
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
            bool isAdding,
            bool isUpdating,
            bool isRemoving,
            List<TrustedContact> contacts,
            TrustedContact? selectedContact,
            bool hasContacts,
            bool isProcessing,
            int emergencyContactsCount,
            int locationSharingCount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrustedContactsState() when $default != null:
        return $default(
            _that.isAdding,
            _that.isUpdating,
            _that.isRemoving,
            _that.contacts,
            _that.selectedContact,
            _that.hasContacts,
            _that.isProcessing,
            _that.emergencyContactsCount,
            _that.locationSharingCount);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TrustedContactsState extends TrustedContactsState {
  const _TrustedContactsState(
      {this.isAdding = false,
      this.isUpdating = false,
      this.isRemoving = false,
      final List<TrustedContact> contacts = const [],
      this.selectedContact,
      this.hasContacts = false,
      this.isProcessing = false,
      this.emergencyContactsCount = 0,
      this.locationSharingCount = 0})
      : _contacts = contacts,
        super._();

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

  /// Whether there are any trusted contacts
  @override
  @JsonKey()
  final bool hasContacts;

  /// Whether operations are in progress
  @override
  @JsonKey()
  final bool isProcessing;

  /// Count of contacts receiving emergency alerts
  @override
  @JsonKey()
  final int emergencyContactsCount;

  /// Count of contacts with location sharing enabled
  @override
  @JsonKey()
  final int locationSharingCount;

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TrustedContactsStateCopyWith<_TrustedContactsState> get copyWith =>
      __$TrustedContactsStateCopyWithImpl<_TrustedContactsState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TrustedContactsState &&
            (identical(other.isAdding, isAdding) ||
                other.isAdding == isAdding) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isRemoving, isRemoving) ||
                other.isRemoving == isRemoving) &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            (identical(other.selectedContact, selectedContact) ||
                other.selectedContact == selectedContact) &&
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
      isAdding,
      isUpdating,
      isRemoving,
      const DeepCollectionEquality().hash(_contacts),
      selectedContact,
      hasContacts,
      isProcessing,
      emergencyContactsCount,
      locationSharingCount);

  @override
  String toString() {
    return 'TrustedContactsState(isAdding: $isAdding, isUpdating: $isUpdating, isRemoving: $isRemoving, contacts: $contacts, selectedContact: $selectedContact, hasContacts: $hasContacts, isProcessing: $isProcessing, emergencyContactsCount: $emergencyContactsCount, locationSharingCount: $locationSharingCount)';
  }
}

/// @nodoc
abstract mixin class _$TrustedContactsStateCopyWith<$Res>
    implements $TrustedContactsStateCopyWith<$Res> {
  factory _$TrustedContactsStateCopyWith(_TrustedContactsState value,
          $Res Function(_TrustedContactsState) _then) =
      __$TrustedContactsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isAdding,
      bool isUpdating,
      bool isRemoving,
      List<TrustedContact> contacts,
      TrustedContact? selectedContact,
      bool hasContacts,
      bool isProcessing,
      int emergencyContactsCount,
      int locationSharingCount});

  @override
  $TrustedContactCopyWith<$Res>? get selectedContact;
}

/// @nodoc
class __$TrustedContactsStateCopyWithImpl<$Res>
    implements _$TrustedContactsStateCopyWith<$Res> {
  __$TrustedContactsStateCopyWithImpl(this._self, this._then);

  final _TrustedContactsState _self;
  final $Res Function(_TrustedContactsState) _then;

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isAdding = null,
    Object? isUpdating = null,
    Object? isRemoving = null,
    Object? contacts = null,
    Object? selectedContact = freezed,
    Object? hasContacts = null,
    Object? isProcessing = null,
    Object? emergencyContactsCount = null,
    Object? locationSharingCount = null,
  }) {
    return _then(_TrustedContactsState(
      isAdding: null == isAdding
          ? _self.isAdding
          : isAdding // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isRemoving: null == isRemoving
          ? _self.isRemoving
          : isRemoving // ignore: cast_nullable_to_non_nullable
              as bool,
      contacts: null == contacts
          ? _self._contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<TrustedContact>,
      selectedContact: freezed == selectedContact
          ? _self.selectedContact
          : selectedContact // ignore: cast_nullable_to_non_nullable
              as TrustedContact?,
      hasContacts: null == hasContacts
          ? _self.hasContacts
          : hasContacts // ignore: cast_nullable_to_non_nullable
              as bool,
      isProcessing: null == isProcessing
          ? _self.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyContactsCount: null == emergencyContactsCount
          ? _self.emergencyContactsCount
          : emergencyContactsCount // ignore: cast_nullable_to_non_nullable
              as int,
      locationSharingCount: null == locationSharingCount
          ? _self.locationSharingCount
          : locationSharingCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of TrustedContactsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrustedContactCopyWith<$Res>? get selectedContact {
    if (_self.selectedContact == null) {
      return null;
    }

    return $TrustedContactCopyWith<$Res>(_self.selectedContact!, (value) {
      return _then(_self.copyWith(selectedContact: value));
    });
  }
}

// dart format on
