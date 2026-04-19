import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reaction.dart';
import '../../domain/entities/reaction_summary.dart';
import '../../providers/reaction_providers.dart';

/// Compact horizontal row of reaction chips that sits below journal content.
///
/// Shows 4 reaction types (like, love, inspire, helpful) as tappable chips
/// with emoji, label, and count. The user's active reaction is highlighted.
class ReactionBar extends ConsumerWidget {
  const ReactionBar({
    super.key,
    required this.targetId,
    required this.targetType,
  });

  final String targetId;
  final ReactionTargetType targetType;

  static const _reactionConfig = {
    ReactionType.like: ('👍', 'Like'),
    ReactionType.love: ('❤️', 'Love'),
    ReactionType.inspire: ('✨', 'Inspire'),
    ReactionType.helpful: ('💡', 'Helpful'),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(
      reactionSummaryProvider(targetId, targetType));

    return summaryAsync.when(
      loading: () => SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 120,
            height: 2,
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
      error: (err, _) => _buildErrorBar(context, ref),
      data: (summary) => _buildReactionChips(context, ref, summary),
    );
  }

  Widget _buildReactionChips(
      BuildContext context, WidgetRef ref, ReactionSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: ReactionType.values.map((type) {
          final config = _reactionConfig[type]!;
          final emoji = config.$1;
          final label = config.$2;
          final count = summary.counts[type] ?? 0;
          final isActive = summary.userReaction == type;

          return _ReactionChip(
            emoji: emoji,
            label: label,
            count: count,
            isActive: isActive,
            onTap: () => _handleTap(ref, type),
          );
        }).toList(),
      ),
    );
  }

  void _handleTap(WidgetRef ref, ReactionType reaction) {
    ref
        .read(reactionSummaryProvider(targetId, targetType).notifier)
        .toggleReaction(reaction);
  }

  Widget _buildErrorBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ReactionType.values.map((type) {
          final config = _reactionConfig[type]!;
          return _ReactionChip(
            emoji: config.$1,
            label: config.$2,
            count: 0,
            isActive: false,
            onTap: () => _handleTap(ref, type),
          );
        }).toList(),
      ),
    );
  }
}

/// A single tappable reaction chip
class _ReactionChip extends StatefulWidget {
  const _ReactionChip({
    required this.emoji,
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_ReactionChip> createState() => _ReactionChipState();
}

class _ReactionChipState extends State<_ReactionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(_ReactionChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _scaleController.forward(from: 0.85);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeBg = colorScheme.primaryContainer;
    final activeFg = colorScheme.onPrimaryContainer;
    final inactiveBg = colorScheme.surfaceContainerHighest.withAlpha(180);
    final inactiveFg = colorScheme.onSurfaceVariant;

    return Expanded(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: widget.isActive ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(
                    widget.count > 0 ? '${widget.count}' : '',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: widget.isActive ? activeFg : inactiveFg,
                      fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
