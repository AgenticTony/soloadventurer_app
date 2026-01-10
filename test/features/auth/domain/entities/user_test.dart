import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('User Entity', () {
    test('should create a valid User instance', () {
      final user = User(
        id: testUserId,
        email: testEmail,
        username: testUsername,
        createdAt: testDateTime,
        lastLoginAt: testDateTime,
      );

      expect(user.id, equals(testUserId));
      expect(user.email, equals(testEmail));
      expect(user.username, equals(testUsername));
      expect(user.createdAt, equals(testDateTime));
      expect(user.lastLoginAt, equals(testDateTime));
    });

    test('should create a User instance with optional fields as null', () {
      final user = User(
        id: testUserId,
        email: testEmail,
        username: testUsername,
        createdAt: testDateTime,
      );

      expect(user.id, equals(testUserId));
      expect(user.email, equals(testEmail));
      expect(user.username, equals(testUsername));
      expect(user.createdAt, equals(testDateTime));
      expect(user.lastLoginAt, isNull);
    });

    test('should compare equal when all properties match', () {
      final user1 = User(
        id: testUserId,
        email: testEmail,
        username: testUsername,
        createdAt: testDateTime,
        lastLoginAt: testDateTime,
      );

      final user2 = User(
        id: testUserId,
        email: testEmail,
        username: testUsername,
        createdAt: testDateTime,
        lastLoginAt: testDateTime,
      );

      expect(user1, equals(user2));
    });

    test('should not compare equal when any property differs', () {
      final user1 = User(
        id: testUserId,
        email: testEmail,
        username: testUsername,
        createdAt: testDateTime,
        lastLoginAt: testDateTime,
      );

      final user2 = User(
        id: 'different-id',
        email: testEmail,
        username: testUsername,
        createdAt: testDateTime,
        lastLoginAt: testDateTime,
      );

      expect(user1, isNot(equals(user2)));
    });
  });
}
