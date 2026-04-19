import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/features/journal/data/services/geocoding_service.dart';
import 'package:soloadventurer/features/journal/data/services/location_capture_service.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Widget for manually selecting or editing location for journal entries
///
/// Features:
/// - Search for locations by name/address
/// - List of suggested locations from geocoding
/// - Interactive map for visual location selection
/// - Current location button
/// - Edit existing locations
class LocationPickerWidget extends ConsumerStatefulWidget {
  /// Initial location name (for edit mode)
  final String? initialLocationName;

  /// Initial latitude (for edit mode)
  final double? initialLatitude;

  /// Initial longitude (for edit mode)
  final double? initialLongitude;

  /// Custom padding for the widget
  final EdgeInsetsGeometry? padding;

  const LocationPickerWidget({
    super.key,
    this.initialLocationName,
    this.initialLatitude,
    this.initialLongitude,
    this.padding,
  });

  @override
  ConsumerState<LocationPickerWidget> createState() =>
      _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends ConsumerState<LocationPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  final GeocodingService _geocodingService = GeocodingService.instance;
  final LocationCaptureService _locationService = LocationCaptureService.instance;

  List<GeocodingResult> _searchResults = [];
  bool _isSearching = false;
  bool _isMapLoading = false;
  String? _errorMessage;
  Set<Marker> _markers = {};
  CameraPosition? _cameraPosition;
  GoogleMapController? _mapController;

  // Selected location
  GeocodingResult? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    // Set initial camera position based on existing location or default
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _cameraPosition = CameraPosition(
        target: LatLng(
          widget.initialLatitude!,
          widget.initialLongitude!,
        ),
        zoom: 14,
      );

      // Add marker for existing location
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: LatLng(
            widget.initialLatitude!,
            widget.initialLongitude!,
          ),
          infoWindow: InfoWindow(
            title: widget.initialLocationName ?? 'Selected Location',
          ),
        ),
      );

      _selectedLocation = GeocodingResult(
        name: widget.initialLocationName ?? 'Selected Location',
        latitude: widget.initialLatitude!,
        longitude: widget.initialLongitude!,
      );
    } else {
      // Default to a neutral position (will be updated when user searches or uses current location)
      _cameraPosition = const CameraPosition(
        target: LatLng(0, 0),
        zoom: 2,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Search for locations based on user input
  Future<void> _searchLocations(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await _geocodingService.searchLocations(
        query,
        limit: 5,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } on GeocodingException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isSearching = false;
        _searchResults = [];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to search for locations. Please try again.';
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  /// Select a location from the search results
  void _selectLocation(GeocodingResult location) {
    setState(() {
      _selectedLocation = location;
      _searchController.text = location.name;
      _searchResults = [];

      // Update camera position
      _cameraPosition = CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        zoom: 15,
      );

      // Update marker
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: location.fullAddress,
          ),
        ),
      };
    });

    // Animate map camera to new position
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        15,
      ),
    );

    // Update journal entry provider
    ref.read(journalEntryCreationProvider.notifier).updateLocation(
          locationName: location.name,
          latitude: location.latitude,
          longitude: location.longitude,
          locationAccuracy: null,
        );
  }

  /// Get current device location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isMapLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await _locationService.getCurrentLocation(
        LocationCaptureConfig.forTravelJournal,
      );

      // Get address from coordinates
      final address = await _geocodingService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );

      final locationName = address?.name ?? 'Current Location';

      setState(() {
        _selectedLocation = GeocodingResult(
          name: locationName,
          fullAddress: address?.fullAddress,
          latitude: location.latitude,
          longitude: location.longitude,
          locality: address?.locality,
          administrativeArea: address?.administrativeArea,
          country: address?.country,
        );

        _searchController.text = locationName;

        // Update camera position
        _cameraPosition = CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 15,
        );

        // Update marker
        _markers = {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: locationName,
              snippet: address?.fullAddress,
            ),
          ),
        };

        _isMapLoading = false;
      });

      // Animate map camera
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          15,
        ),
      );

      // Update journal entry provider
      ref.read(journalEntryCreationProvider.notifier).updateLocation(
            locationName: locationName,
            latitude: location.latitude,
            longitude: location.longitude,
            locationAccuracy: location.accuracy,
          );
    } on LocationException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isMapLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location. Please try again.';
        _isMapLoading = false;
      });
    }
  }

  /// Clear selected location
  void _clearLocation() {
    setState(() {
      _selectedLocation = null;
      _searchController.clear();
      _markers = {};
      _errorMessage = null;
    });

    ref.read(journalEntryCreationProvider.notifier).clearLocation();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLocation = _selectedLocation != null;

    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasLocation
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: hasLocation
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with status
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: hasLocation
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Location',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (hasLocation)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Selected',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for a location...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: _isSearching ? null : _searchLocations,
          ),

          const SizedBox(height: 12),

          // Current location button
          if (!hasLocation)
            OutlinedButton.icon(
              onPressed: _isMapLoading ? null : _getCurrentLocation,
              icon: _isMapLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Use Current Location'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
            ),

          // Search results or selected location info
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.place),
                    title: Text(
                      result.name,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: result.fullAddress != null
                        ? Text(
                            result.fullAddress!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () => _selectLocation(result),
                  );
                },
              ),
            ),
          ],

          // Selected location details
          if (hasLocation && _selectedLocation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedLocation!.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedLocation!.fullAddress != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selectedLocation!.fullAddress!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                    'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearLocation,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Mini map preview
          if (hasLocation && _selectedLocation != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: _cameraPosition!,
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                ),
              ),
            ),
          ],

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple button variant for inline location selection
///
/// Use this when you want a compact button that opens the location picker
/// in a dialog or bottom sheet.
class LocationPickerButton extends StatelessWidget {
  /// Current location name (if set)
  final String? currentLocationName;

  /// Button label
  final String label;

  /// Icon to show
  final IconData icon;

  const LocationPickerButton({
    super.key,
    this.currentLocationName,
    this.label = 'Select Location',
    this.icon = Icons.edit_location,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLocation = currentLocationName != null;

    return InkWell(
      onTap: () => _showLocationPickerDialog(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasLocation
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
          color: hasLocation
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: hasLocation ? theme.colorScheme.primary : null,
            ),
            const SizedBox(width: 8),
            Text(
              hasLocation ? currentLocationName! : label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasLocation ? theme.colorScheme.primary : null,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Text(
                      'Select Location',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Location picker
              Expanded(
                child: LocationPickerWidget(
                  initialLocationName: currentLocationName,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
