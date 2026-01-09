import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/error/safety_exceptions.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';

/// Implementation of [SafetyRemoteDataSource] using GraphQL API
///
/// This implementation uses the ApiClient to communicate with the backend
/// via GraphQL queries and mutations for all safety-related operations.
class SafetyRemoteDataSourceImpl implements SafetyRemoteDataSource {
  final ApiClient _apiClient;

  /// GraphQL endpoint for safety operations
  final String _baseUrl;

  /// Creates a new [SafetyRemoteDataSourceImpl]
  SafetyRemoteDataSourceImpl({
    required ApiClient apiClient,
    required String baseUrl,
  })  : _apiClient = apiClient,
        _baseUrl = baseUrl;

  // ==================== Helper Methods ====================

  /// Execute a GraphQL query
  Future<Map<String, dynamic>> _query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      if (_apiClient.isOffline) {
        throw const SafetyOfflineException();
      }

      final response = await _apiClient.post(
        '/graphql',
        data: {
          'query': query,
          'variables': variables,
        },
      );

      if (response.containsKey('errors')) {
        final errors = response['errors'] as List;
        final errorMessage = errors.isNotEmpty
            ? errors[0]['message']?.toString() ?? 'GraphQL error'
            : 'GraphQL error';
        throw _handleGraphQLError(errorMessage);
      }

