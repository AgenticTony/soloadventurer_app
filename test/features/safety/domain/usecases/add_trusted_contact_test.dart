import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/usecases/add_trusted_contact.dart';
import '../../../../helpers/safety_test_helpers.dart';
import '../../../../helpers/safety_test_setup.dart';

void main() {
  late SafetyTestSetup testSetup;
  late AddTrustedContactUseCase addTrustedContactUseCase;

  setUp(() {
    testSetup = SafetyTestSetup()..setUp();
    addTrustedContactUseCase = testSetup.addTrustedContactUseCase;
  });

  tearDown(() {
    testSetup.tearDown();
  });

  group('AddTrustedContactUseCase', () {
    test('should return TrustedContact when add is successful', () async {
      // Arrange
      final testContact = createTestTrustedContact();
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result = await addTrustedContactUseCase(testContact);

      // Assert
      expect(result, isA<TrustedContact>());
      expect(result.id, equals(testContact.id));
      expect(result.name, equals(testContact.name));
      expect(result.phoneNumber, equals(testContact.phoneNumber));
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      final testContact = createTestTrustedContact();
      testSetup.setupSuccessfulContactOperations();

      // Act
      await addTrustedContactUseCase(testContact);

      // Assert
      verify(() => testSetup.mockRepository.addTrustedContact(testContact))
          .called(1);
    });

    test('should throw when repository throws', () async {
      // Arrange
      final testContact = createTestTrustedContact();
      const errorMessage = 'Failed to add contact';
      testSetup.setupFailedContactOperations(errorMessage);

      // Act & Assert
      expect(
        () => addTrustedContactUseCase(testContact),
        throwsA(isA<Exception>()),
      );
    });

    test('should add contact with phone source', () async {
      // Arrange
      final phoneContact = createTestTrustedContact(
        source: ContactSource.phone,
      );
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result = await addTrustedContactUseCase(phoneContact);

      // Assert
      expect(result.source, equals(ContactSource.phone));
      verify(() => testSetup.mockRepository.addTrustedContact(phoneContact))
          .called(1);
    });

    test('should add contact with community source', () async {
      // Arrange
      final communityContact = createTestTrustedContact(
        source: ContactSource.community,
        communityUserId: 'community-user-123',
      );
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result = await addTrustedContactUseCase(communityContact);

      // Assert
      expect(result.source, equals(ContactSource.community));
      expect(result.communityUserId, equals('community-user-123'));
      verify(() =>
              testSetup.mockRepository.addTrustedContact(communityContact))
          .called(1);
    });

    test('should add contact with emergency only permission', () async {
      // Arrange
      final emergencyContact = createTestTrustedContact(
        permission: ContactPermission.emergencyOnly,
      );
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result = await addTrustedContactUseCase(emergencyContact);

      // Assert
      expect(result.permission, equals(ContactPermission.emergencyOnly));
      verify(() =>
              testSetup.mockRepository.addTrustedContact(emergencyContact))
          .called(1);
    });

    test('should add contact with check-ins permission', () async {
      // Arrange
      final checkInsContact = createTestTrustedContact(
        permission: ContactPermission.checkIns,
      );
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result = await addTrustedContactUseCase(checkInsContact);

      // Assert
      expect(result.permission, equals(ContactPermission.checkIns));
      verify(() =>
              testSetup.mockRepository.addTrustedContact(checkInsContact))
          .called(1);
    });

    test('should add contact with full access permission', () async {
      // Arrange
      final fullAccessContact = createTestTrustedContact(
        permission: ContactPermission.fullAccess,
      );
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result = await addTrustedContactUseCase(fullAccessContact);

      // Assert
      expect(result.permission, equals(ContactPermission.fullAccess));
      verify(() =>
              testSetup.mockRepository.addTrustedContact(fullAccessContact))
          .called(1);
    });

    test('should add contact with location sharing enabled', () async {
      // Arrange
      final locationSharingContact = createTestTrustedContact(
        locationSharingEnabled: true,
      );
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result = await addTrustedContactUseCase(locationSharingContact);

      // Assert
      expect(result.locationSharingEnabled, isTrue);
      verify(() =>
              testSetup.mockRepository.addTrustedContact(locationSharingContact))
          .called(1);
    });

    test('should add contact with all notification preferences', () async {
      // Arrange
      final allNotificationsContact = createTestTrustedContact(
        receivesCheckIns: true,
        receivesEmergencyAlerts: true,
      );
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result =
          await addTrustedContactUseCase(allNotificationsContact);

      // Assert
      expect(result.receivesCheckIns, isTrue);
      expect(result.receivesEmergencyAlerts, isTrue);
      verify(() => testSetup.mockRepository.addTrustedContact(
              allNotificationsContact))
          .called(1);
    });

    test('should add contact with no check-in notifications', () async {
      // Arrange
      final noCheckInsContact = createTestTrustedContact(
        receivesCheckIns: false,
        receivesEmergencyAlerts: true,
      );
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result = await addTrustedContactUseCase(noCheckInsContact);

      // Assert
      expect(result.receivesCheckIns, isFalse);
      expect(result.receivesEmergencyAlerts, isTrue);
      verify(() =>
              testSetup.mockRepository.addTrustedContact(noCheckInsContact))
          .called(1);
    });

    test('should add contact with email', () async {
      // Arrange
      final contactWithEmail = createTestTrustedContact(
        email: testContactEmail,
      );
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result = await addTrustedContactUseCase(contactWithEmail);

      // Assert
      expect(result.email, equals(testContactEmail));
      verify(() =>
              testSetup.mockRepository.addTrustedContact(contactWithEmail))
          .called(1);
    });

    test('should add contact with notes', () async {
      // Arrange
      final contactWithNotes = createTestTrustedContact(
        notes: 'Family member',
      );
      testSetup.setupSuccessfulContactOperations();

      // Act
      final result = await addTrustedContactUseCase(contactWithNotes);

      // Assert
      expect(result.notes, equals('Family member'));
      verify(() =>
              testSetup.mockRepository.addTrustedContact(contactWithNotes))
          .called(1);
    });
  });
}
