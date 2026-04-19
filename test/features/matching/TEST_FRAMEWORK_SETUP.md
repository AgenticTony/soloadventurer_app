# Test Framework Setup - SoloAdventurer

**QA Lead:** qa-lead  
**Created:** April 1, 2026  
**Purpose:** Automated test framework architecture and setup guide

---

## 1. Test Framework Overview

### Testing Pyramid

```
           ┌─────────────┐
           │    E2E      │  ← Week 12+ (Post-MVP)
           │   (5%)      │
           ├─────────────┤
           │ Integration │  ← Week 1-14
           │   (25%)     │
           ├─────────────┤
           │   Widget    │  ← Week 5+
           │   (20%)     │
           ├─────────────┤
           │    Unit     │  ← Week 1+
           │   (50%)     │
           └─────────────┘
```

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Unit Tests** | Flutter test + mockito | Business logic, utilities |
| **Widget Tests** | Flutter test + pumpWidget | UI components |
| **Integration Tests** | integration_test package | Full user flows |
| **Backend Tests** | pgTAP + Supabase CLI | Database, RLS, functions |
| **E2E Tests** | Patrol / Appium | Cross-platform flows |
| **Mocking** | mockito + firebase_auth_mocks | External services |

---

## 2. Flutter Test Structure

### Directory Structure

```
soloadventurer-matching/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── services/
│   ├── repositories/
│   └── widgets/
├── test/
│   ├── unit/
│   │   ├── models/
│   │   │   ├── trip_test.dart
│   │   │   └── user_test.dart
│   │   ├── services/
│   │   │   ├── matching_service_test.dart
│   │   │   └── geocoding_service_test.dart
│   │   └── repositories/
│   │       ├── trip_repository_test.dart
│   │       └── user_repository_test.dart
│   ├── widget/
│   │   ├── screens/
│   │   │   ├── matches_screen_test.dart
│   │   │   └── trip_form_test.dart
│   │   └── components/
│   │       ├── match_card_test.dart
│   │       └── activity_button_test.dart
│   ├── integration/
│   │   ├── trip_management_test.dart
│   │   └── matching_flow_test.dart
│   ├── fixtures/
│   │   ├── fixtures.dart
│   │   ├── trip_fixtures.dart
│   │   └── user_fixtures.dart
│   ├── mocks/
│   │   ├── mock_supabase_client.dart
│   │   ├── mock_geolocator.dart
│   │   └── mock_onfido.dart
│   └── test_utils/
│       ├── test_helpers.dart
│       └── test_data_generator.dart
├── integration_test/
│   └── app_test.dart
└── pubspec.yaml
```

### Test Naming Convention

```dart
// Pattern: methodName_scenario_expectedResult
test('createTrip_validInput_returnsTrip', () { ... });
test('createTrip_invalidDates_throwsValidationException', () { ... });

// Group by class/method
group('MatchingService', () {
  group('findMatches', () {
    test('returnsMatches_whenDatesOverlap', () { ... });
    test('returnsEmpty_whenNoOverlap', () { ... });
  });
});
```

---

## 3. Unit Test Setup

### pubspec.yaml Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  fake_async: ^1.3.0
  test: ^1.24.0
  
  # For Supabase mocking
  supabase_flutter: ^1.10.0
  
  # For location mocking
  geolocator_platform_interface: ^9.0.0
  mockito_annotations: ^2.4.0
```

### Base Test Class

```dart
// test/test_base.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

abstract class TestBase {
  /// Setup common test fixtures
  void setupFixtures();
  
  /// Cleanup after tests
  void tearDownFixtures();
  
  /// Assert that condition is true within timeout
  Future<void> eventually(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  });
}

mixin TestHelpers implements TestBase {
  @override
  void setupFixtures() {
    // Override in subclasses
  }
  
  @override
  void tearDownFixtures() {
    // Override in subclasses
  }
  
  @override
  Future<void> eventually(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final startTime = DateTime.now();
    while (DateTime.now().difference(startTime) < timeout) {
      if (condition()) return;
      await Future.delayed(interval);
    }
    throw TestFailure('Condition not met within $timeout');
  }
}
```

### Example Unit Test

```dart
// test/unit/services/matching_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/services/matching_service.dart';
import 'package:soloadventurer/models/trip.dart';
import 'package:soloadventurer/models/user.dart';

