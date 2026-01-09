import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/share_location.dart';
import '../../domain/usecases/stop_location_sharing.dart';
import '../../domain/usecases/get_active_location_shares.dart';
import '../../domain/entities/location_update.dart';
import '../state/location_sharing_state.dart';

/// Notifier for managing location sharing state
/// Handles starting, stopping, and monitoring location shares
class LocationSharingNotifier extends StateNotifier<LocationSharingState> {
  final ShareLocationUseCase _shareLocation;
  final StopLocationSharingUseCase _stopLocationSharing;
  final GetActiveLocationSharesUseCase _getActiveShares;

  LocationSharingNotifier({
    required ShareLocationUseCase shareLocation,
    required StopLocationSharingUseCase stopLocationSharing,
    required GetActiveLocationSharesUseCase getActiveShares,
  })  : _shareLocation = shareLocation,
        _stopLocationSharing = stopLocationSharing,
        _getActiveShares = getActiveShares,
        super(const LocationSharingState());

  /// Load active location shares
  Future<void> loadActiveShares() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final activeShares = await _getActiveShares();
      final recentUpdates = await _getActiveShares.getRecentUpdates();

      state = state.copyWith(
        isLoading: false,
        activeShares: activeShares,
        locationUpdates: recentUpdates,
        latestLocation: recentUpdates.isNotEmpty ? recentUpdates.first : null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Share current location with contacts
  Future<void> shareLocation({
    required double latitude,
    required double longitude,
    required List<String> shareWithContactIds,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
    String? placeName,
    int? batteryLevel,
    bool isEmergency = false,
    String? emergencyAlertId,
    String? checkInId,
  }) async {
    if (state.isStarting) return;

    state = state.copyWith(isStarting: true, error: null);
    try {
      final locationUpdate = await _shareLocation(
        latitude: latitude,
        longitude: longitude,
        shareWithContactIds: shareWithContactIds,
        accuracy: accuracy,
        altitude: altitude,
        speed: speed,
        heading: heading,
        address: address,
        placeName: placeName,
        batteryLevel: batteryLevel,
        isEmergency: isEmergency,
        emergencyAlertId: emergencyAlertId,
        checkInId: checkInId,
      );

      final updatedShares = [locationUpdate, ...state.activeShares];
      final updatedUpdates = [locationUpdate, ...state.locationUpdates];

      state = state.copyWith(
        isStarting: false,
        activeShares: updatedShares,
        locationUpdates: updatedUpdates,
        latestLocation: locationUpdate,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isStarting: false,
        error: e.toString(),
      );
    }
  }

  /// Share location with a single contact
  Future<void> shareWithContact({
    required double latitude,
    required double longitude,
    required String contactId,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
    String? placeName,
    int? batteryLevel,
    bool isEmergency = false,
    String? emergencyAlertId,
    String? checkInId,
  }) async {
    await shareLocation(
      latitude: latitude,
      longitude: longitude,
      shareWithContactIds: [contactId],
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      address: address,
      placeName: placeName,
      batteryLevel: batteryLevel,
      isEmergency: isEmergency,
      emergencyAlertId: emergencyAlertId,
      checkInId: checkInId,
    );
  }

  /// Share emergency location with all contacts
  Future<void> shareEmergencyLocation({
    required double latitude,
    required double longitude,
    required List<String> contactIds,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
    String? placeName,
    int? batteryLevel,
    String? emergencyAlertId,
  }) async {
    await shareLocation(
      latitude: latitude,
      longitude: longitude,
      shareWithContactIds: contactIds,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      address: address,
      placeName: placeName,
      batteryLevel: batteryLevel,
      isEmergency: true,
      emergencyAlertId: emergencyAlertId,
    );
  }

  /// Stop sharing location with specific contacts
  Future<void> stopSharing(List<String> contactIds) async {
    if (state.isStopping) return;

    state = state.copyWith(isStopping: true, error: null);
    try {
      await _stopLocationSharing(contactIds);

      // Filter out shares with the specified contacts
      final updatedShares = state.activeShares
          .where((share) =>
              !share.sharedWithContactIds.any((id) => contactIds.contains(id)))
          .toList();

      state = state.copyWith(
        isStopping: false,
        activeShares: updatedShares,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isStopping: false,
        error: e.toString(),
      );
    }
  }

  /// Stop sharing location with a single contact
  Future<void> stopSharingWithContact(String contactId) async {
    await stopSharing([contactId]);
  }

  /// Stop all location sharing
  Future<void> stopAllSharing() async {
    if (state.isStopping) return;

    state = state.copyWith(isStopping: true, error: null);
    try {
      await _stopLocationSharing.stopAll();

      state = state.copyWith(
        isStopping: false,
        activeShares: [],
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isStopping: false,
        error: e.toString(),
      );
    }
  }

  /// Get recent location updates
  Future<void> loadRecentUpdates({
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final updates = await _getActiveShares.getRecentUpdates(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        locationUpdates: updates,
        latestLocation:
            updates.isNotEmpty ? updates.first : state.latestLocation,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get location shares for a specific contact
  Future<List<LocationUpdate>> getSharesForContact(String contactId) async {
    try {
      return await _getActiveShares.getSharesForContact(contactId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Get emergency location shares
  Future<List<LocationUpdate>> getEmergencyShares() async {
    try {
      return await _getActiveShares.getEmergencyShares();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Get location shares for a check-in
  Future<List<LocationUpdate>> getSharesForCheckIn(String checkInId) async {
    try {
      return await _getActiveShares.getSharesForCheckIn(checkInId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh active shares
  Future<void> refresh() async {
    await loadActiveShares();
  }
}
