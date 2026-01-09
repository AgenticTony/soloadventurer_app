import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Privacy level for location sharing
enum LocationPrivacyLevel {
  /// Minimal location data (city-level only)
  minimal,

  /// Balanced location data (approximate location)
  balanced,

  /// Detailed location data (precise location)
  detailed,
}

/// When to share location
enum LocationSharingTiming {
  /// Share location only during check-ins
  checkInsOnly,

  /// Share location during emergencies
  emergenciesOnly,

  /// Share location during check-ins and emergencies
  checkInsAndEmergencies,

  /// Always share location when active
  always,
}

/// Callback type for when privacy settings are changed
typedef PrivacySettingsChangedCallback = void Function(LocationPrivacySettings);

/// Privacy settings data class
class LocationPrivacySettings {
  /// Privacy level for location sharing
  final LocationPrivacyLevel privacyLevel;

  /// When to share location
  final LocationSharingTiming sharingTiming;

  /// Whether to share exact coordinates
  final bool shareCoordinates;

  /// Whether to share place name/address
  final bool sharePlaceName;

  /// Whether to share battery level
  final bool shareBatteryLevel;

  /// Whether to share speed and altitude
  final bool shareSpeedAndAltitude;

  /// Location accuracy in meters
  final int locationAccuracy;

  /// Whether battery optimization is enabled
  final bool batteryOptimization;

  /// Auto-expire location sharing after minutes (0 = no expiration)
  final int autoExpireMinutes;

  const LocationPrivacySettings({
    this.privacyLevel = LocationPrivacyLevel.balanced,
    this.sharingTiming = LocationSharingTiming.checkInsAndEmergencies,
    this.shareCoordinates = true,
    this.sharePlaceName = true,
    this.shareBatteryLevel = true,
    this.shareSpeedAndAltitude = false,
    this.locationAccuracy = 100,
    this.batteryOptimization = true,
    this.autoExpireMinutes = 0,
  });

  /// Creates a copy with the given fields replaced
  LocationPrivacySettings copyWith({
    LocationPrivacyLevel? privacyLevel,
    LocationSharingTiming? sharingTiming,
    bool? shareCoordinates,
    bool? sharePlaceName,
    bool? shareBatteryLevel,
    bool? shareSpeedAndAltitude,
    int? locationAccuracy,
    bool? batteryOptimization,
    int? autoExpireMinutes,
  }) {
    return LocationPrivacySettings(
      privacyLevel: privacyLevel ?? this.privacyLevel,
      sharingTiming: sharingTiming ?? this.sharingTiming,
      shareCoordinates: shareCoordinates ?? this.shareCoordinates,
      sharePlaceName: sharePlaceName ?? this.sharePlaceName,
      shareBatteryLevel: shareBatteryLevel ?? this.shareBatteryLevel,
      shareSpeedAndAltitude: shareSpeedAndAltitude ?? this.shareSpeedAndAltitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      batteryOptimization: batteryOptimization ?? this.batteryOptimization,
      autoExpireMinutes: autoExpireMinutes ?? this.autoExpireMinutes,
    );
  }

  /// Converts settings to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'privacyLevel': privacyLevel.name,
      'sharingTiming': sharingTiming.name,
      'shareCoordinates': shareCoordinates,
      'sharePlaceName': sharePlaceName,
      'shareBatteryLevel': shareBatteryLevel,
      'shareSpeedAndAltitude': shareSpeedAndAltitude,
      'locationAccuracy': locationAccuracy,
      'batteryOptimization': batteryOptimization,
      'autoExpireMinutes': autoExpireMinutes,
    };
  }

  /// Creates settings from JSON
  factory LocationPrivacySettings.fromJson(Map<String, dynamic> json) {
    return LocationPrivacySettings(
      privacyLevel: LocationPrivacyLevel.values.firstWhere(
        (e) => e.name == json['privacyLevel'],
        orElse: () => LocationPrivacyLevel.balanced,
      ),
      sharingTiming: LocationSharingTiming.values.firstWhere(
        (e) => e.name == json['sharingTiming'],
        orElse: () => LocationSharingTiming.checkInsAndEmergencies,
      ),
      shareCoordinates: json['shareCoordinates'] ?? true,
      sharePlaceName: json['sharePlaceName'] ?? true,
      shareBatteryLevel: json['shareBatteryLevel'] ?? true,
      shareSpeedAndAltitude: json['shareSpeedAndAltitude'] ?? false,
      locationAccuracy: json['locationAccuracy'] ?? 100,
      batteryOptimization: json['batteryOptimization'] ?? true,
      autoExpireMinutes: json['autoExpireMinutes'] ?? 0,
    );
  }
}

