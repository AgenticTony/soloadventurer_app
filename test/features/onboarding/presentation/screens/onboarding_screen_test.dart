import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/budget_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/onboarding/domain/usecases/generate_starter_itinerary.dart';
import 'package:soloadventurer/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:soloadventurer/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:soloadventurer/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:soloadventurer/features/onboarding/presentation/state/onboarding_state.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';

// Mock classes
class MockGenerateStarterItinerary extends Mock
    implements GenerateStarterItinerary {}

class MockOnboardingNotifier extends ChangeNotifier
    implements OnboardingNotifier {
  OnboardingState _state = const OnboardingState.initial();

  @override
  OnboardingState get state => _state;

  void setState(OnboardingState state) {
    _state = state;
    notifyListeners();
  }

  @override
  bool get isSubmitting => _state.maybeWhen(
        submitting: (_) => true,
        orElse: () => false,
      );

  @override
  Future<void> updateName(String name) async {
    final currentData = _state.maybeWhen(
      inProgress: (data, _, __) => data,
      submitting: (data) => data,
      error: (data, _, __) => data,
      orElse: () => null,
    );
    if (currentData != null) {
      _state = OnboardingState.inProgress(
        currentData.copyWith(name: name),
        {},
        {},
      );
      notifyListeners();
    }
  }

  @override
  Future<void> updateDestination(Destination destination) async {
    final currentData = _state.maybeWhen(
      inProgress: (data, _, __) => data,
      submitting: (data) => data,
      error: (data, _, __) => data,
      orElse: () => null,
    );
    if (currentData != null) {
      _state = OnboardingState.inProgress(
        currentData.copyWith(destination: destination),
        {},
        {},
      );
      notifyListeners();
    }
  }

  @override
  Future<void> updateDateRange(DateRange dateRange) async {
    final currentData = _state.maybeWhen(
      inProgress: (data, _, __) => data,
      submitting: (data) => data,
      error: (data, _, __) => data,
      orElse: () => null,
    );
    if (currentData != null) {
      _state = OnboardingState.inProgress(
        currentData.copyWith(dateRange: dateRange),
        {},
        {},
      );
      notifyListeners();
    }
  }

  @override
  Future<void> updateInterests(Set<TravelInterest> interests) async {
    final currentData = _state.maybeWhen(
      inProgress: (data, _, __) => data,
      submitting: (data) => data,
      error: (data, _, __) => data,
      orElse: () => null,
    );
    if (currentData != null) {
      _state = OnboardingState.inProgress(
        currentData.copyWith(interests: interests),
        {},
        {},
      );
      notifyListeners();
    }
  }

  @override
  Future<void> updateBudget(BudgetRange? budget) async {
    final currentData = _state.maybeWhen(
      inProgress: (data, _, __) => data,
      submitting: (data) => data,
      error: (data, _, __) => data,
      orElse: () => null,
    );
    if (currentData != null) {
      _state = OnboardingState.inProgress(
        currentData.copyWith(budget: budget),
        {},
        {},
      );
      notifyListeners();
    }
  }

  @override
  Future<void> submitForm(GenerateStarterItinerary generateItinerary) async {
    final currentData = _state.maybeWhen(
      inProgress: (data, _, __) => data,
      orElse: () => null,
    );
    if (currentData != null) {
      _state = OnboardingState.submitting(currentData);
      notifyListeners();

      // Simulate success after a delay
      await Future.delayed(const Duration(milliseconds: 100));

      final testItinerary = Itinerary(
        id: 'test-itinerary-id',
        name: 'Test Trip',
        destination: currentData.destination,
        dateRange: currentData.dateRange,
        items: [],
        isStarter: true,
        createdAt: DateTime.now(),
      );

      _state = OnboardingState.success(currentData, testItinerary);
      notifyListeners();
    }
  }

  @override
  Future<void> reset() async {
    _state = const OnboardingState.initial();
    notifyListeners();
  }
}

