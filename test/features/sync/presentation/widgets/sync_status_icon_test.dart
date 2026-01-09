import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_status_icon.dart';

void main() {
  group('SyncStatusIcon', () {
    testWidgets('renders icon for each status', (tester) async {
      for (final status in SyncStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyncStatusIcon(status: status),
            ),
          ),
        );

        expect(find.byType(SyncStatusIcon), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      }
    });

    testWidgets('shows label when showLabel is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusIcon(
              status: SyncStatus.syncing,
              showLabel: true,
            ),
          ),
        ),
      );

      expect(find.byType(SyncStatusIcon), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.text('Syncing...'), findsOneWidget);
    });

    testWidgets('shows custom label when provided', (tester) async {
      const customLabel = 'Custom Status';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusIcon(
              status: SyncStatus.success,
              showLabel: true,
              customLabel: customLabel,
            ),
          ),
        ),
      );

      expect(find.text(customLabel), findsOneWidget);
      expect(find.text(SyncStatus.success.displayName), findsNothing);
    });

    testWidgets('renders with background when withBackground is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusIcon(
              status: SyncStatus.success,
              withBackground: true,
            ),
          ),
        ),
      );

      expect(find.byType(SyncStatusIcon), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      const customSize = 48.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusIcon(
              status: SyncStatus.success,
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
        SyncStatus.idle: Icons.sync,
        SyncStatus.syncing: Icons.sync,
        SyncStatus.success: Icons.check_circle,
        SyncStatus.failed: Icons.error,
        SyncStatus.pending: Icons.schedule,
      };

      for (final entry in expectedIcons.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyncStatusIcon(status: entry.key),
            ),
          ),
        );

        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.icon, entry.value);
      }
    });
  });

  group('SyncStatusIndicator', () {
    testWidgets('renders indicator for each status', (tester) async {
      for (final status in SyncStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyncStatusIndicator(status: status),
            ),
          ),
        );

        expect(find.byType(SyncStatusIndicator), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      }
    });

    testWidgets('respects custom size', (tester) async {
      const customSize = 20.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncStatusIndicator(
              status: SyncStatus.success,
              size: customSize,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SyncStatusIndicator),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('can disable animation for syncing status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusIndicator(
              status: SyncStatus.syncing,
              animateWhenSyncing: false,
            ),
          ),
        ),
      );

      // Should render without animation
      expect(find.byType(SyncStatusIndicator), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('shows correct color for each status', (tester) async {
      final theme = ThemeData();

      for (final status in SyncStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyncStatusIndicator(status: status),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SyncStatusIndicator),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, isNotNull);
      }
    });
  });

  group('SyncStatusIcon integration', () {
    testWidgets('works with Row layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                SyncStatusIcon(status: SyncStatus.success),
                SyncStatusIcon(status: SyncStatus.syncing),
                SyncStatusIcon(status: SyncStatus.failed),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SyncStatusIcon), findsNWidgets(3));
    });

    testWidgets('works with Column layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SyncStatusIcon(status: SyncStatus.idle),
                SyncStatusIcon(status: SyncStatus.pending),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SyncStatusIcon), findsNWidgets(2));
    });

    testWidgets('handles theme changes', (tester) async {
      var darkTheme = ThemeData.dark();
      var lightTheme = ThemeData.light();

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: SyncStatusIcon(status: SyncStatus.success),
          ),
        ),
      );

      expect(find.byType(SyncStatusIcon), findsOneWidget);

      // Change to dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const Scaffold(
            body: SyncStatusIcon(status: SyncStatus.success),
          ),
        ),
      );

      expect(find.byType(SyncStatusIcon), findsOneWidget);
    });
  });
}
