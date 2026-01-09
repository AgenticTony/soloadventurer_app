import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';
import 'package:soloadventurer/features/safety/domain/providers/safety_usecase_providers.dart';

part 'location_sharing_notifier.freezed.dart';
part 'location_sharing_notifier.g.dart';

/// Data class for location sharing state
@freezed
class LocationSharingData with _$LocationSharingData {
  const LocationSharingData._();

  const factory LocationSharingData({
    @Default([]) List<LocationUpdate> locationUpdates,
    @Default([]) List<LocationUpdate> activeShares,
    LocationUpdate? latestLocation,
  }) = _LocationSharingData;

  /// Whether any location sharing is currently active
  bool get hasActiveShares => activeShares.isNotEmpty;

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
}

/// Notifier for managing location sharing state
/// Handles starting, stopping, and monitoring location shares
@riverpod
class LocationSharingNotifier extends _$LocationSharingNotifier {
  /// Load active location shares
  Future<void> loadActiveShares() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final activeShares = await ref.read(getActiveLocationSharesUseCaseProvider)();
      final recentUpdates = await ref.read(getActiveLocationSharesUseCaseProvider).getRecentUpdates();

      return LocationSharingData(
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
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final locationUpdate = await ref.read(shareLocationUseCaseProvider)(
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

      final currentData = state.value ?? const LocationSharingData();
      final updatedShares = [locationUpdate, ...currentData.activeShares];
      final updatedUpdates = [locationUpdate, ...currentData.locationUpdates];

      return currentData.copyWith(
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
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(stopLocationSharingUseCaseProvider)(contactIds);

      final currentData = state.value ?? const LocationSharingData();
      final updatedShares = currentData.activeShares
          .where((share) =>
              !share.sharedWithContactIds
                  .any((id) => contactIds.contains(id)))
          .toList();

      return currentData.copyWith(activeShares: updatedShares);
    });
  }

  /// Stop sharing location with a single contact
  Future<void> stopSharingWithContact(String contactId) async {
    await stopSharing([contactId]);
  }

  /// Stop all location sharing
  Future<void> stopAllSharing() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(stopLocationSharingUseCaseProvider).stopAll();

      return const LocationSharingData();
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
      final updates = await ref.read(getActiveLocationSharesUseCaseProvider).getRecentUpdates(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      final currentData = state.value ?? const LocationSharingData();
      return currentData.copyWith(
        locationUpdates: updates,
        latestLocation: updates.isNotEmpty ? updates.first : currentData.latestLocation,
      );
    });
  }

  /// Get location shares for a specific contact
  Future<List<LocationUpdate>> getSharesForContact(String contactId) async {
    try {
      return await ref.read(getActiveLocationSharesUseCaseProvider).getSharesForContact(contactId);
    } catch (e) {
      return [];
    }
  }

  /// Get emergency location shares
  Future<List<LocationUpdate>> getEmergencyShares() async {
    try {
      return await ref.read(getActiveLocationSharesUseCaseProvider).getEmergencyShares();
    } catch (e) {
      return [];
    }
  }

  /// Get location shares for a check-in
  Future<List<LocationUpdate>> getSharesForCheckIn(String checkInId) async {
    try {
      return await ref.read(getActiveLocationSharesUseCaseProvider).getSharesForCheckIn(checkInId);
    } catch (e) {
      return [];
    }
  }

  /// Refresh active shares
  Future<void> refresh() async {
    await loadActiveShares();
  }

  @override
  AsyncValue<LocationSharingData> build() {
    // Don't auto-initialize - let consumers explicitly call loadActiveShares()
    // This allows for better control over when initialization happens
    return const AsyncValue.data(LocationSharingData());
  }
}
