import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/refresh_token.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:soloadventurer/features/profile/presentation/providers/profile_providers.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'auth_notifier.dart';

export 'auth_notifier.dart';
export '../state/auth_state.dart';

/// Provider for the auth state notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    getCurrentUser: ref.watch(getCurrentUserProvider),
    isSignedIn: ref.watch(isSignedInProvider),
    login: ref.watch(loginProvider),
    signUp: ref.watch(signUpProvider),
    signOut: ref.watch(signOutProvider),
    refreshToken: ref.watch(refreshTokenProvider),
    createProfile: ref.watch(createProfileUseCaseProvider),
    repository: ref.watch(authRepositoryProvider),
  );
});

/// Provider for the auth initialization state
final authInitProvider = FutureProvider<void>((ref) async {
  // Initialize auth-related services
  await getIt.allReady();
  return;
});

/// Provider for the auth repository
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => getIt<AuthRepository>(),
);

/// Provider for the get current user use case
final getCurrentUserProvider = Provider<GetCurrentUser>(
  (ref) => GetCurrentUser(ref.watch(authRepositoryProvider)),
);

/// Provider for the is signed in use case
final isSignedInProvider = Provider<IsSignedIn>(
  (ref) => IsSignedIn(ref.watch(authRepositoryProvider)),
);

/// Provider for the login use case
final loginProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

/// Provider for the sign up use case
final signUpProvider = Provider<SignUp>(
  (ref) => SignUp(ref.watch(authRepositoryProvider)),
);

/// Provider for the sign out use case
final signOutProvider = Provider<SignOut>(
  (ref) => SignOut(ref.watch(authRepositoryProvider)),
);

/// Provider for the refresh token use case
final refreshTokenProvider = Provider<RefreshToken>(
  (ref) => RefreshToken(ref.watch(authRepositoryProvider)),
);
