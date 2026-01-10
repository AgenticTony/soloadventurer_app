import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/register_use_case.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/test_setup.dart';

void main() {
  late AuthTestSetup testSetup;
  late RegisterUseCase registerUseCase;

  setUp(() {
    testSetup = AuthTestSetup()..setUp();
    registerUseCase = RegisterUseCase(testSetup.mockAuthRepository);
  });

  tearDown(() {
    testSetup.tearDown();
  });

  group('RegisterUseCase', () {
    test('should return User when registration is successful', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => (testSetup.createTestUser(), false));

      // Act
      final result = await registerUseCase.execute(
        email: testEmail,
        password: testPassword,
        name: testUsername,
      );

      // Assert
      expect(result.$1, isA<User>());
      expect(result.$1.email, equals(testEmail));
      expect(result.$1.username, equals(testUsername));
    });

    test('should throw when registration fails', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenThrow(Exception('Registration failed'));

      // Act & Assert
      expect(
        () => registerUseCase.execute(
          email: testEmail,
          password: testPassword,
          name: testUsername,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => (testSetup.createTestUser(), false));

      // Act
      await registerUseCase.execute(
        email: testEmail,
        password: testPassword,
        name: testUsername,
      );

      // Assert
      verify(
        () => testSetup.mockAuthRepository.register(
          email: testEmail,
          password: testPassword,
          name: testUsername,
        ),
      ).called(1);
    });
  });
}
