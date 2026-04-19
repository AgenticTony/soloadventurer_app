import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/trusted_contact.dart';

part 'trusted_contacts_state.freezed.dart';

/// Immutable state for Trusted Contacts.
///
/// Riverpod 3.0 Compliant:
/// - All fields must be final (enforced by freezed)
/// - Uses sealed class as required by Freezed 3.2.x with Dart 3.10
/// - Loading/error handled by AsyncNotifier/AsyncValue, NOT state fields
@freezed
sealed class TrustedContactsState with _$TrustedContactsState {
  const TrustedContactsState._();
  const factory TrustedContactsState({
    /// Whether an add operation is in progress
    @Default(false) bool isAdding,

    /// Whether an update operation is in progress
    @Default(false) bool isUpdating,

    /// Whether a remove operation is in progress
    @Default(false) bool isRemoving,

    /// List of all trusted contacts
    @Default([]) List<TrustedContact> contacts,

    /// Currently selected contact (for editing/viewing)
    TrustedContact? selectedContact,

    /// Whether there are any trusted contacts
    @Default(false) bool hasContacts,

    /// Whether operations are in progress
    @Default(false) bool isProcessing,

    /// Count of contacts receiving emergency alerts
    @Default(0) int emergencyContactsCount,

    /// Count of contacts with location sharing enabled
    @Default(0) int locationSharingCount,
  }) = _TrustedContactsState;

  factory TrustedContactsState.initial() => const TrustedContactsState();
}
