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

/// Provides the current user's ID, or null if not authenticated.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(supabaseClientProvider).auth.currentUser?.id;
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
