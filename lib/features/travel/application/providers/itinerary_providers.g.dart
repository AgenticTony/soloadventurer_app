// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for ItineraryNotifier - manages itinerary state
///
/// Use this provider to watch itinerary state and perform actions.
///
/// Example:
/// dart
/// // Watch the state
/// final state = ref.watch(itineraryNotifierProvider('itinerary-'));
///
/// // Perform actions
/// ref.read(itineraryNotifierProvider('itinerary-').notifier)
///     .toggleItemCompletion('item-');
///

@ProviderFor(ItineraryNotifier)
const itineraryProvider = ItineraryNotifierFamily._();

/// Provider for ItineraryNotifier - manages itinerary state
///
/// Use this provider to watch itinerary state and perform actions.
///
/// Example:
/// dart
/// // Watch the state
/// final state = ref.watch(itineraryNotifierProvider('itinerary-'));
///
/// // Perform actions
/// ref.read(itineraryNotifierProvider('itinerary-').notifier)
///     .toggleItemCompletion('item-');
///
final class ItineraryNotifierProvider
    extends $AsyncNotifierProvider<ItineraryNotifier, Itinerary> {
  /// Provider for ItineraryNotifier - manages itinerary state
  ///
  /// Use this provider to watch itinerary state and perform actions.
  ///
  /// Example:
  /// dart
  /// // Watch the state
  /// final state = ref.watch(itineraryNotifierProvider('itinerary-'));
  ///
  /// // Perform actions
  /// ref.read(itineraryNotifierProvider('itinerary-').notifier)
  ///     .toggleItemCompletion('item-');
  ///
  const ItineraryNotifierProvider._(
      {required ItineraryNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'itineraryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryNotifierHash();

  @override
  String toString() {
    return r'itineraryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ItineraryNotifier create() => ItineraryNotifier();

  @override
  bool operator ==(Object other) {
    return other is ItineraryNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itineraryNotifierHash() => r'caff6253c205288079ce9ed274fb7c484f35a13f';

/// Provider for ItineraryNotifier - manages itinerary state
///
/// Use this provider to watch itinerary state and perform actions.
///
/// Example:
/// dart
/// // Watch the state
/// final state = ref.watch(itineraryNotifierProvider('itinerary-'));
///
/// // Perform actions
/// ref.read(itineraryNotifierProvider('itinerary-').notifier)
///     .toggleItemCompletion('item-');
///

final class ItineraryNotifierFamily extends $Family
    with
        $ClassFamilyOverride<ItineraryNotifier, AsyncValue<Itinerary>,
            Itinerary, FutureOr<Itinerary>, String> {
  const ItineraryNotifierFamily._()
      : super(
          retry: null,
          name: r'itineraryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for ItineraryNotifier - manages itinerary state
  ///
  /// Use this provider to watch itinerary state and perform actions.
  ///
  /// Example:
  /// dart
  /// // Watch the state
  /// final state = ref.watch(itineraryNotifierProvider('itinerary-'));
  ///
  /// // Perform actions
  /// ref.read(itineraryNotifierProvider('itinerary-').notifier)
  ///     .toggleItemCompletion('item-');
  ///

  ItineraryNotifierProvider call(
    String itineraryId,
  ) =>
      ItineraryNotifierProvider._(argument: itineraryId, from: this);

  @override
  String toString() => r'itineraryProvider';
}

/// Provider for ItineraryNotifier - manages itinerary state
///
/// Use this provider to watch itinerary state and perform actions.
///
/// Example:
/// dart
/// // Watch the state
/// final state = ref.watch(itineraryNotifierProvider('itinerary-'));
///
/// // Perform actions
/// ref.read(itineraryNotifierProvider('itinerary-').notifier)
///     .toggleItemCompletion('item-');
///

abstract class _$ItineraryNotifier extends $AsyncNotifier<Itinerary> {
  late final _$args = ref.$arg as String;
  String get itineraryId => _$args;

  FutureOr<Itinerary> build(
    String itineraryId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<AsyncValue<Itinerary>, Itinerary>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Itinerary>, Itinerary>,
        AsyncValue<Itinerary>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider for watching all itineraries
///
/// Example:
/// dart
/// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
///

@ProviderFor(itineraries)
const itinerariesProvider = ItinerariesFamily._();

/// Provider for watching all itineraries
///
/// Example:
/// dart
/// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
///

final class ItinerariesProvider extends $FunctionalProvider<
        AsyncValue<List<ItineraryListState>>,
        List<ItineraryListState>,
        FutureOr<List<ItineraryListState>>>
    with
        $FutureModifier<List<ItineraryListState>>,
        $FutureProvider<List<ItineraryListState>> {
  /// Provider for watching all itineraries
  ///
  /// Example:
  /// dart
  /// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
  ///
  const ItinerariesProvider._(
      {required ItinerariesFamily super.from, required String? super.argument})
      : super(
          retry: null,
          name: r'itinerariesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itinerariesHash();

  @override
  String toString() {
    return r'itinerariesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ItineraryListState>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ItineraryListState>> create(Ref ref) {
    final argument = this.argument as String?;
    return itineraries(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItinerariesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itinerariesHash() => r'42f718cf502d290192c096df1c99cbcf8f9206ba';

/// Provider for watching all itineraries
///
/// Example:
/// dart
/// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
///

final class ItinerariesFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<ItineraryListState>>, String?> {
  const ItinerariesFamily._()
      : super(
          retry: null,
          name: r'itinerariesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for watching all itineraries
  ///
  /// Example:
  /// dart
  /// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
  ///

  ItinerariesProvider call(
    String? userId,
  ) =>
      ItinerariesProvider._(argument: userId, from: this);

  @override
  String toString() => r'itinerariesProvider';
}
