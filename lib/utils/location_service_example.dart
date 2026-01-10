import 'package:flutter/material.dart';
import 'package:soloadventurer/utils/location_service.dart';

/// Example demonstrating various LocationService usage patterns
class LocationServiceExample extends StatefulWidget {
  const LocationServiceExample({super.key});

  @override
  State<LocationServiceExample> createState() => _LocationServiceExampleState();
}

class _LocationServiceExampleState extends State<LocationServiceExample> {
  final LocationService _locationService = LocationService.instance;

  LocationData? _currentLocation;
  LocationData? _lastKnownLocation;
  String _statusMessage = 'No location captured yet';
  bool _isLoading = false;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _captureCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Capturing location...';
    });

    try {
      // Check if location service is enabled
      final isEnabled = await _locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        final opened = await _locationService.openLocationSettings();
        if (!opened) {
          setState(() {
            _statusMessage = 'Location service is disabled. Please enable it.';
            _isLoading = false;
          });
          return;
        }
      }

      // Check permission
      final permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await _locationService.requestPermission();
        if (newPermission == LocationPermission.denied) {
          setState(() {
            _statusMessage = 'Location permission denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final opened = await _locationService.openAppSettings();
        setState(() {
          _statusMessage = opened
              ? 'Please grant location permission in settings.'
              : 'Location permission permanently denied.';
          _isLoading = false;
        });
        return;
      }

      // Capture current location with travel journal config
      final location = await _locationService.getCurrentLocation(
        LocationCaptureConfig.forTravelJournal,
      );

      setState(() {
        _currentLocation = location;
        _statusMessage = 'Location captured successfully!';
        _isLoading = false;
      });
    } on LocationException catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.message}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getQuickLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting quick location...';
    });

    try {
      // Quick capture with cached location acceptable
      final location = await _locationService.getCurrentLocation(
        LocationCaptureConfig.quick,
      );

      setState(() {
        _currentLocation = location;
        _statusMessage = 'Quick location captured!';
        _isLoading = false;
      });
    } on LocationException catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.message}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getLastKnownLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting last known location...';
    });

    try {
      final location = await _locationService.getLastKnownLocation();

      setState(() {
        _lastKnownLocation = location;
        _statusMessage = location != null
            ? 'Last known location retrieved!'
            : 'No last known location available.';
        _isLoading = false;
      });
    } on LocationException catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.message}';
        _isLoading = false;
      });
    }
  }

  void _startLocationUpdates() {
    setState(() {
      _statusMessage = 'Listening for location updates...';
    });

    _locationSubscription = _locationService
        .getLocationUpdates(LocationCaptureConfig.forTravelJournal)
        .listen(
      (location) {
        setState(() {
          _currentLocation = location;
          _statusMessage =
              'Location updated: ${location.latitude}, ${location.longitude}';
        });
      },
      onError: (error) {
        setState(() {
          _statusMessage = 'Location update error: $error';
        });
      },
    );
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
    setState(() {
      _statusMessage = 'Location updates stopped.';
    });
  }

  void _clearLocation() {
    setState(() {
      _currentLocation = null;
      _lastKnownLocation = null;
      _statusMessage = 'Location cleared.';
    });
  }

  void _calculateDistance() {
    if (_currentLocation == null) {
      setState(() {
        _statusMessage = 'Capture a location first.';
      });
      return;
    }

    // Example: Distance to San Francisco
    final distance = _locationService.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      37.7749, // SF latitude
      -122.4194, // SF longitude
    );

    setState(() {
      _statusMessage =
          'Distance to San Francisco: ${(distance / 1000).toStringAsFixed(2)} km';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Service Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Current location display
            if (_currentLocation != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _locationInfo(_currentLocation!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Last known location display
            if (_lastKnownLocation != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Known Location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _locationInfo(_lastKnownLocation!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Capture buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _captureCurrentLocation,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Capture Current Location (Best for Travel)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _getQuickLocation,
              child: const Text('Capture Quick Location'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _getLastKnownLocation,
              child: const Text('Get Last Known Location'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startLocationUpdates,
                    child: const Text('Start Updates'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _stopLocationUpdates,
                    child: const Text('Stop Updates'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _calculateDistance,
              child: const Text('Calculate Distance to San Francisco'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _clearLocation,
              child: const Text('Clear Location'),
            ),

            const SizedBox(height: 24),
            Text(
              'Accuracy Guide:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('• < 10m: Excellent'),
            const Text('• 10-50m: Good'),
            const Text('• 50-100m: Fair'),
            const Text('• > 100m: Poor'),
          ],
        ),
      ),
    );
  }

  Widget _locationInfo(LocationData location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latitude: ${location.latitude.toStringAsFixed(6)}'),
        Text('Longitude: ${location.longitude.toStringAsFixed(6)}'),
        Text('Accuracy: ${location.accuracy.toStringAsFixed(1)}m '
            '${location.hasAcceptableAccuracy() ? '✓' : '⚠'}'),
        if (location.altitude != null)
          Text('Altitude: ${location.altitude!.toStringAsFixed(1)}m'),
        if (location.speed != null)
          Text('Speed: ${location.speed!.toStringAsFixed(1)} m/s'),
        Text('Timestamp: ${location.timestamp.toString()}'),
        if (location.locationName != null)
          Text('Location: ${location.locationName}'),
      ],
    );
  }
}

/// Example 2: Simple location capture with error handling
class SimpleLocationCaptureExample extends StatelessWidget {
  const SimpleLocationCaptureExample({super.key});

  Future<LocationData?> captureLocation(BuildContext context) async {
    final locationService = LocationService.instance;

    try {
      // Ensure location is enabled
      await locationService.ensureLocationEnabled();

      // Get current location
      final location = await locationService.getCurrentLocation(
        LocationCaptureConfig.forTravelJournal,
      );

      // Check if accuracy is acceptable
      if (!location.hasAcceptableAccuracy()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location accuracy is poor. Try again.'),
            ),
          );
        }
        return null;
      }

      return location;
    } on LocationException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: ${e.message}')),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Location Capture')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final location = await captureLocation(context);
            if (location != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Location: ${location.latitude}, ${location.longitude}',
                  ),
                ),
              );
            }
          },
          child: const Text('Capture Location'),
        ),
      ),
    );
  }
}

