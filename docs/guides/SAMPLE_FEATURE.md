# Sample Feature Implementation: Auth Feature

This document provides a concrete example of how the Auth feature would be implemented using clean architecture principles in the SoloAdventurer app.

## Directory Structure

```
lib/
└── features/
    └── auth/
        ├── data/
        │   ├── sources/
        │   │   ├── auth_local_data_source.dart
        │   │   └── auth_remote_data_source.dart
        │   ├── models/
        │   │   ├── user_model.dart
        │   │   └── auth_response_model.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── user.dart
        │   ├── repositories/
        │   │   └── auth_repository.dart
        │   └── use_cases/
        │       ├── login_use_case.dart
        │       ├── register_use_case.dart
        │       ├── logout_use_case.dart
        │       └── get_current_user_use_case.dart
        └── presentation/
            ├── screens/
            │   ├── login_screen.dart
            │   └── register_screen.dart
            ├── widgets/
            │   ├── auth_form.dart
            │   └── social_login_buttons.dart
            └── providers/
                └── auth_provider.dart
```

## Implementation Details

### Domain Layer

#### User Entity (user.dart)

```dart
class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? location;
  final List<String>? travelPreferences;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    this.phoneNumber,
    this.location,
    this.travelPreferences,
  });

  bool get hasCompletedProfile {
    return firstName != null &&
           lastName != null &&
           profileImageUrl != null;
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return email;
    }
  }
}
```

#### Auth Repository Interface (auth_repository.dart)

```dart
abstract class AuthRepository {
  /// Login with email and password
  ///
  /// Returns the authenticated user
  /// Throws [AuthException] if login fails
  Future<User> login(String email, String password);

  /// Register a new user with email and password
  ///
  /// Returns the registered user
  /// Throws [AuthException] if registration fails
  Future<User> register(String email, String password, String? firstName, String? lastName);

  /// Logout the current user
  ///
  /// Throws [AuthException] if logout fails
  Future<void> logout();

  /// Get the current authenticated user
  ///
  /// Returns null if no user is authenticated
  Future<User?> getCurrentUser();

  /// Check if a user is authenticated
  ///
  /// Returns true if a user is authenticated, false otherwise
  Future<bool> isAuthenticated();
}
```

#### Login Use Case (login_use_case.dart)

```dart
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> execute(String email, String password) async {
    if (email.isEmpty) {
      throw ValidationException('Email cannot be empty');
    }

    if (!email.contains('@')) {
      throw ValidationException('Invalid email format');
    }

    if (password.isEmpty) {
      throw ValidationException('Password cannot be empty');
    }

    return repository.login(email, password);
  }
}
```

### Data Layer

#### User Model (user_model.dart)

```dart
class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? location;
  final List<String>? travelPreferences;

  const UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    this.phoneNumber,
    this.location,
    this.travelPreferences,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      location: json['location'] as String?,
      travelPreferences: json['travelPreferences'] != null
          ? List<String>.from(json['travelPreferences'])
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'location': location,
      'travelPreferences': travelPreferences,
    };
  }

  // From Entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      profileImageUrl: user.profileImageUrl,
      phoneNumber: user.phoneNumber,
      location: user.location,
      travelPreferences: user.travelPreferences,
    );
  }

  // To Entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      profileImageUrl: profileImageUrl,
      phoneNumber: phoneNumber,
      location: location,
      travelPreferences: travelPreferences,
    );
  }
}
```

#### Auth Remote Data Source (auth_remote_data_source.dart)

```dart
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String? firstName, String? lastName);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Store tokens
      await SecureStorage.instance.setAuthToken(authResponse.token);
      await SecureStorage.instance.setRefreshToken(authResponse.refreshToken);

      return authResponse.user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> register(String email, String password, String? firstName, String? lastName) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Store tokens
      await SecureStorage.instance.setAuthToken(authResponse.token);
      await SecureStorage.instance.setRefreshToken(authResponse.refreshToken);

      return authResponse.user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout');

      // Clear tokens
      await SecureStorage.instance.clearAuthToken();
      await SecureStorage.instance.clearRefreshToken();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await SecureStorage.instance.getAuthToken();

      if (token == null) {
        return null;
      }

      final response = await apiClient.get('/auth/me');
      return UserModel.fromJson(response.data);
    } catch (e) {
      // If unauthorized, return null instead of throwing
      if (e is DioError && e.response?.statusCode == 401) {
        return null;
      }
      throw _handleError(e);
    }
  }

  AuthException _handleError(dynamic error) {
    if (error is DioError) {
      final statusCode = error.response?.statusCode;
      final message = error.response?.data?['message'] ?? error.message;

      if (statusCode == 401) {
        return AuthException('Invalid credentials');
      } else if (statusCode == 409) {
        return AuthException('Email already in use');
      } else {
        return AuthException('Authentication failed: $message');
      }
    }

    return AuthException('Authentication failed: ${error.toString()}');
  }
}
```

