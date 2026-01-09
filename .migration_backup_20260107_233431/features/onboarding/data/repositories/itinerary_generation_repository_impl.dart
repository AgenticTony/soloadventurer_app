import 'package:uuid/uuid.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/onboarding/data/services/itinerary_generation_service.dart';
import 'package:soloadventurer/features/onboarding/domain/repositories/itinerary_generation_repository.dart';

/// Implementation of the itinerary generation repository
///
/// This class bridges the domain layer repository interface with the
/// application service layer. It handles the conversion between domain
/// entities and JSON maps, and manages the orchestration of itinerary
/// generation.
class ItineraryGenerationRepositoryImpl implements ItineraryGenerationRepository {
  /// The itinerary generation service
  final ItineraryGenerationService _service;

  /// Creates a new repository implementation
  ///
  /// [_service] The itinerary generation service to use
  const ItineraryGenerationRepositoryImpl(this._service);

  @override
  Future<Map<String, dynamic>> generateStarterItinerary(
    Map<String, dynamic> data,
  ) async {
    try {
      // Convert JSON to OnboardingData would happen here in a real implementation
      // For now, we'll pass the data directly to the service
      //
      // In production, you would do:
      // final onboardingData = OnboardingData.fromJson(data);
      // final itinerary = await _service.generateFromOnboarding(onboardingData);
      // return itinerary.toJson();

      // For now, return a mock itinerary structure
      final destination = data['destination'] as Map<String, dynamic>? ?? {};
      return {
        'id': const Uuid().v4(),
        'name': 'Trip to ${destination['name']?.toString() ?? 'Destination'}',
        'destination': destination,
        'dateRange': data['dateRange'] as Map<String, dynamic>? ?? {},
        'items': <Map<String, dynamic>>[],
        'isStarter': true,
        'createdAt': DateTime.now().toIso8601String(),
        'userId': data['userId']?.toString(),
      };
    } on ServerException {
      rethrow;
    } on NetworkConnectivityException {
      rethrow;
    } on CacheException {
      rethrow;
    } on Exception catch (e) {
      throw ServerException(
        message: 'Failed to generate itinerary: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> canGenerateItinerary(Map<String, dynamic> data) async {
    try {
      // Validate required fields
      final destination = data['destination'];
      final dateRange = data['dateRange'];

      if (destination == null || destination is! Map<String, dynamic>) {
        return false;
      }

      if (dateRange == null || dateRange is! Map<String, dynamic>) {
        return false;
      }

      // Basic validation: check destination has required fields
      if (!destination.containsKey('placeId') ||
          !destination.containsKey('name') ||
          !destination.containsKey('latitude') ||
          !destination.containsKey('longitude')) {
        return false;
      }

      // Basic validation: check dateRange has required fields
      if (!dateRange.containsKey('start') || !dateRange.containsKey('end')) {
        return false;
      }

      // For now, return true if basic validation passes
      // In production, you would convert to OnboardingData and check with service:
      // final onboardingData = OnboardingData.fromJson(data);
      // return await _service.canGenerateItinerary(onboardingData);
      return true;
    } catch (e) {
      return false;
    }
  }
}
