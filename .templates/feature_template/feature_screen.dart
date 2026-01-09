// Feature Screen Template - Riverpod 2 Compliant
// UI reads STATE ONLY

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feature_provider.dart';

/// Screen template showing correct Riverpod 2 usage
///
/// RULES:
/// - UI reads STATE only via ref.watch()
/// - NEVER call ref.watch(provider.notifier)
/// - User actions call ref.read(provider.notifier).method()
class FeatureScreen extends ConsumerWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ CORRECT: Watch state
    final state = ref.watch(featureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feature')),
      body: switch (state.isLoading) {
        true => const LoadingView(),
        false when state.error != null => ErrorView(
            error: state.error!,
            onRetry: () => _retry(context, ref),
          ),
        false => Content(
            data: state.data,
            onAction: () => _performAction(context, ref),
          ),
      },
    );
  }

  void _performAction(BuildContext context, WidgetRef ref) {
    // ✅ CORRECT: Call notifier methods via ref.read
    ref.read(featureProvider.notifier).performAction();
  }

  void _retry(BuildContext context, WidgetRef ref) {
    ref.read(featureProvider.notifier).performAction();
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.error,
    required this.onRetry,
    super.key,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class Content extends StatelessWidget {
  const Content({
    required this.data,
    required this.onAction,
    super.key,
  });

  final FeatureData? data;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child: Text('No data'));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Data: ${data!.name}'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onAction, child: const Text('Action')),
        ],
      ),
    );
  }
}

// ❌ WRONG - Don't do this:
// class BadExample extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // ❌ WRONG: Watching notifier
//     final notifier = ref.watch(featureProvider.notifier);
//
//     // ❌ WRONG: Calling getter on notifier
//     final isValid = ref.read(featureProvider.notifier).isValid;
//
//     return Container();
//   }
// }
