import 'package:equatable/equatable.dart';
import '../../domain/entities/trusted_contact.dart';

/// State for trusted contacts management
/// Manages the list of trusted contacts and CRUD operations
class TrustedContactsState extends Equatable {
  /// Whether contacts are currently loading
  final bool isLoading;

  /// Whether an add operation is in progress
  final bool isAdding;

  /// Whether an update operation is in progress
  final bool isUpdating;

  /// Whether a remove operation is in progress
  final bool isRemoving;

  /// List of all trusted contacts
  final List<TrustedContact> contacts;

  /// Currently selected contact (for editing/viewing)
  final TrustedContact? selectedContact;

  /// Error message if any operation failed
  final String? error;

  /// Whether there are any trusted contacts
  bool get hasContacts => contacts.isNotEmpty;

  /// Whether operations are in progress
  bool get isProcessing => isAdding || isUpdating || isRemoving;

  /// Count of contacts receiving emergency alerts
  int get emergencyContactsCount => contacts
      .where((contact) => contact.receivesEmergencyAlerts)
      .length;

  /// Count of contacts with location sharing enabled
  int get locationSharingCount => contacts
      .where((contact) => contact.locationSharingEnabled)
      .length;

  const TrustedContactsState({
    this.isLoading = false,
    this.isAdding = false,
    this.isUpdating = false,
    this.isRemoving = false,
    this.contacts = const [],
    this.selectedContact,
    this.error,
  });

  /// Creates a copy of this state with the given fields replaced
  TrustedContactsState copyWith({
    bool? isLoading,
    bool? isAdding,
    bool? isUpdating,
    bool? isRemoving,
    List<TrustedContact>? contacts,
    TrustedContact? selectedContact,
    String? error,
    bool clearSelected = false,
  }) {
    return TrustedContactsState(
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      isUpdating: isUpdating ?? this.isUpdating,
      isRemoving: isRemoving ?? this.isRemoving,
      contacts: contacts ?? this.contacts,
      selectedContact: clearSelected ? null : (selectedContact ?? this.selectedContact),
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isAdding,
        isUpdating,
        isRemoving,
        contacts,
        selectedContact,
        error,
      ];
}
