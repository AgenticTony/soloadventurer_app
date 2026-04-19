import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/add_trusted_contact.dart';
import '../../domain/usecases/remove_trusted_contact.dart';
import '../../domain/usecases/update_trusted_contact.dart';
import '../../domain/usecases/get_trusted_contacts.dart';
import '../../domain/entities/trusted_contact.dart';
import '../state/trusted_contacts_state.dart';
import 'safety_providers.dart';

part 'trusted_contacts_provider.g.dart';

/// AsyncNotifier for managing trusted contacts state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields
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
  Future<TrustedContactsState> build() async => TrustedContactsState.initial();

  /// Helper to compute derived fields from a contact list
  TrustedContactsState _withDerivedFields(
    TrustedContactsState base,
    List<TrustedContact> contacts,
  ) {
    return base.copyWith(
      contacts: contacts,
      hasContacts: contacts.isNotEmpty,
      emergencyContactsCount:
          contacts.where((c) => c.receivesEmergencyAlerts).length,
      locationSharingCount:
          contacts.where((c) => c.locationSharingEnabled).length,
    );
  }

  /// Load all trusted contacts
  Future<void> loadContacts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final contacts = await _getContacts();
      return _withDerivedFields(
        state.value ?? TrustedContactsState.initial(),
        contacts,
      );
    });
  }

  /// Add a new trusted contact
  Future<void> addContact(TrustedContact contact) async {
    final current = state.value!;
    if (current.isAdding) return;

    state = AsyncData(current.copyWith(isAdding: true, isProcessing: true));
    state = await AsyncValue.guard(() async {
      final newContact = await _addContact(contact);
      final updatedContacts = [...current.contacts, newContact];
      return _withDerivedFields(
        current.copyWith(
          isAdding: false,
          isProcessing: false,
          selectedContact: newContact,
        ),
        updatedContacts,
      );
    });
  }

  /// Update an existing trusted contact
  Future<void> updateContact(TrustedContact contact) async {
    final current = state.value!;
    if (current.isUpdating) return;

    state = AsyncData(current.copyWith(isUpdating: true, isProcessing: true));
    state = await AsyncValue.guard(() async {
      final updatedContact = await _updateContact(contact);
      final updatedContacts = current.contacts.map((c) {
        return c.id == contact.id ? updatedContact : c;
      }).toList();
      return _withDerivedFields(
        current.copyWith(
          isUpdating: false,
          isProcessing: false,
          selectedContact: updatedContact,
        ),
        updatedContacts,
      );
    });
  }

  /// Remove a trusted contact
  Future<void> removeContact(String contactId) async {
    final current = state.value!;
    if (current.isRemoving) return;

    state = AsyncData(current.copyWith(isRemoving: true, isProcessing: true));
    state = await AsyncValue.guard(() async {
      await _removeContact(contactId);
      final updatedContacts =
          current.contacts.where((contact) => contact.id != contactId).toList();
      return _withDerivedFields(
        current.copyWith(
          isRemoving: false,
          isProcessing: false,
          selectedContact:
              current.selectedContact?.id == contactId ? null : current.selectedContact,
        ),
        updatedContacts,
      );
    });
  }

  /// Select a contact for viewing/editing
  void selectContact(TrustedContact? contact) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(selectedContact: contact));
    }
  }

  /// Clear the selected contact
  void clearSelection() {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(selectedContact: null));
    }
  }

  /// Update location sharing for a contact
  Future<void> updateLocationSharing(String contactId, bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final contact = current.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contact not found'),
    );

    final updatedContact = contact.copyWith(locationSharingEnabled: enabled);
    await updateContact(updatedContact);
  }

  /// Update emergency alerts for a contact
  Future<void> updateEmergencyAlerts(String contactId, bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final contact = current.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contact not found'),
    );

    final updatedContact = contact.copyWith(receivesEmergencyAlerts: enabled);
    await updateContact(updatedContact);
  }

  /// Update check-in notifications for a contact
  Future<void> updateCheckInNotifications(
      String contactId, bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final contact = current.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contact not found'),
    );

    final updatedContact = contact.copyWith(receivesCheckIns: enabled);
    await updateContact(updatedContact);
  }
}
