import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/operation_queue_provider.dart';

/// A persistent indicator that shows the number of pending operations in the queue
///
/// This widget displays a badge with the count of pending operations and navigates
/// to the [OperationQueueScreen] when tapped. It automatically hides when the queue
/// is empty (no pending operations).
///
/// Example usage in an AppBar actions list:
/// ```dart
/// AppBar(
///   actions: [
///     const QueueStatusIndicator(),
///     IconButton(...),
///   ],
/// )
/// ```
class QueueStatusIndicator extends ConsumerWidget {
  /// Creates a new [QueueStatusIndicator]
  const QueueStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(operationQueueNotifierProvider);
    final pendingCount = queueState.pendingCount;

    // Hide indicator when there are no pending operations
    if (pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Badge(
        label: Text(
          pendingCount > 99 ? '99+' : pendingCount.toString(),
          style: TextStyle(
            fontSize: pendingCount > 99 ? 10 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Icon(Icons.cloud_sync),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/operation-queue');
      },
      tooltip: 'View operation queue ($pendingCount pending)',
    );
  }
}
