import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/journal/data/services/shared_link_service_impl.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';
import 'package:soloadventurer/features/journal/domain/services/shared_link_service.dart';

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

/// Provider for SharedLinkService
final sharedLinkServiceProvider = Provider<SharedLinkService>((ref) {
  final client = Supabase.instance.client;
  return SharedLinkServiceImpl(client: client);
});

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
class SharedLinkNotifier extends StateNotifier<SharedLinkState> {
  final SharedLinkService _service;

  SharedLinkNotifier(this._service) : super(const SharedLinkState()) {
    loadLinks();
  }

  /// Load all shared links for the current user
  Future<void> loadLinks() async {
    state = state.copyWith(isLoading: true, clearSelected: true);

    try {
      final links = await _service.getUserSharedLinks();
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
    state = state.copyWith(isLoading: true, clearSelected: true);

    try {
      final links = await _service.getSharedLinksForTrip(tripId);
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
class CreateSharedLinkNotifier extends StateNotifier<CreateSharedLinkState> {
  final SharedLinkService _service;

  CreateSharedLinkNotifier(this._service) : super(const CreateSharedLinkState());

  /// Create a new shared link
  Future<void> createLink(CreateSharedLinkConfig config) async {
    state = state.copyWith(isCreating: true, clearError: true, clearLink: true);

    try {
      final link = await _service.createSharedLink(config);
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
class ValidateLinkNotifier extends StateNotifier<ValidateLinkState> {
  final SharedLinkService _service;

  ValidateLinkNotifier(this._service) : super(const ValidateLinkState());

  /// Validate access to a shared link
  Future<void> validateAccess({
    required String slug,
    String? password,
  }) async {
    state = state.copyWith(
      isValidating: true,
      clearError: true,
      clearResult: true,
    );

    try {
      final result = await _service.validateAccess(
        slug: slug,
        password: password,
      );

      // Record view if access is granted
      if (result.isAccessible) {
        await _service.recordView(slug);
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
// PROVIDERS
// ============================================================================

/// Provider for SharedLinkNotifier
final sharedLinkNotifierProvider =
    StateNotifierProvider<SharedLinkNotifier, SharedLinkState>((ref) {
  final service = ref.watch(sharedLinkServiceProvider);
  return SharedLinkNotifier(service);
});

/// Provider for shared links for a specific trip
final tripSharedLinksProvider =
    Provider.family<Future<List<SharedLink>>, String>((ref, tripId) async {
  final service = ref.watch(sharedLinkServiceProvider);
  return service.getSharedLinksForTrip(tripId);
});

/// Provider for a single shared link by ID
final sharedLinkProvider =
    Provider.family<Future<SharedLink?>, String>((ref, linkId) async {
  final service = ref.watch(sharedLinkServiceProvider);
  return service.getSharedLink(linkId);
});

/// Provider for a shared link by slug
final sharedLinkBySlugProvider =
    Provider.family<Future<SharedLink?>, String>((ref, slug) async {
  final service = ref.watch(sharedLinkServiceProvider);
  return service.getSharedLinkBySlug(slug);
});

/// Provider for CreateSharedLinkNotifier
final createSharedLinkNotifierProvider =
    StateNotifierProvider<CreateSharedLinkNotifier, CreateSharedLinkState>(
  (ref) {
    final service = ref.watch(sharedLinkServiceProvider);
    return CreateSharedLinkNotifier(service);
  },
);

/// Provider for ValidateLinkNotifier
final validateLinkNotifierProvider =
    StateNotifierProvider<ValidateLinkNotifier, ValidateLinkState>((ref) {
  final service = ref.watch(sharedLinkServiceProvider);
  return ValidateLinkNotifier(service);
  });

/// Provider for shared link statistics
final sharedLinkStatisticsProvider =
    Provider.family<Future<SharedLinkStatistics>, String>((ref, linkId) async {
  final service = ref.watch(sharedLinkServiceProvider);
  return service.getStatistics(linkId);
});

// ============================================================================
// COMPUTED PROVIDERS
// ============================================================================

/// Provider for active shared links only
final activeSharedLinksProvider = Provider<List<SharedLink>>((ref) {
  final state = ref.watch(sharedLinkNotifierProvider);
  return state.links.where((link) => link.isActive).toList();
});

/// Provider for expired shared links
final expiredSharedLinksProvider = Provider<List<SharedLink>>((ref) {
  final state = ref.watch(sharedLinkNotifierProvider);
  return state.links.where((link) => link.isExpired).toList();
});

/// Provider for password-protected links
final protectedSharedLinksProvider = Provider<List<SharedLink>>((ref) {
  final state = ref.watch(sharedLinkNotifierProvider);
  return state.links.where((link) => link.hasPassword).toList();
});

/// Provider for public (no password) links
final publicSharedLinksProvider = Provider<List<SharedLink>>((ref) {
  final state = ref.watch(sharedLinkNotifierProvider);
  return state.links.where((link) => !link.hasPassword).toList();
});

/// Provider for shared links count
final sharedLinksCountProvider = Provider<int>((ref) {
  final state = ref.watch(sharedLinkNotifierProvider);
  return state.links.length;
});

/// Provider for active links count
final activeLinksCountProvider = Provider<int>((ref) {
  final links = ref.watch(activeSharedLinksProvider);
  return links.length;
});
