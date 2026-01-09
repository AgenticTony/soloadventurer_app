import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/presentation/providers/notification_providers.dart';

/// Screen for managing notification preferences
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPreferencesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _showResetDialog(context),
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: prefsAsync.when(
        data: (preferences) => _buildSettings(context, preferences),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading settings: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(notificationPreferencesNotifierProvider.notifier)
                    .resetToDefaults(),
                child: const Text('Reset to Defaults'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings(
    BuildContext context,
    NotificationPreferences preferences,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Flight notifications
        _buildSectionHeader(
          context,
          '✈️ Trip Notifications',
          'Recommended: Keep ON',
        ),
        _buildSwitchTile(
          context,
          'Flight check-in reminders',
          '24 hours before departure',
          preferences.flightCheckInReminders,
          (value) => _updatePreference(
            preferences.copyWith(flightCheckInReminders: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Flight delays & cancellations',
          'Real-time updates',
          preferences.flightDelaysAndCancellations,
          (value) => _updatePreference(
            preferences.copyWith(flightDelaysAndCancellations: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Gate changes',
          'Boarding gate updates',
          preferences.flightGateChanges,
          (value) => _updatePreference(
            preferences.copyWith(flightGateChanges: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Booking confirmations',
          'When reservations are confirmed',
          preferences.bookingConfirmations,
          (value) => _updatePreference(
            preferences.copyWith(bookingConfirmations: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Reservation reminders',
          '24 hours before activities',
          preferences.reservationReminders,
          (value) => _updatePreference(
            preferences.copyWith(reservationReminders: value),
          ),
        ),

        const SizedBox(height: 24),

        // Weather notifications
        _buildSectionHeader(
          context,
          '🌤️ Weather Alerts',
          'Recommended: Keep ON',
        ),
        _buildSwitchTile(
          context,
          'Severe weather warnings',
          'Critical weather updates',
          preferences.severeWeatherAlerts,
          (value) => _updatePreference(
            preferences.copyWith(severeWeatherAlerts: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Daily weather summary',
          '7 AM each day',
          preferences.dailyWeatherSummary,
          (value) => _updatePreference(
            preferences.copyWith(dailyWeatherSummary: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Rain alerts for outdoor activities',
          'Suggest indoor alternatives',
          preferences.rainAlertsForOutdoorActivities,
          (value) => _updatePreference(
            preferences.copyWith(rainAlertsForOutdoorActivities: value),
          ),
        ),

        const SizedBox(height: 24),

        // Safety notifications
        _buildSectionHeader(
          context,
          '🛡️ Safety Alerts',
          'Always ON for your protection',
        ),
        _buildSwitchTile(
          context,
          'Destination safety updates',
          'Travel advisories and alerts',
          preferences.safetyAlerts,
          (value) => _updatePreference(
            preferences.copyWith(safetyAlerts: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Travel advisories',
          'Government travel alerts',
          preferences.travelAdvisories,
          (value) => _updatePreference(
            preferences.copyWith(travelAdvisories: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Emergency alerts',
          'Critical emergency notifications',
          preferences.emergencyAlerts,
          (value) => _updatePreference(
            preferences.copyWith(emergencyAlerts: value),
          ),
        ),

        const SizedBox(height: 24),

        // Recommendation notifications
        _buildSectionHeader(
          context,
          '📍 Local Recommendations',
          'Optional - Turn OFF for fewer notifications',
        ),
        _buildSwitchTile(
          context,
          'Nearby deals & offers',
          'Special offers near your location',
          preferences.nearbyDeals,
          (value) => _updatePreference(
            preferences.copyWith(nearbyDeals: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Local event suggestions',
          'Events happening near you',
          preferences.localEventSuggestions,
          (value) => _updatePreference(
            preferences.copyWith(localEventSuggestions: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Restaurant recommendations',
          'Highly rated places nearby',
          preferences.restaurantRecommendations,
          (value) => _updatePreference(
            preferences.copyWith(restaurantRecommendations: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Location-based notifications',
          'Enable location tracking for recommendations',
          preferences.locationBasedNotificationsEnabled,
          (value) => _updatePreference(
            preferences.copyWith(locationBasedNotificationsEnabled: value),
          ),
        ),

        const SizedBox(height: 24),

        // Notification style
        _buildSectionHeader(
          context,
          '📱 Notification Style',
          null,
        ),
        _buildTimeRangeTile(
          context,
          'Quiet Hours',
          preferences.quietHoursStart,
          preferences.quietHoursEnd,
          preferences,
        ),
        _buildSwitchTile(
          context,
          'Vibrate',
          null,
          preferences.vibrateEnabled,
          (value) => _updatePreference(
            preferences.copyWith(vibrateEnabled: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Sound',
          null,
          preferences.soundEnabled,
          (value) => _updatePreference(
            preferences.copyWith(soundEnabled: value),
          ),
        ),
        _buildSwitchTile(
          context,
          'Bypass Do Not Disturb',
          'For urgent notifications only',
          preferences.bypassDoNotDisturb,
          (value) => _updatePreference(
            preferences.copyWith(bypassDoNotDisturb: value),
          ),
        ),

        const SizedBox(height: 24),

        // History settings
        _buildSectionHeader(
          context,
          '📜 History',
          null,
        ),
        _buildSwitchTile(
          context,
          'Keep notification history',
          null,
          preferences.keepNotificationHistory,
          (value) => _updatePreference(
            preferences.copyWith(keepNotificationHistory: value),
          ),
        ),
        ListTile(
          title: const Text('History Retention'),
          subtitle: Text('${preferences.historyRetentionDays} days'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _selectRetentionDays(context, preferences),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String? subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String? subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildTimeRangeTile(
    BuildContext context,
    String title,
    int start,
    int end,
    NotificationPreferences preferences,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(preferences.quietHoursFormatted),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _selectTimeRange(context, preferences),
    );
  }

  Future<void> _selectTimeRange(
    BuildContext context,
    NotificationPreferences preferences,
  ) async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: preferences.quietHoursStart, minute: 0),
    );

    if (start == null) return;

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: preferences.quietHoursEnd, minute: 0),
    );

    if (end == null) return;

    await _updatePreference(
      preferences.copyWith(
        quietHoursStart: start.hour,
        quietHoursEnd: end.hour,
      ),
    );
  }

  Future<void> _selectRetentionDays(
    BuildContext context,
    NotificationPreferences preferences,
  ) async {
    final days = await showDialog<int>(
      context: context,
      builder: (context) => _RetentionDaysDialog(
        currentDays: preferences.historyRetentionDays,
      ),
    );

    if (days != null) {
      await _updatePreference(preferences.copyWith(historyRetentionDays: days));
    }
  }

  Future<void> _updatePreference(NotificationPreferences updated) async {
    await ref
        .read(notificationPreferencesNotifierProvider.notifier)
        .updatePreferences(updated);
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'Are you sure you want to reset all notification settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(notificationPreferencesNotifierProvider.notifier)
                  .resetToDefaults();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _RetentionDaysDialog extends StatelessWidget {
  final int currentDays;

  const _RetentionDaysDialog({required this.currentDays});

  @override
  Widget build(BuildContext context) {
    final options = [7, 14, 30, 60, 90];

    return AlertDialog(
      title: const Text('History Retention'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((days) {
          return RadioListTile<int>(
            title: Text('$days days'),
            value: days,
            groupValue: currentDays,
            onChanged: (value) => Navigator.pop(context, value),
          );
        }).toList(),
      ),
    );
  }
}
