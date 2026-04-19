// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages saving user activity selections from destination discovery
/// to the matching system's user_activities table.
///
/// When a user picks interests from the discovery screen (Google Places or
/// Viator), this provider persists them so the matching algorithm can use
/// activity overlap for scoring.

@ProviderFor(ActivitySelection)
const activitySelectionProvider = ActivitySelectionProvider._();

/// Manages saving user activity selections from destination discovery
/// to the matching system's user_activities table.
///
/// When a user picks interests from the discovery screen (Google Places or
/// Viator), this provider persists them so the matching algorithm can use
/// activity overlap for scoring.
final class ActivitySelectionProvider
    extends $NotifierProvider<ActivitySelection, Set<String>> {
  /// Manages saving user activity selections from destination discovery
  /// to the matching system's user_activities table.
  ///
  /// When a user picks interests from the discovery screen (Google Places or
  /// Viator), this provider persists them so the matching algorithm can use
  /// activity overlap for scoring.
  const ActivitySelectionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activitySelectionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activitySelectionHash();

  @$internal
  @override
  ActivitySelection create() => ActivitySelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$activitySelectionHash() => r'dbbbc8f63ad32f2472aa3b10552d20a53c128d7b';

/// Manages saving user activity selections from destination discovery
/// to the matching system's user_activities table.
///
/// When a user picks interests from the discovery screen (Google Places or
/// Viator), this provider persists them so the matching algorithm can use
/// activity overlap for scoring.

abstract class _$ActivitySelection extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<String>, Set<String>>, Set<String>, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

/// Bridge provider for the matching repository.
///
/// In production, the matching module overrides this with its actual
/// implementation. Returns null if not overridden (selections are tracked
/// locally only).

@ProviderFor(matchingRepositoryBridge)
const matchingRepositoryBridgeProvider = MatchingRepositoryBridgeProvider._();

/// Bridge provider for the matching repository.
///
/// In production, the matching module overrides this with its actual
/// implementation. Returns null if not overridden (selections are tracked
/// locally only).

final class MatchingRepositoryBridgeProvider extends $FunctionalProvider<
    MatchingRepository?,
    MatchingRepository?,
    MatchingRepository?> with $Provider<MatchingRepository?> {
  /// Bridge provider for the matching repository.
  ///
  /// In production, the matching module overrides this with its actual
  /// implementation. Returns null if not overridden (selections are tracked
  /// locally only).
  const MatchingRepositoryBridgeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'matchingRepositoryBridgeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$matchingRepositoryBridgeHash();

  @$internal
  @override
  $ProviderElement<MatchingRepository?> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MatchingRepository? create(Ref ref) {
    return matchingRepositoryBridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchingRepository? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchingRepository?>(value),
    );
  }
}

String _$matchingRepositoryBridgeHash() =>
    r'd5d0c4e93800ffeb9e35feb8d8d657c41e0e2d8a';
