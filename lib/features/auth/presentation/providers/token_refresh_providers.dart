import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';

part 'token_refresh_providers.g.dart';

/// Provider for the TokenRefreshService
///
/// Delegates to the canonical provider in auth_service_providers.dart.
@riverpod
TokenRefreshService tokenRefreshService(Ref ref) {
  return ref.watch(tokenRefreshServiceProvider);
}
