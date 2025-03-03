import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/signup_screen.dart';
import 'package:soloadventurer/features/profile/presentation/providers/profile_providers.dart';
import 'package:soloadventurer/features/profile/presentation/notifiers/profile_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';

import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

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

    // Mock profile data source
    final mockProfile = ProfileModel(
      id: 'test-user-id',
      displayName: 'Test User',
      bio: 'Test bio',
      avatarUrl: null,
      isPublic: false,
    );

    getIt<ProfileRemoteDataSource>().setMockProfile(mockProfile);

    // Override sharedPreferencesProvider with the test instance
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) => prefs),
        profileProvider.overrideWith((ref) => ProfileNotifier(
              getCurrentProfile: ref.watch(getCurrentProfileUseCaseProvider),
              updateProfile: ref.watch(updateProfileUseCaseProvider),
              manageAvatar: ref.watch(manageAvatarUseCaseProvider),
              deleteProfile: ref.watch(deleteProfileUseCaseProvider),
            )),
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
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    expect(find.text('SoloAdventurer'), findsOneWidget);

    // Test: Navigate to sign up screen
    await tester.tap(find.widgetWithText(TextButton, 'Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Join SoloAdventurer'), findsOneWidget);

    // Test: Sign up flow
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();

    // Wait for the state to be updated and navigation to complete
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Debug prints
    debugPrint('Current widget tree:');
    debugPrint('Current widgets:');
    for (var widget in tester.allWidgets) {
      debugPrint('  ${widget.runtimeType}');
      if (widget is Text) {
        debugPrint('    Text: "${widget.data}"');
      }
      if (widget is AppBar) {
        debugPrint('    AppBar title: ${(widget.title as Text?)?.data}');
      }
    }

    // Wait for any loading indicators to disappear and navigation to complete
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify that we're on the edit profile screen
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);

    // Enter display name
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'), 'Test User');
    await tester.pumpAndSettle();

    // Save the profile
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Wait for navigation to complete and state to update
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Debug prints
    debugPrint('Current widget tree after save:');
    debugPrint('Current widgets:');
    for (var widget in tester.allWidgets) {
      debugPrint('  ${widget.runtimeType}');
      if (widget is Text) {
        debugPrint('    Text: "${widget.data}"');
      }
      if (widget is AppBar) {
        debugPrint('    AppBar title: ${(widget.title as Text?)?.data}');
      }
    }

    // Verify that we're on the home screen
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byKey(const Key('home_screen_title')), findsOneWidget);
    expect(find.textContaining('Welcome'), findsOneWidget);

    // Test: Sign out
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    // Test: Should be back on login screen
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);

    // Test: Sign in with created account
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Wait for navigation to complete
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Test: Should be authenticated again
    expect(find.text('Welcome, Test User!'), findsOneWidget);

    // Test: Token refresh
    await Future.delayed(const Duration(seconds: 1)); // Simulate time passing
    await tester
        .tap(find.byIcon(Icons.refresh)); // Assuming there's a refresh button
    await tester.pumpAndSettle();

    // Test: Should still be authenticated after token refresh
    expect(find.text('Welcome, Test User!'), findsOneWidget);

    // Test: Sign out again
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    // Test: Should be back on login screen
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);

    // Test: Offline mode
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');

    // Simulate offline mode by setting API client to offline mode
    getIt<ApiClient>().setOfflineMode(true);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Test: Should show offline error
    expect(find.text('No internet connection'), findsOneWidget);

    // Test: Error handling
    getIt<ApiClient>().setOfflineMode(false);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'wrongpassword');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Test: Should show invalid credentials error
    expect(find.text('Invalid credentials'), findsOneWidget);

    // Verify we're on the home screen
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Test User!'), findsOneWidget);
  });
}
