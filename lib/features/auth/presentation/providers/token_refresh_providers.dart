import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'package:soloadventurer/features/auth/presentation/notifiers/token_refresh_notification_handler.dart';

part 'token_refresh_providers.g.dart';

/// Provider for the TokenRefreshService from the service locator
@riverpod
TokenRefreshService tokenRefreshService(TokenRefreshServiceRef ref) {
  return getIt<TokenRefreshService>();
}
