import 'package:flutter/material.dart' as material
    show
        TextButton,
        ElevatedButton,
        AppBar,
        Text,
        Icons,
        Key,
        TextFormField;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/api/interceptors/auth_interceptor.dart';
import 'package:soloadventurer/core/api/interceptors/error_interceptor.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/mock_auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:soloadventurer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/core/monitoring/performance/network_monitor.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'test_config.dart';
import 'package:soloadventurer/app/providers/auth_service_providers.dart'
    as auth_providers;

class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  ProfileModel? _mockProfile;

  void setMockProfile(ProfileModel profile) {
    _mockProfile = profile;
  }

  @override
  Future<ProfileModel> createProfile(ProfileModel profile) async {
    _mockProfile = profile;
    return profile;
  }

  @override
  Future<ProfileModel> getProfile(String userId) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    return _mockProfile!;
  }

  @override
  Future<ProfileModel> getCurrentProfile() async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    return _mockProfile!;
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    _mockProfile = profile;
    return profile;
  }

  @override
  Future<ProfileModel> updateProfileFields(
      String userId, Map<String, dynamic> fields) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    final updatedProfile = _mockProfile!.toEntity().copyWith(
          displayName: fields['displayName'] as String?,
          bio: fields['bio'] as String?,
          avatarUrl: fields['avatarUrl'] as String?,
          isPublic: fields['isPublic'] as bool?,
        );
    _mockProfile = ProfileModel.fromEntity(updatedProfile);
    return _mockProfile!;
  }

  @override
  Future<void> deleteProfile(String userId) async {
    _mockProfile = null;
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    final updatedProfile = _mockProfile!.toEntity().copyWith(
          avatarUrl: filePath,
        );
    _mockProfile = ProfileModel.fromEntity(updatedProfile);
    return filePath;
  }

  @override
  Future<void> removeAvatar(String userId) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    final updatedProfile = _mockProfile!.toEntity().copyWith(
          avatarUrl: null,
        );
    _mockProfile = ProfileModel.fromEntity(updatedProfile);
  }

  @override
  Future<void> updatePreferences(
      String userId, Map<String, dynamic> preferences) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    // Note: preferences are handled by the model's copyWith method
  }

  @override
  Future<void> updateInterests(String userId, List<String> interests) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    // Note: interests are handled by the model's copyWith method
  }

  @override
  Future<void> toggleProfileVisibility(String userId, bool isPublic) async {
    if (_mockProfile == null) {
      throw Exception('Mock profile not set');
    }
    final updatedProfile = _mockProfile!.toEntity().copyWith(
          isPublic: isPublic,
        );
    _mockProfile = ProfileModel.fromEntity(updatedProfile);
  }

  @override
  Future<bool> profileExists(String userId) async {
    return _mockProfile != null;
  }
}

class MockProfileLocalDataSource implements ProfileLocalDataSource {
  ProfileModel? _cachedProfile;
  Map<String, dynamic>? _cachedPreferences;
  List<String>? _cachedInterests;
  DateTime? _lastUpdate;

  @override
  Future<void> createProfile(ProfileModel profile) async {
    _cachedProfile = profile;
    _lastUpdate = DateTime.now();
  }

  @override
  Future<ProfileModel> getCachedProfile(String userId) async {
    if (await isCacheExpired()) {
      throw const CacheException(message: 'Cache expired');
    }
    if (_cachedProfile == null) {
      throw const CacheException(message: 'No cached profile found');
    }
    return _cachedProfile!;
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    _cachedProfile = profile;
    _lastUpdate = DateTime.now();
  }

  @override
  Future<void> clearCachedProfile(String userId) async {
    _cachedProfile = null;
    _cachedPreferences = null;
    _cachedInterests = null;
    _lastUpdate = null;
  }

  @override
  Future<void> cachePreferences(
      String userId, Map<String, dynamic> preferences) async {
    _cachedPreferences = preferences;
    _lastUpdate = DateTime.now();
  }

  @override
  Future<Map<String, dynamic>?> getCachedPreferences(String userId) async {
    if (await isCacheExpired()) {
      return null;
    }
    return _cachedPreferences;
  }

  @override
  Future<void> cacheInterests(String userId, List<String> interests) async {
    _cachedInterests = interests;
    _lastUpdate = DateTime.now();
  }

  @override
  Future<List<String>?> getCachedInterests(String userId) async {
    if (await isCacheExpired()) {
      return null;
    }
    return _cachedInterests;
  }

