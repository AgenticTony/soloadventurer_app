import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/token_manager.dart';

/// A widget that handles silent token refresh by listening to token state changes
/// and initiating refresh when needed.
class SilentTokenRefreshHandler extends ConsumerWidget {
  /// The child widget to display
  final Widget child;

  const SilentTokenRefreshHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(tokenManagerProvider, (previous, current) {
      if (current == FeatureAvailability.tokenExpired) {
        // Initiate silent refresh
        ref.read(tokenManagerProvider.notifier).refreshToken();
      }
    });

    return child;
  }
}
