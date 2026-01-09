import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/trusted_contact.dart';

part 'trusted_contacts_state.freezed.dart';

/// Immutable state for Trusted Contacts.
///
/// Riverpod 2 Compliant:
/// - All fields must be final (enforced by freezed)
/// - NO getters - all derived values are fields
/// - isLoading and error are ALWAYS fields on state
/// - State is NEVER nullable
@freezed
class TrustedContactsState with _$TrustedContactsState {
  const TrustedContactsState._();

  const factory TrustedContactsState({
    /// Loading indicator - always a field on State
    @Default(false) bool isLoading,

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

    /// Error message - always a field on State
    String? error,

    /// Whether there are any trusted contacts (was a getter, now a field)
    @Default(false) bool hasContacts,

    /// Whether operations are in progress (was a getter, now a field)
    @Default(false) bool isProcessing,

    /// Count of contacts receiving emergency alerts (was a getter, now a field)
    @Default(0) int emergencyContactsCount,

    /// Count of contacts with location sharing enabled (was a getter, now a field)
    @Default(0) int locationSharingCount,
  }) = _TrustedContactsState;

  factory TrustedContactsState.initial() => const TrustedContactsState();
}
