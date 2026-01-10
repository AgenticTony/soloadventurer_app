// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itinerariesHash() => r'42f718cf502d290192c096df1c99cbcf8f9206ba';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for watching all itineraries
///
/// Example:
/// dart
/// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
///
///
/// Copied from [itineraries].
@ProviderFor(itineraries)
const itinerariesProvider = ItinerariesFamily();

/// Provider for watching all itineraries
///
/// Example:
/// dart
/// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
///
///
/// Copied from [itineraries].
class ItinerariesFamily extends Family<AsyncValue<List<ItineraryListState>>> {
  /// Provider for watching all itineraries
  ///
  /// Example:
  /// dart
  /// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
  ///
  ///
  /// Copied from [itineraries].
  const ItinerariesFamily();

  /// Provider for watching all itineraries
  ///
  /// Example:
  /// dart
  /// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
  ///
  ///
  /// Copied from [itineraries].
  ItinerariesProvider call(
    String? userId,
  ) {
    return ItinerariesProvider(
      userId,
    );
  }

  @override
  ItinerariesProvider getProviderOverride(
    covariant ItinerariesProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itinerariesProvider';
}

/// Provider for watching all itineraries
///
/// Example:
/// dart
/// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
///
///
/// Copied from [itineraries].
class ItinerariesProvider
    extends AutoDisposeFutureProvider<List<ItineraryListState>> {
  /// Provider for watching all itineraries
  ///
  /// Example:
  /// dart
  /// final itinerariesAsync = ref.watch(itinerariesProvider(userId: 'user-'));
  ///
  ///
  /// Copied from [itineraries].
  ItinerariesProvider(
    String? userId,
  ) : this._internal(
          (ref) => itineraries(
            ref as ItinerariesRef,
            userId,
          ),
          from: itinerariesProvider,
          name: r'itinerariesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itinerariesHash,
          dependencies: ItinerariesFamily._dependencies,
          allTransitiveDependencies:
              ItinerariesFamily._allTransitiveDependencies,
          userId: userId,
        );

  ItinerariesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String? userId;

  @override
  Override overrideWith(
    FutureOr<List<ItineraryListState>> Function(ItinerariesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItinerariesProvider._internal(
        (ref) => create(ref as ItinerariesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ItineraryListState>> createElement() {
    return _ItinerariesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItinerariesProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItinerariesRef on AutoDisposeFutureProviderRef<List<ItineraryListState>> {
  /// The parameter `userId` of this provider.
  String? get userId;
}

class _ItinerariesProviderElement
    extends AutoDisposeFutureProviderElement<List<ItineraryListState>>
    with ItinerariesRef {
  _ItinerariesProviderElement(super.provider);

  @override
  String? get userId => (origin as ItinerariesProvider).userId;
}

String _$itineraryNotifierHash() => r'caff6253c205288079ce9ed274fb7c484f35a13f';

abstract class _$ItineraryNotifier
    extends BuildlessAutoDisposeAsyncNotifier<Itinerary> {
  late final String itineraryId;

  FutureOr<Itinerary> build(
    String itineraryId,
  );
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
///
/// Copied from [ItineraryNotifier].
@ProviderFor(ItineraryNotifier)
const itineraryNotifierProvider = ItineraryNotifierFamily();

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
///
/// Copied from [ItineraryNotifier].
class ItineraryNotifierFamily extends Family<AsyncValue<Itinerary>> {
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
  ///
  /// Copied from [ItineraryNotifier].
  const ItineraryNotifierFamily();

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
  ///
  /// Copied from [ItineraryNotifier].
  ItineraryNotifierProvider call(
    String itineraryId,
  ) {
    return ItineraryNotifierProvider(
      itineraryId,
    );
  }

  @override
  ItineraryNotifierProvider getProviderOverride(
    covariant ItineraryNotifierProvider provider,
  ) {
    return call(
      provider.itineraryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itineraryNotifierProvider';
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
///
/// Copied from [ItineraryNotifier].
class ItineraryNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ItineraryNotifier, Itinerary> {
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
  ///
  /// Copied from [ItineraryNotifier].
  ItineraryNotifierProvider(
    String itineraryId,
  ) : this._internal(
          () => ItineraryNotifier()..itineraryId = itineraryId,
          from: itineraryNotifierProvider,
          name: r'itineraryNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itineraryNotifierHash,
          dependencies: ItineraryNotifierFamily._dependencies,
          allTransitiveDependencies:
              ItineraryNotifierFamily._allTransitiveDependencies,
          itineraryId: itineraryId,
        );

  ItineraryNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itineraryId,
  }) : super.internal();

  final String itineraryId;

  @override
  FutureOr<Itinerary> runNotifierBuild(
    covariant ItineraryNotifier notifier,
  ) {
    return notifier.build(
      itineraryId,
    );
  }

  @override
  Override overrideWith(ItineraryNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItineraryNotifierProvider._internal(
        () => create()..itineraryId = itineraryId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itineraryId: itineraryId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ItineraryNotifier, Itinerary>
      createElement() {
    return _ItineraryNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItineraryNotifierProvider &&
        other.itineraryId == itineraryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itineraryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItineraryNotifierRef on AutoDisposeAsyncNotifierProviderRef<Itinerary> {
  /// The parameter `itineraryId` of this provider.
  String get itineraryId;
}

class _ItineraryNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ItineraryNotifier,
        Itinerary> with ItineraryNotifierRef {
  _ItineraryNotifierProviderElement(super.provider);

  @override
  String get itineraryId => (origin as ItineraryNotifierProvider).itineraryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
