import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Regression test for the H review finding on [currentUserIdProvider].
///
/// The provider used to read `auth.currentUser?.id` while watching only
/// [supabaseClientProvider]. `Supabase.instance.client` is a singleton, so that
/// dependency never changes: a plain `Provider` computed the id once and cached
/// it for the life of the container. Nothing invalidated it on sign-out —
/// `signOut()` neither disposes the container nor invalidates this provider — so
/// after signing in as a different user, callers that scope by user id kept
/// using the previous one. `trip_providers.dart` stamped it onto new trips;
/// `meetup_checkin_providers.dart` bound a realtime subscription to it.
///
/// The fix is a dependency on the auth-change stream. That dependency is what
/// this file pins.
///
/// Scope note: asserting the *recomputed value* would require faking
/// `SupabaseClient.auth.currentUser`, and a fake shallow enough to build here
/// would only re-assert its own stub rather than the production provider. The
/// dependency edge below is the real defect and the part worth locking down;
/// re-evaluation on dependency change is Riverpod's own guarantee.
void main() {
  late StreamController<AuthState> authEvents;
  late ProviderContainer container;

  setUp(() {
    authEvents = StreamController<AuthState>.broadcast();
    container = ProviderContainer(
      overrides: [
        // A locally-constructed client, so the *real* currentUserIdProvider
        // runs rather than a stub of it. No network is touched: the provider
        // only reads `auth.currentUser`, which is null here.
        // Supabase.instance is unavailable in unit tests.
        supabaseClientProvider.overrideWithValue(
          SupabaseClient('http://localhost', 'test-anon-key'),
        ),
        authStateChangesProvider.overrideWith((ref) => authEvents.stream),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    authEvents.close();
  });

  test('currentUserIdProvider subscribes to auth changes', () {
    // Reading the id must pull the auth stream into the graph. Without this
    // edge the provider silently reverts to compute-once-and-cache, which is
    // exactly the bug: no error, no warning, just a stale user id.
    container.read(currentUserIdProvider);

    expect(
      container.exists(authStateChangesProvider),
      isTrue,
      reason: 'currentUserIdProvider must watch authStateChangesProvider so a '
          'sign-out/sign-in recomputes it',
    );
  });

  test('authStateChangesProvider surfaces auth events', () async {
    final seen = <AuthChangeEvent>[];
    final sub = container.listen(
      authStateChangesProvider,
      (_, next) {
        next.whenData((state) => seen.add(state.event));
      },
      fireImmediately: true,
    );
    addTearDown(sub.close);

    authEvents.add(AuthState(AuthChangeEvent.signedOut, null));
    authEvents.add(AuthState(AuthChangeEvent.signedIn, null));
    await Future<void>.delayed(Duration.zero);

    expect(seen, [AuthChangeEvent.signedOut, AuthChangeEvent.signedIn]);
  });
}