#### Auth Local Data Source (auth_local_data_source.dart)

```dart
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<bool> hasValidToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(
      'cached_user',
      jsonEncode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = sharedPreferences.getString('cached_user');

    if (userJson == null) {
      return null;
    }

    return UserModel.fromJson(jsonDecode(userJson));
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove('cached_user');
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await secureStorage.getAuthToken();
    return token != null;
  }
}
```

#### Auth Repository Implementation (auth_repository_impl.dart)

```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);

    // Cache user
    await localDataSource.cacheUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<User> register(String email, String password, String? firstName, String? lastName) async {
    final userModel = await remoteDataSource.register(email, password, firstName, lastName);

    // Cache user
    await localDataSource.cacheUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await localDataSource.clearUser();
  }

  @override
  Future<User?> getCurrentUser() async {
    // Check if we have a valid token
    final hasValidToken = await localDataSource.hasValidToken();

    if (!hasValidToken) {
      return null;
    }

    try {
      // Try to get user from remote
      final remoteUser = await remoteDataSource.getCurrentUser();

      if (remoteUser != null) {
        // Cache user
        await localDataSource.cacheUser(remoteUser);
        return remoteUser.toEntity();
      }

      return null;
    } catch (e) {
      // If remote fails, try to get from cache
      final cachedUser = await localDataSource.getUser();
      return cachedUser?.toEntity();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user != null;
  }
}
```

### Presentation Layer

#### Auth Provider (auth_provider.dart)

```dart
// Auth State
class AuthState {
  final AsyncValue<User?> user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user = const AsyncValue.loading(),
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user.value != null;

  AuthState copyWith({
    AsyncValue<User?>? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final user = await getCurrentUserUseCase.execute();
      state = state.copyWith(
        user: AsyncValue.data(user),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        user: AsyncValue.error(e, stackTrace),
        error: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final user = await loginUseCase.execute(email, password);

      state = state.copyWith(
        user: AsyncValue.data(user),
        isLoading: false,
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        user: AsyncValue.error(e, stackTrace),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register(String email, String password, String? firstName, String? lastName) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final user = await registerUseCase.execute(email, password, firstName, lastName);

      state = state.copyWith(
        user: AsyncValue.data(user),
        isLoading: false,
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        user: AsyncValue.error(e, stackTrace),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      await logoutUseCase.execute();

      state = state.copyWith(
        user: const AsyncValue.data(null),
        isLoading: false,
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
  );
});

// Use case providers
final loginUseCaseProvider = Provider((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});
```

#### Login Screen (login_screen.dart)

```dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).login(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Redirect to home if already authenticated
    ref.listen<AuthState>(authProvider, (previous, current) {
      if (current.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _login,
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    authState.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: const Text('Don\'t have an account? Register'),
              ),
              const SizedBox(height: 24),
              const SocialLoginButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Dependency Injection Setup

```dart
// In service_locator.dart