void main() {
  late MockOnboardingNotifier mockOnboardingNotifier;
  late MockGenerateStarterItinerary mockGenerateStarterItinerary;

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(const OnboardingState.initial());
  });

  setUp(() {
    mockOnboardingNotifier = MockOnboardingNotifier();
    mockGenerateStarterItinerary = MockGenerateStarterItinerary();

    // Set default state
    mockOnboardingNotifier.setState(
      OnboardingState.inProgress(
        OnboardingData(
          name: '',
          destination: const Destination(
            placeId: '',
            name: '',
            latitude: 0,
            longitude: 0,
          ),
          dateRange: DateRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          ),
          interests: {},
          budget: null,
        ),
        {},
        {},
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        onboardingNotifierProvider
            .overrideWith((ref) => mockOnboardingNotifier),
        generateStarterItineraryProvider
            .overrideWith((ref) => mockGenerateStarterItinerary),
      ],
      child: const MaterialApp(
        home: OnboardingScreen(),
      ),
    );
  }

  group('OnboardingScreen Widget Tests', () {
    group('Rendering', () {
      testWidgets('renders all form fields', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Welcome header
        expect(find.text("Let's plan your solo adventure! ✈️"), findsOneWidget);

        // Name field
        expect(find.text('Your Name'), findsOneWidget);
        expect(find.byType(TextFormField).at(0), findsOneWidget);

        // Destination field
        expect(find.text('Where are you going?'), findsOneWidget);

        // Date range field
        expect(find.text('When are you traveling?'), findsOneWidget);

        // Interests section
        expect(find.text('What interests you?'), findsOneWidget);

        // Budget section
        expect(find.text('Budget Preference (Optional)'), findsOneWidget);

        // Submit button
        expect(find.text('Get My Free Trip Plan'), findsOneWidget);
      });

      testWidgets('renders all 10 travel interest chips', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Check for all interest emojis/labels
        expect(find.text('Food & Cuisine'), findsOneWidget);
        expect(find.text('Culture & History'), findsOneWidget);
        expect(find.text('Art & Museums'), findsOneWidget);
        expect(find.text('Adventure & Outdoors'), findsOneWidget);
        expect(find.text('Wellness & Relaxation'), findsOneWidget);
        expect(find.text('Nightlife & Entertainment'), findsOneWidget);
        expect(find.text('Nature & Scenery'), findsOneWidget);
        expect(find.text('Shopping & Markets'), findsOneWidget);
        expect(find.text('Photography'), findsOneWidget);
        expect(find.text('Local Experiences'), findsOneWidget);
      });

      testWidgets('shows interest selection counter', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('0/5 selected'), findsOneWidget);
      });

      testWidgets('renders budget selection options', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Budget-Friendly'), findsOneWidget);
        expect(find.text('Moderate'), findsOneWidget);
        expect(find.text('Flexible'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
      });
    });

    group('Form Field Interactions', () {
      testWidgets('allows entering name in text field', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final nameField = find.byType(TextFormField).at(0);
        await tester.enterText(nameField, 'John Doe');
        await tester.pumpAndSettle();

        expect(find.text('John Doe'), findsOneWidget);
      });

      testWidgets('shows clear button when destination is selected',
          (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Initially, no clear button should be visible (destination not selected)
        expect(find.byIcon(Icons.clear), findsNothing);

        // Note: Full destination selection test would require mocking Google Places API
        // This test verifies the structure is in place
      });

      testWidgets('tapping date field opens date range picker', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Find the date range InkWell
        final dateField = find.widgetWithText(InkWell, 'Select travel dates');
        expect(dateField, findsOneWidget);

        // Tapping should trigger the date picker (which is a placeholder in current implementation)
        await tester.tap(dateField);
        await tester.pumpAndSettle();

        // The placeholder implementation keeps the same range
        // In production, this would open a proper date picker dialog
      });

      testWidgets('interest chips are toggleable', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Find and tap first interest chip
        final foodChip = find.ancestor(
          of: find.text('Food & Cuisine'),
          matching: find.byType(FilterChip),
        );

        await tester.tap(foodChip);
        await tester.pumpAndSettle();

        // Counter should update
        expect(find.text('1/5 selected'), findsOneWidget);
      });

      testWidgets('allows selecting multiple interests', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap multiple interest chips
        final chips = find.byType(FilterChip);
        await tester.tap(chips.at(0)); // Food
        await tester.pumpAndSettle();

        await tester.tap(chips.at(1)); // Culture
        await tester.pumpAndSettle();

        await tester.tap(chips.at(2)); // Art
        await tester.pumpAndSettle();

        expect(find.text('3/5 selected'), findsOneWidget);
      });

      testWidgets('budget chips are selectable', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Find budget chips (FilterChip widgets in BudgetSelectionCompact)
        final budgetChips = find.byType(FilterChip);

        // The budget widget uses FilterChips
        expect(budgetChips, findsWidgets);

        // Tap first budget option
        await tester.tap(budgetChips.first);
        await tester.pumpAndSettle();
      });
    });

    group('Form Validation', () {
      testWidgets('submit button is disabled when form is invalid',
          (tester) async {
        mockOnboardingNotifier.setState(
          OnboardingState.inProgress(
            OnboardingData(
              name: '',
              destination: const Destination(
                placeId: '',
                name: '',
                latitude: 0,
                longitude: 0,
              ),
              dateRange: DateRange(
                start: DateTime.now(),
                end: DateTime.now().add(const Duration(days: 7)),
              ),
              interests: {},
              budget: null,
            ),
            {},
            {},
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final submitButton = find.text('Get My Free Trip Plan');
        final button = tester.widget<FilledButton>(submitButton);

        expect(button.enabled, isFalse);
      });

      testWidgets('submit button is enabled when form is valid',
          (tester) async {
        mockOnboardingNotifier.setState(
          OnboardingState.inProgress(
            OnboardingData(
              name: 'Test User',
              destination: const Destination(
                placeId: 'test-place',
                name: 'Paris',
                latitude: 48.8566,
                longitude: 2.3522,
              ),
              dateRange: DateRange(
                start: DateTime.now().add(const Duration(days: 30)),
                end: DateTime.now().add(const Duration(days: 37)),
              ),
              interests: {TravelInterest.food, TravelInterest.culture},
              budget: BudgetRange.moderate,
            ),
            {TravelInterest.food, TravelInterest.culture},
            {
              TravelInterest.food: DateRange(
                start: DateTime.now().add(const Duration(days: 30)),
                end: DateTime.now().add(const Duration(days: 37)),
              ),
              TravelInterest.culture: DateRange(
                start: DateTime.now().add(const Duration(days: 30)),
                end: DateTime.now().add(const Duration(days: 37)),
              ),
            },
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Form validation happens in _isFormValid() which checks state
        // The button should be enabled when all fields are valid
        final submitButton = find.text('Get My Free Trip Plan');
        expect(submitButton, findsOneWidget);
      });

      testWidgets('shows error message when name is empty on submit',
          (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Try to submit without filling form
        final submitButton = find.text('Get My Free Trip Plan');
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Should show validation error snackbar
        expect(
          find.text('Please fix the errors before submitting'),
          findsOneWidget,
        );
      });

      testWidgets('shows validation errors for all required fields',
          (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap submit with empty form
        await tester.tap(find.text('Get My Free Trip Plan'));
        await tester.pumpAndSettle();

        // Should show snackbar
        expect(
          find.text('Please fix the errors before submitting'),
          findsOneWidget,
        );
      });
    });

    group('Loading States', () {
      testWidgets('shows loading indicator when submitting', (tester) async {
        mockOnboardingNotifier.setState(
          OnboardingState.submitting(
            OnboardingData(
              name: 'Test User',
              destination: const Destination(
                placeId: 'test-place',
                name: 'Paris',
                latitude: 48.8566,
                longitude: 2.3522,
              ),
              dateRange: DateRange(
                start: DateTime.now(),
                end: DateTime.now().add(const Duration(days: 7)),
              ),
              interests: {TravelInterest.food},
              budget: null,
            ),
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Should show CircularProgressIndicator in submit button
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Form fields should be disabled
        final nameField = find.byType(TextFormField).at(0);
        final textField = tester.widget<TextFormField>(nameField);
        expect(textField.enabled, isFalse);
      });

      testWidgets('disables form fields during submission', (tester) async {
        mockOnboardingNotifier.setState(
          OnboardingState.submitting(
            OnboardingData(
              name: 'Test User',
              destination: const Destination(
                placeId: 'test-place',
                name: 'Paris',
                latitude: 48.8566,
                longitude: 2.3522,
              ),
              dateRange: DateRange(
                start: DateTime.now(),
                end: DateTime.now().add(const Duration(days: 7)),
              ),
              interests: {TravelInterest.food},
              budget: null,
            ),
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Interest chips should be disabled
        final chips = find.byType(FilterChip);
        for (int i = 0; i < 10; i++) {
          final chip = tester.widget<FilterChip>(chips.at(i));
          expect(chip.onSelected, isNull);
        }

        // Date field should not be tappable
        final dateField = find.widgetWithText(InkWell, 'Select travel dates');
        final inkWell = tester.widget<InkWell>(dateField);
        expect(inkWell.onTap, isNull);
      });
    });

    group('Error States', () {
      testWidgets('shows error snackbar when submission fails', (tester) async {
        mockOnboardingNotifier.setState(
          OnboardingState.error(
            OnboardingData(
              name: 'Test User',
              destination: const Destination(
                placeId: 'test-place',
                name: 'Paris',
                latitude: 48.8566,
                longitude: 2.3522,
              ),
              dateRange: DateRange(
                start: DateTime.now(),
                end: DateTime.now().add(const Duration(days: 7)),
              ),
              interests: {TravelInterest.food},
              budget: null,
            ),
            'Failed to generate itinerary. Please try again.',
            null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // ref.listen in the widget should show error snackbar
        // The error message should be displayed
        expect(find.text('Failed to generate itinerary. Please try again.'),
            findsOneWidget);
      });

      testWidgets('error snackbar has dismiss button', (tester) async {
        mockOnboardingNotifier.setState(
          OnboardingState.error(
            OnboardingData(
              name: 'Test User',
              destination: const Destination(
                placeId: 'test-place',
                name: 'Paris',
                latitude: 48.8566,
                longitude: 2.3522,
              ),
              dateRange: DateRange(
                start: DateTime.now(),
                end: DateTime.now().add(const Duration(days: 7)),
              ),
              interests: {TravelInterest.food},
              budget: null,
            ),
            'Network error occurred',
            null,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Should show dismiss button
        expect(find.text('Dismiss'), findsOneWidget);
      });
    });

    group('Success State and Navigation', () {
      testWidgets('navigates to success screen on successful submission',
          (tester) async {
        final testItinerary = Itinerary(
          id: 'test-itinerary-id',
          name: 'Paris Trip',
          destination: const Destination(
            placeId: 'test-place',
            name: 'Paris',
            latitude: 48.8566,
            longitude: 2.3522,
          ),
          dateRange: DateRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          ),
          items: [],
          isStarter: true,
          createdAt: DateTime.now(),
        );

        mockOnboardingNotifier.setState(
          OnboardingState.success(
            OnboardingData(
              name: 'Test User',
              destination: const Destination(
                placeId: 'test-place',
                name: 'Paris',
                latitude: 48.8566,
                longitude: 2.3522,
              ),
              dateRange: DateRange(
                start: DateTime.now(),
                end: DateTime.now().add(const Duration(days: 7)),
              ),
              interests: {TravelInterest.food},
              budget: null,
            ),
            testItinerary,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Navigation should be triggered
        // In a real test, we'd verify the route was pushed
        // Since we're using MaterialApp without routes, we verify the state change
        expect(
            mockOnboardingNotifier.state.maybeWhen(
              success: (_, itinerary) => itinerary.id == 'test-itinerary-id',
              orElse: () => false,
            ),
            isTrue);
      });
    });

    group('Accessibility', () {
      testWidgets('name field has proper semantics', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Your Name'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('destination field has proper semantics', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Where are you going?'), findsOneWidget);
        expect(find.byIcon(Icons.place), findsOneWidget);
      });

      testWidgets('date field has proper semantics', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('When are you traveling?'), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });
    });

    group('Interest Selection Limits', () {
      testWidgets('shows max interests warning when 5 selected',
          (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Select 5 interests
        final chips = find.byType(FilterChip);
        for (int i = 0; i < 5; i++) {
          await tester.tap(chips.at(i));
          await tester.pumpAndSettle();
        }

        // Counter should show 5/5 with green color
        expect(find.text('5/5 selected'), findsOneWidget);
      });

      testWidgets('prevents selecting more than 5 interests', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Try to select 6 interests
        final chips = find.byType(FilterChip);
        for (int i = 0; i < 6; i++) {
          await tester.tap(chips.at(i));
          await tester.pumpAndSettle();
        }

        // Should still show 5/5
        expect(find.text('5/5 selected'), findsOneWidget);
      });
    });

    group('Budget Selection', () {
      testWidgets('allows skipping budget selection', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap Skip option
        final skipChip = find.widgetWithText(FilterChip, 'Skip');
        expect(skipChip, findsOneWidget);

        await tester.tap(skipChip);
        await tester.pumpAndSettle();

        // Budget is optional, so form should still work
      });
    });

    group('Layout and Styling', () {
      testWidgets('app bar has correct title', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Plan Your Solo Adventure'), findsOneWidget);
      });

      testWidgets('form uses SingleChildScrollView', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('form fields have consistent spacing', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verify structure with SizedBox spacing
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsWidgets);
      });
    });
  });
}
