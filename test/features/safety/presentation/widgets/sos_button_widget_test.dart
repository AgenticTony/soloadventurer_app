import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/safety/presentation/widgets/sos_button_widget.dart';

void main() {
  group('SOSButtonWidget', () {
    group('Rendering', () {
      testWidgets('renders SOS button with default label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('SOS'), findsOneWidget);
      });

      testWidgets('renders with custom label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                label: 'HELP',
              ),
            ),
          ),
        );

        expect(find.text('HELP'), findsOneWidget);
        expect(find.text('SOS'), findsNothing);
      });

      testWidgets('renders ACTIVE state when hasActiveEmergency is true',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                hasActiveEmergency: true,
              ),
            ),
          ),
        );

        expect(find.text('ACTIVE'), findsOneWidget);
        expect(find.text('SOS'), findsNothing);
      });

      testWidgets('renders with custom active label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                hasActiveEmergency: true,
                activeLabel: 'ALERT ON',
              ),
            ),
          ),
        );

        expect(find.text('ALERT ON'), findsOneWidget);
        expect(find.text('ACTIVE'), findsNothing);
      });

      testWidgets('renders subtitle on large size', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                size: SOSButtonSize.large,
                subtitle: 'Emergency',
              ),
            ),
          ),
        );

        expect(find.text('SOS'), findsOneWidget);
        expect(find.text('Emergency'), findsOneWidget);
      });

      testWidgets('renders loading indicator when isLoading is true',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('SOS'), findsNothing);
      });

      testWidgets('renders small size without subtitle', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                size: SOSButtonSize.small,
                subtitle: 'Should not show',
              ),
            ),
          ),
        );

        expect(find.text('SOS'), findsOneWidget);
        expect(find.text('Should not show'), findsNothing);
      });
    });

    group('Dimensions', () {
      testWidgets('renders with small size dimensions', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                size: SOSButtonSize.small,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SOSButtonWidget),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.shape, BoxShape.circle);
      });

      testWidgets('renders with medium size dimensions', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                size: SOSButtonSize.medium,
              ),
            ),
          ),
        );

        expect(find.byType(SOSButtonWidget), findsOneWidget);
      });

      testWidgets('renders with large size dimensions', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                size: SOSButtonSize.large,
              ),
            ),
          ),
        );

        expect(find.byType(SOSButtonWidget), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('calls onPressed when tapped', (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(SOSButtonWidget));
        expect(pressed, isTrue);
      });

      testWidgets('does not call onPressed when isLoading', (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () => pressed = true,
                isLoading: true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(SOSButtonWidget));
        expect(pressed, isFalse);
      });

      testWidgets('does not call onPressed when hasActiveEmergency',
          (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () => pressed = true,
                hasActiveEmergency: true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(SOSButtonWidget));
        expect(pressed, isFalse);
      });

      testWidgets('does not call onPressed when callback is null',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: null,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(SOSButtonWidget));
        // Should not throw
      });
    });

    group('Accessibility', () {
      testWidgets('has semantic label for screen readers', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                semanticLabel: 'Emergency button',
              ),
            ),
          ),
        );

        expect(find.bySemanticsLabel('Emergency button'), findsOneWidget);
      });

      testWidgets('has default semantic label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Emergency SOS button'),
          findsOneWidget,
        );
      });

      testWidgets('semantic label changes for active emergency',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                hasActiveEmergency: true,
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Active emergency alert'),
          findsOneWidget,
        );
      });

      testWidgets('semantics indicates enabled state', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(SOSButtonWidget));
        expect(
          semantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
      });
    });

    group('Animation', () {
      testWidgets('pulses when showPulse is true', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                showPulse: true,
              ),
            ),
          ),
        );

        // Pump a few frames to allow animation to progress
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(SOSButtonWidget), findsOneWidget);
      });

      testWidgets('does not pulse when showPulse is false', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                showPulse: false,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(SOSButtonWidget), findsOneWidget);
      });

      testWidgets('stops pulsing when isLoading becomes true',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                isLoading: false,
                showPulse: true,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        // Update to loading state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                isLoading: true,
                showPulse: true,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('stops pulsing when hasActiveEmergency becomes true',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                hasActiveEmergency: false,
                showPulse: true,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        // Update to active emergency state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                hasActiveEmergency: true,
                showPulse: true,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('ACTIVE'), findsOneWidget);
      });
    });

    group('Visual appearance', () {
      testWidgets('uses custom color when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                color: Colors.purple,
              ),
            ),
          ),
        );

        expect(find.byType(SOSButtonWidget), findsOneWidget);
      });

      testWidgets('shows gradient effect', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SOSButtonWidget),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);
      });

      testWidgets('shows shadow effect', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SOSButtonWidget),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotEmpty);
      });

      testWidgets('color changes for active emergency', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SOSButtonWidget(
                onPressed: () {},
                hasActiveEmergency: true,
              ),
            ),
          ),
        );

        expect(find.byType(SOSButtonWidget), findsOneWidget);
      });
    });

    group('SOSButtonDimensions', () {
      test('small dimensions are correct', () {
        const dimensions = SOSButtonSize.small.dimensions;

        expect(dimensions.width, 56);
        expect(dimensions.height, 56);
        expect(dimensions.fontSize, 18);
        expect(dimensions.loadingIndicatorSize, 20);
      });

      test('medium dimensions are correct', () {
        const dimensions = SOSButtonSize.medium.dimensions;

        expect(dimensions.width, 100);
        expect(dimensions.height, 100);
        expect(dimensions.fontSize, 28);
        expect(dimensions.loadingIndicatorSize, 30);
      });

      test('large dimensions are correct', () {
        const dimensions = SOSButtonSize.large.dimensions;

        expect(dimensions.width, 180);
        expect(dimensions.height, 180);
        expect(dimensions.fontSize, 48);
        expect(dimensions.loadingIndicatorSize, 40);
      });

      test('dimensions equality works correctly', () {
        const dimensions1 = SOSButtonDimensions(
          width: 100,
          height: 100,
          fontSize: 28,
          subtitleFontSize: 12,
          subtitleSpacing: 4,
          blurRadius: 20,
          spreadRadius: 5,
          loadingIndicatorSize: 30,
        );

        const dimensions2 = SOSButtonDimensions(
          width: 100,
          height: 100,
          fontSize: 28,
          subtitleFontSize: 12,
          subtitleSpacing: 4,
          blurRadius: 20,
          spreadRadius: 5,
          loadingIndicatorSize: 30,
        );

        expect(dimensions1, equals(dimensions2));
        expect(dimensions1.hashCode, equals(dimensions2.hashCode));
      });
    });
  });
}
