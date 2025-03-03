import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/refresh_token.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';

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
