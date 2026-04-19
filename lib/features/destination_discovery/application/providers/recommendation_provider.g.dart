// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<T>>` to `AsyncNotifier<T>`
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns `Future<T>` not `AsyncValue<T>`
/// - State is automatically `AsyncValue<RecommendationState>` when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for personalized recommendations state management
///
/// This provider manages the state of personalized destination recommendations including:
/// - Recommendation data with match scores and reasons
/// - Loading and error states
/// - Expiration checking and auto-refresh
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
///
/// Usage:
/// ```dart
/// final recommendationState = ref.watch(recommendationProvider(userId));
/// final recommendationNotifier = ref.read(recommendationProvider(userId).notifier);
///
/// // Load recommendations (automatically called on first watch)
/// // The userId is passed as a parameter to the provider
///
/// // Refresh recommendations
/// await recommendationNotifier.refresh();
///
/// // Clear recommendations
/// recommendationNotifier.clear();
/// ```
///
/// The [userId] parameter is the user ID to load recommendations for.

@ProviderFor(Recommendation)
const recommendationProvider = RecommendationFamily._();

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<T>>` to `AsyncNotifier<T>`
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns `Future<T>` not `AsyncValue<T>`
/// - State is automatically `AsyncValue<RecommendationState>` when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for personalized recommendations state management
///
/// This provider manages the state of personalized destination recommendations including:
/// - Recommendation data with match scores and reasons
/// - Loading and error states
/// - Expiration checking and auto-refresh
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
///
/// Usage:
/// ```dart
/// final recommendationState = ref.watch(recommendationProvider(userId));
/// final recommendationNotifier = ref.read(recommendationProvider(userId).notifier);
///
/// // Load recommendations (automatically called on first watch)
/// // The userId is passed as a parameter to the provider
///
/// // Refresh recommendations
/// await recommendationNotifier.refresh();
///
/// // Clear recommendations
/// recommendationNotifier.clear();
/// ```
///
/// The [userId] parameter is the user ID to load recommendations for.
final class RecommendationProvider
    extends $AsyncNotifierProvider<Recommendation, RecommendationState> {
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from `StateNotifier<AsyncValue<T>>` to `AsyncNotifier<T>`
  /// - Dependencies injected via ref.watch() in build() method
  /// - Family provider with userId parameter in build()
  /// - AutoDispose enabled via @Riverpod annotation
  /// - build() returns `Future<T>` not `AsyncValue<T>`
  /// - State is automatically `AsyncValue<RecommendationState>` when consumed
  /// - Constructor auto-load logic moved to build() method
  ///
  /// Provider for personalized recommendations state management
  ///
  /// This provider manages the state of personalized destination recommendations including:
  /// - Recommendation data with match scores and reasons
  /// - Loading and error states
  /// - Expiration checking and auto-refresh
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
  /// Auto-dispose behavior for family provider.
  ///
  /// Usage:
  /// ```dart
  /// final recommendationState = ref.watch(recommendationProvider(userId));
  /// final recommendationNotifier = ref.read(recommendationProvider(userId).notifier);
  ///
  /// // Load recommendations (automatically called on first watch)
  /// // The userId is passed as a parameter to the provider
  ///
  /// // Refresh recommendations
  /// await recommendationNotifier.refresh();
  ///
  /// // Clear recommendations
  /// recommendationNotifier.clear();
  /// ```
  ///
  /// The [userId] parameter is the user ID to load recommendations for.
  const RecommendationProvider._(
      {required RecommendationFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'recommendationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recommendationHash();

  @override
  String toString() {
    return r'recommendationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Recommendation create() => Recommendation();

  @override
  bool operator ==(Object other) {
    return other is RecommendationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recommendationHash() => r'2cd1f5501c15671c922470636d23ca56a362c17a';

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<T>>` to `AsyncNotifier<T>`
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns `Future<T>` not `AsyncValue<T>`
/// - State is automatically `AsyncValue<RecommendationState>` when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for personalized recommendations state management
///
/// This provider manages the state of personalized destination recommendations including:
/// - Recommendation data with match scores and reasons
/// - Loading and error states
/// - Expiration checking and auto-refresh
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
///
/// Usage:
/// ```dart
/// final recommendationState = ref.watch(recommendationProvider(userId));
/// final recommendationNotifier = ref.read(recommendationProvider(userId).notifier);
///
/// // Load recommendations (automatically called on first watch)
/// // The userId is passed as a parameter to the provider
///
/// // Refresh recommendations
/// await recommendationNotifier.refresh();
///
/// // Clear recommendations
/// recommendationNotifier.clear();
/// ```
///
/// The [userId] parameter is the user ID to load recommendations for.

final class RecommendationFamily extends $Family
    with
        $ClassFamilyOverride<Recommendation, AsyncValue<RecommendationState>,
            RecommendationState, FutureOr<RecommendationState>, String> {
  const RecommendationFamily._()
      : super(
          retry: null,
          name: r'recommendationProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Riverpod 3.0 Migration Notes:
  /// - Converted from `StateNotifier<AsyncValue<T>>` to `AsyncNotifier<T>`
  /// - Dependencies injected via ref.watch() in build() method
  /// - Family provider with userId parameter in build()
  /// - AutoDispose enabled via @Riverpod annotation
  /// - build() returns `Future<T>` not `AsyncValue<T>`
  /// - State is automatically `AsyncValue<RecommendationState>` when consumed
  /// - Constructor auto-load logic moved to build() method
  ///
  /// Provider for personalized recommendations state management
  ///
  /// This provider manages the state of personalized destination recommendations including:
  /// - Recommendation data with match scores and reasons
  /// - Loading and error states
  /// - Expiration checking and auto-refresh
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
  /// Auto-dispose behavior for family provider.
  ///
  /// Usage:
  /// ```dart
  /// final recommendationState = ref.watch(recommendationProvider(userId));
  /// final recommendationNotifier = ref.read(recommendationProvider(userId).notifier);
  ///
  /// // Load recommendations (automatically called on first watch)
  /// // The userId is passed as a parameter to the provider
  ///
  /// // Refresh recommendations
  /// await recommendationNotifier.refresh();
  ///
  /// // Clear recommendations
  /// recommendationNotifier.clear();
  /// ```
  ///
  /// The [userId] parameter is the user ID to load recommendations for.

  RecommendationProvider call(
    String userId,
  ) =>
      RecommendationProvider._(argument: userId, from: this);

  @override
  String toString() => r'recommendationProvider';
}

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<T>>` to `AsyncNotifier<T>`
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns `Future<T>` not `AsyncValue<T>`
/// - State is automatically `AsyncValue<RecommendationState>` when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for personalized recommendations state management
///
/// This provider manages the state of personalized destination recommendations including:
/// - Recommendation data with match scores and reasons
/// - Loading and error states
/// - Expiration checking and auto-refresh
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
///
/// Usage:
/// ```dart
/// final recommendationState = ref.watch(recommendationProvider(userId));
/// final recommendationNotifier = ref.read(recommendationProvider(userId).notifier);
///
/// // Load recommendations (automatically called on first watch)
/// // The userId is passed as a parameter to the provider
///
/// // Refresh recommendations
/// await recommendationNotifier.refresh();
///
/// // Clear recommendations
/// recommendationNotifier.clear();
/// ```
///
/// The [userId] parameter is the user ID to load recommendations for.

abstract class _$Recommendation extends $AsyncNotifier<RecommendationState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<RecommendationState> build(
    String userId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref =
        this.ref as $Ref<AsyncValue<RecommendationState>, RecommendationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<RecommendationState>, RecommendationState>,
        AsyncValue<RecommendationState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