@GenerateMocks([TripRepository, UserRepository])
void main() {
  late MatchingService service;
  late MockTripRepository mockTripRepo;
  late MockUserRepository mockUserRepo;
  
  setUp(() {
    mockTripRepo = MockTripRepository();
    mockUserRepo = MockUserRepository();
    service = MatchingService(mockTripRepo, mockUserRepo);
  });
  
  group('findMatches', () {
    test('returns matches when dates overlap', () async {
      // Arrange
      final userTrip = Trip(
        id: 'trip-1',
        userId: 'user-a',
        destination: 'Paris',
        startDate: DateTime(2026, 4, 10),
        endDate: DateTime(2026, 4, 15),
      );
      
      final potentialMatch = Trip(
        id: 'trip-2',
        userId: 'user-b',
        destination: 'Paris',
        startDate: DateTime(2026, 4, 12),
        endDate: DateTime(2026, 4, 18),
      );
      
      when(mockTripRepo.getOverlappingTrips(any))
          .thenAnswer((_) async => [potentialMatch]);
      when(mockUserRepo.getUser('user-b'))
          .thenAnswer((_) async => User(id: 'user-b', firstName: 'Marcus'));
      
      // Act
      final matches = await service.findMatches('user-a', userTrip);
      
      // Assert
      expect(matches, hasLength(1));
      expect(matches.first.trip.userId, equals('user-b'));
    });
    
    test('excludes user from own matches', () async {
      // Arrange
      final userTrip = Trip(
        id: 'trip-1',
        userId: 'user-a',
        destination: 'Paris',
        startDate: DateTime(2026, 4, 10),
        endDate: DateTime(2026, 4, 15),
      );
      
      when(mockTripRepo.getOverlappingTrips(any))
          .thenAnswer((_) async => [userTrip]); // Same user
      
      // Act
      final matches = await service.findMatches('user-a', userTrip);
      
      // Assert
      expect(matches, isEmpty);
    });
    
    test('filters by women-only mode', () async {
      // Arrange
      final femaleUser = User(
        id: 'user-a',
        gender: 'female',
        womenOnlyMode: true,
      );
      
      final maleMatch = Trip(
        id: 'trip-2',
        userId: 'user-male',
        destination: 'Paris',
        startDate: DateTime(2026, 4, 10),
        endDate: DateTime(2026, 4, 15),
      );
      
      final femaleMatch = Trip(
        id: 'trip-3',
        userId: 'user-female',
        destination: 'Paris',
        startDate: DateTime(2026, 4, 12),
        endDate: DateTime(2026, 4, 18),
      );
      
      when(mockTripRepo.getOverlappingTrips(any))
          .thenAnswer((_) async => [maleMatch, femaleMatch]);
      when(mockUserRepo.getUser('user-male'))
          .thenAnswer((_) async => User(id: 'user-male', gender: 'male'));
      when(mockUserRepo.getUser('user-female'))
          .thenAnswer((_) async => User(id: 'user-female', gender: 'female'));
      when(mockUserRepo.getUser('user-a'))
          .thenAnswer((_) async => femaleUser);
      
      // Act
      final matches = await service.findMatches('user-a', userTrip);
      
      // Assert
      expect(matches, hasLength(1));
      expect(matches.first.trip.userId, equals('user-female'));
    });
  });
}
```

---

## 4. Widget Test Setup

### Widget Test Helpers

```dart
// test/widget/widget_test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:soloadventurer/main.dart';

class WidgetTestHelpers {
  /// Wrap widget with necessary providers for testing
  static Widget wrapWithProviders(Widget child, {
    List<Override> overrides = const [],
  }) {
    return MultiProvider(
      providers: [
        // Add providers here
        ...overrides,
      ],
      child: MaterialApp(home: child),
    );
  }
  
  /// Pump widget and settle
  static Future<void> pumpAndSettle(
    WidgetTester tester,
    Widget widget, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(timeout);
  }
  
  /// Find widget by key
  static Finder findByKey(String key) => find.byKey(Key(key));
  
  /// Find widget by type
  static Finder findByType<T extends Widget>() => find.byType<T>();
  
  /// Find text
  static Finder findText(String text) => find.text(text);
  
  /// Tap widget and settle
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
  
