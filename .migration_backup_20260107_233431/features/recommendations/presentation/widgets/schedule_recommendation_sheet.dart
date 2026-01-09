import 'package:flutter/material.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';

/// Modal sheet for scheduling a recommendation
class ScheduleRecommendationSheet extends StatefulWidget {
  final PersonalizedRecommendation recommendation;

  const ScheduleRecommendationSheet({
    required this.recommendation,
    super.key,
  });

  @override
  State<ScheduleRecommendationSheet> createState() =>
      _ScheduleRecommendationSheetState();
}

class _ScheduleRecommendationSheetState
    extends State<ScheduleRecommendationSheet> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Schedule: ${widget.recommendation.activity.name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Date picker
          ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today),
            label: Text(_selectedDate == null
                ? 'Select Date'
                : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'),
          ),

          if (_selectedDate != null) ...[
            const SizedBox(height: 8),

            // Suggested time
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Suggested Time'),
              subtitle: Text(widget.recommendation.metadata.suggestedTime.formatted),
              trailing: FilledButton.tonal(
                onPressed: () => _confirmScheduling(),
                child: const Text('Use Suggested Time'),
              ),
            ),

            // Custom time picker button
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Custom Time'),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () => _selectTime(context),
              ),
            ),
          ],

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = widget.recommendation.metadata.suggestedDate;
    final lastDate = firstDate.add(const Duration(days: 30));

    final selected = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate.isBefore(now) ? now : firstDate,
      lastDate: lastDate,
    );

    if (selected != null) {
      setState(() => _selectedDate = selected);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final suggestedTime = widget.recommendation.metadata.suggestedTime;
    final initialTime = TimeOfDay(
      hour: suggestedTime.hour,
      minute: suggestedTime.minute,
    );

    final selected = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selected != null && _selectedDate != null) {
      final scheduledAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        selected.hour,
        selected.minute,
      );
      Navigator.of(context).pop(scheduledAt);
    }
  }

  void _confirmScheduling() {
    if (_selectedDate != null) {
      final scheduledAt = widget.recommendation.metadata.suggestedTime
          .toDateTime(_selectedDate!);
      Navigator.of(context).pop(scheduledAt);
    }
  }
}
