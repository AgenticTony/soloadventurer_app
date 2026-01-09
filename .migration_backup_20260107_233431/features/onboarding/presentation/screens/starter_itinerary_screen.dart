import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';

/// Success screen displayed after generating a starter itinerary
///
/// Features:
/// - Confetti celebration animation
/// - Trip summary with destination and dates
/// - Day preview cards showing planned activities
/// - "View Full Itinerary" button
/// - "Customize Plan" button
/// - "Share Trip Plan" button
///
/// This is the "a-ha moment" screen where users immediately see value
class StarterItineraryScreen extends StatefulWidget {
  /// The generated itinerary
  final Itinerary itinerary;

  const StarterItineraryScreen({
    super.key,
    required this.itinerary,
  });

  @override
  State<StarterItineraryScreen> createState() => _StarterItineraryScreenState();
}

class _StarterItineraryScreenState extends State<StarterItineraryScreen> {
  // Confetti controller
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Initialize confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start confetti animation
    _confettiController.play();

    // Auto-stop confetti after animation
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _confettiController.stop();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          _buildContent(context),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // Downward
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.02,
              numberOfParticles: 75,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main content
  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success header
            _buildSuccessHeader(context),

            const SizedBox(height: 16),

            // Trip summary card
            _buildTripSummaryCard(context),

            const SizedBox(height: 24),

            // Day preview list
            _buildDayPreviewSection(context),

            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Builds the success header section
  Widget _buildSuccessHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // Success message
          Text(
            "✨ Your trip is ready!",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Based on your interests, here\'s your personalized starter plan',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the trip summary card
  Widget _buildTripSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final destination = widget.itinerary.destination;
    final dateRange = widget.itinerary.dateRange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip name
            Text(
              widget.itinerary.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Destination
            _buildSummaryRow(
              context: context,
              icon: Icons.place,
              label: 'Destination',
              value: destination.formattedLocation,
            ),
            const SizedBox(height: 8),

            // Dates
            _buildSummaryRow(
              context: context,
              icon: Icons.calendar_today,
              label: 'Dates',
              value: dateRange.formatted,
            ),
            const SizedBox(height: 8),

            // Duration
            _buildSummaryRow(
              context: context,
              icon: Icons.schedule,
              label: 'Duration',
              value: '${dateRange.numberOfDays} days',
            ),
            const SizedBox(height: 12),

            // Divider
            Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
            const SizedBox(height: 12),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  context: context,
                  value: '${dateRange.numberOfDays}',
                  label: 'Days',
                ),
                _buildVerticalDivider(context),
                _buildStat(
                  context: context,
                  value: '${widget.itinerary.items.length}',
                  label: 'Activities',
                ),
                _buildVerticalDivider(context),
                _buildStat(
                  context: context,
                  value: '${widget.itinerary.completionPercentage.toStringAsFixed(0)}%',
                  label: 'Complete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a summary row with icon and text
  Widget _buildSummaryRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds a stat widget
  Widget _buildStat({
    required BuildContext context,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Builds a vertical divider
  Widget _buildVerticalDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 30,
      width: 1,
      color: theme.colorScheme.outline.withOpacity(0.3),
    );
  }

  /// Builds the day preview section
  Widget _buildDayPreviewSection(BuildContext context) {
    final theme = Theme.of(context);
    final itemsByDay = widget.itinerary.itemsByDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Your Itinerary Preview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Day cards
        ...itemsByDay.entries.take(3).map((entry) {
          final dayNumber = entry.key;
          final items = entry.value;
          return _buildDayPreviewCard(
            context: context,
            dayNumber: dayNumber,
            items: items,
          );
        }),

        // "More days" indicator
        if (itemsByDay.length > 3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: Chip(
                label: Text(
                  '+${itemsByDay.length - 3} more days planned',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds a day preview card
  Widget _buildDayPreviewCard({
    required BuildContext context,
    required int dayNumber,
    required List items,
  }) {
    final theme = Theme.of(context);

    // Get first 3 items for preview
    final previewItems = items.take(3).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Day $dayNumber',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${items.length} activities planned',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Preview items
            ...previewItems.map((item) => _buildActivityPreview(
                  context: context,
                  item: item,
                )),
          ],
        ),
      ),
    );
  }

  /// Builds an activity preview item
  Widget _buildActivityPreview({
    required BuildContext context,
    required dynamic item,
  }) {
    final theme = Theme.of(context);

    // Get item details
    final displayName = item.displayName;
    final time = _formatTime(item.time);
    final isCompleted = item.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isCompleted ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // View Full Itinerary button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _viewFullItinerary(context),
              icon: const Icon(Icons.map),
              label: const Text('View Full Itinerary'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary actions row
          Row(
            children: [
              // Customize Plan button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _customizePlan(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Customize'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Share button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareTrip(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dismiss button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _dismiss(context),
              icon: const Icon(Icons.close),
              label: const Text('I\'ll explore later'),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats time for display
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final hourFormatted = hour == 0 ? 12 : hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hourFormatted:${time.minute.toString().padLeft(2, '0')} $period';
  }

  /// Navigates to full itinerary view
  void _viewFullItinerary(BuildContext context) {
    // TODO: Navigate to full itinerary screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full itinerary view coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Opens customization options
  void _customizePlan(BuildContext context) {
    // TODO: Navigate to customization screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Customization options coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shares the trip plan
  void _shareTrip(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Dismisses the screen and returns to home
  void _dismiss(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
