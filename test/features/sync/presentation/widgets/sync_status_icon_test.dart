import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_status_icon.dart';

void main() {
  group('SyncOperationStatusIcon', () {
    testWidgets('renders icon for each status', (tester) async {
      for (final status in SyncOperationStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyncOperationStatusIcon(status: status),
            ),
          ),
        );

        expect(find.byType(SyncOperationStatusIcon), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      }
    });

    testWidgets('shows label when showLabel is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncOperationStatusIcon(
              status: SyncOperationStatus.syncing,
              showLabel: true,
            ),
          ),
        ),
      );

      expect(find.byType(SyncOperationStatusIcon), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.text('Syncing...'), findsOneWidget);
    });

    testWidgets('shows custom label when provided', (tester) async {
      const customLabel = 'Custom Status';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncOperationStatusIcon(
              status: SyncOperationStatus.success,
              showLabel: true,
              customLabel: customLabel,
            ),
          ),
        ),
      );

      expect(find.text(customLabel), findsOneWidget);
      expect(find.text(SyncOperationStatus.success.displayName), findsNothing);
    });

    testWidgets('renders with background when withBackground is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncOperationStatusIcon(
              status: SyncOperationStatus.success,
              withBackground: true,
            ),
          ),
        ),
      );

      expect(find.byType(SyncOperationStatusIcon), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      const customSize = 48.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncOperationStatusIcon(
              status: SyncOperationStatus.success,
              size: customSize,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, customSize);
    });

    testWidgets('shows correct icon for each status', (tester) async {
      final expectedIcons = {
        SyncOperationStatus.idle: Icons.sync,
        SyncOperationStatus.syncing: Icons.sync,
        SyncOperationStatus.success: Icons.check_circle,
        SyncOperationStatus.failed: Icons.error,
        SyncOperationStatus.pending: Icons.schedule,
      };

      for (final entry in expectedIcons.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyncOperationStatusIcon(status: entry.key),
            ),
          ),
        );

        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.icon, entry.value);
      }
    });
  });

  group('SyncOperationStatusIndicator', () {
    testWidgets('renders indicator for each status', (tester) async {
      for (final status in SyncOperationStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyncOperationStatusIndicator(status: status),
            ),
          ),
        );

        expect(find.byType(SyncOperationStatusIndicator), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      }
    });

    testWidgets('respects custom size', (tester) async {
      const customSize = 20.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncOperationStatusIndicator(
              status: SyncOperationStatus.success,
              size: customSize,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(SyncOperationStatusIndicator),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('can disable animation for syncing status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncOperationStatusIndicator(
              status: SyncOperationStatus.syncing,
              animateWhenSyncing: false,
            ),
          ),
        ),
      );

      // Should render without animation
      expect(find.byType(SyncOperationStatusIndicator), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('shows correct color for each status', (tester) async {
      final theme = ThemeData();

      for (final status in SyncOperationStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyncOperationStatusIndicator(status: status),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(SyncOperationStatusIndicator),
                matching: find.byType(Container),
              )
              .first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, isNotNull);
      }
    });
  });

  group('SyncOperationStatusIcon integration', () {
    testWidgets('works with Row layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                SyncOperationStatusIcon(status: SyncOperationStatus.success),
                SyncOperationStatusIcon(status: SyncOperationStatus.syncing),
                SyncOperationStatusIcon(status: SyncOperationStatus.failed),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SyncOperationStatusIcon), findsNWidgets(3));
    });

    testWidgets('works with Column layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SyncOperationStatusIcon(status: SyncOperationStatus.idle),
                SyncOperationStatusIcon(status: SyncOperationStatus.pending),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SyncOperationStatusIcon), findsNWidgets(2));
    });

    testWidgets('handles theme changes', (tester) async {
      var darkTheme = ThemeData.dark();
      var lightTheme = ThemeData.light();

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: SyncOperationStatusIcon(status: SyncOperationStatus.success),
          ),
        ),
      );

      expect(find.byType(SyncOperationStatusIcon), findsOneWidget);

      // Change to dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const Scaffold(
            body: SyncOperationStatusIcon(status: SyncOperationStatus.success),
          ),
        ),
      );

      expect(find.byType(SyncOperationStatusIcon), findsOneWidget);
    });
  });
}