/// Example 3: Location capture with journal entry integration
class JournalLocationExample extends StatefulWidget {
  const JournalLocationExample({super.key});

  @override
  State<JournalLocationExample> createState() => _JournalLocationExampleState();
}

class _JournalLocationExampleState extends State<JournalLocationExample> {
  double? _latitude;
  double? _longitude;
  double? _accuracy;
  bool _isCapturing = false;

  Future<void> _captureLocation() async {
    setState(() => _isCapturing = true);

    try {
      final locationService = LocationService.instance;
      await locationService.ensureLocationEnabled();

      final location = await locationService.getCurrentLocation(
        LocationCaptureConfig.forTravelJournal,
      );

      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        _accuracy = location.accuracy;
        _isCapturing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location captured successfully')),
        );
      }
    } on LocationException catch (e) {
      setState(() => _isCapturing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture location: ${e.message}')),
        );
      }
    }
  }

  void _clearLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _accuracy = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal Location Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_latitude != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text('Lat: ${_latitude!.toStringAsFixed(6)}'),
                  subtitle: Text(
                    'Lng: ${_longitude!.toStringAsFixed(6)}\n'
                    'Accuracy: ${_accuracy!.toStringAsFixed(1)}m',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearLocation,
                  ),
                ),
              ),
            ] else ...[
              const Card(
                child: ListTile(
                  leading: Icon(Icons.location_off),
                  title: Text('No location set'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureLocation,
              icon: _isCapturing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isCapturing ? 'Capturing...' : 'Capture Location'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main example screen with navigation
class LocationServiceMainExample extends StatelessWidget {
  const LocationServiceMainExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Service Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select an example:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _ExampleTile(
            title: 'Full Feature Demo',
            subtitle: 'Complete example with all features',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LocationServiceExample(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Simple Capture',
            subtitle: 'Minimal location capture example',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimpleLocationCaptureExample(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Journal Integration',
            subtitle: 'Location capture for journal entries',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const JournalLocationExample(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExampleTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
