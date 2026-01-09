import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/core/error/safety_exceptions.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/models/check_in_model.dart';
import 'package:soloadventurer/features/safety/data/models/location_update_model.dart';
import 'package:soloadventurer/features/safety/data/models/safety_alert_model.dart';
import 'package:soloadventurer/features/safety/data/models/safety_status_model.dart';
import 'package:soloadventurer/features/safety/data/models/trusted_contact_model.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';

import '../../../../helpers/safety_test_helpers.dart';

class MockSafetyRemoteDataSource extends Mock
    implements SafetyRemoteDataSource {}

class MockSafetyLocalDataSource extends Mock implements SafetyLocalDataSource {}

void main() {
  late MockSafetyRemoteDataSource mockRemoteDataSource;
  late MockSafetyLocalDataSource mockLocalDataSource;
  late SafetyRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockSafetyRemoteDataSource();
    mockLocalDataSource = MockSafetyLocalDataSource();
    repository = SafetyRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('SafetyRepositoryImpl - Trusted Contacts Operations', () {
    final testContact = createTestTrustedContact();
    final testContactModel = TrustedContactModel.fromEntity(testContact);

    test('should add trusted contact successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.addTrustedContact(any()))
          .thenAnswer((_) async => testContactModel);
      when(() => mockLocalDataSource.cacheTrustedContact(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.addTrustedContact(testContact);

      // Assert
      expect(result, isA<TrustedContact>());
      expect(result.id, testContact.id);
      expect(result.name, testContact.name);
      verify(() => mockRemoteDataSource.addTrustedContact(testContactModel))
          .called(1);
      verify(() => mockLocalDataSource.cacheTrustedContact(testContactModel))
          .called(1);
    });

    test('should throw SafetyOfflineException when add fails due to network',
        () async {
      // Arrange
      when(() => mockRemoteDataSource.addTrustedContact(any()))
          .thenThrow(const NetworkException('No internet connection'));

      // Act & Assert
      expect(
        () => repository.addTrustedContact(testContact),
        throwsA(isA<SafetyOfflineException>()),
      );
    });

    test('should rethrow SafetyException when add fails', () async {
      // Arrange
      when(() => mockRemoteDataSource.addTrustedContact(any()))
          .thenThrow(const SafetyException('Contact already exists'));

      // Act & Assert
      expect(
        () => repository.addTrustedContact(testContact),
        throwsA(isA<SafetyException>()),
      );
    });

    test('should remove trusted contact successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.removeTrustedContact(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.removeCachedTrustedContact(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.removeTrustedContact(testContactId);

      // Assert
      verify(() => mockRemoteDataSource.removeTrustedContact(testContactId))
          .called(1);
      verify(() =>
              mockLocalDataSource.removeCachedTrustedContact(testContactId))
          .called(1);
    });

    test('should update trusted contact successfully', () async {
      // Arrange
      final updatedContact = createTestTrustedContact(name: 'Updated Name');
      final updatedContactModel =
          TrustedContactModel.fromEntity(updatedContact);

      when(() => mockRemoteDataSource.updateTrustedContact(any()))
          .thenAnswer((_) async => updatedContactModel);
      when(() => mockLocalDataSource.cacheTrustedContact(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.updateTrustedContact(updatedContact);

      // Assert
      expect(result.name, 'Updated Name');
      verify(() =>
              mockRemoteDataSource.updateTrustedContact(updatedContactModel))
          .called(1);
      verify(() => mockLocalDataSource.cacheTrustedContact(updatedContactModel))
          .called(1);
    });

    test('should get trusted contacts from remote', () async {
      // Arrange
      final contactModels = createTestTrustedContactsList(count: 3)
          .map((c) => TrustedContactModel.fromEntity(c))
          .toList();

      when(() => mockRemoteDataSource.getTrustedContacts())
          .thenAnswer((_) async => contactModels);
      when(() => mockLocalDataSource.cacheTrustedContacts(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getTrustedContacts();

      // Assert
      expect(result, hasLength(3));
      verify(() => mockRemoteDataSource.getTrustedContacts()).called(1);
      verify(() => mockLocalDataSource.cacheTrustedContacts(contactModels))
          .called(1);
    });

    test('should fallback to cache when getting contacts offline', () async {
      // Arrange
      final cachedModels = createTestTrustedContactsList(count: 2)
          .map((c) => TrustedContactModel.fromEntity(c))
          .toList();

      when(() => mockRemoteDataSource.getTrustedContacts())
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedTrustedContacts())
          .thenAnswer((_) async => cachedModels);

      // Act
      final result = await repository.getTrustedContacts();

      // Assert
      expect(result, hasLength(2));
      verify(() => mockRemoteDataSource.getTrustedContacts()).called(1);
      verify(() => mockLocalDataSource.getCachedTrustedContacts()).called(1);
    });

    test('should get trusted contact by ID from remote', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTrustedContact(any()))
          .thenAnswer((_) async => testContactModel);
      when(() => mockLocalDataSource.cacheTrustedContact(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getTrustedContact(testContactId);

      // Assert
      expect(result.id, testContactId);
      verify(() => mockRemoteDataSource.getTrustedContact(testContactId))
          .called(1);
      verify(() => mockLocalDataSource.cacheTrustedContact(testContactModel))
          .called(1);
    });

    test('should throw when getting non-existent contact from cache', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTrustedContact(any()))
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedTrustedContact(any()))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => repository.getTrustedContact('non-existent'),
        throwsA(isA<TrustedContactNotFoundException>()),
      );
    });
  });

  group('SafetyRepositoryImpl - Check-in Operations', () {
    final testCheckIn = createTestCheckIn();
    final testCheckInModel = CheckInModel.fromEntity(testCheckIn);

    test('should create check-in successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.createCheckIn(any()))
          .thenAnswer((_) async => testCheckInModel);
      when(() => mockLocalDataSource.cacheCheckIn(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.createCheckIn(testCheckIn);

      // Assert
      expect(result.id, testCheckIn.id);
      verify(() => mockRemoteDataSource.createCheckIn(testCheckInModel))
          .called(1);
      verify(() => mockLocalDataSource.cacheCheckIn(testCheckInModel))
          .called(1);
    });

    test('should complete check-in successfully', () async {
      // Arrange
      final testLocation = createTestCheckInLocation();

      when(() => mockRemoteDataSource.completeCheckIn(
            checkInId: any(),
            location: any(),
            statusMessage: any('statusMessage'),
          )).thenAnswer((_) async => testCheckInModel);
      when(() => mockLocalDataSource.cacheCheckIn(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.completeCheckIn(
        checkInId: testCheckInId,
        location: testLocation,
        statusMessage: testStatusMessage,
      );

      // Assert
      expect(result.id, testCheckInId);
      verify(() => mockRemoteDataSource.completeCheckIn(
            checkInId: testCheckInId,
            location: testLocation,
            statusMessage: testStatusMessage,
          )).called(1);
      verify(() => mockLocalDataSource.cacheCheckIn(testCheckInModel))
          .called(1);
    });

    test('should schedule check-in successfully', () async {
      // Arrange
      final scheduledTime = testFutureDateTime;
      final deadline = scheduledTime.add(const Duration(hours: 1));
      final testLocation = createTestCheckInLocation();

      when(() => mockRemoteDataSource.scheduleCheckIn(
            userId: any(),
            scheduledTime: any(),
            deadline: any('deadline'),
            location: any('location'),
            statusMessage: any('statusMessage'),
            notifyContactIds: any('notifyContactIds'),
            tripId: any('tripId'),
            triggerType: any('triggerType'),
          )).thenAnswer((_) async => testCheckInModel);
      when(() => mockLocalDataSource.cacheCheckIn(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.scheduleCheckIn(
        userId: testUserId,
        scheduledTime: scheduledTime,
        deadline: deadline,
        location: testLocation,
        statusMessage: testStatusMessage,
        notifyContactIds: [testContactId],
        tripId: testTripId,
        triggerType: CheckInTriggerType.scheduled,
      );

      // Assert
      expect(result.id, testCheckInId);
      verify(() => mockRemoteDataSource.scheduleCheckIn(
            userId: testUserId,
            scheduledTime: scheduledTime,
            deadline: deadline,
            location: testLocation,
            statusMessage: testStatusMessage,
            notifyContactIds: [testContactId],
            tripId: testTripId,
            triggerType: CheckInTriggerType.scheduled,
          )).called(1);
      verify(() => mockLocalDataSource.cacheCheckIn(testCheckInModel))
          .called(1);
    });

    test('should cancel check-in successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelCheckIn(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.removeCachedCheckIn(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.cancelCheckIn(testCheckInId);

      // Assert
      verify(() => mockRemoteDataSource.cancelCheckIn(testCheckInId)).called(1);
      verify(() => mockLocalDataSource.removeCachedCheckIn(testCheckInId))
          .called(1);
    });

    test('should get upcoming check-ins from remote', () async {
      // Arrange
      final checkInModels = createTestCheckInsList(count: 3)
          .map((c) => CheckInModel.fromEntity(c))
          .toList();

      when(() => mockRemoteDataSource.getUpcomingCheckIns())
          .thenAnswer((_) async => checkInModels);
      when(() => mockLocalDataSource.cacheCheckIns(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getUpcomingCheckIns();

      // Assert
      expect(result, hasLength(3));
      verify(() => mockRemoteDataSource.getUpcomingCheckIns()).called(1);
      verify(() => mockLocalDataSource.cacheCheckIns(checkInModels)).called(1);
    });

    test('should get all check-ins from remote', () async {
      // Arrange
      final checkInModels = createTestCheckInsList(count: 5)
          .map((c) => CheckInModel.fromEntity(c))
          .toList();

      when(() => mockRemoteDataSource.getAllCheckIns())
          .thenAnswer((_) async => checkInModels);
      when(() => mockLocalDataSource.cacheCheckIns(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getAllCheckIns();

      // Assert
      expect(result, hasLength(5));
      verify(() => mockRemoteDataSource.getAllCheckIns()).called(1);
      verify(() => mockLocalDataSource.cacheCheckIns(checkInModels)).called(1);
    });

    test('should fallback to cache when getting check-ins offline', () async {
      // Arrange
      final cachedModels = createTestCheckInsList(count: 2)
          .map((c) => CheckInModel.fromEntity(c))
          .toList();

      when(() => mockRemoteDataSource.getAllCheckIns())
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedCheckIns())
          .thenAnswer((_) async => cachedModels);

      // Act
      final result = await repository.getAllCheckIns();

      // Assert
      expect(result, hasLength(2));
      verify(() => mockRemoteDataSource.getAllCheckIns()).called(1);
      verify(() => mockLocalDataSource.getCachedCheckIns()).called(1);
    });

    test('should get check-in by ID from remote', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCheckIn(any()))
          .thenAnswer((_) async => testCheckInModel);
      when(() => mockLocalDataSource.cacheCheckIn(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getCheckIn(testCheckInId);

      // Assert
      expect(result.id, testCheckInId);
      verify(() => mockRemoteDataSource.getCheckIn(testCheckInId)).called(1);
      verify(() => mockLocalDataSource.cacheCheckIn(testCheckInModel))
          .called(1);
    });

    test('should throw when getting non-existent check-in from cache',
        () async {
      // Arrange
      when(() => mockRemoteDataSource.getCheckIn(any()))
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedCheckIn(any()))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => repository.getCheckIn('non-existent'),
        throwsA(isA<CheckInNotFoundException>()),
      );
    });

    test('should get check-ins by trip', () async {
      // Arrange
      final tripCheckIns = [
        createTestCheckIn(id: 'checkin-1', tripId: testTripId),
        createTestCheckIn(id: 'checkin-2', tripId: testTripId),
      ];
      final checkInModels =
          tripCheckIns.map((c) => CheckInModel.fromEntity(c)).toList();

      when(() => mockRemoteDataSource.getCheckInsByTrip(any()))
          .thenAnswer((_) async => checkInModels);

      // Act
      final result = await repository.getCheckInsByTrip(testTripId);

      // Assert
      expect(result, hasLength(2));
      verify(() => mockRemoteDataSource.getCheckInsByTrip(testTripId))
          .called(1);
    });

    test('should update check-in status successfully', () async {
      // Arrange
      final updatedCheckIn = testCheckIn.copyWith(
        status: CheckInStatus.completed,
      );
      final updatedCheckInModel = CheckInModel.fromEntity(updatedCheckIn);

      when(() => mockRemoteDataSource.updateCheckInStatus(
            checkInId: any(),
            status: any(),
          )).thenAnswer((_) async => updatedCheckInModel);
      when(() => mockLocalDataSource.cacheCheckIn(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.updateCheckInStatus(
        checkInId: testCheckInId,
        status: CheckInStatus.completed,
      );

      // Assert
      expect(result.status, CheckInStatus.completed);
      verify(() => mockRemoteDataSource.updateCheckInStatus(
            checkInId: testCheckInId,
            status: CheckInStatus.completed,
          )).called(1);
      verify(() => mockLocalDataSource.cacheCheckIn(updatedCheckInModel))
          .called(1);
    });
  });

  group('SafetyRepositoryImpl - Location Sharing Operations', () {
    final testLocationUpdate = LocationUpdateModel(
      id: 'update-1',
      userId: testUserId,
      latitude: testLatitude,
      longitude: testLongitude,
      sharingStatus: LocationSharingStatus.active,
      timestamp: testDateTime,
      sharedWithContactIds: [testContactId],
    );

    test('should share location successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.shareLocation(
            latitude: any(),
            longitude: any(),
            accuracy: any('accuracy'),
            altitude: any('altitude'),
            speed: any('speed'),
            heading: any('heading'),
            address: any('address'),
            placeName: any('placeName'),
            shareWithContactIds: any('shareWithContactIds'),
            batteryLevel: any('batteryLevel'),
            isEmergency: any('isEmergency'),
            emergencyAlertId: any('emergencyAlertId'),
            checkInId: any('checkInId'),
          )).thenAnswer((_) async => testLocationUpdate);
      when(() => mockLocalDataSource.cacheLocationUpdate(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.shareLocation(
        latitude: testLatitude,
        longitude: testLongitude,
        accuracy: testAccuracy,
        shareWithContactIds: [testContactId],
        batteryLevel: 85,
      );

      // Assert
      expect(result.id, 'update-1');
      expect(result.latitude, testLatitude);
      expect(result.longitude, testLongitude);
      verify(() => mockRemoteDataSource.shareLocation(
            latitude: testLatitude,
            longitude: testLongitude,
            accuracy: testAccuracy,
            shareWithContactIds: [testContactId],
            batteryLevel: 85,
          )).called(1);
      verify(() => mockLocalDataSource.cacheLocationUpdate(testLocationUpdate))
          .called(1);
    });

    test('should share location for emergency', () async {
      // Arrange
      when(() => mockRemoteDataSource.shareLocation(
            latitude: any(),
            longitude: any(),
            shareWithContactIds: any('shareWithContactIds'),
            isEmergency: any('isEmergency'),
            emergencyAlertId: any('emergencyAlertId'),
          )).thenAnswer((_) async => testLocationUpdate);
      when(() => mockLocalDataSource.cacheLocationUpdate(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.shareLocation(
        latitude: testLatitude,
        longitude: testLongitude,
        shareWithContactIds: [testContactId],
        isEmergency: true,
        emergencyAlertId: testAlertId,
      );

      // Assert
      verify(() => mockRemoteDataSource.shareLocation(
            latitude: testLatitude,
            longitude: testLongitude,
            shareWithContactIds: [testContactId],
            isEmergency: true,
            emergencyAlertId: testAlertId,
          )).called(1);
    });

    test('should stop location sharing successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.stopLocationSharing(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.stopLocationSharing([testContactId]);

      // Assert
      verify(() => mockRemoteDataSource.stopLocationSharing([testContactId]))
          .called(1);
    });

    test('should stop all location sharing successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.stopAllLocationSharing())
          .thenAnswer((_) async {});

      // Act
      await repository.stopAllLocationSharing();

      // Assert
      verify(() => mockRemoteDataSource.stopAllLocationSharing()).called(1);
    });

    test('should get active location shares from remote', () async {
      // Arrange
      final locationUpdates = [
        testLocationUpdate,
        testLocationUpdate.copyWith(id: 'update-2'),
      ];

      when(() => mockRemoteDataSource.getActiveLocationShares())
          .thenAnswer((_) async => locationUpdates);
      when(() => mockLocalDataSource.cacheLocationUpdates(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getActiveLocationShares();

      // Assert
      expect(result, hasLength(2));
      verify(() => mockRemoteDataSource.getActiveLocationShares()).called(1);
      verify(() => mockLocalDataSource.cacheLocationUpdates(locationUpdates))
          .called(1);
    });

    test('should fallback to cache when getting active shares offline',
        () async {
      // Arrange
      final cachedUpdates = [testLocationUpdate];

      when(() => mockRemoteDataSource.getActiveLocationShares())
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedActiveLocationShares())
          .thenAnswer((_) async => cachedUpdates);

      // Act
      final result = await repository.getActiveLocationShares();

      // Assert
      expect(result, hasLength(1));
      verify(() => mockRemoteDataSource.getActiveLocationShares()).called(1);
      verify(() => mockLocalDataSource.getCachedActiveLocationShares())
          .called(1);
    });

    test('should get location updates with filters', () async {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);
      final locationUpdates = [testLocationUpdate];

      when(() => mockRemoteDataSource.getLocationUpdates(
            limit: any(),
            startDate: any('startDate'),
            endDate: any('endDate'),
          )).thenAnswer((_) async => locationUpdates);

      // Act
      final result = await repository.getLocationUpdates(
        limit: 20,
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(result, hasLength(1));
      verify(() => mockRemoteDataSource.getLocationUpdates(
            limit: 20,
            startDate: startDate,
            endDate: endDate,
          )).called(1);
    });

    test('should fallback to cache when getting location updates offline',
        () async {
      // Arrange
      final cachedUpdates = [testLocationUpdate];

      when(() => mockRemoteDataSource.getLocationUpdates(
            limit: any(),
            startDate: any('startDate'),
            endDate: any('endDate'),
          )).thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedLocationUpdates())
          .thenAnswer((_) async => cachedUpdates);

      // Act
      final result = await repository.getLocationUpdates(limit: 10);

      // Assert
      expect(result, hasLength(1));
      verify(() => mockLocalDataSource.getCachedLocationUpdates()).called(1);
    });

    test('should update location sharing permission successfully', () async {
      // Arrange
      final testContact = createTestTrustedContact(
        id: testContactId,
        locationSharingEnabled: false,
      );
      final cachedContactModel = TrustedContactModel.fromEntity(testContact);
      final updatedContactModel = cachedContactModel.copyWith(
        locationSharingEnabled: true,
      );

      when(() => mockRemoteDataSource.updateLocationSharingPermission(
            contactId: any(),
            enabled: any(),
          )).thenAnswer((_) async {});
      when(() => mockLocalDataSource.getCachedTrustedContact(any()))
          .thenAnswer((_) async => cachedContactModel);
      when(() => mockLocalDataSource.cacheTrustedContact(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.updateLocationSharingPermission(
        contactId: testContactId,
        enabled: true,
      );

      // Assert
      verify(() => mockRemoteDataSource.updateLocationSharingPermission(
            contactId: testContactId,
            enabled: true,
          )).called(1);
      verify(() => mockLocalDataSource.getCachedTrustedContact(testContactId))
          .called(1);
      verify(() => mockLocalDataSource.cacheTrustedContact(
            argThat(isA<TrustedContactModel>().having(
                (c) => c.locationSharingEnabled,
                'locationSharingEnabled',
                true)),
          )).called(1);
    });
  });

  group('SafetyRepositoryImpl - Emergency SOS Operations', () {
    final testAlert = createTestSafetyAlert();
    final testAlertModel = SafetyAlertModel.fromEntity(testAlert);

    test('should trigger emergency SOS successfully', () async {
      // Arrange
      final testLocation = createTestSafetyAlertLocation();

      when(() => mockRemoteDataSource.triggerEmergencySOS(
            userId: any(),
            message: any('message'),
            location: any(),
            notifyContactIds: any('notifyContactIds'),
            batteryLevel: any('batteryLevel'),
            tripId: any('tripId'),
          )).thenAnswer((_) async => testAlertModel);
      when(() => mockLocalDataSource.cacheSafetyAlert(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.triggerEmergencySOS(
        userId: testUserId,
        message: testEmergencyMessage,
        location: testLocation,
        notifyContactIds: [testContactId],
        batteryLevel: 85,
        tripId: testTripId,
      );

      // Assert
      expect(result.id, testAlertId);
      expect(result.type, SafetyAlertType.emergencySOS);
      verify(() => mockRemoteDataSource.triggerEmergencySOS(
            userId: testUserId,
            message: testEmergencyMessage,
            location: testLocation,
            notifyContactIds: [testContactId],
            batteryLevel: 85,
            tripId: testTripId,
          )).called(1);
      verify(() => mockLocalDataSource.cacheSafetyAlert(testAlertModel))
          .called(1);
    });

    test('should update safety status successfully', () async {
      // Arrange
      final testStatus = SafetyStatusModel(
        userId: testUserId,
        status: SafetyStatusType.safe,
        message: testStatusMessage,
        timestamp: testDateTime,
      );

      when(() => mockRemoteDataSource.updateSafetyStatus(
            status: any(),
            message: any('message'),
            location: any('location'),
            batteryLevel: any('batteryLevel'),
            safetyAlertId: any('safetyAlertId'),
            checkInId: any('checkInId'),
          )).thenAnswer((_) async => testStatus);
      when(() => mockLocalDataSource.cacheSafetyStatus(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.updateSafetyStatus(
        status: SafetyStatusType.safe,
        message: testStatusMessage,
      );

      // Assert
      expect(result.status, SafetyStatusType.safe);
      expect(result.message, testStatusMessage);
      verify(() => mockRemoteDataSource.updateSafetyStatus(
            status: SafetyStatusType.safe,
            message: testStatusMessage,
          )).called(1);
      verify(() => mockLocalDataSource.cacheSafetyStatus(testStatus)).called(1);
    });

    test('should get safety status from remote', () async {
      // Arrange
      final testStatus = SafetyStatusModel(
        userId: testUserId,
        status: SafetyStatusType.safe,
        timestamp: testDateTime,
      );

      when(() => mockRemoteDataSource.getSafetyStatus())
          .thenAnswer((_) async => testStatus);
      when(() => mockLocalDataSource.cacheSafetyStatus(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getSafetyStatus();

      // Assert
      expect(result.status, SafetyStatusType.safe);
      verify(() => mockRemoteDataSource.getSafetyStatus()).called(1);
      verify(() => mockLocalDataSource.cacheSafetyStatus(testStatus)).called(1);
    });

    test('should fallback to cache when getting safety status offline',
        () async {
      // Arrange
      final cachedStatus = SafetyStatusModel(
        userId: testUserId,
        status: SafetyStatusType.needHelp,
        timestamp: testDateTime,
      );

      when(() => mockRemoteDataSource.getSafetyStatus())
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedSafetyStatus())
          .thenAnswer((_) async => cachedStatus);

      // Act
      final result = await repository.getSafetyStatus();

      // Assert
      expect(result.status, SafetyStatusType.needHelp);
      verify(() => mockRemoteDataSource.getSafetyStatus()).called(1);
      verify(() => mockLocalDataSource.getCachedSafetyStatus()).called(1);
    });

    test('should throw when no cached safety status exists', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSafetyStatus())
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedSafetyStatus())
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => repository.getSafetyStatus(),
        throwsA(isA<SafetyException>().having(
          (e) => e.code,
          'code',
          'safety_status_not_found',
        )),
      );
    });

    test('should get safety status for another user', () async {
      // Arrange
      const otherUserId = 'user-456';
      final testStatus = SafetyStatusModel(
        userId: otherUserId,
        status: SafetyStatusType.safe,
        timestamp: testDateTime,
      );

      when(() => mockRemoteDataSource.getSafetyStatusForUser(any()))
          .thenAnswer((_) async => testStatus);

      // Act
      final result = await repository.getSafetyStatusForUser(otherUserId);

      // Assert
      expect(result.userId, otherUserId);
      verify(() => mockRemoteDataSource.getSafetyStatusForUser(otherUserId))
          .called(1);
      verifyNever(() => mockLocalDataSource.cacheSafetyStatus(any()));
    });
  });

  group('SafetyRepositoryImpl - Safety Alerts Operations', () {
    final testAlerts = createTestSafetyAlertsList(count: 3)
        .map((a) => SafetyAlertModel.fromEntity(a))
        .toList();

    test('should get safety alerts from remote', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSafetyAlerts())
          .thenAnswer((_) async => testAlerts);
      when(() => mockLocalDataSource.cacheSafetyAlerts(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getSafetyAlerts();

      // Assert
      expect(result, hasLength(3));
      verify(() => mockRemoteDataSource.getSafetyAlerts()).called(1);
      verify(() => mockLocalDataSource.cacheSafetyAlerts(testAlerts)).called(1);
    });

    test('should fallback to cache when getting alerts offline', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSafetyAlerts())
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedSafetyAlerts())
          .thenAnswer((_) async => testAlerts);

      // Act
      final result = await repository.getSafetyAlerts();

      // Assert
      expect(result, hasLength(3));
      verify(() => mockRemoteDataSource.getSafetyAlerts()).called(1);
      verify(() => mockLocalDataSource.getCachedSafetyAlerts()).called(1);
    });

    test('should get safety alert by ID from remote', () async {
      // Arrange
      final testAlert = createTestSafetyAlert();
      final testAlertModel = SafetyAlertModel.fromEntity(testAlert);

      when(() => mockRemoteDataSource.getSafetyAlert(any()))
          .thenAnswer((_) async => testAlertModel);
      when(() => mockLocalDataSource.cacheSafetyAlert(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getSafetyAlert(testAlertId);

      // Assert
      expect(result.id, testAlertId);
      verify(() => mockRemoteDataSource.getSafetyAlert(testAlertId)).called(1);
      verify(() => mockLocalDataSource.cacheSafetyAlert(testAlertModel))
          .called(1);
    });

    test('should throw when getting non-existent alert from cache', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSafetyAlert(any()))
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedSafetyAlert(any()))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => repository.getSafetyAlert('non-existent'),
        throwsA(isA<SafetyAlertNotFoundException>()),
      );
    });

    test('should get recent safety alerts from remote', () async {
      // Arrange
      when(() => mockRemoteDataSource.getRecentSafetyAlerts(
            limit: any(),
            type: any('type'),
          )).thenAnswer((_) async => testAlerts);

      // Act
      final result = await repository.getRecentSafetyAlerts(limit: 10);

      // Assert
      expect(result, hasLength(3));
      verify(() => mockRemoteDataSource.getRecentSafetyAlerts(limit: 10))
          .called(1);
    });

    test('should get recent safety alerts with type filter', () async {
      // Arrange
      final emergencyAlerts = testAlerts
          .where((a) => a.type == SafetyAlertType.emergencySOS)
          .toList();

      when(() => mockRemoteDataSource.getRecentSafetyAlerts(
            limit: any(),
            type: any('type'),
          )).thenAnswer((_) async => emergencyAlerts);

      // Act
      final result = await repository.getRecentSafetyAlerts(
        limit: 10,
        type: SafetyAlertType.emergencySOS,
      );

      // Assert
      expect(result, hasLength(emergencyAlerts.length));
      verify(() => mockRemoteDataSource.getRecentSafetyAlerts(
            limit: 10,
            type: SafetyAlertType.emergencySOS,
          )).called(1);
    });

    test('should acknowledge safety alert successfully', () async {
      // Arrange
      final testAlert = createTestSafetyAlert(
        acknowledgedBy: [],
      );
      final cachedAlertModel = SafetyAlertModel.fromEntity(testAlert);
      const acknowledgedContactId = 'contact-ack';

      when(() => mockRemoteDataSource.acknowledgeSafetyAlert(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.getCachedSafetyAlert(any()))
          .thenAnswer((_) async => cachedAlertModel);
      when(() => mockLocalDataSource.cacheSafetyAlert(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.acknowledgeSafetyAlert(
          testAlertId, acknowledgedContactId);

      // Assert
      verify(() => mockRemoteDataSource.acknowledgeSafetyAlert(
            testAlertId,
            acknowledgedContactId,
          )).called(1);
      verify(() => mockLocalDataSource.getCachedSafetyAlert(testAlertId))
          .called(1);
      verify(() => mockLocalDataSource.cacheSafetyAlert(
            argThat(isA<SafetyAlertModel>().having(
                (a) => a.acknowledgedBy.contains(acknowledgedContactId),
                'acknowledgedBy',
                true)),
          )).called(1);
    });

    test('should resolve safety alert successfully', () async {
      // Arrange
      final testAlert = createTestSafetyAlert(
        status: SafetyAlertStatus.sent,
      );
      final cachedAlertModel = SafetyAlertModel.fromEntity(testAlert);

      when(() => mockRemoteDataSource.resolveSafetyAlert(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.getCachedSafetyAlert(any()))
          .thenAnswer((_) async => cachedAlertModel);
      when(() => mockLocalDataSource.cacheSafetyAlert(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.resolveSafetyAlert(testAlertId);

      // Assert
      verify(() => mockRemoteDataSource.resolveSafetyAlert(testAlertId))
          .called(1);
      verify(() => mockLocalDataSource.getCachedSafetyAlert(testAlertId))
          .called(1);
      verify(() => mockLocalDataSource.cacheSafetyAlert(
            argThat(isA<SafetyAlertModel>()
                .having((a) => a.status, 'status', SafetyAlertStatus.resolved)),
          )).called(1);
    });

    test('should cancel safety alert successfully', () async {
      // Arrange
      final testAlert = createTestSafetyAlert(
        status: SafetyAlertStatus.sent,
      );
      final cachedAlertModel = SafetyAlertModel.fromEntity(testAlert);

      when(() => mockRemoteDataSource.cancelSafetyAlert(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.getCachedSafetyAlert(any()))
          .thenAnswer((_) async => cachedAlertModel);
      when(() => mockLocalDataSource.cacheSafetyAlert(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.cancelSafetyAlert(testAlertId);

      // Assert
      verify(() => mockRemoteDataSource.cancelSafetyAlert(testAlertId))
          .called(1);
      verify(() => mockLocalDataSource.getCachedSafetyAlert(testAlertId))
          .called(1);
      verify(() => mockLocalDataSource.cacheSafetyAlert(
            argThat(isA<SafetyAlertModel>()
                .having((a) => a.status, 'status', SafetyAlertStatus.canceled)),
          )).called(1);
    });

    test('should get missed check-in alerts', () async {
      // Arrange
      final missedCheckInAlerts = [
        createTestSafetyAlert(
          id: 'alert-1',
          type: SafetyAlertType.missedCheckIn,
        ),
        createTestSafetyAlert(
          id: 'alert-2',
          type: SafetyAlertType.missedCheckIn,
        ),
      ];
      final alertModels = missedCheckInAlerts
          .map((a) => SafetyAlertModel.fromEntity(a))
          .toList();

      when(() => mockRemoteDataSource.getMissedCheckInAlerts())
          .thenAnswer((_) async => alertModels);

      // Act
      final result = await repository.getMissedCheckInAlerts();

      // Assert
      expect(result, hasLength(2));
      verify(() => mockRemoteDataSource.getMissedCheckInAlerts()).called(1);
    });

    test('should fallback to cache when getting missed check-in alerts offline',
        () {
      // Arrange
      final missedCheckInAlerts = [
        createTestSafetyAlert(
          id: 'alert-1',
          type: SafetyAlertType.missedCheckIn,
        ),
      ];
      final alertModels = missedCheckInAlerts
          .map((a) => SafetyAlertModel.fromEntity(a))
          .toList();

      when(() => mockRemoteDataSource.getMissedCheckInAlerts())
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedMissedCheckInAlerts())
          .thenAnswer((_) async => alertModels);

      // Act
      final result = repository.getMissedCheckInAlerts();

      // Assert
      expect(result, completes);
      verify(() => mockRemoteDataSource.getMissedCheckInAlerts()).called(1);
      verify(() => mockLocalDataSource.getCachedMissedCheckInAlerts())
          .called(1);
    });
  });

  group('SafetyRepositoryImpl - Battery & Settings Operations', () {
    test('should update battery level successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateBatteryLevel(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.cacheBatteryLevel(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.updateBatteryLevel(75);

      // Assert
      verify(() => mockRemoteDataSource.updateBatteryLevel(75)).called(1);
      verify(() => mockLocalDataSource.cacheBatteryLevel(75)).called(1);
    });

    test('should get battery level from remote', () async {
      // Arrange
      when(() => mockRemoteDataSource.getBatteryLevel())
          .thenAnswer((_) async => 85);
      when(() => mockLocalDataSource.cacheBatteryLevel(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getBatteryLevel();

      // Assert
      expect(result, equals(85));
      verify(() => mockRemoteDataSource.getBatteryLevel()).called(1);
      verify(() => mockLocalDataSource.cacheBatteryLevel(85)).called(1);
    });

    test('should fallback to cache when getting battery level offline',
        () async {
      // Arrange
      when(() => mockRemoteDataSource.getBatteryLevel())
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedBatteryLevel())
          .thenAnswer((_) async => 70);

      // Act
      final result = await repository.getBatteryLevel();

      // Assert
      expect(result, equals(70));
      verify(() => mockRemoteDataSource.getBatteryLevel()).called(1);
      verify(() => mockLocalDataSource.getCachedBatteryLevel()).called(1);
    });

    test('should return null when remote returns null battery level', () async {
      // Arrange
      when(() => mockRemoteDataSource.getBatteryLevel())
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getBatteryLevel();

      // Assert
      expect(result, isNull);
      verifyNever(() => mockLocalDataSource.cacheBatteryLevel(any()));
    });

    test('should get safety settings from remote', () async {
      // Arrange
      final testSettings = {
        'key1': 'value1',
        'key2': true,
        'key3': 42,
      };

      when(() => mockRemoteDataSource.getSafetySettings())
          .thenAnswer((_) async => testSettings);
      when(() => mockLocalDataSource.cacheSafetySettings(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getSafetySettings();

      // Assert
      expect(result, equals(testSettings));
      verify(() => mockRemoteDataSource.getSafetySettings()).called(1);
      verify(() => mockLocalDataSource.cacheSafetySettings(testSettings))
          .called(1);
    });

    test('should fallback to cache when getting safety settings offline',
        () async {
      // Arrange
      final cachedSettings = {'cached': 'value'};

      when(() => mockRemoteDataSource.getSafetySettings())
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedSafetySettings())
          .thenAnswer((_) async => cachedSettings);

      // Act
      final result = await repository.getSafetySettings();

      // Assert
      expect(result, equals(cachedSettings));
      verify(() => mockRemoteDataSource.getSafetySettings()).called(1);
      verify(() => mockLocalDataSource.getCachedSafetySettings()).called(1);
    });

    test('should throw when no cached safety settings exist', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSafetySettings())
          .thenThrow(const NetworkException('No internet'));
      when(() => mockLocalDataSource.getCachedSafetySettings())
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => repository.getSafetySettings(),
        throwsA(isA<SafetySettingsLoadFailedException>()),
      );
    });

    test('should update safety settings successfully', () async {
      // Arrange
      final newSettings = {'newKey': 'newValue'};

      when(() => mockRemoteDataSource.updateSafetySettings(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.cacheSafetySettings(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.updateSafetySettings(newSettings);

      // Assert
      verify(() => mockRemoteDataSource.updateSafetySettings(newSettings))
          .called(1);
      verify(() => mockLocalDataSource.cacheSafetySettings(newSettings))
          .called(1);
    });
  });

  group('SafetyRepositoryImpl - Contact Notification Preferences', () {
    test('should update contact notification preferences successfully',
        () async {
      // Arrange
      final testContact = createTestTrustedContact(
        id: testContactId,
        receivesCheckIns: false,
        receivesEmergencyAlerts: false,
      );
      final cachedContactModel = TrustedContactModel.fromEntity(testContact);
      final updatedContactModel = cachedContactModel.copyWith(
        receivesCheckIns: true,
        receivesEmergencyAlerts: true,
      );

      when(() => mockRemoteDataSource.updateContactNotificationPreferences(
            contactId: any(),
            receivesCheckIns: any(),
            receivesEmergencyAlerts: any(),
          )).thenAnswer((_) async {});
      when(() => mockLocalDataSource.getCachedTrustedContact(any()))
          .thenAnswer((_) async => cachedContactModel);
      when(() => mockLocalDataSource.cacheTrustedContact(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.updateContactNotificationPreferences(
        contactId: testContactId,
        receivesCheckIns: true,
        receivesEmergencyAlerts: true,
      );

      // Assert
      verify(() => mockRemoteDataSource.updateContactNotificationPreferences(
            contactId: testContactId,
            receivesCheckIns: true,
            receivesEmergencyAlerts: true,
          )).called(1);
      verify(() => mockLocalDataSource.getCachedTrustedContact(testContactId))
          .called(1);
      verify(() => mockLocalDataSource.cacheTrustedContact(
            argThat(isA<TrustedContactModel>()
                .having((c) => c.receivesCheckIns, 'receivesCheckIns', true)
                .having((c) => c.receivesEmergencyAlerts,
                    'receivesEmergencyAlerts', true)),
          )).called(1);
    });
  });
}
