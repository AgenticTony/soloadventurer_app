import 'package:flutter/material.dart';

/// AI Suggestions Bottom Sheet
/// Displays optimization suggestions for the itinerary
class AISuggestionsBottomSheet extends StatelessWidget {
  const AISuggestionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI Suggestions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Suggestion cards
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: const [
                    _SuggestionCard(
                      title: 'Group nearby activities',
                      description:
                          'Save  minutes by clustering activities in the same area',
                      icon: Icons.place,
                    ),
                    SizedBox(height: 8),
                    _SuggestionCard(
                      title: 'Adjust for weather',
                      description:
                          'Move outdoor activities to avoid expected rain at  PM',
                      icon: Icons.cloud,
                    ),
                    SizedBox(height: 8),
                    _SuggestionCard(
                      title: 'Avoid peak hours',
                      description:
                          'Visit popular sites during less crowded morning hours',
                      icon: Icons.access_time,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _SuggestionCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    // TODO: Apply suggestion
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Suggestion applied!')),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
