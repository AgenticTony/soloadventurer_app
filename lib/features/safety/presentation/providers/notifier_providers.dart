/// Barrel file for all safety notifier providers
///
/// This file exports all the notifier providers from safety_providers.dart
/// where they are actually defined.
library;

// Export Phase 1 Riverpod 2 providers (from @riverpod annotations)
export 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart'
    show trustedContactsProvider, checkInNotifierProvider;

// Export legacy StateNotifier providers (Phase 2 - not yet migrated)
export 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart'
    show locationSharingNotifierProvider, safetyNotifierProvider;
