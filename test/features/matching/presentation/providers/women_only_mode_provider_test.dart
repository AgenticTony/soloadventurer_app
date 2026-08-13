import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/matching/domain/repositories/matching_repository.dart';
import 'package:soloadventurer/features/matching/presentation/providers/chat_provider.dart';
import 'package:soloadventurer/features/matching/presentation/providers/matching_provider.dart';

/// Minimal stand-in for [MatchingRepository].
///
/// Only the women-only surface is implemented; `noSuchMethod` absorbs the rest
/// of the (large) interface so this file stays about the behaviour under test.
class FakeMatchingRepository implements MatchingRepository {
  /// Backing value for [isWomenOnlyModeEnabled]. `null` = indeterminate.
  bool? enabled = false;

  /// Backing value for [isVerifiedForWomenOnly].
  bool verified = true;

  /// When set, the enable/disable writes throw this instead of succeeding.
  Object? throwOnWrite;

  @override
  Future<bool?> isWomenOnlyModeEnabled() async => enabled;

  @override
  Future<bool> isVerifiedForWomenOnly() async => verified;

  @override
  Future<String?> getUserGender() async => 'female';

  @override
  Future<void> enableWomenOnlyMode() async {
    if (throwOnWrite != null) throw throwOnWrite!;
    enabled = true;
  }

  @override
  Future<void> disableWomenOnlyMode() async {
    if (throwOnWrite != null) throw throwOnWrite!;
    enabled = false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not needed for this test');
}

/// Regression tests for the H.1–H.7 review findings on women-only mode.
///
/// Two of the six findings landed on this surface, and both made the safety
/// control lie to the user:
///
///   * `enable()` / `disable()` updated the notifier but never invalidated
///     `womenOnlyModeEnabledProvider`, which is what the settings switch binds
///     to — so a successful toggle visibly snapped back to its old value.
///   * `isWomenOnlyModeEnabled()` returned `false` when offline, rendering an
///     active protection as "Disabled".
void main() {
  late FakeMatchingRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeMatchingRepository();
    container = ProviderContainer(
      overrides: [
        matchingRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  // Closure, not a tear-off: `container` is late and a tear-off would be
  // evaluated at registration time, before setUp assigns it.
  tearDown(() => container.dispose());

  group('toggling refreshes what the switch actually reads', () {
    test('enable() invalidates womenOnlyModeEnabledProvider', () async {
      repository.enabled = false;

      // Prime the read provider the settings switch binds to.
      expect(await container.read(womenOnlyModeEnabledProvider.future), isFalse);

      repository.enabled = true;
      await container.read(womenOnlyModeProvider.notifier).enable();

      // Without the invalidation this still returns the cached `false`, which
      // is exactly what made the toggle appear to reject the change.
      expect(
        await container.read(womenOnlyModeEnabledProvider.future),
        isTrue,
        reason: 'the switch must reflect the write that just succeeded',
      );
    });

    test('disable() invalidates womenOnlyModeEnabledProvider', () async {
      repository.enabled = true;
      expect(await container.read(womenOnlyModeEnabledProvider.future), isTrue);

      repository.enabled = false;
      await container.read(womenOnlyModeProvider.notifier).disable();

      expect(await container.read(womenOnlyModeEnabledProvider.future), isFalse);
    });

    test('a failed enable() leaves the read provider untouched', () async {
      repository.enabled = false;
      repository.throwOnWrite = Exception('offline');

      await expectLater(
        container.read(womenOnlyModeProvider.notifier).enable(),
        throwsA(isA<Exception>()),
      );

      // The write never landed, so the displayed state must not claim it did.
      expect(await container.read(womenOnlyModeEnabledProvider.future), isFalse);
    });
  });

  group('indeterminate status is not reported as "off"', () {
    test('propagates null when the repository cannot determine status',
        () async {
      repository.enabled = null; // offline / signed out / read failed

      expect(
        await container.read(womenOnlyModeEnabledProvider.future),
        isNull,
        reason: 'null must reach the UI so it can render "unavailable"; '
            'flattening it to false tells a protected user she is exposed',
      );
    });

    test('distinguishes a genuine off from an unknown', () async {
      repository.enabled = false;
      expect(await container.read(womenOnlyModeEnabledProvider.future), isFalse);

      container.invalidate(womenOnlyModeEnabledProvider);
      repository.enabled = null;
      expect(await container.read(womenOnlyModeEnabledProvider.future), isNull);
    });
  });

  group('canEnableWomenOnlyMode is verification-gated only', () {
    test('a verified user can enable, with no subscription check', () async {
      repository.verified = true;
      expect(await container.read(canEnableWomenOnlyModeProvider.future), isTrue);
    });

    test('an unverified user cannot', () async {
      repository.verified = false;
      expect(await container.read(canEnableWomenOnlyModeProvider.future), isFalse);
    });
  });
}
