import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../storage/secure_storage.dart';

// NOTE: The ApiClient provider has moved to api_providers.dart
// (apiClientProviderFull). This file now only contains providers
// that don't belong in api_providers.dart.

/// Provides the Supabase client instance.
///
/// This is the canonical provider for the Supabase client across all features.
/// Presentation-layer code should use this instead of `Supabase.instance.client`
/// directly — see Story H.4 (no Supabase in presentation without going through
/// a provider).
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Emits an [AuthState] whenever the user signs in, signs out, or the session
/// is refreshed.
///
/// [currentUserIdProvider] depends on this so it re-evaluates on auth changes.
/// Watching the client alone is not enough: `Supabase.instance.client` is a
/// singleton whose identity never changes, so a provider watching it is
/// computed once and cached for the life of the container.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

/// Provides the current user's ID, or null if not authenticated.
///
/// Re-evaluates whenever [authStateChangesProvider] emits, so callers that
/// scope queries by user id get the *current* user after a sign-out /
/// sign-in within a single app session.
///
/// Before this depended on the auth stream it cached the first value it ever
/// saw: signing out and back in as a different user left trips being created
/// under the previous user's id and realtime subscriptions bound to the
/// previous user's rows.
final currentUserIdProvider = Provider<String?>((ref) {
  // Establish the dependency so a sign-in/sign-out recomputes this provider.
  // The stream's value is unused — `currentUser` is the authoritative read, and
  // it is already updated by the time the event fires.
  ref.watch(authStateChangesProvider);
  return ref.watch(supabaseClientProvider).auth.currentUser?.id;
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
