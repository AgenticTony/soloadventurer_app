# Riverpod Strategy for SoloAdventurer

This document outlines our approach to using Riverpod for state management in the SoloAdventurer app, including provider organization, testing strategy, and best practices.

## Provider Organization

### Directory Structure

We organize providers by feature and type:

```
lib/
├─ features/
│  ├─ auth/
│  │  ├─ presentation/
│  │  │  ├─ providers/
│  │  │  │  ├─ auth_provider.dart
│  │  │  │  ├─ auth_state.dart
│  │  │  │  ├─ token_provider.dart
│  │  │  │  └─ session_provider.dart
│  ├─ profile/
│  │  ├─ presentation/
│  │  │  ├─ providers/
│  │  │  │  └─ profile_provider.dart
├─ shared/
│  ├─ providers/
│  │  ├─ app_providers.dart      // App-wide providers
│  │  └─ network_providers.dart  // Network-related providers
```

### Provider Types

We use four main types of providers:

1. **State Providers**: Business logic and UI state

   ```dart
   @riverpod
   class AuthNotifier extends _$AuthNotifier {
     @override
     AuthState build() => AuthState.initial();

     Future<void> signIn(String email, String password) async {
       state = state.copyWith(isLoading: true, errorMessage: null);
       final result = await AsyncValue.guard(
         () => _authRepository.signInWithEmailAndPassword(email, password),
       );

       state = state.copyWith(
         user: result,
         isLoading: false,
         status: result.hasError ? AuthStatus.error : AuthStatus.authenticated,
         errorMessage: result.hasError ? _mapErrorToMessage(result.error!) : null,
       );
     }
   }
   ```

2. **Service Providers**: External services and repositories

   ```dart
   @riverpod
   AuthRepository authRepository(AuthRepositoryRef ref) {
     final authService = ref.watch(authServiceProvider);
     return AuthRepositoryImpl(authService);
   }
   ```

3. **Infrastructure Providers**: AWS services, network clients, etc.

   ```dart
   @riverpod
   Dio dioClient(DioClientRef ref) {
     final token = ref.watch(tokenProvider);
     return Dio()
       ..interceptors.add(
         AuthInterceptor(token),
       );
   }
   ```

4. **Utility Providers**: Helpers and formatters
   ```dart
   @riverpod
   class ErrorMapper extends _$ErrorMapper {
     String mapAuthError(AuthException error) {
       return switch (error) {
         UserNotFoundException() => 'No account found with this email',
         InvalidPasswordException() => 'Incorrect password',
         _ => 'An unexpected error occurred'
       };
     }
   }
   ```

## Error Handling Strategy

### 1. Using AsyncValue

Always use AsyncValue for async operations:

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    required AsyncValue<User?> user,
    required AuthStatus status,
    String? errorMessage,
    required bool isLoading,
  }) = _AuthState;

  factory AuthState.initial() => AuthState(
    user: const AsyncValue.data(null),
    status: AuthStatus.initial,
    isLoading: false,
  );
}
```

### 2. Error Mapping

Implement consistent error mapping:

```dart
@riverpod
class AuthErrorMapper extends _$AuthErrorMapper {
  String mapCognitoError(CognitoException error) {
    return switch (error.code) {
      'UserNotFoundException' => 'No account found with this email',
      'NotAuthorizedException' => 'Incorrect password',
      'UserNotConfirmedException' => 'Please verify your email first',
      _ => 'An unexpected error occurred'
    };
  }
}
```

### 3. Error Propagation

Properly propagate errors through layers:

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authRepository.signIn(email, password);
      state = state.copyWith(
        user: AsyncValue.data(result),
        status: AuthStatus.authenticated,
      );
    } on CognitoException catch (e) {
      final errorMessage = ref.read(authErrorMapperProvider).mapCognitoError(e);
      state = state.copyWith(
        user: AsyncValue.error(e, StackTrace.current),
        errorMessage: errorMessage,
        status: AuthStatus.error,
      );
    }
  }
}
```