  /// Enter text and settle
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }
}
```

### Example Widget Test

```dart
// test/widget/screens/matches_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:soloadventurer/screens/matches_screen.dart';
import 'package:soloadventurer/models/match.dart';
import '../widget/widget_test_helpers.dart';
import '../mocks/mock_supabase_client.dart';

void main() {
  group('MatchesScreen', () {
    testWidgets('displays loading indicator while fetching', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithProviders(
          MatchesScreen(),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('displays matches after loading', (tester) async {
      // Arrange
      final matches = [
        Match(
          id: 'match-1',
          userId: 'user-b',
          firstName: 'Marcus',
          destination: 'Paris',
          overlapDays: 3,
        ),
      ];
      
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithProviders(
          MatchesScreen(matches: matches),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert
      expect(WidgetTestHelpers.findText('Marcus'), findsOneWidget);
      expect(WidgetTestHelpers.findText('Paris'), findsOneWidget);
    });
    
    testWidgets('shows empty state when no matches', (tester) async {
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithProviders(
          MatchesScreen(matches: []),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert
      expect(
        WidgetTestHelpers.findText('No travelers found'),
        findsOneWidget,
      );
    });
    
    testWidgets('women-only indicator visible when enabled', (tester) async {
      // Arrange
      final matches = [
        Match(
          id: 'match-1',
          userId: 'user-female',
          firstName: 'Priya',
          destination: 'Paris',
          womenOnlyMode: true,
        ),
      ];
      
      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithProviders(
          MatchesScreen(matches: matches),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert
      expect(
        find.byIcon(Icons.female),
        findsOneWidget,
      );
    });
  });
}
```

---

## 5. Integration Test Setup

### Integration Test Configuration

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soloadventurer/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('End-to-End Tests', () {
    testWidgets('User can create trip and see matches', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to trip creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Enter destination
      await tester.enterText(
        find.byKey(Key('destination_field')),
        'Paris, France',
      );
      
      // Select dates
      await tester.tap(find.byKey(Key('start_date')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('end_date')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      
      // Submit
      await tester.tap(find.byKey(Key('save_trip')));
      await tester.pumpAndSettle(Duration(seconds: 3));
      
      // Verify matches screen
      expect(find.text('Matches'), findsOneWidget);
    });
    
    testWidgets('Women-only mode filters matches', (tester) async {
      // This test requires authenticated female user
      // Setup: Create test user with women-only mode enabled
      
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      
      // Enable women-only mode
      await tester.tap(find.byKey(Key('women_only_toggle')));
      await tester.pumpAndSettle();
      
      // Navigate to matches
      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();
      
      // Verify only female matches shown
      // (This would check actual data in real test)
    });
  });
}
```

---

## 6. Supabase Local Testing

### Local Supabase Setup

```bash
# Install Supabase CLI
npm install -g supabase

# Initialize project
supabase init

# Start local instance
supabase start

# Output:
# API URL: http://localhost:54321
# DB URL: postgresql://postgres:postgres@localhost:54322/postgres
# Studio URL: http://localhost:54323
# Anon key: eyJ...
# Service role key: eyJ...
```

### Database Test Configuration

```dart
// test/test_utils/supabase_test_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

class SupabaseTestConfig {
  static const String localUrl = 'http://localhost:54321';
  static const String localAnonKey = 'your-local-anon-key';
  
  /// Initialize Supabase for testing
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: localUrl,
      anonKey: localAnonKey,
      debug: true,
    );
  }
  
  /// Reset test database
  static Future<void> resetDatabase() async {
    final client = Supabase.instance.client;
    
    // Truncate all tables
    await client.rpc('reset_test_data');
  }
  
  /// Seed test data
  static Future<void> seedTestData() async {
    final client = Supabase.instance.client;
    
    // Insert test users
    await client.from('users').insert([
      {
        'id': 'test-user-1',
        'email': 'test1@example.com',
        'first_name': 'Alex',
        'gender': 'female',
      },
      {
        'id': 'test-user-2',
        'email': 'test2@example.com',
        'first_name': 'Marcus',
        'gender': 'male',
      },
    ]);
    
    // Insert test trips
    await client.from('trips').insert([
      {
        'id': 'test-trip-1',
        'user_id': 'test-user-1',
        'destination': 'Paris, France',
        'start_date': '2026-04-10',
        'end_date': '2026-04-15',
      },
    ]);
  }
}
```

### Test Setup/Teardown

```dart
// test/test_utils/test_setup.dart
import 'package:flutter_test/flutter_test.dart';
import 'supabase_test_config.dart';

/// Call this in setUpAll for integration tests
Future<void> setupIntegrationTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await SupabaseTestConfig.initialize();
}

/// Call this in setUp for each test
Future<void> setupEachTest() async {
  await SupabaseTestConfig.resetDatabase();
  await SupabaseTestConfig.seedTestData();
}

/// Call this in tearDownAll
Future<void> teardownIntegrationTests() async {
  await Supabase.instance.client.dispose();
}
```

### Example Supabase Integration Test

```dart
// test/integration/matching_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_utils/test_setup.dart';

void main() {
  late SupabaseClient client;
  
  setUpAll(() async {
    await setupIntegrationTests();
    client = Supabase.instance.client;
  });
  
  setUp(() async {
    await setupEachTest();
  });
  
  tearDownAll(() async {
    await teardownIntegrationTests();
  });
  
  group('Matching API Integration', () {
    test('get_matches returns overlapping trips', () async {
      // Arrange - seed two overlapping trips
      await client.from('trips').insert([
        {
          'user_id': 'test-user-1',
          'destination': 'Paris',
          'location': 'POINT(2.3522 48.8566)',
          'start_date': '2026-04-10',
          'end_date': '2026-04-15',
        },
        {
          'user_id': 'test-user-2',
          'destination': 'Paris',
          'location': 'POINT(2.3522 48.8566)',
          'start_date': '2026-04-12',
          'end_date': '2026-04-18',
        },
      ]);
      
      // Act
      final response = await client
          .rpc('get_matches', params: {'p_user_id': 'test-user-1'});
      
      // Assert
      expect(response, isNotEmpty);
      expect(response[0]['user_id'], equals('test-user-2'));
    });
    
    test('get_matches respects women-only mode', () async {
      // Arrange - female user with women-only mode
      await client.from('users').update({
        'women_only_mode': true,
        'gender': 'female',
      }).eq('id', 'test-user-1');
      
      await client.from('trips').insert([
        {
          'user_id': 'test-user-1',
          'destination': 'Paris',
          'location': 'POINT(2.3522 48.8566)',
          'start_date': '2026-04-10',
          'end_date': '2026-04-15',
        },
        {
          'user_id': 'test-user-2', // male
          'destination': 'Paris',
          'location': 'POINT(2.3522 48.8566)',
          'start_date': '2026-04-12',
          'end_date': '2026-04-18',
        },
      ]);
      
      // Act
      final response = await client
          .rpc('get_matches', params: {'p_user_id': 'test-user-1'});
      
      // Assert - male user should not appear
      final hasMale = response.any((m) => m['gender'] == 'male');
      expect(hasMale, isFalse);
    });
  });
}
```

---

## 7. Mock Strategies

### Mocking Supabase Client

```dart
// test/mocks/mock_supabase_client.dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([SupabaseClient, GoTrueClient, PostgrestClient])
class MockSupabaseClient extends Mock implements SupabaseClient {
  final MockGoTrueClient mockAuth = MockGoTrueClient();
  final MockPostgrestClient mockFrom = MockPostgrestClient();
  
  @override
  GoTrueClient get auth => mockAuth;
  
  @override
  PostgrestClient from(String table) => mockFrom;
}

// Helper to create mock responses
class SupabaseMockHelper {
  static PostgrestResponse createResponse(List<dynamic> data) {
    return PostgrestResponse(
      data: data,
      status: 200,
      statusText: 'OK',
    );
  }
  
  static void setupMockQuery(
    MockPostgrestClient mock,
    String table,
    List<dynamic> response,
  ) {
    when(mock.from(table)).thenReturn(mock);
    when(mock.select()).thenAnswer((_) async => response);
  }
}
```

### Mocking Geolocation

```dart
// test/mocks/mock_geolocator.dart
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart';

class MockGeolocator extends Mock implements GeolocatorPlatform {
  /// Setup mock to return specific location
  void mockLocation({
    double latitude = 48.8566,
    double longitude = 2.3522,
  }) {
    when(getCurrentPosition(
      desiredAccuracy: anyNamed('desiredAccuracy'),
    )).thenAnswer((_) async => Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 10,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
    ));
  }
  
  /// Setup mock to deny permission
  void mockPermissionDenied() {
    when(checkPermission())
        .thenAnswer((_) async => LocationPermission.denied);
    when(requestPermission())
        .thenAnswer((_) async => LocationPermission.denied);
  }
  
  /// Setup mock to grant permission
  void mockPermissionGranted() {
    when(checkPermission())
        .thenAnswer((_) async => LocationPermission.whileInUse);
  }
}
```

### Mocking Onfido (External Service)

```dart
// test/mocks/mock_onfido.dart
import 'package:mockito/mockito.dart';

/// Onfido SDK mock for testing verification flows
class MockOnfidoService extends Mock implements OnfidoService {
  /// Setup successful verification
  void mockSuccessfulVerification({
    String applicantId = 'test-applicant',
    String checkId = 'test-check',
  }) {
    when(createApplicant(any))
        .thenAnswer((_) async => applicantId);
    when(startVerification(any))
        .thenAnswer((_) async => VerificationResult(
          success: true,
          checkId: checkId,
        ));
    when(getVerificationStatus(checkId))
        .thenAnswer((_) async => VerificationStatus.complete);
  }
  
  /// Setup failed verification
  void mockFailedVerification() {
    when(createApplicant(any))
        .thenAnswer((_) async => 'test-applicant');
    when(startVerification(any))
        .thenAnswer((_) async => VerificationResult(
          success: false,
          error: 'Document rejected',
        ));
  }
  
  /// Setup pending verification
  void mockPendingVerification() {
    when(getVerificationStatus(any))
        .thenAnswer((_) async => VerificationStatus.inProgress);
  }
}

/// Verification result model
class VerificationResult {
  final bool success;
  final String? checkId;
  final String? error;
  
  VerificationResult({
    required this.success,
    this.checkId,
    this.error,
  });
}

enum VerificationStatus {
  inProgress,
  complete,
  failed,
}
```

### Using Mocks in Tests

```dart
// test/unit/services/verification_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:soloadventurer/services/verification_service.dart';
import '../mocks/mock_onfido.dart';

void main() {
  late VerificationService service;
  late MockOnfidoService mockOnfido;
  
  setUp(() {
    mockOnfido = MockOnfidoService();
    service = VerificationService(onfido: mockOnfido);
  });
  
  group('verifyUser', () {
    test('returns verified status on success', () async {
      // Arrange
      mockOnfido.mockSuccessfulVerification();
      
      // Act
      final result = await service.verifyUser(
        userId: 'user-1',
        documentType: 'passport',
      );
      
      // Assert
      expect(result.isVerified, isTrue);
      verify(mockOnfido.createApplicant(any)).called(1);
    });
    
    test('returns error on verification failure', () async {
      // Arrange
      mockOnfido.mockFailedVerification();
      
      // Act
      final result = await service.verifyUser(
        userId: 'user-1',
        documentType: 'passport',
      );
      
      // Assert
      expect(result.isVerified, isFalse);
      expect(result.error, contains('rejected'));
    });
  });
}
```

---

## 8. Test Data Generators

### Factory Pattern for Test Data

```dart
// test/test_utils/test_data_generator.dart
import 'package:soloadventurer/models/trip.dart';
import 'package:soloadventurer/models/user.dart';
import 'package:soloadventurer/models/match.dart';

class TestDataGenerator {
  static int _idCounter = 0;
  
  static String _generateId([String prefix = 'test']) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';
  }
  
  /// Generate a test user
  static User user({
    String? id,
    String? email,
    String? firstName,
    String? gender,
    bool? womenOnlyMode,
    String? homeCountry,
  }) {
    return User(
      id: id ?? _generateId('user'),
      email: email ?? 'test@example.com',
      firstName: firstName ?? 'Test User',
      gender: gender ?? 'female',
      womenOnlyMode: womenOnlyMode ?? false,
      homeCountry: homeCountry ?? 'US',
    );
  }
  
  /// Generate a test trip
  static Trip trip({
    String? id,
    String? userId,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    double? latitude,
    double? longitude,
  }) {
    final start = startDate ?? DateTime.now().add(Duration(days: 7));
    return Trip(
      id: id ?? _generateId('trip'),
      userId: userId ?? _generateId('user'),
      destination: destination ?? 'Paris, France',
      startDate: start,
      endDate: endDate ?? start.add(Duration(days: 5)),
      isActive: isActive ?? true,
      latitude: latitude ?? 48.8566,
      longitude: longitude ?? 2.3522,
    );
  }
  
  /// Generate a test match
  static Match match({
    String? id,
    String? userId,
    String? firstName,
    String? destination,
    int? overlapDays,
    double? distance,
    String? gender,
  }) {
    return Match(
      id: id ?? _generateId('match'),
      userId: userId ?? _generateId('user'),
      firstName: firstName ?? 'Match User',
      destination: destination ?? 'Paris, France',
      overlapDays: overlapDays ?? 3,
      distance: distance ?? 0.0,
      gender: gender ?? 'female',
    );
  }
  
  /// Generate multiple trips for batch testing
  static List<Trip> trips(int count, {
    String? userId,
    String baseDestination = 'Paris, France',
  }) {
    return List.generate(count, (i) => trip(
      userId: userId,
      destination: '$baseDestination $i',
      startDate: DateTime.now().add(Duration(days: i)),
      endDate: DateTime.now().add(Duration(days: i + 5)),
    ));
  }
  
  /// Generate trips for benchmark testing
  static List<Map<String, dynamic>> benchmarkTrips({
    int count = 100000,
    int userCount = 50000,
    List<String>? cities,
  }) {
    final cityList = cities ?? [
      'Paris', 'London', 'Berlin', 'Rome', 'Barcelona',
      'Bangkok', 'Tokyo', 'Singapore', 'Sydney', 'New York',
    ];
    
    return List.generate(count, (i) {
      final city = cityList[i % cityList.length];
      final startDay = i % 365;
      return {
        'id': 'bench-trip-$i',
        'user_id': 'bench-user-${i % userCount}',
        'destination': city,
        'start_date': DateTime.now().add(Duration(days: startDay)).toIso8601String(),
        'end_date': DateTime.now().add(Duration(days: startDay + (i % 90) + 1)).toIso8601String(),
        'is_active': i % 5 != 0, // 80% active
      };
    });
  }
}
```

### Test Fixtures

```dart
// test/fixtures/fixtures.dart
export 'trip_fixtures.dart';
export 'user_fixtures.dart';

// test/fixtures/user_fixtures.dart
import '../test_utils/test_data_generator.dart';

class UserFixtures {
  static get alex => TestDataGenerator.user(
    id: 'user-alex',
    email: 'alex@test.com',
    firstName: 'Alex',
    gender: 'female',
    womenOnlyMode: false,
  );
  
  static get marcus => TestDataGenerator.user(
    id: 'user-marcus',
    email: 'marcus@test.com',
    firstName: 'Marcus',
    gender: 'male',
  );
  
  static get priya => TestDataGenerator.user(
    id: 'user-priya',
    email: 'priya@test.com',
    firstName: 'Priya',
    gender: 'female',
    womenOnlyMode: true,
  );
}

// test/fixtures/trip_fixtures.dart
import '../test_utils/test_data_generator.dart';

class TripFixtures {
  static parisAlex() => TestDataGenerator.trip(
    id: 'trip-paris-alex',
    userId: 'user-alex',
    destination: 'Paris, France',
    startDate: DateTime(2026, 4, 10),
    endDate: DateTime(2026, 4, 15),
  );
  
  static parisMarcus() => TestDataGenerator.trip(
    id: 'trip-paris-marcus',
    userId: 'user-marcus',
    destination: 'Paris, France',
    startDate: DateTime(2026, 4, 12),
    endDate: DateTime(2026, 4, 18),
  );
  
  static lyonPriya() => TestDataGenerator.trip(
    id: 'trip-lyon-priya',
    userId: 'user-priya',
    destination: 'Lyon, France',
    latitude: 45.7640,
    longitude: 4.8357,
    startDate: DateTime(2026, 4, 10),
    endDate: DateTime(2026, 4, 15),
  );
  
  static noOverlapParis() => TestDataGenerator.trip(
    id: 'trip-paris-no-overlap',
    userId: 'user-other',
    destination: 'Paris, France',
    startDate: DateTime(2026, 4, 1),
    endDate: DateTime(2026, 4, 5),
  );
}
```

---

## 9. Running Tests

### Test Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/services/matching_service_test.dart

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# Run integration tests
flutter test integration_test/app_test.dart

# Run specific test group
flutter test --name "MatchingService"

# Run with verbose output
flutter test --reporter expanded

# Run in debug mode
flutter test --debug
```

### Test Script (run_all_tests.sh)

```bash
#!/bin/bash
# run_all_tests.sh

set -e

echo "========================================="
echo "SoloAdventurer Test Suite"
echo "========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run tests and track results
run_test_suite() {
    local name=$1
    local command=$2
    
    echo ""
    echo "Running: $name"
    echo "-----------------------------------------"
    
    if eval $command; then
        echo -e "${GREEN}✓ $name passed${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ $name failed${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# 1. Static Analysis
echo ""
echo "Step 1: Static Analysis (flutter analyze)"
echo "========================================="
run_test_suite "Flutter Analyze" "flutter analyze"

# 2. Unit Tests
echo ""
echo "Step 2: Unit Tests"
echo "========================================="
run_test_suite "Unit Tests" "flutter test test/unit/ --reporter compact"

# 3. Widget Tests
echo ""
echo "Step 3: Widget Tests"
echo "========================================="
run_test_suite "Widget Tests" "flutter test test/widget/ --reporter compact"

# 4. Integration Tests (requires running emulator)
echo ""
echo "Step 4: Integration Tests"
echo "========================================="
echo -e "${YELLOW}Skipping integration tests (requires emulator)${NC}"
echo "To run: flutter test integration_test/"
# run_test_suite "Integration Tests" "flutter test integration_test/"

# 5. Coverage Report
echo ""
echo "Step 5: Coverage Report"
echo "========================================="
if flutter test --coverage 2>/dev/null; then
    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html 2>/dev/null
        echo -e "${GREEN}Coverage report generated: coverage/html/index.html${NC}"
    else
        echo -e "${YELLOW}genhtml not installed. Install with: brew install lcov${NC}"
    fi
fi

# Summary
echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo -e "Total Suites: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
echo "========================================="

# Exit code
if [ $FAILED_TESTS -gt 0 ]; then
    exit 1
else
    exit 0
fi
```

---

## 10. CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        cache: true
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run analyzer
      run: flutter analyze
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: coverage/lcov.info
    
    - name: Generate test report
      run: |
        flutter test --machine > test-results.json
        flutter pub run junitreport:tojunit -i test-results.json -o test-report.xml
    
    - name: Publish test report
      uses: mikepenz/action-junit-report@v3
      if: always()
      with:
        report_paths: test-report.xml
```

---

## 11. Test Best Practices

### Do's

✅ **Use descriptive test names**: `test('createTrip_validInput_returnsTrip', () {})`

✅ **Follow AAA pattern**: Arrange, Act, Assert

✅ **Test edge cases**: Empty input, null values, boundaries

✅ **Keep tests isolated**: Each test should be independent

✅ **Use test fixtures**: Consistent test data across tests

✅ **Mock external dependencies**: Don't call real APIs

✅ **Test error paths**: Not just happy paths

✅ **Document complex tests**: Add comments for clarity

### Don'ts

❌ **Don't test implementation details**: Test behavior, not code

❌ **Don't use production data**: Always use test fixtures

❌ **Don't skip tests**: Fix them or delete them

❌ **Don't use sleeps**: Use async/await properly

❌ **Don't make tests dependent**: Each test should run alone

❌ **Don't ignore flaky tests**: Fix the root cause

---

## 12. Framework Maintenance

### Weekly Tasks

- [ ] Update test dependencies
- [ ] Review and fix flaky tests
- [ ] Update test fixtures to match schema changes
- [ ] Review test coverage report
- [ ] Clean up obsolete tests

### Monthly Tasks

- [ ] Audit test suite for redundancy
- [ ] Update mock implementations for API changes
- [ ] Review and update test data generators
- [ ] Performance benchmark of test suite

---

**Document Status:** ✅ Complete  
**Next Step:** Run `flutter pub get && flutter analyze` to validate  
**Owner:** qa-lead
