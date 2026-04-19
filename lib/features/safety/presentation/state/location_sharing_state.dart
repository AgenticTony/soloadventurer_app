import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/location_update.dart';

part 'location_sharing_state.freezed.dart';

/// State for location sharing functionality.
///
/// Riverpod 3.0 Compliant:
/// - Uses @freezed with sealed class as required by Freezed 3.2.x with Dart 3.10
/// - Loading/error handled by AsyncNotifier/AsyncValue, NOT state fields
@freezed
sealed class LocationSharingState with _$LocationSharingState {
  const LocationSharingState._();
  const factory LocationSharingState({
    /// Whether location sharing is being started
    @Default(false) bool isStarting,

    /// Whether location sharing is being stopped
    @Default(false) bool isStopping,

    /// List of all location updates
    @Default([]) List<LocationUpdate> locationUpdates,

    /// List of currently active location shares
    @Default([]) List<LocationUpdate> activeShares,

    /// Most recent location update
    LocationUpdate? latestLocation,
  }) = _LocationSharingState;

  factory LocationSharingState.initial() => const LocationSharingState();

  /// Whether any location sharing is currently active
  bool get hasActiveShares => activeShares.isNotEmpty;

  /// Whether operations are in progress
  bool get isProcessing => isStarting || isStopping;

  /// Count of contacts currently receiving location updates
  int get activeSharingCount => activeShares.fold(
      0, (sum, update) => sum + update.sharedWithContactIds.length);

  /// Whether there are any emergency location shares active
  bool get hasEmergencySharing =>
      activeShares.any((update) => update.isEmergency);

  /// IDs of contacts currently receiving location updates
  List<String> get activeContactIds {
    final ids = <String>{};
    for (final share in activeShares) {
      ids.addAll(share.sharedWithContactIds);
    }
    return ids.toList();
  }
}
