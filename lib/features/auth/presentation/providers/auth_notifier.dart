import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/refresh_token.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';
import 'package:soloadventurer/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/foundation.dart';

/// Provider for the auth notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    getCurrentUser: ref.watch(getCurrentUserProvider),
    isSignedIn: ref.watch(isSignedInProvider),
    login: ref.watch(loginProvider),
    signUp: ref.watch(signUpProvider),
    signOut: ref.watch(signOutProvider),
    refreshToken: ref.watch(refreshTokenProvider),
    createProfile: ref.watch(createProfileUseCaseProvider),
  );
});

/// Notifier that manages authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final GetCurrentUser _getCurrentUser;
  final IsSignedIn _isSignedIn;
  final LoginUseCase _login;
  final SignUp _signUp;
  final SignOut _signOut;
  final RefreshToken _refreshToken;
  final CreateProfileUseCase _createProfile;

  /// Creates a new [AuthNotifier]
  AuthNotifier({
    required GetCurrentUser getCurrentUser,
    required IsSignedIn isSignedIn,
    required LoginUseCase login,
    required SignUp signUp,
    required SignOut signOut,
    required RefreshToken refreshToken,
    required CreateProfileUseCase createProfile,
  })  : _getCurrentUser = getCurrentUser,
        _isSignedIn = isSignedIn,
        _login = login,
        _signUp = signUp,
        _signOut = signOut,
        _refreshToken = refreshToken,
        _createProfile = createProfile,
        super(AuthState.initial()) {
    // Check for existing user on initialization
    Future(() => _checkAuthState());
  }

  /// Check the current authentication state
  Future<void> _checkAuthState() async {
    state = AuthState.loading();
    try {
      final isAuthenticated = await _isSignedIn();
      if (isAuthenticated) {
        final user = await _getCurrentUser();
        if (user != null) {
          state = AuthState.authenticated(user);
          return;
        }
      }
      state = AuthState.initial();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Test-only method to check auth state
  @visibleForTesting
  Future<void> checkAuthState() => _checkAuthState();

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await _login(LoginParams(
        email: email,
        password: password,
      ));
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Register with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    debugPrint('AuthNotifier: Starting sign up');
    state = AuthState.loading();
    try {
      final user = await _signUp(SignUpParams(
        email: email,
        password: password,
        name: name,
      ));
      debugPrint('AuthNotifier: Sign up successful, user: $user');

      // Create profile for the new user
      final now = DateTime.now();
      final profile = ProfileModel(
        id: user.id,
        userId: user.id,
        displayName: name,
        createdAt: now,
        updatedAt: now,
      );
      await _createProfile(profile);
      debugPrint('AuthNotifier: Profile created successfully');

      state = AuthState.authenticated(user);
    } catch (e) {
      debugPrint('AuthNotifier: Sign up failed: $e');
      state = AuthState.error(e.toString());
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = AuthState.loading();
    try {
      await _signOut();
      state = AuthState.initial();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Refresh the authentication token
  Future<void> refreshToken() async {
    try {
      await _refreshToken();
      // After refreshing the token, check the auth state again
      await _checkAuthState();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Clear any error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}
