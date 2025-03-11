import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/token_expired_dialog.dart';

class TokenRefreshIndicator extends ConsumerWidget {
  final Widget child;

  const TokenRefreshIndicator({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(tokenManagerProvider);

    // Show token expired dialog when needed
    ref.listen(tokenManagerProvider, (previous, current) {
      if (current == FeatureAvailability.tokenExpired) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const TokenExpiredDialog(),
        );
      }
    });

    // Show loading overlay during token refresh
    return Stack(
      children: [
        child,
        if (tokenState == FeatureAvailability.tokenExpired)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
