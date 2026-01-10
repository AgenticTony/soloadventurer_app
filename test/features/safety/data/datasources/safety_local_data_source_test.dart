import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/core/error/safety_exceptions.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source_impl.dart';
import 'package:soloadventurer/features/safety/data/models/location_update_model.dart';
import 'package:soloadventurer/features/safety/data/models/safety_status_model.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';

import '../../../../helpers/safety_test_helpers.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late SafetyLocalDataSourceImpl dataSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = SafetyLocalDataSourceImpl(mockSharedPreferences);
  });

  group('SafetyLocalDataSourceImpl - Trusted Contacts', () {
    final testContacts = createTestTrustedContactsList(count: 3);

    test('should cache trusted contacts successfully', () async {
      // Arrange
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheTrustedContacts(testContacts);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_trusted_contacts',
            any(that: isA<String>()),
          )).called(1);
      verify(() => mockSharedPreferences.setInt(
            'safety_last_cache_update',
            any(that: isA<int>()),
          )).called(1);
    });

    test('should retrieve cached trusted contacts', () async {
      // Arrange
      final jsonList = testContacts.map((c) => c.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_trusted_contacts'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedTrustedContacts();

      // Assert
      expect(result, hasLength(3));
      expect(result.first.id, testContacts.first.id);
      expect(result.first.name, testContacts.first.name);
    });

    test('should return empty list when cache is expired', () async {
      // Arrange
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now()
              .subtract(const Duration(hours: 2))
              .millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedTrustedContacts();

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list when no cached contacts exist', () async {
      // Arrange
      when(() => mockSharedPreferences.getString('cached_trusted_contacts'))
          .thenReturn(null);
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedTrustedContacts();

      // Assert
      expect(result, isEmpty);
    });

    test('should cache a single trusted contact', () async {
      // Arrange
      final existingContacts = createTestTrustedContactsList(count: 2);
      final newContact = createTestTrustedContact(id: 'new-contact');
      final jsonList = existingContacts.map((c) => c.toJson()).toList();

      when(() => mockSharedPreferences.getString('cached_trusted_contacts'))
          .thenReturn(jsonEncode(jsonList))
          .thenReturn(jsonEncode([...jsonList, newContact.toJson()]));
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheTrustedContact(newContact);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_trusted_contacts',
            any(that: contains('new-contact')),
          )).called(1);
    });

    test('should update existing contact when caching', () async {
      // Arrange
      final existingContact =
          createTestTrustedContact(id: 'contact-1', name: 'Old Name');
      final updatedContact =
          createTestTrustedContact(id: 'contact-1', name: 'New Name');
      final jsonList = [existingContact.toJson()];

      when(() => mockSharedPreferences.getString('cached_trusted_contacts'))
          .thenReturn(jsonEncode(jsonList))
          .thenReturn(jsonEncode([updatedContact.toJson()]));
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheTrustedContact(updatedContact);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_trusted_contacts',
            any(that: contains('New Name')),
          )).called(1);
    });

    test('should get cached trusted contact by ID', () async {
      // Arrange
      final contacts = createTestTrustedContactsList(count: 3);
      final jsonList = contacts.map((c) => c.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_trusted_contacts'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedTrustedContact('contact-1');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'contact-1');
      expect(result.name, 'Contact 1');
    });

    test('should return null when getting non-existent cached contact',
        () async {
      // Arrange
      final contacts = createTestTrustedContactsList(count: 2);
      final jsonList = contacts.map((c) => c.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_trusted_contacts'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedTrustedContact('non-existent');

      // Assert
      expect(result, isNull);
    });

    test('should remove cached trusted contact', () async {
      // Arrange
      final contacts = createTestTrustedContactsList(count: 3);
      final jsonList = contacts.map((c) => c.toJson()).toList();
      final remainingJson =
          jsonList.where((json) => json['id'] != 'contact-1').toList();

      when(() => mockSharedPreferences.getString('cached_trusted_contacts'))
          .thenReturn(jsonEncode(jsonList))
          .thenReturn(jsonEncode(remainingJson));
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.removeCachedTrustedContact('contact-1');

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_trusted_contacts',
            any(that: isNot(contains('contact-1'))),
          )).called(1);
    });

    test('should throw SafetyCacheException when caching fails', () async {
      // Arrange
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(
        () => dataSource.cacheTrustedContacts(testContacts),
        throwsA(isA<SafetyCacheException>()),
      );
    });

    test('should throw SafetyCacheRetrievalException when retrieval fails',
        () async {
      // Arrange
      when(() => mockSharedPreferences.getString('cached_trusted_contacts'))
          .thenThrow(Exception('Read error'));

      // Act & Assert
      expect(
        () => dataSource.getCachedTrustedContacts(),
        throwsA(isA<SafetyCacheRetrievalException>()),
      );
    });
  });

  group('SafetyLocalDataSourceImpl - Check-ins', () {
    final testCheckIns = createTestCheckInsList(count: 3);

    test('should cache check-ins successfully', () async {
      // Arrange
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheCheckIns(testCheckIns);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_check_ins',
            any(that: isA<String>()),
          )).called(1);
      verify(() => mockSharedPreferences.setInt(
            'safety_last_cache_update',
            any(that: isA<int>()),
          )).called(1);
    });

    test('should retrieve cached check-ins', () async {
      // Arrange
      final jsonList = testCheckIns.map((c) => c.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_check_ins'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedCheckIns();

      // Assert
      expect(result, hasLength(3));
      expect(result.first.id, testCheckIns.first.id);
    });

    test('should retrieve upcoming check-ins only', () async {
      // Arrange
      final now = DateTime.now();
      final pastCheckIn = createTestCheckIn(
        id: 'past',
        scheduledTime: now.subtract(const Duration(hours: 1)),
        status: CheckInStatus.completed,
      );
      final upcomingCheckIn1 = createTestCheckIn(
        id: 'upcoming-1',
        scheduledTime: now.add(const Duration(hours: 1)),
        status: CheckInStatus.scheduled,
      );
      final upcomingCheckIn2 = createTestCheckIn(
        id: 'upcoming-2',
        scheduledTime: now.add(const Duration(hours: 2)),
        status: CheckInStatus.active,
      );
      final allCheckIns = [pastCheckIn, upcomingCheckIn1, upcomingCheckIn2];
      final jsonList = allCheckIns.map((c) => c.toJson()).toList();

      when(() => mockSharedPreferences.getString('cached_check_ins'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedUpcomingCheckIns();

      // Assert
      expect(result, hasLength(2));
      expect(result.any((c) => c.id == 'past'), isFalse);
      expect(result.any((c) => c.id == 'upcoming-1'), isTrue);
      expect(result.any((c) => c.id == 'upcoming-2'), isTrue);
    });

    test('should cache a single check-in', () async {
      // Arrange
      final existingCheckIns = createTestCheckInsList(count: 2);
      final newCheckIn = createTestCheckIn(id: 'new-checkin');
      final jsonList = existingCheckIns.map((c) => c.toJson()).toList();

      when(() => mockSharedPreferences.getString('cached_check_ins'))
          .thenReturn(jsonEncode(jsonList))
          .thenReturn(jsonEncode([...jsonList, newCheckIn.toJson()]));
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheCheckIn(newCheckIn);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_check_ins',
            any(that: contains('new-checkin')),
          )).called(1);
    });

    test('should get cached check-in by ID', () async {
      // Arrange
      final checkIns = createTestCheckInsList(count: 3);
      final jsonList = checkIns.map((c) => c.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_check_ins'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedCheckIn('checkin-1');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'checkin-1');
    });

    test('should remove cached check-in', () async {
      // Arrange
      final checkIns = createTestCheckInsList(count: 3);
      final jsonList = checkIns.map((c) => c.toJson()).toList();
      final remainingJson =
          jsonList.where((json) => json['id'] != 'checkin-1').toList();

      when(() => mockSharedPreferences.getString('cached_check_ins'))
          .thenReturn(jsonEncode(jsonList))
          .thenReturn(jsonEncode(remainingJson));
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.removeCachedCheckIn('checkin-1');

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_check_ins',
            any(that: isNot(contains('checkin-1'))),
          )).called(1);
    });
  });

  group('SafetyLocalDataSourceImpl - Location Updates', () {
    final testLocationUpdates = [
      LocationUpdateModel(
        id: 'update-1',
        userId: testUserId,
        latitude: testLatitude,
        longitude: testLongitude,
        sharingStatus: LocationSharingStatus.active,
        timestamp: testDateTime,
        sharedWithContactIds: [testContactId],
      ),
      LocationUpdateModel(
        id: 'update-2',
        userId: testUserId,
        latitude: testLatitude,
        longitude: testLongitude,
        sharingStatus: LocationSharingStatus.ended,
        timestamp: testDateTime,
        sharedWithContactIds: [testContactId],
      ),
    ];

    test('should cache location updates successfully', () async {
      // Arrange
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheLocationUpdates(testLocationUpdates);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_location_updates',
            any(that: isA<String>()),
          )).called(1);
    });

    test('should retrieve cached location updates', () async {
      // Arrange
      final jsonList = testLocationUpdates.map((u) => u.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_location_updates'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedLocationUpdates();

      // Assert
      expect(result, hasLength(2));
      expect(result.first.id, 'update-1');
    });

    test('should retrieve active location shares only', () async {
      // Arrange
      final jsonList = testLocationUpdates.map((u) => u.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_location_updates'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedActiveLocationShares();

      // Assert
      expect(result, hasLength(1));
      expect(result.first.id, 'update-1');
      expect(result.first.sharingStatus, LocationSharingStatus.active);
    });

    test('should cache a single location update', () async {
      // Arrange
      final newUpdate = LocationUpdateModel(
        id: 'new-update',
        userId: testUserId,
        latitude: testLatitude,
        longitude: testLongitude,
        sharingStatus: LocationSharingStatus.active,
        timestamp: testDateTime,
        sharedWithContactIds: [testContactId],
      );
      final jsonList = testLocationUpdates.map((u) => u.toJson()).toList();

      when(() => mockSharedPreferences.getString('cached_location_updates'))
          .thenReturn(jsonEncode(jsonList))
          .thenReturn(jsonEncode([...jsonList, newUpdate.toJson()]));
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheLocationUpdate(newUpdate);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_location_updates',
            any(that: contains('new-update')),
          )).called(1);
    });

    test('should get cached location update by ID', () async {
      // Arrange
      final jsonList = testLocationUpdates.map((u) => u.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_location_updates'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedLocationUpdate('update-1');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'update-1');
    });
  });

  group('SafetyLocalDataSourceImpl - Safety Alerts', () {
    final testAlerts = createTestSafetyAlertsList(count: 3);

    test('should cache safety alerts successfully', () async {
      // Arrange
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheSafetyAlerts(testAlerts);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_safety_alerts',
            any(that: isA<String>()),
          )).called(1);
    });

    test('should retrieve cached safety alerts', () async {
      // Arrange
      final jsonList = testAlerts.map((a) => a.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_safety_alerts'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedSafetyAlerts();

      // Assert
      expect(result, hasLength(3));
      expect(result.first.id, testAlerts.first.id);
    });

    test('should retrieve recent safety alerts with limit', () async {
      // Arrange
      final jsonList = testAlerts.map((a) => a.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_safety_alerts'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedRecentSafetyAlerts(limit: 2);

      // Assert
      expect(result, hasLength(2));
    });

    test('should cache a single safety alert', () async {
      // Arrange
      final newAlert = createTestSafetyAlert(id: 'new-alert');
      final jsonList = testAlerts.map((a) => a.toJson()).toList();

      when(() => mockSharedPreferences.getString('cached_safety_alerts'))
          .thenReturn(jsonEncode(jsonList))
          .thenReturn(jsonEncode([...jsonList, newAlert.toJson()]));
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheSafetyAlert(newAlert);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_safety_alerts',
            any(that: contains('new-alert')),
          )).called(1);
    });

    test('should get cached safety alert by ID', () async {
      // Arrange
      final jsonList = testAlerts.map((a) => a.toJson()).toList();
      when(() => mockSharedPreferences.getString('cached_safety_alerts'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedSafetyAlert('alert-1');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'alert-1');
    });

    test('should retrieve missed check-in alerts only', () async {
      // Arrange
      final sosAlert = createTestSafetyAlert(
        id: 'alert-sos',
        type: SafetyAlertType.emergencySOS,
      );
      final missedCheckInAlert = createTestSafetyAlert(
        id: 'alert-missed',
        type: SafetyAlertType.missedCheckIn,
      );
      final allAlerts = [sosAlert, missedCheckInAlert];
      final jsonList = allAlerts.map((a) => a.toJson()).toList();

      when(() => mockSharedPreferences.getString('cached_safety_alerts'))
          .thenReturn(jsonEncode(jsonList));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedMissedCheckInAlerts();

      // Assert
      expect(result, hasLength(1));
      expect(result.first.id, 'alert-missed');
      expect(result.first.type, SafetyAlertType.missedCheckIn);
    });
  });

  group('SafetyLocalDataSourceImpl - Safety Status', () {
    final testStatus = SafetyStatusModel(
      id: 'test-status-id',
      userId: testUserId,
      statusType: SafetyStatusType.safe,
      timestamp: testDateTime,
    );

    test('should cache safety status successfully', () async {
      // Arrange
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheSafetyStatus(testStatus);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_safety_status',
            any(that: isA<String>()),
          )).called(1);
    });

    test('should retrieve cached safety status', () async {
      // Arrange
      when(() => mockSharedPreferences.getString('cached_safety_status'))
          .thenReturn(jsonEncode(testStatus.toJson()));
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedSafetyStatus();

      // Assert
      expect(result, isNotNull);
      expect(result!.userId, testUserId);
      expect(result.status, SafetyStatusType.safe);
    });

    test('should return null when no cached status exists', () async {
      // Arrange
      when(() => mockSharedPreferences.getString('cached_safety_status'))
          .thenReturn(null);
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(DateTime.now().millisecondsSinceEpoch);

      // Act
      final result = await dataSource.getCachedSafetyStatus();

      // Assert
      expect(result, isNull);
    });
  });

  group('SafetyLocalDataSourceImpl - Battery & Settings', () {
    test('should cache battery level successfully', () async {
      // Arrange
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheBatteryLevel(85);

      // Assert
      verify(() => mockSharedPreferences.setInt(
            'cached_battery_level',
            85,
          )).called(1);
    });

    test('should retrieve cached battery level', () async {
      // Arrange
      when(() => mockSharedPreferences.getInt('cached_battery_level'))
          .thenReturn(75);

      // Act
      final result = await dataSource.getCachedBatteryLevel();

      // Assert
      expect(result, equals(75));
    });

    test('should return null when no battery level cached', () async {
      // Arrange
      when(() => mockSharedPreferences.getInt('cached_battery_level'))
          .thenReturn(null);

      // Act
      final result = await dataSource.getCachedBatteryLevel();

      // Assert
      expect(result, isNull);
    });

    test('should cache safety settings successfully', () async {
      // Arrange
      final testSettings = {'key': 'value', 'enabled': true};
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheSafetySettings(testSettings);

      // Assert
      verify(() => mockSharedPreferences.setString(
            'cached_safety_settings',
            any(that: isA<String>()),
          )).called(1);
    });

    test('should retrieve cached safety settings', () async {
      // Arrange
      final testSettings = {'key': 'value', 'enabled': true};
      when(() => mockSharedPreferences.getString('cached_safety_settings'))
          .thenReturn(jsonEncode(testSettings));

      // Act
      final result = await dataSource.getCachedSafetySettings();

      // Assert
      expect(result, isNotNull);
      expect(result!['key'], 'value');
      expect(result['enabled'], isTrue);
    });

    test('should return null when no safety settings cached', () async {
      // Arrange
      when(() => mockSharedPreferences.getString('cached_safety_settings'))
          .thenReturn(null);

      // Act
      final result = await dataSource.getCachedSafetySettings();

      // Assert
      expect(result, isNull);
    });
  });

  group('SafetyLocalDataSourceImpl - Cache Management', () {
    test('should clear all cached data', () async {
      // Arrange
      when(() => mockSharedPreferences.remove(any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.clearAllCache();

      // Assert
      final keys = [
        'cached_trusted_contacts',
        'cached_check_ins',
        'cached_location_updates',
        'cached_safety_alerts',
        'cached_safety_status',
        'cached_battery_level',
        'cached_safety_settings',
        'safety_last_cache_update',
      ];
      for (final key in keys) {
        verify(() => mockSharedPreferences.remove(key)).called(1);
      }
    });

    test('should return true when cache is expired', () async {
      // Arrange
      final oldTimestamp = DateTime.now()
          .subtract(const Duration(hours: 2))
          .millisecondsSinceEpoch;
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(oldTimestamp);

      // Act
      final result = await dataSource.isCacheExpired();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when cache is fresh', () async {
      // Arrange
      final freshTimestamp = DateTime.now()
          .subtract(const Duration(minutes: 30))
          .millisecondsSinceEpoch;
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(freshTimestamp);

      // Act
      final result = await dataSource.isCacheExpired();

      // Assert
      expect(result, isFalse);
    });

    test('should return true when no cache timestamp exists', () async {
      // Arrange
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(null);

      // Act
      final result = await dataSource.isCacheExpired();

      // Assert
      expect(result, isTrue);
    });

    test('should return last cache update timestamp', () async {
      // Arrange
      final testTimestamp = DateTime(2024, 1, 1, 12, 0).millisecondsSinceEpoch;
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(testTimestamp);

      // Act
      final result = await dataSource.getLastCacheUpdate();

      // Assert
      expect(result, isNotNull);
      expect(result!.millisecondsSinceEpoch, testTimestamp);
    });

    test('should return null when no last cache update timestamp exists',
        () async {
      // Arrange
      when(() => mockSharedPreferences.getInt('safety_last_cache_update'))
          .thenReturn(null);

      // Act
      final result = await dataSource.getLastCacheUpdate();

      // Assert
      expect(result, isNull);
    });
  });
}
