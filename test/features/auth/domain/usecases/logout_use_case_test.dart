import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/usecases/logout_use_case.dart';
import '../../helpers/test_setup.dart';

void main() {
  late AuthTestSetup testSetup;
  late LogoutUseCase logoutUseCase;

  setUp(() {
    testSetup = AuthTestSetup()..setUp();
    logoutUseCase = LogoutUseCase(testSetup.mockAuthRepository);
  });

  tearDown(() {
    testSetup.tearDown();
  });

  group('LogoutUseCase', () {
    test('should complete successfully when logout succeeds', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.signOut())
          .thenAnswer((_) async {});

      // Act & Assert
      expect(
        logoutUseCase.execute(),
        completes,
      );
    });

    test('should throw when logout fails', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.signOut())
          .thenThrow(Exception('Logout failed'));

      // Act & Assert
      expect(
        () => logoutUseCase.execute(),
        throwsA(isA<Exception>()),
      );
    });

    test('should call repository signOut method', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.signOut())
          .thenAnswer((_) async {});

      // Act
      await logoutUseCase.execute();

      // Assert
      verify(
        () => testSetup.mockAuthRepository.signOut(),
      ).called(1);
    });
  });
}
