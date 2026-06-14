import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/matching/domain/entities/connection.dart';
import 'package:soloadventurer/features/matching/domain/entities/matching_trip.dart';
import 'package:soloadventurer/features/matching/presentation/providers/connection_provider.dart';
import 'package:soloadventurer/features/matching/presentation/providers/trip_provider.dart';
import 'package:soloadventurer/features/matching/presentation/screens/matches_screen.dart';
import 'package:soloadventurer/l10n/app_localizations.dart';

/// Sprint 7.1 — first slice: 3-state widget tests for [MatchesScreen].
///
/// Each test injects one `AsyncValue` state (loading / error / empty) by
/// overriding `matchesProvider` / `activeTripsProvider`, then asserts the
/// widget *unique* to that state renders AND the other states' widgets do not.
/// That is the "teeth" — these tests fail if the screen stops branching on
/// state (e.g. always renders the list, or collapses loading/error together).
///
/// Sources:
///  - Flutter widget testing: https://docs.flutter.dev/cookbook/testing/widget/introduction
///  - Riverpod testing (provider overrides): https://riverpod.dev/docs/advanced/testing
void main() {
  group('MatchesScreen 3-state (loading / error / empty)', () {
    testWidgets('loading state shows a progress indicator', (tester) async {
      // matchesProvider never completes during the assertion -> matchesAsync
      // stays in `AsyncValue.loading` and the screen renders its loading branch.
      final completer = Completer<List<Connection>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            matchesProvider.overrideWith((ref) => completer.future),
            activeTripsProvider.overrideWith(
              (ref) => Future.value(<MatchingTrip>[]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MatchesScreen(),
          ),
        ),
      );
      await tester.pump(); // do NOT settle: we want to observe loading.

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.byIcon(Icons.flight_takeoff), findsNothing);

      completer.complete(<Connection>[]); // leave no future pending.
    });

    testWidgets('error state shows the error icon and retry button',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            matchesProvider.overrideWith(
              (ref) => Future<List<Connection>>.error(Exception('boom')),
            ),
            activeTripsProvider.overrideWith(
              (ref) => Future.value(<MatchingTrip>[]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MatchesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // _buildErrorState renders Icons.error_outline + a refresh retry button.
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('empty state (no trips) shows the no-trips CTA', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            matchesProvider.overrideWith((ref) => Future.value(<Connection>[])),
            activeTripsProvider.overrideWith(
              (ref) => Future.value(<MatchingTrip>[]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MatchesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // trips.isEmpty is checked first -> _buildNoTripsState (flight_takeoff).
      expect(find.byIcon(Icons.flight_takeoff), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });
}
