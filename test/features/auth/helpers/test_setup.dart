import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/app/providers/auth_service_providers.dart';
import 'test_helpers.dart';

/// Sets up a test environment for auth feature tests
class AuthTestSetup {
  late MockAuthRepository mockAuthRepository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockApiClient mockApiClient;
  late MockFlutterSecureStorage mockSecureStorage;
  late ProviderContainer container;

  /// Initialize test dependencies
  void setUp() {
    mockAuthRepository = MockAuthRepository();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockApiClient = MockApiClient();
    mockSecureStorage = MockFlutterSecureStorage();

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );

    addTearDown(container.dispose);
  }

  /// Clean up test dependencies
  void tearDown() {
    container.dispose();
  }

  /// Creates a test user for testing
  User createTestUser() {
    return User(
      id: testUserId,
      email: testEmail,
      username: testUsername,
      createdAt: testDateTime,
      lastLoginAt: testDateTime,
    );
  }
}

/// Extension methods for setting up common test scenarios
extension AuthTestSetupExtensions on AuthTestSetup {
  /// Sets up a successful authentication scenario
  void setupSuccessfulAuth() {
    when(() => mockAuthRepository.signInWithEmailAndPassword(
          any(),
          any(),
        )).thenAnswer((_) async => createTestUser());

    when(() => mockAuthRepository.isAuthenticated())
        .thenAnswer((_) async => true);
  }

  /// Sets up a failed authentication scenario
  void setupFailedAuth(String errorMessage) {
    when(() => mockAuthRepository.signInWithEmailAndPassword(
          any(),
          any(),
        )).thenThrow(Exception(errorMessage));

    when(() => mockAuthRepository.isAuthenticated())
        .thenAnswer((_) async => false);
  }
}
