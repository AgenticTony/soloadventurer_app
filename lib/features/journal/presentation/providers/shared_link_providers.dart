import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/journal/data/services/shared_link_service_impl.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';
import 'package:soloadventurer/features/journal/domain/services/shared_link_service.dart';

// Generated file
part 'shared_link_providers.g.dart';

// ============================================================================
// DEPENDENCY INJECTION PROVIDERS
// ============================================================================

/// Provider for SharedLinkService
@riverpod
SharedLinkService sharedLinkService(Ref ref) {
  final client = Supabase.instance.client;
  return SharedLinkServiceImpl(client: client);
}

// ============================================================================
// STATE MODELS
// ============================================================================

/// State for shared link operations
class SharedLinkState {
  /// Current shared links
  final List<SharedLink> links;

  /// Currently selected shared link
  final SharedLink? selectedLink;

  /// Whether data is loading
  final bool isLoading;

  /// Whether an operation is in progress
  final bool isBusy;

  /// Error message if any
  final String? errorMessage;

  /// Timestamp of last update
  final DateTime? lastUpdated;

  const SharedLinkState({
    this.links = const [],
    this.selectedLink,
    this.isLoading = false,
    this.isBusy = false,
    this.errorMessage,
    this.lastUpdated,
  });

  SharedLinkState copyWith({
    List<SharedLink>? links,
    SharedLink? selectedLink,
    bool? isLoading,
    bool? isBusy,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearSelected = false,
  }) {
    return SharedLinkState(
      links: links ?? this.links,
      selectedLink: clearSelected ? null : (selectedLink ?? this.selectedLink),
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// State for creating a shared link
class CreateSharedLinkState {
  /// Whether creation is in progress
  final bool isCreating;

  /// Error message if creation failed
  final String? errorMessage;

  /// The created link (if successful)
  final SharedLink? createdLink;

  const CreateSharedLinkState({
    this.isCreating = false,
    this.errorMessage,
    this.createdLink,
  });

  CreateSharedLinkState copyWith({
    bool? isCreating,
    String? errorMessage,
    SharedLink? createdLink,
    bool clearError = false,
    bool clearLink = false,
  }) {
    return CreateSharedLinkState(
      isCreating: isCreating ?? this.isCreating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdLink: clearLink ? null : (createdLink ?? this.createdLink),
    );
  }
}

/// State for validating shared link access
class ValidateLinkState {
  /// Whether validation is in progress
  final bool isValidating;

  /// The validation result
  final SharedLinkAccessResult? result;

  /// Error message if validation failed
  final String? errorMessage;

  const ValidateLinkState({
    this.isValidating = false,
    this.result,
    this.errorMessage,
  });

  ValidateLinkState copyWith({
    bool? isValidating,
    SharedLinkAccessResult? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return ValidateLinkState(
      isValidating: isValidating ?? this.isValidating,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ============================================================================
// NOTIFIERS
// ============================================================================

/// Notifier for managing shared links
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
@riverpod
class SharedLinks extends _$SharedLinks {
  @override
  SharedLinkState build() {
    // Load links automatically on build
    loadLinks();
    return const SharedLinkState();
  }

  /// Load all shared links for the current user
  Future<void> loadLinks() async {
    final service = ref.read(sharedLinkServiceProvider);
    state = state.copyWith(isLoading: true, clearSelected: true);

    try {
      final links = await service.getUserSharedLinks();
      state = state.copyWith(
        links: links,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load shared links for a specific trip
  Future<void> loadLinksForTrip(String tripId) async {
    final service = ref.read(sharedLinkServiceProvider);
    state = state.copyWith(isLoading: true, clearSelected: true);

    try {
      final links = await service.getSharedLinksForTrip(tripId);
      state = state.copyWith(
        links: links,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Select a shared link
  void selectLink(SharedLink link) {
    state = state.copyWith(selectedLink: link);
  }

  /// Clear the selected link
  void clearSelection() {
    state = state.copyWith(clearSelected: true);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: '');
  }

  /// Refresh the current list
  Future<void> refresh() async {
    await loadLinks();
  }
}

/// Notifier for creating shared links
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
@riverpod
class CreateSharedLink extends _$CreateSharedLink {
  @override
  CreateSharedLinkState build() {
    return const CreateSharedLinkState();
  }

  /// Create a new shared link
  Future<void> createLink(CreateSharedLinkConfig config) async {
    final service = ref.read(sharedLinkServiceProvider);
    state = state.copyWith(isCreating: true, clearError: true, clearLink: true);

    try {
      final link = await service.createSharedLink(config);
      state = state.copyWith(
        isCreating: false,
        createdLink: link,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset the state
  void reset() {
    state = const CreateSharedLinkState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Notifier for validating shared link access
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
@riverpod
class ValidateLink extends _$ValidateLink {
  @override
  ValidateLinkState build() {
    return const ValidateLinkState();
  }

  /// Validate access to a shared link
  Future<void> validateAccess({
    required String slug,
    String? password,
  }) async {
    final service = ref.read(sharedLinkServiceProvider);
    state = state.copyWith(
      isValidating: true,
      clearError: true,
      clearResult: true,
    );

    try {
      final result = await service.validateAccess(
        slug: slug,
        password: password,
      );

      // Record view if access is granted
      if (result.isAccessible) {
        await service.recordView(slug);
      }

      state = state.copyWith(
        isValidating: false,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        isValidating: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset the state
  void reset() {
    state = const ValidateLinkState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ============================================================================
// FAMILY PROVIDERS
// ============================================================================

/// Provider for shared links for a specific trip
@riverpod
Future<List<SharedLink>> tripSharedLinks(Ref ref, String tripId) async {
  final service = ref.watch(sharedLinkServiceProvider);
  return service.getSharedLinksForTrip(tripId);
}

/// Provider for a single shared link by ID
@riverpod
Future<SharedLink?> sharedLink(Ref ref, String linkId) async {
  final service = ref.watch(sharedLinkServiceProvider);
  return service.getSharedLink(linkId);
}

/// Provider for a shared link by slug
@riverpod
Future<SharedLink?> sharedLinkBySlug(Ref ref, String slug) async {
  final service = ref.watch(sharedLinkServiceProvider);
  return service.getSharedLinkBySlug(slug);
}

/// Provider for shared link statistics
@riverpod
Future<SharedLinkStatistics> sharedLinkStatistics(Ref ref, String linkId) async {
  final service = ref.watch(sharedLinkServiceProvider);
  return service.getStatistics(linkId);
}

// ============================================================================
// COMPUTED PROVIDERS
// ============================================================================

/// Provider for active shared links only
@riverpod
List<SharedLink> activeSharedLinks(Ref ref) {
  final state = ref.watch(sharedLinksProvider);
  return state.links.where((link) => link.isActive).toList();
}

/// Provider for expired shared links
@riverpod
List<SharedLink> expiredSharedLinks(Ref ref) {
  final state = ref.watch(sharedLinksProvider);
  return state.links.where((link) => link.isExpired).toList();
}

/// Provider for password-protected links
@riverpod
List<SharedLink> protectedSharedLinks(Ref ref) {
  final state = ref.watch(sharedLinksProvider);
  return state.links.where((link) => link.hasPassword).toList();
}

/// Provider for public (no password) links
@riverpod
List<SharedLink> publicSharedLinks(Ref ref) {
  final state = ref.watch(sharedLinksProvider);
  return state.links.where((link) => !link.hasPassword).toList();
}

/// Provider for shared links count
@riverpod
int sharedLinksCount(Ref ref) {
  final state = ref.watch(sharedLinksProvider);
  return state.links.length;
}

/// Provider for active links count
@riverpod
int activeLinksCount(Ref ref) {
  final links = ref.watch(activeSharedLinksProvider);
  return links.length;
}
