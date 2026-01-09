import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/providers/safety_usecase_providers.dart';

part 'trusted_contacts_notifier.g.dart';

/// Notifier for managing trusted contacts state
/// Handles CRUD operations for trusted contacts
@riverpod
class TrustedContactsNotifier extends _$TrustedContactsNotifier {
  /// Load all trusted contacts
  Future<void> loadContacts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await ref.read(getTrustedContactsUseCaseProvider)();
    });
  }

  /// Add a new trusted contact
  Future<void> addContact(TrustedContact contact) async {
    // Optimistically add the contact
    final previousState = state.value ?? [];
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final newContact = await ref.read(addTrustedContactUseCaseProvider)(contact);
      return [...previousState, newContact];
    });
  }

  /// Update an existing trusted contact
  Future<void> updateContact(TrustedContact contact) async {
    final previousState = state.value ?? [];
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final updatedContact = await ref.read(updateTrustedContactUseCaseProvider)(contact);
      return previousState.map((c) {
        return c.id == contact.id ? updatedContact : c;
      }).toList();
    });
  }

  /// Remove a trusted contact
  Future<void> removeContact(String contactId) async {
    final previousState = state.value ?? [];
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(removeTrustedContactUseCaseProvider)(contactId);
      return previousState.where((contact) => contact.id != contactId).toList();
    });
  }

  /// Update location sharing for a contact
  Future<void> updateLocationSharing(
    String contactId,
    bool enabled,
  ) async {
    final currentState = state.value;
    if (currentState == null) return;

    final contact = currentState.firstWhere(
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
    final currentState = state.value;
    if (currentState == null) return;

    final contact = currentState.firstWhere(
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
    final currentState = state.value;
    if (currentState == null) return;

    final contact = currentState.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw Exception('Contact not found'),
    );

    final updatedContact = contact.copyWith(
      receivesCheckIns: enabled,
    );

    await updateContact(updatedContact);
  }

  @override
  AsyncValue<List<TrustedContact>> build() {
    // Don't auto-initialize - let consumers explicitly call loadContacts()
    // This allows for better control over when initialization happens
    return const AsyncValue.data([]);
  }
}
