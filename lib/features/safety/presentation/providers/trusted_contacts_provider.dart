import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/add_trusted_contact.dart';
import '../../domain/usecases/remove_trusted_contact.dart';
import '../../domain/usecases/update_trusted_contact.dart';
import '../../domain/usecases/get_trusted_contacts.dart';
import '../../domain/entities/trusted_contact.dart';
import '../state/trusted_contacts_state.dart';
import 'safety_providers.dart';

part 'trusted_contacts_provider.g.dart';

/// Notifier for managing trusted contacts state
/// Handles CRUD operations for trusted contacts
///
/// Riverpod 2 Compliant:
/// - Uses AutoDisposeNotifier (auto-disposes when unused)
/// - NO getters in state - all derived values are fields
/// - UI reads STATE only via ref.watch()
/// - UI calls methods via ref.read(provider.notifier)
@riverpod
class TrustedContacts extends _$TrustedContacts {
  AddTrustedContactUseCase get _addContact =>
      ref.watch(addTrustedContactUseCaseProvider);
  RemoveTrustedContactUseCase get _removeContact =>
      ref.watch(removeTrustedContactUseCaseProvider);
  UpdateTrustedContactUseCase get _updateContact =>
      ref.watch(updateTrustedContactUseCaseProvider);
  GetTrustedContactsUseCase get _getContacts =>
      ref.watch(getTrustedContactsUseCaseProvider);

  @override
  TrustedContactsState build() => TrustedContactsState.initial();

  /// Load all trusted contacts
  Future<void> loadContacts() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final contacts = await _getContacts();
      state = state.copyWith(
        isLoading: false,
        contacts: contacts,
        error: null,
        // Update all derived fields
        hasContacts: contacts.isNotEmpty,
        isProcessing: false,
        emergencyContactsCount:
            contacts.where((c) => c.receivesEmergencyAlerts).length,
        locationSharingCount:
            contacts.where((c) => c.locationSharingEnabled).length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Add a new trusted contact
  Future<void> addContact(TrustedContact contact) async {
    if (state.isAdding) return;

    state = state.copyWith(isAdding: true, error: null, isProcessing: true);
    try {
      final newContact = await _addContact(contact);
      final updatedContacts = [...state.contacts, newContact];
      state = state.copyWith(
        isAdding: false,
        contacts: updatedContacts,
        selectedContact: newContact,
        error: null,
        // Update all derived fields
        hasContacts: true,
        isProcessing: false,
        emergencyContactsCount:
            updatedContacts.where((c) => c.receivesEmergencyAlerts).length,
        locationSharingCount:
            updatedContacts.where((c) => c.locationSharingEnabled).length,
      );
    } catch (e) {
      state = state.copyWith(
        isAdding: false,
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Update an existing trusted contact
  Future<void> updateContact(TrustedContact contact) async {
    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true, error: null, isProcessing: true);
    try {
      final updatedContact = await _updateContact(contact);
      final updatedContacts = state.contacts.map((c) {
        return c.id == contact.id ? updatedContact : c;
      }).toList();
      state = state.copyWith(
        isUpdating: false,
        contacts: updatedContacts,
        selectedContact: updatedContact,
        error: null,
        // Update all derived fields
        isProcessing: false,
        emergencyContactsCount:
            updatedContacts.where((c) => c.receivesEmergencyAlerts).length,
        locationSharingCount:
            updatedContacts.where((c) => c.locationSharingEnabled).length,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Remove a trusted contact
  Future<void> removeContact(String contactId) async {
    if (state.isRemoving) return;

    state = state.copyWith(isRemoving: true, error: null, isProcessing: true);
    try {
      await _removeContact(contactId);
      final updatedContacts =
          state.contacts.where((contact) => contact.id != contactId).toList();
      state = state.copyWith(
        isRemoving: false,
        contacts: updatedContacts,
        selectedContact: state.selectedContact?.id == contactId
            ? null
            : state.selectedContact,
        error: null,
        // Update all derived fields
        hasContacts: updatedContacts.isNotEmpty,
        isProcessing: false,
        emergencyContactsCount:
            updatedContacts.where((c) => c.receivesEmergencyAlerts).length,
        locationSharingCount:
            updatedContacts.where((c) => c.locationSharingEnabled).length,
      );
    } catch (e) {
      state = state.copyWith(
        isRemoving: false,
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Select a contact for viewing/editing
  void selectContact(TrustedContact? contact) {
    state = state.copyWith(selectedContact: contact);
  }

  /// Clear the selected contact
  void clearSelection() {
    state = state.copyWith(selectedContact: null);
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update location sharing for a contact
  Future<void> updateLocationSharing(String contactId, bool enabled) async {
    final contact = state.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contact not found'),
    );

    final updatedContact = contact.copyWith(locationSharingEnabled: enabled);
    await updateContact(updatedContact);
  }

  /// Update emergency alerts for a contact
  Future<void> updateEmergencyAlerts(String contactId, bool enabled) async {
    final contact = state.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contact not found'),
    );

    final updatedContact = contact.copyWith(receivesEmergencyAlerts: enabled);
    await updateContact(updatedContact);
  }

  /// Update check-in notifications for a contact
  Future<void> updateCheckInNotifications(
      String contactId, bool enabled) async {
    final contact = state.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contact not found'),
    );

    final updatedContact = contact.copyWith(receivesCheckIns: enabled);
    await updateContact(updatedContact);
  }
}