## Testing Strategy

### 1. Provider Unit Tests

Test providers in isolation:

```dart
void main() {
  late ProviderContainer container;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  });

  test('signIn updates state correctly on success', () async {
    final notifier = container.read(authNotifierProvider.notifier);

    when(mockAuthRepository.signIn(any, any))
        .thenAnswer((_) async => mockUser);

    await notifier.signIn('email', 'password');

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user, isA<AsyncData<User>>());
  });

  test('signIn handles errors correctly', () async {
    final notifier = container.read(authNotifierProvider.notifier);

    when(mockAuthRepository.signIn(any, any))
        .thenThrow(const CognitoException('UserNotFoundException'));

    await notifier.signIn('email', 'password');

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'No account found with this email');
  });
}
```

### 2. Widget Tests with Providers

Test widgets with provider integration:

```dart
testWidgets('LoginScreen shows error message on failed login',
    (WidgetTester tester) async {
  final mockAuthNotifier = MockAuthNotifier();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => mockAuthNotifier),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    ),
  );

  when(mockAuthNotifier.signIn(any, any))
      .thenThrow(const CognitoException('UserNotFoundException'));

  await tester.enterText(find.byType(EmailField), 'test@example.com');
  await tester.enterText(find.byType(PasswordField), 'password');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  expect(find.text('No account found with this email'), findsOneWidget);
});
```

### 3. Integration Tests

Test complete features:

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete auth flow test', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Test sign up
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EmailField), 'test@example.com');
    await tester.enterText(find.byType(PasswordField), 'password123');
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify email verification screen is shown
    expect(find.text('Verify your email'), findsOneWidget);
  });
}
```

## Performance Optimization

### 1. Selective Updates

Use select for granular updates:

```dart
// Good: Only rebuilds when user name changes
final userName = ref.watch(
  authProvider.select((state) => state.user.value?.name)
);

// Bad: Rebuilds on any auth state change
final user = ref.watch(authProvider).user.value;
final userName = user?.name;
```

### 2. Caching Strategy

Implement proper caching:

```dart
@riverpod
class CachedUserProfile extends _$CachedUserProfile {
  @override
  Future<UserProfile> build(String userId) async {
    // Cache for 5 minutes
    ref.keepAlive();
    ref.onDispose(() {
      // Clear cache after 5 minutes
      Future.delayed(const Duration(minutes: 5), () {
        ref.invalidateSelf();
      });
    });

    return ref.watch(userRepositoryProvider).getUserProfile(userId);
  }
}
```

## Implementation Plan

### Phase 1: Core Authentication (Current)

1. ✅ Basic provider structure
2. ✅ Auth state management
3. 🚧 Error handling
4. 🚧 Token management
5. 🚧 Testing infrastructure

### Phase 2: Profile Feature

1. Profile state management
2. Profile error handling
3. Avatar management
4. Testing implementation

### Phase 3: Advanced Features

1. Real-time updates
2. Offline support
3. Performance optimization
4. Advanced caching

## Best Practices

1. Always use AsyncValue for async operations
2. Implement proper error handling at all layers
3. Write comprehensive tests
4. Use selective updates for performance
5. Document provider dependencies
6. Maintain consistent naming conventions
7. Keep providers focused and small
8. Use proper provider organization
9. Implement proper cleanup in dispose
10. Monitor provider performance

## Monitoring & Debugging

### 1. Provider Observer

```dart
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "previousValue": "$previousValue",
  "newValue": "$newValue"
}''');
  }
}
```

### 2. Performance Monitoring

```dart
extension ProviderContainerX on ProviderContainer {
  void trackProviderUpdates() {
    final observer = ProviderLogger();
    this.addObserver(observer);
  }
}
```

## References

- [Riverpod Documentation](https://riverpod.dev)
- [AWS Cognito Integration Guide](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-app-integration.html)
- [Flutter Testing Best Practices](https://docs.flutter.dev/testing)
