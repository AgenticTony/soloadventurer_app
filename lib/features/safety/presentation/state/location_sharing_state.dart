import 'package:equatable/equatable.dart';
import '../../domain/entities/location_update.dart';

/// State for location sharing functionality
/// Manages active location shares and location updates
class LocationSharingState extends Equatable {
  /// Whether location data is currently loading
  final bool isLoading;

  /// Whether location sharing is being started
  final bool isStarting;

  /// Whether location sharing is being stopped
  final bool isStopping;

  /// List of all location updates
  final List<LocationUpdate> locationUpdates;

  /// List of currently active location shares
  final List<LocationUpdate> activeShares;

  /// Most recent location update
  final LocationUpdate? latestLocation;

  /// Error message if any operation failed
  final String? error;

  /// Whether any location sharing is currently active
  bool get hasActiveShares => activeShares.isNotEmpty;

  /// Whether operations are in progress
  bool get isProcessing => isStarting || isStopping;

  /// Count of contacts currently receiving location updates
  int get activeSharingCount => activeShares
      .fold(0, (sum, update) => sum + update.sharedWithContactIds.length);

  /// Whether there are any emergency location shares active
  bool get hasEmergencySharing => activeShares
      .any((update) => update.isEmergency);

  /// IDs of contacts currently receiving location updates
  List<String> get activeContactIds {
    final ids = <String>{};
    for (final share in activeShares) {
      ids.addAll(share.sharedWithContactIds);
    }
    return ids.toList();
  }

  const LocationSharingState({
    this.isLoading = false,
    this.isStarting = false,
    this.isStopping = false,
    this.locationUpdates = const [],
    this.activeShares = const [],
    this.latestLocation,
    this.error,
  });

  /// Creates a copy of this state with the given fields replaced
  LocationSharingState copyWith({
    bool? isLoading,
    bool? isStarting,
    bool? isStopping,
    List<LocationUpdate>? locationUpdates,
    List<LocationUpdate>? activeShares,
    LocationUpdate? latestLocation,
    String? error,
  }) {
    return LocationSharingState(
      isLoading: isLoading ?? this.isLoading,
      isStarting: isStarting ?? this.isStarting,
      isStopping: isStopping ?? this.isStopping,
      locationUpdates: locationUpdates ?? this.locationUpdates,
      activeShares: activeShares ?? this.activeShares,
      latestLocation: latestLocation ?? this.latestLocation,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isStarting,
        isStopping,
        locationUpdates,
        activeShares,
        latestLocation,
        error,
      ];
}
