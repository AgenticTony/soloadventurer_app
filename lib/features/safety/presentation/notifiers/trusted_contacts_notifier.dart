import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/add_trusted_contact.dart';
import '../../domain/usecases/remove_trusted_contact.dart';
import '../../domain/usecases/update_trusted_contact.dart';
import '../../domain/usecases/get_trusted_contacts.dart';
import '../../domain/entities/trusted_contact.dart';
import '../state/trusted_contacts_state.dart';

/// Notifier for managing trusted contacts state
/// Handles CRUD operations for trusted contacts
class TrustedContactsNotifier extends StateNotifier<TrustedContactsState> {
  final AddTrustedContactUseCase _addContact;
  final RemoveTrustedContactUseCase _removeContact;
  final UpdateTrustedContactUseCase _updateContact;
  final GetTrustedContactsUseCase _getContacts;

  TrustedContactsNotifier({
    required AddTrustedContactUseCase addContact,
    required RemoveTrustedContactUseCase removeContact,
    required UpdateTrustedContactUseCase updateContact,
    required GetTrustedContactsUseCase getContacts,
  })  : _addContact = addContact,
        _removeContact = removeContact,
        _updateContact = updateContact,
        _getContacts = getContacts,
        super(const TrustedContactsState());

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

    state = state.copyWith(isAdding: true, error: null);
    try {
      final newContact = await _addContact(contact);
      final updatedContacts = [...state.contacts, newContact];
      state = state.copyWith(
        isAdding: false,
        contacts: updatedContacts,
        selectedContact: newContact,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isAdding: false,
        error: e.toString(),
      );
    }
  }

  /// Update an existing trusted contact
  Future<void> updateContact(TrustedContact contact) async {
    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true, error: null);
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
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  /// Remove a trusted contact
  Future<void> removeContact(String contactId) async {
    if (state.isRemoving) return;

    state = state.copyWith(isRemoving: true, error: null);
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
      );
    } catch (e) {
      state = state.copyWith(
        isRemoving: false,
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
    state = state.copyWith(clearSelected: true);
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update location sharing for a contact
  Future<void> updateLocationSharing(
    String contactId,
    bool enabled,
  ) async {
    final contact = state.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contact not found'),
    );

    final updatedContact = contact.copyWith(
      locationSharingEnabled: enabled,
    );

    await updateContact(updatedContact);
  }

  /// Update emergency alerts for a contact
  Future<void> updateEmergencyAlerts(
    String contactId,
    bool enabled,
  ) async {
    final contact = state.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contact not found'),
    );

    final updatedContact = contact.copyWith(
      receivesEmergencyAlerts: enabled,
    );

    await updateContact(updatedContact);
  }

  /// Update check-in notifications for a contact
  Future<void> updateCheckInNotifications(
    String contactId,
    bool enabled,
  ) async {
    final contact = state.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contact not found'),
    );

    final updatedContact = contact.copyWith(
      receivesCheckIns: enabled,
    );

    await updateContact(updatedContact);
  }
}
