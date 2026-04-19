import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/share_location.dart';
import '../../domain/usecases/stop_location_sharing.dart';
import '../../domain/usecases/get_active_location_shares.dart';
import '../../domain/entities/location_update.dart';
import '../state/location_sharing_state.dart';
import 'safety_providers.dart';

part 'location_sharing_provider.g.dart';

/// AsyncNotifier for managing location sharing state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields
@riverpod
class LocationSharing extends _$LocationSharing {
  @override
  Future<LocationSharingState> build() async => LocationSharingState.initial();

  ShareLocationUseCase get _shareLocation =>
      ref.watch(shareLocationUseCaseProvider);
  StopLocationSharingUseCase get _stopLocationSharing =>
      ref.watch(stopLocationSharingUseCaseProvider);
  GetActiveLocationSharesUseCase get _getActiveShares =>
      ref.watch(getActiveLocationSharesUseCaseProvider);

  /// Load active location shares
  Future<void> loadActiveShares() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final activeShares = await _getActiveShares();
      final recentUpdates = await _getActiveShares.getRecentUpdates();

      return (state.value ?? LocationSharingState.initial()).copyWith(
        activeShares: activeShares,
        locationUpdates: recentUpdates,
        latestLocation: recentUpdates.isNotEmpty ? recentUpdates.first : null,
      );
    });
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
    final current = state.value;
    if (current == null || current.isStarting) return;

    state = AsyncData(current.copyWith(isStarting: true));
    state = await AsyncValue.guard(() async {
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

      final updatedShares = [locationUpdate, ...current.activeShares];
      final updatedUpdates = [locationUpdate, ...current.locationUpdates];

      return current.copyWith(
        isStarting: false,
        activeShares: updatedShares,
        locationUpdates: updatedUpdates,
        latestLocation: locationUpdate,
      );
    });
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
    final current = state.value;
    if (current == null || current.isStopping) return;

    state = AsyncData(current.copyWith(isStopping: true));
    state = await AsyncValue.guard(() async {
      await _stopLocationSharing(contactIds);

      final updatedShares = current.activeShares
          .where((share) =>
              !share.sharedWithContactIds.any((id) => contactIds.contains(id)))
          .toList();

      return current.copyWith(
        isStopping: false,
        activeShares: updatedShares,
      );
    });
  }

  /// Stop sharing location with a single contact
  Future<void> stopSharingWithContact(String contactId) async {
    await stopSharing([contactId]);
  }

  /// Stop all location sharing
  Future<void> stopAllSharing() async {
    final current = state.value;
    if (current == null || current.isStopping) return;

    state = AsyncData(current.copyWith(isStopping: true));
    state = await AsyncValue.guard(() async {
      await _stopLocationSharing.stopAll();
      return current.copyWith(
        isStopping: false,
        activeShares: [],
      );
    });
  }

  /// Get recent location updates
  Future<void> loadRecentUpdates({
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updates = await _getActiveShares.getRecentUpdates(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      return (state.value ?? LocationSharingState.initial()).copyWith(
        locationUpdates: updates,
        latestLocation:
            updates.isNotEmpty ? updates.first : (state.value ?? LocationSharingState.initial()).latestLocation,
      );
    });
  }

  /// Get location shares for a specific contact
  Future<List<LocationUpdate>> getSharesForContact(String contactId) async {
    try {
      return await _getActiveShares.getSharesForContact(contactId);
    } catch (_) {
      return [];
    }
  }

  /// Get emergency location shares
  Future<List<LocationUpdate>> getEmergencyShares() async {
    try {
      return await _getActiveShares.getEmergencyShares();
    } catch (_) {
      return [];
    }
  }

  /// Get location shares for a check-in
  Future<List<LocationUpdate>> getSharesForCheckIn(String checkInId) async {
    try {
      return await _getActiveShares.getSharesForCheckIn(checkInId);
    } catch (_) {
      return [];
    }
  }

  /// Refresh active shares
  Future<void> refresh() async {
    await loadActiveShares();
  }
}
