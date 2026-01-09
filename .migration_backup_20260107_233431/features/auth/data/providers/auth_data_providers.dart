import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/config/cognito_config.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/supabase_auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/services/token_blacklist_manager.dart';

/// Provider for SecurityManager
/// SecurityManager is now a Riverpod notifier
final securityManagerProvider = Provider<SecurityManager>((ref) {
  throw UnimplementedError(
    'SecurityManager should be accessed via securityManagerProvider from core/providers/api_providers.dart',
  );
});

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider must be overridden');
});

/// Provider for CognitoUserPool
final cognitoUserPoolProvider = Provider<CognitoUserPool>((ref) {
  return CognitoUserPool(
    CognitoConfig.userPoolId,
    CognitoConfig.clientId,
  );
});

/// Provider for HTTP Client
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// Override for AuthLocalDataSource provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final securityManager = ref.watch(securityManagerProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return AuthLocalDataSourceImpl(securityManager, sharedPreferences);
});

/// Override for AuthRemoteDataSource provider
///
/// This provider automatically switches between AWS Cognito and Supabase
/// based on environment configuration:
/// - If SUPABASE_URL and SUPABASE_ANON_KEY are set, uses Supabase
/// - Otherwise, falls back to AWS Cognito (existing behavior)
///
/// This allows for gradual migration without breaking existing functionality.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final useSupabase = ref.watch(useSupabaseAuthProvider);

  if (useSupabase) {
    // Use Supabase implementation
    return ref.watch(supabaseAuthRemoteDataSourceProvider);
  } else {
    // Use AWS Cognito implementation (existing behavior)
    return ref.watch(awsCognitoAuthRemoteDataSourceProvider);
  }
});

/// Provider for TokenBlacklistManager
final tokenBlacklistManagerProvider = Provider<TokenBlacklistManager>((ref) {
  return TokenBlacklistManager();
});

// =============================================================================
// SUPABASE AUTH PROVIDERS (Migration in progress - replacing AWS Cognito)
// =============================================================================

/// Provider to determine if Supabase should be used instead of AWS Cognito
///
/// Checks if Supabase credentials are configured in the environment.
/// Returns true if Supabase URL and anon key are both set and non-empty.
final useSupabaseAuthProvider = Provider<bool>((ref) {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  return supabaseUrl != null &&
      supabaseAnonKey != null &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
});

/// Provider for SupabaseClient
///
/// Provides access to the Supabase client instance that was initialized
/// in bootstrap.dart. Throws UnimplementedError if Supabase is not configured.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for AWS Cognito AuthRemoteDataSource
///
/// This provider exists for backwards compatibility and will be removed
/// after the Supabase migration is complete.
final awsCognitoAuthRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final userPool = ref.watch(cognitoUserPoolProvider);
  final client = ref.watch(httpClientProvider);

  return AuthRemoteDataSourceImpl(
    userPool: userPool,
    clientSecret: CognitoConfig.clientSecret,
    client: client,
    baseUrl: CognitoConfig.baseUrl,
  );
});

/// Provider for Supabase AuthRemoteDataSource
///
/// Provides the Supabase implementation of AuthRemoteDataSource.
/// This provider will become the default after AWS Cognito removal.
final supabaseAuthRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final httpClient = ref.watch(httpClientProvider);

  return SupabaseAuthRemoteDataSourceImpl(
    client: client,
    httpClient: httpClient,
  );
});
