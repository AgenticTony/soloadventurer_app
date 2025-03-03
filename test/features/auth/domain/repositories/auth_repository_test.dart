import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/test_setup.dart';

void main() {
  late AuthTestSetup testSetup;

  setUp(() {
    testSetup = AuthTestSetup()..setUp();
  });

  tearDown(() {
    testSetup.tearDown();
  });

  group('AuthRepository', () {
    test('signInWithEmailAndPassword should return User on success', () async {
      // Arrange
      testSetup.setupSuccessfulAuth();

      // Act
      final user =
          await testSetup.mockAuthRepository.signInWithEmailAndPassword(
        testEmail,
        testPassword,
      );

      // Assert
      expect(user, isA<User>());
      expect(user.email, equals(testEmail));
    });

    test('signInWithEmailAndPassword should throw on failure', () async {
      // Arrange
      const errorMessage = 'Invalid credentials';
      testSetup.setupFailedAuth(errorMessage);

      // Act & Assert
      expect(
        () => testSetup.mockAuthRepository.signInWithEmailAndPassword(
          testEmail,
          testPassword,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('isAuthenticated should return true when user is authenticated',
        () async {
      // Arrange
      testSetup.setupSuccessfulAuth();

      // Act
      final isAuthenticated =
          await testSetup.mockAuthRepository.isAuthenticated();

      // Assert
      expect(isAuthenticated, isTrue);
    });

    test('isAuthenticated should return false when user is not authenticated',
        () async {
      // Arrange
      testSetup.setupFailedAuth('Not authenticated');

      // Act
      final isAuthenticated =
          await testSetup.mockAuthRepository.isAuthenticated();

      // Assert
      expect(isAuthenticated, isFalse);
    });
  });
}