/// Reusable widget for granular location privacy controls
///
/// Features:
/// - Privacy level selector (minimal, balanced, detailed)
/// - What to share controls (coordinates, place name, battery level, speed/altitude)
/// - When to share controls (check-ins only, emergencies only, always)
/// - Location accuracy slider
/// - Battery optimization toggle
/// - Auto-expiration settings
/// - Privacy level descriptions
/// - Follows Material Design guidelines with proper theming
///
/// Can be used in:
/// - Location sharing screen
/// - Settings screen
/// - Trusted contacts screen
/// - Check-in configuration screens
///
/// Example usage:
/// ```dart
/// LocationPrivacyWidget(
///   initialSettings: _privacySettings,
///   onSettingsChanged: (settings) => _updateSettings(settings),
///   enabled: true,
/// )
/// ```
class LocationPrivacyWidget extends ConsumerStatefulWidget {
  /// Initial privacy settings
  final LocationPrivacySettings? initialSettings;

  /// Callback when settings are changed
  final PrivacySettingsChangedCallback? onSettingsChanged;

  /// Whether the widget is enabled (for loading/disabled states)
  final bool enabled;

  /// Whether to show the header section
  final bool showHeader;

  /// Whether to wrap in a Card
  final bool wrapInCard;

  /// Whether to show advanced options
  final bool showAdvanced;

  const LocationPrivacyWidget({
    super.key,
    this.initialSettings,
    this.onSettingsChanged,
    this.enabled = true,
    this.showHeader = true,
    this.wrapInCard = false,
    this.showAdvanced = true,
  });

  @override
  ConsumerState<LocationPrivacyWidget> createState() =>
      _LocationPrivacyWidgetState();
}

