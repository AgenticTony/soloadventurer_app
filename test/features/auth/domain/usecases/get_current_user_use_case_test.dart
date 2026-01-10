import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user_use_case.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/test_setup.dart';

void main() {
  late AuthTestSetup testSetup;
  late GetCurrentUserUseCase getCurrentUserUseCase;

  setUp(() {
    testSetup = AuthTestSetup()..setUp();
    getCurrentUserUseCase = GetCurrentUserUseCase(testSetup.mockAuthRepository);
  });

  tearDown(() {
    testSetup.tearDown();
  });

  group('GetCurrentUserUseCase', () {
    test('should return User when there is a current user', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => testSetup.createTestUser());

      // Act
      final result = await getCurrentUserUseCase.execute();

      // Assert
      expect(result, isA<User>());
      expect(result?.email, equals(testEmail));
      expect(result?.username, equals(testUsername));
    });

    test('should return null when there is no current user', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      // Act
      final result = await getCurrentUserUseCase.execute();

      // Assert
      expect(result, isNull);
    });

    test('should throw when getCurrentUser fails', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.getCurrentUser())
          .thenThrow(Exception('Failed to get current user'));

      // Act & Assert
      expect(
        () => getCurrentUserUseCase.execute(),
        throwsA(isA<Exception>()),
      );
    });

    test('should call repository getCurrentUser method', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      // Act
      await getCurrentUserUseCase.execute();

      // Assert
      verify(
        () => testSetup.mockAuthRepository.getCurrentUser(),
      ).called(1);
    });
  });
}
