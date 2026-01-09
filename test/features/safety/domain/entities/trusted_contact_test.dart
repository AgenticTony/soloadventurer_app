import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import '../../../../helpers/safety_test_helpers.dart';

void main() {
  group('TrustedContact Entity', () {
    test('should create a valid TrustedContact instance', () {
      // Arrange & Act
      final contact = createTestTrustedContact();

      // Assert
      expect(contact.id, equals(testContactId));
      expect(contact.userId, equals(testUserId));
      expect(contact.name, equals(testContactName));
      expect(contact.phoneNumber, equals(testContactPhone));
      expect(contact.email, equals(testContactEmail));
      expect(contact.source, equals(ContactSource.phone));
      expect(contact.permission, equals(ContactPermission.fullAccess));
    });

    test('should create a TrustedContact with default boolean values', () {
      // Arrange & Act
      final contact = TrustedContact(
        id: testContactId,
        userId: testUserId,
        name: testContactName,
        phoneNumber: testContactPhone,
        source: ContactSource.phone,
        permission: ContactPermission.fullAccess,
        addedAt: testDateTime,
      );

      // Assert
      expect(contact.locationSharingEnabled, isFalse);
      expect(contact.receivesCheckIns, isTrue);
      expect(contact.receivesEmergencyAlerts, isTrue);
    });

    test('should create a TrustedContact with optional fields as null', () {
      // Arrange & Act
      final contact = TrustedContact(
        id: testContactId,
        userId: testUserId,
        name: testContactName,
        phoneNumber: testContactPhone,
        source: ContactSource.phone,
        permission: ContactPermission.emergencyOnly,
        addedAt: testDateTime,
      );

      // Assert
      expect(contact.email, isNull);
      expect(contact.communityUserId, isNull);
      expect(contact.updatedAt, isNull);
      expect(contact.revokedAt, isNull);
      expect(contact.notes, isNull);
    });

    test('should compare equal when all properties match', () {
      // Arrange
      final contact1 = createTestTrustedContact();
      final contact2 = createTestTrustedContact();

      // Assert
      expect(contact1, equals(contact2));
    });

    test('should not compare equal when any property differs', () {
      // Arrange
      final contact1 = createTestTrustedContact();
      final contact2 = createTestTrustedContact(id: 'different-id');

      // Assert
      expect(contact1, isNot(equals(contact2)));
    });

    test('should handle ContactSource enum values correctly', () {
      // Assert
      expect(ContactSource.phone, equals(ContactSource.phone));
      expect(ContactSource.community, equals(ContactSource.community));
      expect(ContactSource.phone, isNot(equals(ContactSource.community)));
    });

    test('should handle ContactPermission enum values correctly', () {
      // Assert
      expect(ContactPermission.emergencyOnly,
          equals(ContactPermission.emergencyOnly));
      expect(ContactPermission.checkIns, equals(ContactPermission.checkIns));
      expect(
          ContactPermission.fullAccess, equals(ContactPermission.fullAccess));
      expect(ContactPermission.emergencyOnly,
          isNot(equals(ContactPermission.fullAccess)));
    });

    test('should create TrustedContact with community source', () {
      // Arrange & Act
      final contact = TrustedContact(
        id: testContactId,
        userId: testUserId,
        name: testContactName,
        phoneNumber: testContactPhone,
        source: ContactSource.community,
        communityUserId: 'community-user-123',
        permission: ContactPermission.checkIns,
        addedAt: testDateTime,
      );

      // Assert
      expect(contact.source, equals(ContactSource.community));
      expect(contact.communityUserId, equals('community-user-123'));
    });

    test('should create TrustedContact with all permission levels', () {
      // Arrange & Act
      final emergencyOnlyContact = createTestTrustedContact(
        permission: ContactPermission.emergencyOnly,
      );
      final checkInsContact = createTestTrustedContact(
        permission: ContactPermission.checkIns,
      );
      final fullAccessContact = createTestTrustedContact(
        permission: ContactPermission.fullAccess,
      );

      // Assert
      expect(emergencyOnlyContact.permission,
          equals(ContactPermission.emergencyOnly));
      expect(checkInsContact.permission, equals(ContactPermission.checkIns));
      expect(
          fullAccessContact.permission, equals(ContactPermission.fullAccess));
    });

    test('should handle boolean flags correctly', () {
      // Arrange & Act
      final contact = TrustedContact(
        id: testContactId,
        userId: testUserId,
        name: testContactName,
        phoneNumber: testContactPhone,
        source: ContactSource.phone,
        permission: ContactPermission.fullAccess,
        locationSharingEnabled: true,
        receivesCheckIns: false,
        receivesEmergencyAlerts: true,
        addedAt: testDateTime,
      );

      // Assert
      expect(contact.locationSharingEnabled, isTrue);
      expect(contact.receivesCheckIns, isFalse);
      expect(contact.receivesEmergencyAlerts, isTrue);
    });

    test('should include timestamp fields', () {
      // Arrange & Act
      final addedAt = DateTime(2024, 1, 1, 10, 0);
      final updatedAt = DateTime(2024, 1, 2, 10, 0);
      final revokedAt = DateTime(2024, 1, 3, 10, 0);

      final contact = createTestTrustedContact(
        addedAt: addedAt,
        updatedAt: updatedAt,
        revokedAt: revokedAt,
      );

      // Assert
      expect(contact.addedAt, equals(addedAt));
      expect(contact.updatedAt, equals(updatedAt));
      expect(contact.revokedAt, equals(revokedAt));
    });
  });
}