void setupAuthFeature() {
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: getIt<SecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );
}
```

## Testing

### Domain Layer Tests

```dart
// login_use_case_test.dart
void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepository);
  });

  test('should throw ValidationException when email is empty', () async {
    // Act & Assert
    expect(
      () => loginUseCase.execute('', 'password'),
      throwsA(isA<ValidationException>()),
    );
  });

  test('should throw ValidationException when email format is invalid', () async {
    // Act & Assert
    expect(
      () => loginUseCase.execute('invalid-email', 'password'),
      throwsA(isA<ValidationException>()),
    );
  });

  test('should throw ValidationException when password is empty', () async {
    // Act & Assert
    expect(
      () => loginUseCase.execute('test@example.com', ''),
      throwsA(isA<ValidationException>()),
    );
  });

  test('should call repository login with correct parameters', () async {
    // Arrange
    final testUser = User(id: '1', email: 'test@example.com');
    when(() => mockAuthRepository.login('test@example.com', 'password'))
        .thenAnswer((_) async => testUser);

    // Act
    final result = await loginUseCase.execute('test@example.com', 'password');

    // Assert
    expect(result, equals(testUser));
    verify(() => mockAuthRepository.login('test@example.com', 'password')).called(1);
  });
}
```

### Data Layer Tests

```dart
// auth_repository_impl_test.dart
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('login', () {
    test('should return User when login is successful', () async {
      // Arrange
      final userModel = UserModel(id: '1', email: 'test@example.com');
      when(() => mockRemoteDataSource.login('test@example.com', 'password'))
          .thenAnswer((_) async => userModel);
      when(() => mockLocalDataSource.cacheUser(userModel))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.login('test@example.com', 'password');

      // Assert
      expect(result, equals(userModel.toEntity()));
      verify(() => mockRemoteDataSource.login('test@example.com', 'password')).called(1);
      verify(() => mockLocalDataSource.cacheUser(userModel)).called(1);
    });

    test('should throw AuthException when login fails', () async {
      // Arrange
      when(() => mockRemoteDataSource.login('test@example.com', 'password'))
          .thenThrow(AuthException('Invalid credentials'));

      // Act & Assert
      expect(
        () => repository.login('test@example.com', 'password'),
        throwsA(isA<AuthException>()),
      );
      verify(() => mockRemoteDataSource.login('test@example.com', 'password')).called(1);
      verifyNever(() => mockLocalDataSource.cacheUser(any()));
    });
  });

  // Additional tests for register, logout, getCurrentUser, and isAuthenticated
}
```

### Presentation Layer Tests

```dart
// auth_provider_test.dart
void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        registerUseCaseProvider.overrideWithValue(mockRegisterUseCase),
        logoutUseCaseProvider.overrideWithValue(mockLogoutUseCase),
        getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUserUseCase),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('initial state is loading', () async {
    // Arrange
    when(() => mockGetCurrentUserUseCase.execute())
        .thenAnswer((_) async => null);

    // Act
    final container = createContainer();

    // Assert
    expect(container.read(authProvider).user, const AsyncValue<User?>.loading());
    expect(container.read(authProvider).isLoading, false);
    expect(container.read(authProvider).error, null);
  });

  test('login updates state correctly on success', () async {
    // Arrange
    final testUser = User(id: '1', email: 'test@example.com');
    when(() => mockGetCurrentUserUseCase.execute())
        .thenAnswer((_) async => null);
    when(() => mockLoginUseCase.execute('test@example.com', 'password'))
        .thenAnswer((_) async => testUser);

    // Act
    final container = createContainer();
    await container.read(authProvider.notifier).login('test@example.com', 'password');

    // Assert
    expect(container.read(authProvider).user, AsyncValue.data(testUser));
    expect(container.read(authProvider).isLoading, false);
    expect(container.read(authProvider).error, null);
    verify(() => mockLoginUseCase.execute('test@example.com', 'password')).called(1);
  });

  test('login updates state correctly on error', () async {
    // Arrange
    when(() => mockGetCurrentUserUseCase.execute())
        .thenAnswer((_) async => null);
    when(() => mockLoginUseCase.execute('test@example.com', 'password'))
        .thenThrow(AuthException('Invalid credentials'));

    // Act
    final container = createContainer();
    await container.read(authProvider.notifier).login('test@example.com', 'password');

    // Assert
    expect(container.read(authProvider).user.hasError, true);
    expect(container.read(authProvider).isLoading, false);
    expect(container.read(authProvider).error, 'AuthException: Invalid credentials');
    verify(() => mockLoginUseCase.execute('test@example.com', 'password')).called(1);
  });

  // Additional tests for register, logout, and initialization
}
```

## Conclusion

This sample implementation demonstrates how the Auth feature would be structured using clean architecture principles in the SoloAdventurer app. The separation of concerns between the domain, data, and presentation layers makes the code more maintainable, testable, and scalable.

Key benefits of this implementation:

1. **Separation of Concerns**: Each layer has a clear responsibility
2. **Testability**: Each component can be tested in isolation
3. **Dependency Rule**: Dependencies point inward, with the domain layer having no dependencies on outer layers
4. **Abstraction**: Interfaces define contracts between layers
5. **Error Handling**: Errors are handled at appropriate layers
6. **Caching Strategy**: Local caching is implemented for offline support
7. **State Management**: Riverpod is used for state management in the presentation layer

This implementation can serve as a template for other features in the app, ensuring consistency across the codebase.