  @override
  Future<bool> isCacheExpired() async {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > const Duration(hours: 24);
  }
}

/// Mock AuthLocalDataSource for integration testing
class MockAuthLocalDataSource implements AuthLocalDataSource {
  final SecureStorage _storage;
  User? _cachedUser;
  String? _authToken;
  String? _refreshToken;
  DateTime? _tokenExpiration;

  MockAuthLocalDataSource(this._storage);

  @override
  Future<void> cacheUser(User user) async {
    _cachedUser = user;
  }

  @override
  Future<User?> getCachedUser() async => _cachedUser;

  @override
  Future<void> clearCache() async {
    _cachedUser = null;
    await _storage.deleteAll();
  }

  @override
  Future<void> saveAuthData(
    String token,
    String refreshToken, {
    DateTime? expiresAt,
    String? idToken,
  }) async {
    _authToken = token;
    _refreshToken = refreshToken;
    _tokenExpiration = expiresAt;
  }

  @override
  Future<String?> getAuthToken() async => _authToken;

  @override
  Future<String?> getIdToken() async => null;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<bool> isTokenExpired() async {
    if (_tokenExpiration == null) return false;
    return DateTime.now().isAfter(_tokenExpiration!);
  }

  @override
  Future<DateTime?> getTokenExpiration() async => _tokenExpiration;

  @override
  Future<void> clearAuthData() async {
    _authToken = null;
    _refreshToken = null;
    _tokenExpiration = null;
  }

  @override
  Future<bool> hasValidSession() async {
    return _authToken != null &&
        _refreshToken != null &&
        !(await isTokenExpired());
  }

  @override
  Future<void> cacheAuthToken(String token) async {
    _authToken = token;
  }

  @override
  Future<void> cacheIdToken(String token) async {}

  @override
  Future<void> cacheRefreshToken(String token) async {
    _refreshToken = token;
  }

  @override
  Future<void> cacheUserData(Map<String, dynamic> userData) async {}

  @override
  Future<String?> getCachedAuthToken() async => _authToken;

  @override
  Future<String?> getCachedRefreshToken() async => _refreshToken;

  @override
  Future<User?> getCachedUserData() async => _cachedUser;

  @override
  Future<void> deleteAuthToken() async {
    _authToken = null;
  }

  @override
  Future<void> deleteRefreshToken() async {
    _refreshToken = null;
  }

  @override
  Future<void> setTokenExpiration(DateTime expiration) async {
    _tokenExpiration = expiration;
  }

  @override
  Future<void> clearSession() async {
    _authToken = null;
    _refreshToken = null;
    _tokenExpiration = null;
    _cachedUser = null;
  }

  @override
  Future<bool> hasAuthToken() async => _authToken != null;

  @override
  Future<bool> hasRefreshToken() async => _refreshToken != null;

  @override
  Future<void> setAuthToken(String token) async {
    _authToken = token;
  }

  @override
  Future<void> setIdToken(String idToken) async {
    // Store for later use
  }