class _LocationPrivacyWidgetState extends ConsumerState<LocationPrivacyWidget> {
  late LocationPrivacySettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings ?? const LocationPrivacySettings();
  }

  void _updateSettings(LocationPrivacySettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    widget.onSettingsChanged?.call(_settings);
  }

  void _updatePrivacyLevel(LocationPrivacyLevel level) {
    // Auto-adjust settings based on privacy level
    LocationPrivacySettings newSettings;
    switch (level) {
      case LocationPrivacyLevel.minimal:
        newSettings = _settings.copyWith(
          privacyLevel: level,
          shareCoordinates: false,
          sharePlaceName: false,
          shareBatteryLevel: true,
          shareSpeedAndAltitude: false,
          locationAccuracy: 3000,
        );
        break;
      case LocationPrivacyLevel.balanced:
        newSettings = _settings.copyWith(
          privacyLevel: level,
          shareCoordinates: true,
          sharePlaceName: true,
          shareBatteryLevel: true,
          shareSpeedAndAltitude: false,
          locationAccuracy: 100,
        );
        break;
      case LocationPrivacyLevel.detailed:
        newSettings = _settings.copyWith(
          privacyLevel: level,
          shareCoordinates: true,
          sharePlaceName: true,
          shareBatteryLevel: true,
          shareSpeedAndAltitude: true,
          locationAccuracy: 10,
        );
        break;
    }
    _updateSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header section
        if (widget.showHeader) ...[
          _buildHeader(context),
          const SizedBox(height: 16),
        ],

        // Privacy level selector
        _buildPrivacyLevelSection(context),
        const SizedBox(height: 24),

        // When to share
        _buildSharingTimingSection(context),
        const SizedBox(height: 24),

        // What to share
        _buildWhatToShareSection(context),
        const SizedBox(height: 24),

        // Advanced options
        if (widget.showAdvanced) ...[
          _buildAdvancedSection(context),
        ],
      ],
    );

    if (widget.wrapInCard) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: content,
        ),
      );
    }

    return content;
  }

  /// Builds the header section
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.privacy_tip,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location Privacy Settings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Control what, when, and with whom you share your location',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the privacy level selector section
  Widget _buildPrivacyLevelSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(
          context,
          'Privacy Level',
          'How precise should your location be?',
        ),
        const SizedBox(height: 12),
        _buildPrivacyLevelCards(context),
      ],
    );
  }

  /// Builds privacy level selection cards
  Widget _buildPrivacyLevelCards(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PrivacyLevelCard(
          level: LocationPrivacyLevel.minimal,
          title: 'Minimal',
          description: 'City-level location only',
          icon: Icons.location_city,
          color: Colors.green,
          isSelected: _settings.privacyLevel == LocationPrivacyLevel.minimal,
          onTap: widget.enabled ? () => _updatePrivacyLevel(LocationPrivacyLevel.minimal) : null,
        ),
        const SizedBox(height: 8),
        _PrivacyLevelCard(
          level: LocationPrivacyLevel.balanced,
          title: 'Balanced',
          description: 'Approximate location (recommended)',
          icon: Icons.balance,
          color: Colors.blue,
          isSelected: _settings.privacyLevel == LocationPrivacyLevel.balanced,
          onTap: widget.enabled ? () => _updatePrivacyLevel(LocationPrivacyLevel.balanced) : null,
        ),
        const SizedBox(height: 8),
        _PrivacyLevelCard(
          level: LocationPrivacyLevel.detailed,
          title: 'Detailed',
          description: 'Precise location with full details',
          icon: Icons.my_location,
          color: Colors.orange,
          isSelected: _settings.privacyLevel == LocationPrivacyLevel.detailed,
          onTap: widget.enabled ? () => _updatePrivacyLevel(LocationPrivacyLevel.detailed) : null,
        ),
      ],
    );
  }

  /// Builds the "when to share" section
  Widget _buildSharingTimingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(
          context,
          'When to Share',
          'When should your location be shared?',
        ),
        const SizedBox(height: 12),
        _buildTimingOptions(context),
      ],
    );
  }

  /// Builds timing radio options
  Widget _buildTimingOptions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimingRadioTile(
          context: context,
          timing: LocationSharingTiming.checkInsOnly,
          title: 'Check-ins Only',
          subtitle: 'Share location only when you manually check in',
          icon: Icons.check_circle,
        ),
        const Divider(height: 1),
        _buildTimingRadioTile(
          context: context,
          timing: LocationSharingTiming.emergenciesOnly,
          title: 'Emergencies Only',
          subtitle: 'Share location only during emergency situations',
          icon: Icons.warning,
        ),
        const Divider(height: 1),
        _buildTimingRadioTile(
          context: context,
          timing: LocationSharingTiming.checkInsAndEmergencies,
          title: 'Check-ins & Emergencies',
          subtitle: 'Share location during check-ins and emergencies (recommended)',
          icon: Icons.shield,
        ),
        const Divider(height: 1),
        _buildTimingRadioTile(
          context: context,
          timing: LocationSharingTiming.always,
          title: 'Always Share',
          subtitle: 'Continuously share your location while enabled',
          icon: Icons.share,
        ),
      ],
    );
  }

  /// Builds a single timing radio tile
  Widget _buildTimingRadioTile({
    required BuildContext context,
    required LocationSharingTiming timing,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return RadioListTile<LocationSharingTiming>(
      title: Row(
        children: [
          Icon(
            icon,
            color: widget.enabled ? theme.colorScheme.primary : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle),
      value: timing,
      groupValue: _settings.sharingTiming,
      onChanged: widget.enabled
          ? (value) {
              if (value != null) {
                _updateSettings(_settings.copyWith(sharingTiming: value));
              }
            }
          : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      activeColor: theme.colorScheme.primary,
    );
  }

  /// Builds the "what to share" section
  Widget _buildWhatToShareSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(
          context,
          'What to Share',
          'Choose what location information to include',
        ),
        const SizedBox(height: 12),
        _buildWhatToShareToggles(context),
      ],
    );
  }

  /// Builds toggle switches for what to share
  Widget _buildWhatToShareToggles(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          title: const Text('Exact Coordinates'),
          subtitle: const Text('Include latitude and longitude'),
          value: _settings.shareCoordinates,
          onChanged: widget.enabled
              ? (value) {
                  _updateSettings(_settings.copyWith(shareCoordinates: value));
                }
              : null,
          secondary: const Icon(Icons.pin_drop),
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: const Text('Place Name & Address'),
          subtitle: const Text('Include location name and street address'),
          value: _settings.sharePlaceName,
          onChanged: widget.enabled
              ? (value) {
                  _updateSettings(_settings.copyWith(sharePlaceName: value));
                }
              : null,
          secondary: const Icon(Icons.place),
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: const Text('Battery Level'),
          subtitle: const Text('Share your current battery percentage'),
          value: _settings.shareBatteryLevel,
          onChanged: widget.enabled
              ? (value) {
                  _updateSettings(_settings.copyWith(shareBatteryLevel: value));
                }
              : null,
          secondary: const Icon(Icons.battery_full),
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: const Text('Speed & Altitude'),
          subtitle: const Text('Include movement speed and altitude data'),
          value: _settings.shareSpeedAndAltitude,
          onChanged: widget.enabled
              ? (value) {
                  _updateSettings(_settings.copyWith(shareSpeedAndAltitude: value));
                }
              : null,
          secondary: const Icon(Icons.speed),
        ),
      ],
    );
  }

  /// Builds the advanced options section
  Widget _buildAdvancedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(
          context,
          'Advanced Options',
          'Fine-tune location sharing behavior',
        ),
        const SizedBox(height: 12),
        _buildAccuracySlider(context),
        const SizedBox(height: 16),
        _buildBatteryOptimizationToggle(context),
        const Divider(height: 24),
        _buildAutoExpireSection(context),
      ],
    );
  }

  /// Builds location accuracy slider
  Widget _buildAccuracySlider(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = _settings.locationAccuracy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Location Accuracy',
              style: theme.textTheme.titleSmall,
            ),
            Text(
              _getAccuracyLabel(accuracy),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: accuracy.toDouble(),
          min: 10,
          max: 3000,
          divisions: 100,
          label: _getAccuracyLabel(accuracy),
          onChanged: widget.enabled
              ? (value) {
                  _updateSettings(_settings.copyWith(locationAccuracy: value.toInt()));
                }
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precise (10m)',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'City-level (3km)',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Gets label for accuracy value
  String _getAccuracyLabel(int accuracy) {
    if (accuracy <= 50) return 'Precise';
    if (accuracy <= 200) return 'Balanced';
    if (accuracy <= 1000) return 'Approximate';
    return 'City-level';
  }

  /// Builds battery optimization toggle
  Widget _buildBatteryOptimizationToggle(BuildContext context) {
    return SwitchListTile(
      title: const Text('Battery Optimization'),
      subtitle: const Text('Reduce location updates to save battery'),
      value: _settings.batteryOptimization,
      onChanged: widget.enabled
          ? (value) {
              _updateSettings(_settings.copyWith(batteryOptimization: value));
            }
          : null,
      secondary: const Icon(Icons.battery_charging_full),
    );
  }

  /// Builds auto-expire section
  Widget _buildAutoExpireSection(BuildContext context) {
    final theme = Theme.of(context);
    final expireMinutes = _settings.autoExpireMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Auto-Expire Sharing',
              style: theme.textTheme.titleSmall,
            ),
            Text(
              expireMinutes == 0 ? 'Never' : _formatDuration(expireMinutes),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: expireMinutes.toDouble(),
          min: 0,
          max: 480,
          divisions: 16,
          label: expireMinutes == 0 ? 'Never' : _formatDuration(expireMinutes),
          onChanged: widget.enabled
              ? (value) {
                  _updateSettings(_settings.copyWith(autoExpireMinutes: value.toInt()));
                }
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Never',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '8 hours',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (expireMinutes > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(
              'Location sharing will automatically stop after ${_formatDuration(expireMinutes)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.orange[700],
              ),
            ),
          ),
      ],
    );
  }

  /// Formats duration in minutes to readable string
  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes / 60;
    if (hours == 1) return '1 hour';
    return '${hours.toInt()} hours';
  }

  /// Builds a section header with consistent styling
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Privacy level selection card
class _PrivacyLevelCard extends StatelessWidget {
  final LocationPrivacyLevel level;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PrivacyLevelCard({
    required this.level,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: color,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact version of location privacy widget for inline usage
///
/// Shows only essential privacy controls in a compact form
class LocationPrivacyWidgetCompact extends StatefulWidget {
  /// Initial privacy settings
  final LocationPrivacySettings? initialSettings;

  /// Callback when settings are changed
  final PrivacySettingsChangedCallback? onSettingsChanged;

  /// Whether the widget is enabled
  final bool enabled;

  const LocationPrivacyWidgetCompact({
    super.key,
    this.initialSettings,
    this.onSettingsChanged,
    this.enabled = true,
  });

  @override
  State<LocationPrivacyWidgetCompact> createState() =>
      _LocationPrivacyWidgetCompactState();
}

class _LocationPrivacyWidgetCompactState
    extends State<LocationPrivacyWidgetCompact> {
  late LocationPrivacySettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings ?? const LocationPrivacySettings();
  }

  void _updateSettings(LocationPrivacySettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    widget.onSettingsChanged?.call(_settings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.privacy_tip, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Privacy Level',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildPrivacyLevelDropdown(context),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilterChip(
                  label: const Text('Coordinates'),
                  selected: _settings.shareCoordinates,
                  onSelected: widget.enabled
                      ? (value) {
                          _updateSettings(
                            _settings.copyWith(shareCoordinates: value),
                          );
                        }
                      : null,
                  avatar: Icon(
                    _settings.shareCoordinates
                        ? Icons.check
                        : Icons.pin_drop_outlined,
                    size: 16,
                  ),
                ),
                FilterChip(
                  label: const Text('Place'),
                  selected: _settings.sharePlaceName,
                  onSelected: widget.enabled
                      ? (value) {
                          _updateSettings(
                            _settings.copyWith(sharePlaceName: value),
                          );
                        }
                      : null,
                  avatar: Icon(
                    _settings.sharePlaceName
                        ? Icons.check
                        : Icons.place_outlined,
                    size: 16,
                  ),
                ),
                FilterChip(
                  label: const Text('Battery'),
                  selected: _settings.shareBatteryLevel,
                  onSelected: widget.enabled
                      ? (value) {
                          _updateSettings(
                            _settings.copyWith(shareBatteryLevel: value),
                          );
                        }
                      : null,
                  avatar: Icon(
                    _settings.shareBatteryLevel
                        ? Icons.check
                        : Icons.battery_std,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyLevelDropdown(BuildContext context) {
    return DropdownButton<LocationPrivacyLevel>(
      value: _settings.privacyLevel,
      onChanged: widget.enabled
          ? (value) {
              if (value != null) {
                LocationPrivacySettings newSettings;
                switch (value) {
                  case LocationPrivacyLevel.minimal:
                    newSettings = _settings.copyWith(
                      privacyLevel: value,
                      shareCoordinates: false,
                      sharePlaceName: false,
                      locationAccuracy: 3000,
                    );
                    break;
                  case LocationPrivacyLevel.balanced:
                    newSettings = _settings.copyWith(
                      privacyLevel: value,
                      shareCoordinates: true,
                      sharePlaceName: true,
                      locationAccuracy: 100,
                    );
                    break;
                  case LocationPrivacyLevel.detailed:
                    newSettings = _settings.copyWith(
                      privacyLevel: value,
                      shareCoordinates: true,
                      sharePlaceName: true,
                      shareSpeedAndAltitude: true,
                      locationAccuracy: 10,
                    );
                    break;
                }
                _updateSettings(newSettings);
              }
            }
          : null,
      items: const [
        DropdownMenuItem(
          value: LocationPrivacyLevel.minimal,
          child: Text('Minimal', style: TextStyle(fontSize: 12)),
        ),
        DropdownMenuItem(
          value: LocationPrivacyLevel.balanced,
          child: Text('Balanced', style: TextStyle(fontSize: 12)),
        ),
        DropdownMenuItem(
          value: LocationPrivacyLevel.detailed,
          child: Text('Detailed', style: TextStyle(fontSize: 12)),
        ),
      ],
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

/// Display-only widget for showing current privacy settings
///
/// Used in cards, lists, and detail views to display privacy settings
class LocationPrivacyDisplay extends StatelessWidget {
  /// Privacy settings to display
  final LocationPrivacySettings settings;

  /// Display style
  final LocationPrivacyDisplayStyle style;

  const LocationPrivacyDisplay({
    super.key,
    required this.settings,
    this.style = LocationPrivacyDisplayStyle.detailed,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case LocationPrivacyDisplayStyle.detailed:
        return _buildDetailedDisplay(context);
      case LocationPrivacyDisplayStyle.compact:
        return _buildCompactDisplay(context);
      case LocationPrivacyDisplayStyle.badge:
        return _buildBadgeDisplay(context);
    }
  }

  Widget _buildDetailedDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = _getPrivacyLevelColor();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip,
                  color: levelColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Privacy Settings',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildPrivacyLevelChip(context),
              ],
            ),
            const Divider(height: 16),
            _buildInfoRow(
              context,
              Icons.schedule,
              'Sharing:',
              _getSharingTimingLabel(),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.gps_fixed,
              'Accuracy:',
              _getAccuracyLabel(settings.locationAccuracy),
            ),
            if (settings.autoExpireMinutes > 0) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.timer,
                'Expires:',
                _formatDuration(settings.autoExpireMinutes),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDisplay(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.privacy_tip,
          size: 16,
          color: _getPrivacyLevelColor(),
        ),
        const SizedBox(width: 6),
        Text(
          _getPrivacyLevelLabel(),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeDisplay(BuildContext context) {
    final color = _getPrivacyLevelColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.privacy_tip,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _getPrivacyLevelLabel(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyLevelChip(BuildContext context) {
    final color = _getPrivacyLevelColor();
    return Chip(
      label: Text(
        _getPrivacyLevelLabel(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getPrivacyLevelColor() {
    switch (settings.privacyLevel) {
      case LocationPrivacyLevel.minimal:
        return Colors.green;
      case LocationPrivacyLevel.balanced:
        return Colors.blue;
      case LocationPrivacyLevel.detailed:
        return Colors.orange;
    }
  }

  String _getPrivacyLevelLabel() {
    switch (settings.privacyLevel) {
      case LocationPrivacyLevel.minimal:
        return 'Minimal';
      case LocationPrivacyLevel.balanced:
        return 'Balanced';
      case LocationPrivacyLevel.detailed:
        return 'Detailed';
    }
  }

  String _getSharingTimingLabel() {
    switch (settings.sharingTiming) {
      case LocationSharingTiming.checkInsOnly:
        return 'Check-ins Only';
      case LocationSharingTiming.emergenciesOnly:
        return 'Emergencies Only';
      case LocationSharingTiming.checkInsAndEmergencies:
        return 'Check-ins & Emergencies';
      case LocationSharingTiming.always:
        return 'Always';
    }
  }

  String _getAccuracyLabel(int accuracy) {
    if (accuracy <= 50) return 'Precise';
    if (accuracy <= 200) return 'Balanced';
    if (accuracy <= 1000) return 'Approximate';
    return 'City-level';
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes / 60;
    if (hours == 1) return '1 hour';
    return '${hours.toInt()} hours';
  }
}

/// Display style for location privacy display widget
enum LocationPrivacyDisplayStyle {
  /// Detailed card view
  detailed,

  /// Compact inline view
  compact,

  /// Badge style
  badge,
}
