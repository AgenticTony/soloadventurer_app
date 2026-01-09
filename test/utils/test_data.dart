import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';
import 'package:soloadventurer/features/travel/domain/models/travel_preference.dart';

/// Factory functions for creating test data.
class TestData {
  /// Creates a test user with the given parameters.
  static User createUser({
    String id = 'test-user-id',
    String username = 'testuser',
    String email = 'test@example.com',
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? accessToken,
    String? idToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return User(
      id: id,
      username: username,
      email: email,
      createdAt: createdAt ?? DateTime.now(),
      lastLoginAt: lastLoginAt,
      accessToken: accessToken,
      idToken: idToken,
      refreshToken: refreshToken,
      tokenExpiresAt: tokenExpiresAt,
    );
  }

  /// Creates a test trip with the given parameters.
  static Trip createTrip({
    String id = 'test-trip-id',
    String userId = 'test-user-id',
    String title = 'Test Trip',
    String? description = 'A test trip for testing purposes',
    DateTime? startDate,
    DateTime? endDate,
    String destination = 'Test Destination',
    String status = 'planning',
    int budget = 1000,
    String? coverImageUrl,
    List<String>? travelCompanionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id,
      userId: userId,
      title: title,
      description: description,
      startDate: startDate ?? DateTime.now().add(const Duration(days: 7)),
      endDate: endDate ?? DateTime.now().add(const Duration(days: 14)),
      destination: destination,
      status: status,
      budget: budget,
      coverImageUrl: coverImageUrl,
      travelCompanionIds: travelCompanionIds,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Creates test travel preferences with the given parameters.
  static TravelPreference createTravelPreference({
    String id = 'test-preference-id',
    String userId = 'test-user-id',
    List<String> travelStyles = const ['adventure', 'cultural'],
    List<String> accommodationTypes = const ['hotel', 'airbnb'],
    List<String> transportationTypes = const ['airplane', 'car'],
    int minBudget = 50,
    int maxBudget = 200,
    int minTripDuration = 3,
    int maxTripDuration = 14,
    List<String> preferredDestinations = const ['Mountains', 'Beach'],
    List<String> avoidDestinations = const [],
    bool isFlexibleDates = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelPreference(
      id: id,
      userId: userId,
      travelStyles: travelStyles,
      accommodationTypes: accommodationTypes,
      transportationTypes: transportationTypes,
      minBudget: minBudget,
      maxBudget: maxBudget,
      minTripDuration: minTripDuration,
      maxTripDuration: maxTripDuration,
      preferredDestinations: preferredDestinations,
      avoidDestinations: avoidDestinations,
      isFlexibleDates: isFlexibleDates,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Creates a list of test users.
  static List<User> createUsers(int count) {
    return List.generate(
      count,
      (index) => createUser(
        id: 'user-$index',
        username: 'user$index',
        email: 'user$index@example.com',
      ),
    );
  }

  /// Creates a list of test trips.
  static List<Trip> createTrips(int count, {String userId = 'test-user-id'}) {
    return List.generate(
      count,
      (index) => createTrip(
        id: 'trip-$index',
        userId: userId,
        title: 'Trip $index',
        destination: 'Destination $index',
      ),
    );
  }

  /// Creates test authentication data.
  static Map<String, String> createAuthData({
    String accessToken = 'test-access-token',
    String refreshToken = 'test-refresh-token',
    String idToken = 'test-id-token',
  }) {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'idToken': idToken,
    };
  }
}