  @override
  Future<void> setRefreshToken(String refreshToken) async {
    _refreshToken = refreshToken;
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    if (_cachedUser == null) return null;
    return {
      'id': _cachedUser!.id,
      'email': _cachedUser!.email,
      'username': _cachedUser!.username,
      'createdAt': _cachedUser!.createdAt.toIso8601String(),
    };
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late ApiClient apiClient;
  late MockProfileRemoteDataSource mockProfileRemoteDataSource;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late AuthRepository authRepository;

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Initialize service locator in test mode
    await setupServiceLocator(isTest: true);

    // Clear any existing auth data
    await getIt<SecureStorage>().delete(TestConfig.authTokenKey);
    await getIt<SecureStorage>().delete(TestConfig.refreshTokenKey);
    await getIt<SecureStorage>().delete(TestConfig.userDataKey);

    // Create ApiClient instance for testing
    apiClient = ApiClient(
      baseUrl: TestConfig.apiBaseUrl,
      authInterceptor: AuthInterceptor(),
      errorInterceptor: ErrorInterceptor(),
      networkMonitor: NetworkMonitor(),
    );

    // Initialize mock data sources
    mockProfileRemoteDataSource = MockProfileRemoteDataSource();
    mockAuthRemoteDataSource = MockAuthRemoteDataSource(apiClient);

    // Create AuthLocalDataSource and SecurityManager for testing
    final authLocalDataSource = MockAuthLocalDataSource(getIt<SecureStorage>());

    // Get SecurityManager from service locator (it's registered in core_module)
    final securityManager = getIt<SecurityManager>();

    authRepository = AuthRepositoryImpl(
      remoteDataSource: mockAuthRemoteDataSource,
      localDataSource: authLocalDataSource,
      securityManager: securityManager,
    );

    // Override providers with mock implementations
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        auth_providers.authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
  });

  tearDown(() async {
    // Reset service locator after each test
    await resetServiceLocator();
    container.dispose();
  });

  testWidgets('Complete authentication flow', (tester) async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const App(),
    ));
    await tester.pumpAndSettle();

    // Test: Initial state should show login screen
    expect(find.widgetWithText(material.AppBar, 'Login'), findsOneWidget);
    expect(find.text('SoloAdventurer'), findsOneWidget);

    // Test: Navigate to sign up screen
    await tester.tap(find.widgetWithText(material.TextButton, 'Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Join SoloAdventurer'), findsOneWidget);

    // Test: Sign up flow
    await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(find.widgetWithText(material.TextFormField, 'Email'),
        'test@example.com');
    await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Password'), 'password123');
    await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Confirm Password'),
        'password123');

    await tester.tap(find.widgetWithText(material.ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();

    // Set up mock profile data after sign up
    mockProfileRemoteDataSource.setMockProfile(ProfileModel(
      id: 'test-123',
      userId: 'test-user-id',
      username: 'test_user',
      email: 'test@example.com',
      displayName: 'Test User',
      bio: '',
      isPublic: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Wait for the state to be updated and navigation to complete
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify that we're on the edit profile screen
    expect(find.byType(material.AppBar), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);

    // Enter display name
    await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Display Name *'),
        'Test User');
    await tester.pumpAndSettle();

    // Save the profile
    await tester.tap(find.byIcon(material.Icons.save));
    await tester.pumpAndSettle();

    // Wait for navigation to complete and state to update
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Additional wait to ensure navigation is complete
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify that we're on the home screen
    expect(find.byType(material.AppBar), findsOneWidget);
    expect(find.byKey(const material.Key('home_screen_title')), findsOneWidget,
        reason: 'Could not find welcome text with key home_screen_title');
    expect(find.text('Welcome to SoloAdventurer!'), findsOneWidget);

    // Test: Sign out
    await tester.tap(find.byIcon(material.Icons.logout));
    await tester.pumpAndSettle();

    // Additional wait to ensure state updates are processed
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Test: Should be back on login screen
    expect(find.widgetWithText(material.AppBar, 'Login'), findsOneWidget,
        reason: 'Could not find AppBar with title "Login" after sign out');

    // Additional wait to ensure navigation is complete
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Test: Should be back on login screen
    expect(find.byType(material.AppBar), findsOneWidget);
    expect(find.text('SoloAdventurer'), findsOneWidget);

    // Test: Sign in with created account
    await tester.enterText(find.widgetWithText(material.TextFormField, 'Email'),
        'test@example.com');
    await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Password'), 'password123');

    await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Wait for navigation to complete
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Test: Should be authenticated again
    expect(find.text('Welcome to SoloAdventurer!'), findsOneWidget);

    // Test: Sign out again
    await tester.tap(find.byIcon(material.Icons.logout));
    await tester.pumpAndSettle();

    // Test: Should be back on login screen
    expect(find.widgetWithText(material.AppBar, 'Login'), findsOneWidget);

    // Test: Offline mode
    await tester.enterText(find.widgetWithText(material.TextFormField, 'Email'),
        'test@example.com');
    await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Password'), 'password123');

    // Simulate offline mode by setting API client to offline mode
    apiClient.setOfflineMode(true);

    await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Test: Should show offline error
    expect(find.text('No internet connection'), findsOneWidget);

    // Test: Error handling
    apiClient.setOfflineMode(false);
    await tester.enterText(find.widgetWithText(material.TextFormField, 'Email'),
        'test@example.com');
    await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Password'),
        'wrongpassword');

    await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Test: Should show invalid credentials error
    expect(find.text('Invalid credentials'), findsOneWidget);

    // Verify we're on the home screen
    await tester.pumpAndSettle();
    expect(find.text('Welcome to SoloAdventurer!'), findsOneWidget);
  });
}
