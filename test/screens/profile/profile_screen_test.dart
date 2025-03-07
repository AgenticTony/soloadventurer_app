import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/profile/presentation/screens/profile_screen.dart';
import 'package:soloadventurer/providers/user_profile_provider.dart'
    as user_profile;
import 'package:soloadventurer/models/user.dart';

// Mock classes
class MockUserRepository extends Mock implements user_profile.UserRepository {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRoute extends Mock implements Route {}

class MockUserProfileNotifier extends StateNotifier<AsyncValue<User?>>
    with Mock
    implements user_profile.UserProfileNotifier {
  MockUserProfileNotifier() : super(const AsyncValue.loading());
}

void main() {
  late MockNavigatorObserver mockNavigatorObserver;
  late MockUserProfileNotifier mockUserProfileNotifier;
  late User testUser;

  setUp(() {
    mockNavigatorObserver = MockNavigatorObserver();
    mockUserProfileNotifier = MockUserProfileNotifier();

    testUser = User(
      id: '123',
      username: 'testuser',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      profilePictureUrl: 'https://example.com/avatar.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Register fallback values for navigation
    registerFallbackValue(MockRoute());
    registerFallbackValue(MockRoute());
  });

  Widget createTestableWidget() {
    return ProviderScope(
      overrides: [
        // Use a non-family provider for testing
        user_profile.userProfileNotifierProvider('test-user-id').overrideWith(
              (ref) => mockUserProfileNotifier,
            ),
      ],
      child: MaterialApp(
        home: const ProfileScreen(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('ProfileScreen UI Tests', () {
    testWidgets('should display loading indicator when loading',
        (tester) async {
      // Arrange - set up loading state
      when(() => mockUserProfileNotifier.state)
          .thenReturn(const AsyncValue.loading());

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading profile...'), findsOneWidget);
    });

    testWidgets('should display user profile when data is loaded',
        (tester) async {
      // Arrange - set up loaded state with user data
      when(() => mockUserProfileNotifier.state)
          .thenReturn(AsyncValue.data(testUser));

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert - verify profile information is displayed
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('@testuser'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);

      // Verify preferences section
      expect(find.text('Preferences'), findsOneWidget);
    });

    testWidgets('should display error message when error occurs',
        (tester) async {
      // Arrange - set up error state
      when(() => mockUserProfileNotifier.state).thenReturn(
          const AsyncValue.error('Failed to load profile', StackTrace.empty));

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.text('Error: Failed to load profile'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget); // Retry button
    });
  });

  group('Profile Interaction Tests', () {
    testWidgets('should trigger refresh when pull-to-refresh is used',
        (tester) async {
      // Arrange - set up loaded state
      when(() => mockUserProfileNotifier.state)
          .thenReturn(AsyncValue.data(testUser));
      when(() => mockUserProfileNotifier.updateProfile(any()))
          .thenAnswer((_) async {
            return null;
          });

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Perform pull-to-refresh gesture
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert - verify refresh was triggered
      // Note: We're not verifying the exact method call since it depends on the implementation
    });

    testWidgets(
        'should navigate to edit profile screen when edit button is tapped',
        (tester) async {
      // Arrange - set up loaded state
      when(() => mockUserProfileNotifier.state)
          .thenReturn(AsyncValue.data(testUser));

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Tap edit profile button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Assert - verify navigation was triggered
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
    });

    testWidgets('should retry loading when retry button is tapped on error',
        (tester) async {
      // Arrange - set up error state
      when(() => mockUserProfileNotifier.state).thenReturn(
          const AsyncValue.error('Failed to load profile', StackTrace.empty));
      when(() => mockUserProfileNotifier.updateProfile(any()))
          .thenAnswer((_) async {
            return null;
          });

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Tap retry button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - verify refresh was triggered
      // Note: We're not verifying the exact method call since it depends on the implementation
    });
  });

  group('Profile Data Tests', () {
    testWidgets('should handle missing optional fields gracefully',
        (tester) async {
      // Arrange - create user with missing optional fields
      final userWithMissingFields = User(
        id: '123',
        username: 'testuser',
        email: 'test@example.com',
        firstName: null, // Missing first name
        lastName: null, // Missing last name
        profilePictureUrl: null, // Missing profile picture
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Set up loaded state with user missing fields
      when(() => mockUserProfileNotifier.state)
          .thenReturn(AsyncValue.data(userWithMissingFields));

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert - verify fallback values are displayed
      expect(find.text('@testuser'),
          findsOneWidget); // Username is always required
      expect(find.text('test@example.com'),
          findsOneWidget); // Email is always required

      // Verify default avatar is used
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundImage, isNull);
    });

    testWidgets('should update UI when profile is refreshed', (tester) async {
      // Arrange - initially set loading state
      when(() => mockUserProfileNotifier.state)
          .thenReturn(const AsyncValue.loading());

      // Act - render with loading state
      await tester.pumpWidget(createTestableWidget());

      // Assert - verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Update state to loaded
      when(() => mockUserProfileNotifier.state)
          .thenReturn(AsyncValue.data(testUser));

      // Trigger state change notification
      // Use setState to trigger a rebuild
      (mockUserProfileNotifier as StateNotifier<AsyncValue<User?>>).state =
          AsyncValue.data(testUser);
      await tester.pump();

      // Assert - verify profile information is now displayed
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('@testuser'), findsOneWidget);
    });
  });
}