      return response;
    } on SafetyException {
      rethrow;
    } catch (e) {
      debugPrint('GraphQL query error: $e');
      throw const SafetySyncFailedException(
        'Failed to communicate with server',
      );
    }
  }

  /// Execute a GraphQL mutation
  Future<Map<String, dynamic>> _mutation(
    String mutation, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      if (_apiClient.isOffline) {
        throw const SafetyOfflineException();
      }

      final response = await _apiClient.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': variables,
        },
      );

      if (response.containsKey('errors')) {
        final errors = response['errors'] as List;
        final errorMessage = errors.isNotEmpty
            ? errors[0]['message']?.toString() ?? 'GraphQL error'
            : 'GraphQL error';
        throw _handleGraphQLError(errorMessage);
      }

      return response;
    } on SafetyException {
      rethrow;
    } catch (e) {
      debugPrint('GraphQL mutation error: $e');
      throw const SafetySyncFailedException(
        'Failed to communicate with server',
      );
    }
  }

  /// Map GraphQL error messages to SafetyExceptions
  SafetyException _handleGraphQLError(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();

    // Trusted contact errors
    if (lowerMessage.contains('trusted contact not found')) {
      return const TrustedContactNotFoundException();
    }
    if (lowerMessage.contains('trusted contact already exists')) {
      return const TrustedContactAlreadyExistsException();
    }
    if (lowerMessage.contains('invalid contact information')) {
      return const InvalidContactInformationException();
    }
    if (lowerMessage.contains('trusted contact limit exceeded')) {
      return const TrustedContactLimitExceededException();
    }

    // Check-in errors
    if (lowerMessage.contains('check-in not found')) {
      return const CheckInNotFoundException();
    }
    if (lowerMessage.contains('check-in already completed')) {
      return const CheckInAlreadyCompletedException();
    }
    if (lowerMessage.contains('check-in is overdue')) {
      return CheckInOverdueException(DateTime.now());
    }
    if (lowerMessage.contains('invalid check-in schedule')) {
      return const InvalidCheckInScheduleException();
    }
    if (lowerMessage.contains('failed to create check-in')) {
      return const CheckInCreationFailedException();
    }
    if (lowerMessage.contains('check-in cannot be canceled')) {
      return const CheckInCannotBeCanceledException();
    }

    // Location sharing errors
    if (lowerMessage.contains('location service unavailable')) {
      return const LocationServiceUnavailableException();
    }
    if (lowerMessage.contains('location permission denied')) {
      return const LocationPermissionDeniedException();
    }
    if (lowerMessage.contains('invalid location data')) {
      return const InvalidLocationDataException();
    }
    if (lowerMessage.contains('location sharing not active')) {
      return const LocationSharingNotActiveException();
    }
    if (lowerMessage.contains('failed to start location sharing')) {
      return const LocationSharingFailedException();
    }
    if (lowerMessage.contains('failed to update location')) {
      return const LocationUpdateFailedException();
    }

    // Emergency SOS errors
    if (lowerMessage.contains('emergency sos already active')) {
      return const EmergencySOSAlreadyActiveException();
    }
    if (lowerMessage.contains('failed to trigger emergency sos')) {
      return const EmergencySOSTriggerFailedException();
    }
    if (lowerMessage.contains('no trusted contacts configured')) {
      return const NoTrustedContactsConfiguredException();
    }

    // Safety alert errors
    if (lowerMessage.contains('safety alert not found')) {
      return const SafetyAlertNotFoundException();
    }
    if (lowerMessage.contains('safety alert already acknowledged')) {
      return const SafetyAlertAlreadyAcknowledgedException();
    }
    if (lowerMessage.contains('safety alert already resolved')) {
      return const SafetyAlertAlreadyResolvedException();
    }
    if (lowerMessage.contains('failed to create safety alert')) {
      return const SafetyAlertCreationFailedException();
    }

    // Default error
    return SafetyException(errorMessage, code: 'unknown_error');
  }

  // ==================== Trusted Contacts Operations ====================

  @override
  Future<TrustedContact> addTrustedContact(TrustedContact contact) async {
    try {
      const mutation = '''
        mutation AddTrustedContact(
          \$name: String!
          \$email: String
          \$phoneNumber: String
          \$contactSource: String!
          \$notificationPreference: String!
        ) {
          addTrustedContact(
            name: \$name
            email: \$email
            phoneNumber: \$phoneNumber
            contactSource: \$contactSource
            notificationPreference: \$notificationPreference
          ) {
            id
            userId
            name
            email
            phoneNumber
            contactSource
            receivesCheckInNotifications
            receivesEmergencyAlerts
            receivesLocationUpdates
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _mutation(mutation, variables: {
        'name': contact.name,
        'email': contact.email,
        'phoneNumber': contact.phoneNumber,
        'contactSource': contact.source.name,
        'notificationPreference': 'all',
      });

      final data = response['addTrustedContact'] as Map<String, dynamic>;
      return TrustedContact.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const CheckInCreationFailedException(
        'Failed to add trusted contact',
      );
    }
  }

  @override
  Future<void> removeTrustedContact(String contactId) async {
    try {
      const mutation = '''
        mutation RemoveTrustedContact(\$contactId: ID!) {
          removeTrustedContact(contactId: \$contactId) {
            id
            success
          }
        }
      ''';

      await _mutation(mutation, variables: {'contactId': contactId});
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to remove trusted contact',
      );
    }
  }

  @override
  Future<TrustedContact> updateTrustedContact(TrustedContact contact) async {
    try {
      const mutation = '''
        mutation UpdateTrustedContact(
          \$contactId: ID!
          \$name: String
          \$email: String
          \$phoneNumber: String
          \$receivesCheckInNotifications: Boolean
          \$receivesEmergencyAlerts: Boolean
          \$receivesLocationUpdates: Boolean
        ) {
          updateTrustedContact(
            contactId: \$contactId
            name: \$name
            email: \$email
            phoneNumber: \$phoneNumber
            receivesCheckInNotifications: \$receivesCheckInNotifications
            receivesEmergencyAlerts: \$receivesEmergencyAlerts
            receivesLocationUpdates: \$receivesLocationUpdates
          ) {
            id
            userId
            name
            email
            phoneNumber
            contactSource
            receivesCheckInNotifications
            receivesEmergencyAlerts
            receivesLocationUpdates
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _mutation(mutation, variables: {
        'contactId': contact.id,
        'name': contact.name,
        'email': contact.email,
        'phoneNumber': contact.phoneNumber,
        'receivesCheckInNotifications': contact.receivesCheckIns,
        'receivesEmergencyAlerts': contact.receivesEmergencyAlerts,
        'receivesLocationUpdates': contact.locationSharingEnabled,
      });

      final data = response['updateTrustedContact'] as Map<String, dynamic>;
      return TrustedContact.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to update trusted contact',
      );
    }
  }

  @override
  Future<List<TrustedContact>> getTrustedContacts() async {
    try {
      const query = '''
        query GetTrustedContacts {
          getTrustedContacts {
            id
            userId
            name
            email
            phoneNumber
            contactSource
            receivesCheckInNotifications
            receivesEmergencyAlerts
            receivesLocationUpdates
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _query(query);
      final data = response['getTrustedContacts'] as List;
      return data.map((json) => TrustedContact.fromJson(json)).toList();
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get trusted contacts',
      );
    }
  }

  @override
  Future<TrustedContact> getTrustedContact(String contactId) async {
    try {
      const query = '''
        query GetTrustedContact(\$contactId: ID!) {
          getTrustedContact(contactId: \$contactId) {
            id
            userId
            name
            email
            phoneNumber
            contactSource
            receivesCheckInNotifications
            receivesEmergencyAlerts
            receivesLocationUpdates
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _query(query, variables: {'contactId': contactId});
      final data = response['getTrustedContact'] as Map<String, dynamic>;
      return TrustedContact.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get trusted contact',
      );
    }
  }

  // ==================== Check-in Operations ====================

  @override
  Future<CheckIn> createCheckIn(CheckIn checkIn) async {
    try {
      const mutation = '''
        mutation CreateCheckIn(
          \$userId: ID!
          \$scheduledTime: String!
          \$deadline: String
          \$location: LocationInput
          \$statusMessage: String
          \$notifyContactIds: [String!]
          \$tripId: String
          \$triggerType: String
        ) {
          createCheckIn(
            userId: \$userId
            scheduledTime: \$scheduledTime
            deadline: \$deadline
            location: \$location
            statusMessage: \$statusMessage
            notifyContactIds: \$notifyContactIds
            tripId: \$tripId
            triggerType: \$triggerType
          ) {
            id
            userId
            scheduledTime
            deadline
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            status
            statusMessage
            triggerType
            completedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _mutation(mutation, variables: {
        'userId': checkIn.userId,
        'scheduledTime': checkIn.scheduledTime?.toIso8601String() ?? '',
        'deadline': checkIn.deadline?.toIso8601String(),
        'location': checkIn.location?.toJson(),
        'statusMessage': checkIn.statusMessage,
        'notifyContactIds': checkIn.notifyContactIds,
        'tripId': checkIn.tripId,
        'triggerType': checkIn.triggerType.name,
      });

      final data = response['createCheckIn'] as Map<String, dynamic>;
      return CheckIn.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const CheckInCreationFailedException();
    }
  }

  @override
  Future<CheckIn> completeCheckIn({
    required String checkInId,
    required CheckInLocation location,
    String? statusMessage,
  }) async {
    try {
      const mutation = '''
        mutation CompleteCheckIn(
          \$checkInId: ID!
          \$location: LocationInput!
          \$statusMessage: String
        ) {
          completeCheckIn(
            checkInId: \$checkInId
            location: \$location
            statusMessage: \$statusMessage
          ) {
            id
            userId
            scheduledTime
            deadline
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            status
            statusMessage
            triggerType
            completedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _mutation(mutation, variables: {
        'checkInId': checkInId,
        'location': location.toJson(),
        'statusMessage': statusMessage,
      });

      final data = response['completeCheckIn'] as Map<String, dynamic>;
      return CheckIn.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to complete check-in',
      );
    }
  }

  @override
  Future<CheckIn> scheduleCheckIn({
    required String userId,
    required DateTime scheduledTime,
    DateTime? deadline,
    CheckInLocation? location,
    String? statusMessage,
    List<String>? notifyContactIds,
    String? tripId,
    CheckInTriggerType? triggerType,
  }) async {
    try {
      const mutation = '''
        mutation ScheduleCheckIn(
          \$userId: ID!
          \$scheduledTime: String!
          \$deadline: String
          \$location: LocationInput
          \$statusMessage: String
          \$notifyContactIds: [String!]
          \$tripId: String
          \$triggerType: String
        ) {
          scheduleCheckIn(
            userId: \$userId
            scheduledTime: \$scheduledTime
            deadline: \$deadline
            location: \$location
            statusMessage: \$statusMessage
            notifyContactIds: \$notifyContactIds
            tripId: \$tripId
            triggerType: \$triggerType
          ) {
            id
            userId
            scheduledTime
            deadline
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            status
            statusMessage
            triggerType
            completedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _mutation(mutation, variables: {
        'userId': userId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'location': location?.toJson(),
        'statusMessage': statusMessage,
        'notifyContactIds': notifyContactIds,
        'tripId': tripId,
        'triggerType': triggerType?.name,
      });

      final data = response['scheduleCheckIn'] as Map<String, dynamic>;
      return CheckIn.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const CheckInCreationFailedException(
        'Failed to schedule check-in',
      );
    }
  }

  @override
  Future<void> cancelCheckIn(String checkInId) async {
    try {
      const mutation = '''
        mutation CancelCheckIn(\$checkInId: ID!) {
          cancelCheckIn(checkId: \$checkInId) {
            id
            success
          }
        }
      ''';

      await _mutation(mutation, variables: {'checkInId': checkInId});
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to cancel check-in',
      );
    }
  }

  @override
  Future<List<CheckIn>> getUpcomingCheckIns() async {
    try {
      const query = '''
        query GetUpcomingCheckIns {
          getUpcomingCheckIns {
            id
            userId
            scheduledTime
            deadline
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            status
            statusMessage
            triggerType
            completedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _query(query);
      final data = response['getUpcomingCheckIns'] as List;
      return data.map((json) => CheckIn.fromJson(json)).toList();
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get upcoming check-ins',
      );
    }
  }

  @override
  Future<List<CheckIn>> getAllCheckIns() async {
    try {
      const query = '''
        query GetAllCheckIns {
          getAllCheckIns {
            id
            userId
            scheduledTime
            deadline
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            status
            statusMessage
            triggerType
            completedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _query(query);
      final data = response['getAllCheckIns'] as List;
      return data.map((json) => CheckIn.fromJson(json)).toList();
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get all check-ins',
      );
    }
  }

  @override
  Future<CheckIn> getCheckIn(String checkInId) async {
    try {
      const query = '''
        query GetCheckIn(\$checkInId: ID!) {
          getCheckIn(checkInId: \$checkInId) {
            id
            userId
            scheduledTime
            deadline
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            status
            statusMessage
            triggerType
            completedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _query(query, variables: {'checkInId': checkInId});
      final data = response['getCheckIn'] as Map<String, dynamic>;
      return CheckIn.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get check-in',
      );
    }
  }

  @override
  Future<List<CheckIn>> getCheckInsByTrip(String tripId) async {
    try {
      const query = '''
        query GetCheckInsByTrip(\$tripId: ID!) {
          getCheckInsByTrip(tripId: \$tripId) {
            id
            userId
            scheduledTime
            deadline
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            status
            statusMessage
            triggerType
            completedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _query(query, variables: {'tripId': tripId});
      final data = response['getCheckInsByTrip'] as List;
      return data.map((json) => CheckIn.fromJson(json)).toList();
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get check-ins for trip',
      );
    }
  }

  @override
  Future<CheckIn> updateCheckInStatus({
    required String checkInId,
    required CheckInStatus status,
  }) async {
    try {
      const mutation = '''
        mutation UpdateCheckInStatus(
          \$checkInId: ID!
          \$status: String!
        ) {
          updateCheckInStatus(
            checkInId: \$checkInId
            status: \$status
          ) {
            id
            userId
            scheduledTime
            deadline
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            status
            statusMessage
            triggerType
            completedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _mutation(mutation, variables: {
        'checkInId': checkInId,
        'status': status.name,
      });

      final data = response['updateCheckInStatus'] as Map<String, dynamic>;
      return CheckIn.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to update check-in status',
      );
    }
  }

  // ==================== Location Sharing Operations ====================

  @override
  Future<LocationUpdate> shareLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
    String? placeName,
    required List<String> shareWithContactIds,
    int? batteryLevel,
    bool isEmergency = false,
    String? emergencyAlertId,
    String? checkInId,
  }) async {
    try {
      const mutation = '''
        mutation ShareLocation(
          \$latitude: Float!
          \$longitude: Float!
          \$accuracy: Float
          \$altitude: Float
          \$speed: Float
          \$heading: Float
          \$address: String
          \$placeName: String
          \$shareWithContactIds: [String!]!
          \$batteryLevel: Int
          \$isEmergency: Boolean
          \$emergencyAlertId: String
          \$checkInId: String
        ) {
          shareLocation(
            latitude: \$latitude
            longitude: \$longitude
            accuracy: \$accuracy
            altitude: \$altitude
            speed: \$speed
            heading: \$heading
            address: \$address
            placeName: \$placeName
            shareWithContactIds: \$shareWithContactIds
            batteryLevel: \$batteryLevel
            isEmergency: \$isEmergency
            emergencyAlertId: \$emergencyAlertId
            checkInId: \$checkInId
          ) {
            id
            userId
            location {
              latitude
              longitude
              accuracy
              altitude
              speed
              heading
              timestamp
            }
            address
            placeName
            sharedWithContactIds
            sharingStatus
            batteryLevel
            isEmergencyShare
            emergencyAlertId
            checkInId
            startedAt
            expiresAt
            createdAt
          }
        }
      ''';

      final response = await _mutation(mutation, variables: {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'altitude': altitude,
        'speed': speed,
        'heading': heading,
        'address': address,
        'placeName': placeName,
        'shareWithContactIds': shareWithContactIds,
        'batteryLevel': batteryLevel,
        'isEmergency': isEmergency,
        'emergencyAlertId': emergencyAlertId,
        'checkInId': checkInId,
      });

      final data = response['shareLocation'] as Map<String, dynamic>;
      return LocationUpdate.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const LocationSharingFailedException();
    }
  }

  @override
  Future<void> stopLocationSharing(List<String> contactIds) async {
    try {
      const mutation = '''
        mutation StopLocationSharing(\$contactIds: [String!]!) {
          stopLocationSharing(contactIds: \$contactIds) {
            success
          }
        }
      ''';

      await _mutation(mutation, variables: {'contactIds': contactIds});
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to stop location sharing',
      );
    }
  }

  @override
  Future<void> stopAllLocationSharing() async {
    try {
      const mutation = '''
        mutation StopAllLocationSharing {
          stopAllLocationSharing {
            success
          }
        }
      ''';

      await _mutation(mutation);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to stop all location sharing',
      );
    }
  }

  @override
  Future<List<LocationUpdate>> getActiveLocationShares() async {
    try {
      const query = '''
        query GetActiveLocationShares {
          getActiveLocationShares {
            id
            userId
            location {
              latitude
              longitude
              accuracy
              altitude
              speed
              heading
              timestamp
            }
            address
            placeName
            sharedWithContactIds
            sharingStatus
            batteryLevel
            isEmergencyShare
            emergencyAlertId
            checkInId
            startedAt
            expiresAt
            createdAt
          }
        }
      ''';

      final response = await _query(query);
      final data = response['getActiveLocationShares'] as List;
      return data.map((json) => LocationUpdate.fromJson(json)).toList();
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get active location shares',
      );
    }
  }

  @override
  Future<List<LocationUpdate>> getLocationUpdates({
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      const query = '''
        query GetLocationUpdates(
          \$limit: Int!
          \$startDate: String
          \$endDate: String
        ) {
          getLocationUpdates(
            limit: \$limit
            startDate: \$startDate
            endDate: \$endDate
          ) {
            id
            userId
            location {
              latitude
              longitude
              accuracy
              altitude
              speed
              heading
              timestamp
            }
            address
            placeName
            sharedWithContactIds
            sharingStatus
            batteryLevel
            isEmergencyShare
            emergencyAlertId
            checkInId
            startedAt
            expiresAt
            createdAt
          }
        }
      ''';

      final response = await _query(query, variables: {
        'limit': limit,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      });

      final data = response['getLocationUpdates'] as List;
      return data.map((json) => LocationUpdate.fromJson(json)).toList();
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get location updates',
      );
    }
  }

  @override
  Future<void> updateLocationSharingPermission({
    required String contactId,
    required bool enabled,
  }) async {
    try {
      const mutation = '''
        mutation UpdateLocationSharingPermission(
          \$contactId: ID!
          \$enabled: Boolean!
        ) {
          updateLocationSharingPermission(
            contactId: \$contactId
            enabled: \$enabled
          ) {
            success
          }
        }
      ''';

      await _mutation(mutation, variables: {
        'contactId': contactId,
        'enabled': enabled,
      });
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to update location sharing permission',
      );
    }
  }

  // ==================== Emergency SOS Operations ====================

  @override
  Future<SafetyAlert> triggerEmergencySOS({
    required String userId,
    String? message,
    required SafetyAlertLocation location,
    required List<String> notifyContactIds,
    int? batteryLevel,
    String? tripId,
  }) async {
    try {
      const mutation = '''
        mutation TriggerEmergencySOS(
          \$userId: ID!
          \$message: String
          \$location: SafetyAlertLocationInput!
          \$notifyContactIds: [String!]!
          \$batteryLevel: Int
          \$tripId: String
        ) {
          triggerEmergencySOS(
            userId: \$userId
            message: \$message
            location: \$location
            notifyContactIds: \$notifyContactIds
            batteryLevel: \$batteryLevel
            tripId: \$tripId
          ) {
            id
            userId
            alertType
            status
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            message
            notifiedContactIds
            acknowledgedByContactIds
            batteryLevel
            triggeredAt
            resolvedAt
            canceledAt
            tripId
            checkInId
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _mutation(mutation, variables: {
        'userId': userId,
        'message': message,
        'location': location.toJson(),
        'notifyContactIds': notifyContactIds,
        'batteryLevel': batteryLevel,
        'tripId': tripId,
      });

      final data = response['triggerEmergencySOS'] as Map<String, dynamic>;
      return SafetyAlert.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const EmergencySOSTriggerFailedException();
    }
  }

  @override
  Future<SafetyStatus> updateSafetyStatus({
    required SafetyStatusType status,
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? safetyAlertId,
    String? checkInId,
  }) async {
    try {
      const mutation = '''
        mutation UpdateSafetyStatus(
          \$status: String!
          \$message: String
          \$location: SafetyStatusLocationInput
          \$batteryLevel: Int
          \$safetyAlertId: String
          \$checkInId: String
        ) {
          updateSafetyStatus(
            status: \$status
            message: \$message
            location: \$location
            batteryLevel: \$batteryLevel
            safetyAlertId: \$safetyAlertId
            checkInId: \$checkInId
          ) {
            id
            userId
            status
            message
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            batteryLevel
            safetyAlertId
            checkInId
            updatedAt
          }
        }
      ''';

      final response = await _mutation(mutation, variables: {
        'status': status.name,
        'message': message,
        'location': location?.toJson(),
        'batteryLevel': batteryLevel,
        'safetyAlertId': safetyAlertId,
        'checkInId': checkInId,
      });

      final data = response['updateSafetyStatus'] as Map<String, dynamic>;
      return SafetyStatus.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to update safety status',
      );
    }
  }

  @override
  Future<SafetyStatus> getSafetyStatus() async {
    try {
      const query = '''
        query GetSafetyStatus {
          getSafetyStatus {
            id
            userId
            status
            message
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            batteryLevel
            safetyAlertId
            checkInId
            updatedAt
          }
        }
      ''';

      final response = await _query(query);
      final data = response['getSafetyStatus'] as Map<String, dynamic>;
      return SafetyStatus.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get safety status',
      );
    }
  }

  @override
  Future<SafetyStatus> getSafetyStatusForUser(String userId) async {
    try {
      const query = '''
        query GetSafetyStatusForUser(\$userId: ID!) {
          getSafetyStatusForUser(userId: \$userId) {
            id
            userId
            status
            message
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            batteryLevel
            safetyAlertId
            checkInId
            updatedAt
          }
        }
      ''';

      final response = await _query(query, variables: {'userId': userId});
      final data = response['getSafetyStatusForUser'] as Map<String, dynamic>;
      return SafetyStatus.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get safety status for user',
      );
    }
  }

  // ==================== Safety Alerts Operations ====================

  @override
  Future<List<SafetyAlert>> getSafetyAlerts() async {
    try {
      const query = '''
        query GetSafetyAlerts {
          getSafetyAlerts {
            id
            userId
            alertType
            status
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            message
            notifiedContactIds
            acknowledgedByContactIds
            batteryLevel
            triggeredAt
            resolvedAt
            canceledAt
            tripId
            checkInId
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _query(query);
      final data = response['getSafetyAlerts'] as List;
      return data.map((json) => SafetyAlert.fromJson(json)).toList();
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get safety alerts',
      );
    }
  }

  @override
  Future<SafetyAlert> getSafetyAlert(String alertId) async {
    try {
      const query = '''
        query GetSafetyAlert(\$alertId: ID!) {
          getSafetyAlert(alertId: \$alertId) {
            id
            userId
            alertType
            status
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            message
            notifiedContactIds
            acknowledgedByContactIds
            batteryLevel
            triggeredAt
            resolvedAt
            canceledAt
            tripId
            checkInId
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _query(query, variables: {'alertId': alertId});
      final data = response['getSafetyAlert'] as Map<String, dynamic>;
      return SafetyAlert.fromJson(data);
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get safety alert',
      );
    }
  }

  @override
  Future<List<SafetyAlert>> getRecentSafetyAlerts({
    int limit = 20,
    SafetyAlertType? type,
  }) async {
    try {
      const query = '''
        query GetRecentSafetyAlerts(\$limit: Int!, \$type: String) {
          getRecentSafetyAlerts(limit: \$limit, type: \$type) {
            id
            userId
            alertType
            status
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            message
            notifiedContactIds
            acknowledgedByContactIds
            batteryLevel
            triggeredAt
            resolvedAt
            canceledAt
            tripId
            checkInId
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _query(query, variables: {
        'limit': limit,
        'type': type?.name,
      });

      final data = response['getRecentSafetyAlerts'] as List;
      return data.map((json) => SafetyAlert.fromJson(json)).toList();
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get recent safety alerts',
      );
    }
  }

  @override
  Future<void> acknowledgeSafetyAlert(String alertId, String contactId) async {
    try {
      const mutation = '''
        mutation AcknowledgeSafetyAlert(
          \$alertId: ID!
          \$contactId: ID!
        ) {
          acknowledgeSafetyAlert(
            alertId: \$alertId
            contactId: \$contactId
          ) {
            success
          }
        }
      ''';

      await _mutation(mutation, variables: {
        'alertId': alertId,
        'contactId': contactId,
      });
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to acknowledge safety alert',
      );
    }
  }

  @override
  Future<void> resolveSafetyAlert(String alertId) async {
    try {
      const mutation = '''
        mutation ResolveSafetyAlert(\$alertId: ID!) {
          resolveSafetyAlert(alertId: \$alertId) {
            success
          }
        }
      ''';

      await _mutation(mutation, variables: {'alertId': alertId});
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to resolve safety alert',
      );
    }
  }

  @override
  Future<void> cancelSafetyAlert(String alertId) async {
    try {
      const mutation = '''
        mutation CancelSafetyAlert(\$alertId: ID!) {
          cancelSafetyAlert(alertId: \$alertId) {
            success
          }
        }
      ''';

      await _mutation(mutation, variables: {'alertId': alertId});
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to cancel safety alert',
      );
    }
  }

  @override
  Future<List<SafetyAlert>> getMissedCheckInAlerts() async {
    try {
      const query = '''
        query GetMissedCheckInAlerts {
          getMissedCheckInAlerts {
            id
            userId
            alertType
            status
            location {
              latitude
              longitude
              accuracy
              altitude
              timestamp
              address
              placeName
            }
            message
            notifiedContactIds
            acknowledgedByContactIds
            batteryLevel
            triggeredAt
            resolvedAt
            canceledAt
            tripId
            checkInId
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _query(query);
      final data = response['getMissedCheckInAlerts'] as List;
      return data.map((json) => SafetyAlert.fromJson(json)).toList();
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get missed check-in alerts',
      );
    }
  }

  // ==================== Battery & Location Services ====================

  @override
  Future<void> updateBatteryLevel(int level) async {
    try {
      const mutation = '''
        mutation UpdateBatteryLevel(\$level: Int!) {
          updateBatteryLevel(level: \$level) {
            success
          }
        }
      ''';

      await _mutation(mutation, variables: {'level': level});
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to update battery level',
      );
    }
  }

  @override
  Future<int?> getBatteryLevel() async {
    try {
      const query = '''
        query GetBatteryLevel {
          getBatteryLevel
        }
      ''';

      final response = await _query(query);
      return response['getBatteryLevel'] as int?;
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get battery level',
      );
    }
  }

  // ==================== Settings & Preferences ====================

  @override
  Future<void> updateContactNotificationPreferences({
    required String contactId,
    required bool receivesCheckIns,
    required bool receivesEmergencyAlerts,
  }) async {
    try {
      const mutation = '''
        mutation UpdateContactNotificationPreferences(
          \$contactId: ID!
          \$receivesCheckIns: Boolean!
          \$receivesEmergencyAlerts: Boolean!
        ) {
          updateContactNotificationPreferences(
            contactId: \$contactId
            receivesCheckIns: \$receivesCheckIns
            receivesEmergencyAlerts: \$receivesEmergencyAlerts
          ) {
            success
          }
        }
      ''';

      await _mutation(mutation, variables: {
        'contactId': contactId,
        'receivesCheckIns': receivesCheckIns,
        'receivesEmergencyAlerts': receivesEmergencyAlerts,
      });
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to update contact notification preferences',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSafetySettings() async {
    try {
      const query = '''
        query GetSafetySettings {
          getSafetySettings {
            checkInRemindersEnabled
            locationSharingEnabled
            emergencyAlertsEnabled
            batteryMonitoringEnabled
            checkInReminderMinutes
            locationUpdateInterval
            maxTrustedContacts
          }
        }
      ''';

      final response = await _query(query);
      return response['getSafetySettings'] as Map<String, dynamic>;
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySyncFailedException(
        'Failed to get safety settings',
      );
    }
  }

  @override
  Future<void> updateSafetySettings(Map<String, dynamic> settings) async {
    try {
      const mutation = '''
        mutation UpdateSafetySettings(\$settings: SafetySettingsInput!) {
          updateSafetySettings(settings: \$settings) {
            success
          }
        }
      ''';

      await _mutation(mutation, variables: {'settings': settings});
    } on SafetyException {
      rethrow;
    } catch (e) {
      throw const SafetySettingsSaveFailedException();
    }
  }
}
