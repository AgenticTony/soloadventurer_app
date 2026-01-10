// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_link_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SharedLinkService

@ProviderFor(sharedLinkService)
final sharedLinkServiceProvider = SharedLinkServiceProvider._();

/// Provider for SharedLinkService

final class SharedLinkServiceProvider extends $FunctionalProvider<
    SharedLinkService,
    SharedLinkService,
    SharedLinkService> with $Provider<SharedLinkService> {
  /// Provider for SharedLinkService
  SharedLinkServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedLinkServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedLinkServiceHash();

  @$internal
  @override
  $ProviderElement<SharedLinkService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharedLinkService create(Ref ref) {
    return sharedLinkService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedLinkService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedLinkService>(value),
    );
  }
}

String _$sharedLinkServiceHash() => r'241bc04c9bb4b792e69767c5cb55a3832f076740';

/// Notifier for managing shared links
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(SharedLinks)
final sharedLinksProvider = SharedLinksProvider._();

/// Notifier for managing shared links
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class SharedLinksProvider
    extends $NotifierProvider<SharedLinks, SharedLinkState> {
  /// Notifier for managing shared links
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  SharedLinksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedLinksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedLinksHash();

  @$internal
  @override
  SharedLinks create() => SharedLinks();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedLinkState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedLinkState>(value),
    );
  }
}

String _$sharedLinksHash() => r'bc705d7d738190b28297a91127ecdde6e36b756f';

/// Notifier for managing shared links
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$SharedLinks extends $Notifier<SharedLinkState> {
  SharedLinkState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SharedLinkState, SharedLinkState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SharedLinkState, SharedLinkState>,
        SharedLinkState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Notifier for creating shared links
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(CreateSharedLink)
final createSharedLinkProvider = CreateSharedLinkProvider._();

/// Notifier for creating shared links
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class CreateSharedLinkProvider
    extends $NotifierProvider<CreateSharedLink, CreateSharedLinkState> {
  /// Notifier for creating shared links
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  CreateSharedLinkProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createSharedLinkProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createSharedLinkHash();

  @$internal
  @override
  CreateSharedLink create() => CreateSharedLink();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateSharedLinkState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateSharedLinkState>(value),
    );
  }
}

String _$createSharedLinkHash() => r'7263f830dd934ea954852816f7444a6deb6e3e88';

/// Notifier for creating shared links
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$CreateSharedLink extends $Notifier<CreateSharedLinkState> {
  CreateSharedLinkState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CreateSharedLinkState, CreateSharedLinkState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CreateSharedLinkState, CreateSharedLinkState>,
        CreateSharedLinkState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Notifier for validating shared link access
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(ValidateLink)
final validateLinkProvider = ValidateLinkProvider._();

/// Notifier for validating shared link access
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class ValidateLinkProvider
    extends $NotifierProvider<ValidateLink, ValidateLinkState> {
  /// Notifier for validating shared link access
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  ValidateLinkProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'validateLinkProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$validateLinkHash();

  @$internal
  @override
  ValidateLink create() => ValidateLink();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ValidateLinkState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ValidateLinkState>(value),
    );
  }
}

String _$validateLinkHash() => r'37a78412309acc7c6df6640a56e03b722aafbbbf';

/// Notifier for validating shared link access
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$ValidateLink extends $Notifier<ValidateLinkState> {
  ValidateLinkState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ValidateLinkState, ValidateLinkState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ValidateLinkState, ValidateLinkState>,
        ValidateLinkState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for shared links for a specific trip

@ProviderFor(tripSharedLinks)
final tripSharedLinksProvider = TripSharedLinksFamily._();

/// Provider for shared links for a specific trip

final class TripSharedLinksProvider extends $FunctionalProvider<
        AsyncValue<List<SharedLink>>,
        List<SharedLink>,
        FutureOr<List<SharedLink>>>
    with $FutureModifier<List<SharedLink>>, $FutureProvider<List<SharedLink>> {
  /// Provider for shared links for a specific trip
  TripSharedLinksProvider._(
      {required TripSharedLinksFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'tripSharedLinksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripSharedLinksHash();

  @override
  String toString() {
    return r'tripSharedLinksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SharedLink>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<SharedLink>> create(Ref ref) {
    final argument = this.argument as String;
    return tripSharedLinks(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripSharedLinksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripSharedLinksHash() => r'1b3354b9d5144c60ee3a8c306e68d71fdb48f51f';

/// Provider for shared links for a specific trip

final class TripSharedLinksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SharedLink>>, String> {
  TripSharedLinksFamily._()
      : super(
          retry: null,
          name: r'tripSharedLinksProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for shared links for a specific trip

  TripSharedLinksProvider call(
    String tripId,
  ) =>
      TripSharedLinksProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripSharedLinksProvider';
}

/// Provider for a single shared link by ID

@ProviderFor(sharedLink)
final sharedLinkProvider = SharedLinkFamily._();

/// Provider for a single shared link by ID

final class SharedLinkProvider extends $FunctionalProvider<
        AsyncValue<SharedLink?>, SharedLink?, FutureOr<SharedLink?>>
    with $FutureModifier<SharedLink?>, $FutureProvider<SharedLink?> {
  /// Provider for a single shared link by ID
  SharedLinkProvider._(
      {required SharedLinkFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'sharedLinkProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedLinkHash();

  @override
  String toString() {
    return r'sharedLinkProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SharedLink?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedLink?> create(Ref ref) {
    final argument = this.argument as String;
    return sharedLink(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SharedLinkProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sharedLinkHash() => r'fb1dacb0239272e29450ca2f26d34749f142c702';

/// Provider for a single shared link by ID

final class SharedLinkFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SharedLink?>, String> {
  SharedLinkFamily._()
      : super(
          retry: null,
          name: r'sharedLinkProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a single shared link by ID

  SharedLinkProvider call(
    String linkId,
  ) =>
      SharedLinkProvider._(argument: linkId, from: this);

  @override
  String toString() => r'sharedLinkProvider';
}

/// Provider for a shared link by slug

@ProviderFor(sharedLinkBySlug)
final sharedLinkBySlugProvider = SharedLinkBySlugFamily._();

/// Provider for a shared link by slug

final class SharedLinkBySlugProvider extends $FunctionalProvider<
        AsyncValue<SharedLink?>, SharedLink?, FutureOr<SharedLink?>>
    with $FutureModifier<SharedLink?>, $FutureProvider<SharedLink?> {
  /// Provider for a shared link by slug
  SharedLinkBySlugProvider._(
      {required SharedLinkBySlugFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'sharedLinkBySlugProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedLinkBySlugHash();

  @override
  String toString() {
    return r'sharedLinkBySlugProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SharedLink?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedLink?> create(Ref ref) {
    final argument = this.argument as String;
    return sharedLinkBySlug(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SharedLinkBySlugProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sharedLinkBySlugHash() => r'd9c36426a646ec2435b3da748cc9959cd43cebeb';

/// Provider for a shared link by slug

final class SharedLinkBySlugFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SharedLink?>, String> {
  SharedLinkBySlugFamily._()
      : super(
          retry: null,
          name: r'sharedLinkBySlugProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a shared link by slug

  SharedLinkBySlugProvider call(
    String slug,
  ) =>
      SharedLinkBySlugProvider._(argument: slug, from: this);

  @override
  String toString() => r'sharedLinkBySlugProvider';
}

/// Provider for shared link statistics

@ProviderFor(sharedLinkStatistics)
final sharedLinkStatisticsProvider = SharedLinkStatisticsFamily._();

/// Provider for shared link statistics

final class SharedLinkStatisticsProvider extends $FunctionalProvider<
        AsyncValue<SharedLinkStatistics>,
        SharedLinkStatistics,
        FutureOr<SharedLinkStatistics>>
    with
        $FutureModifier<SharedLinkStatistics>,
        $FutureProvider<SharedLinkStatistics> {
  /// Provider for shared link statistics
  SharedLinkStatisticsProvider._(
      {required SharedLinkStatisticsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'sharedLinkStatisticsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedLinkStatisticsHash();

  @override
  String toString() {
    return r'sharedLinkStatisticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SharedLinkStatistics> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedLinkStatistics> create(Ref ref) {
    final argument = this.argument as String;
    return sharedLinkStatistics(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SharedLinkStatisticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sharedLinkStatisticsHash() =>
    r'063584397ba2898c42646ad2cc5cfc4e0492d8ed';

/// Provider for shared link statistics

final class SharedLinkStatisticsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SharedLinkStatistics>, String> {
  SharedLinkStatisticsFamily._()
      : super(
          retry: null,
          name: r'sharedLinkStatisticsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for shared link statistics

  SharedLinkStatisticsProvider call(
    String linkId,
  ) =>
      SharedLinkStatisticsProvider._(argument: linkId, from: this);

  @override
  String toString() => r'sharedLinkStatisticsProvider';
}

/// Provider for active shared links only

@ProviderFor(activeSharedLinks)
final activeSharedLinksProvider = ActiveSharedLinksProvider._();

/// Provider for active shared links only

final class ActiveSharedLinksProvider extends $FunctionalProvider<
    List<SharedLink>,
    List<SharedLink>,
    List<SharedLink>> with $Provider<List<SharedLink>> {
  /// Provider for active shared links only
  ActiveSharedLinksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeSharedLinksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeSharedLinksHash();

  @$internal
  @override
  $ProviderElement<List<SharedLink>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<SharedLink> create(Ref ref) {
    return activeSharedLinks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SharedLink> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SharedLink>>(value),
    );
  }
}

String _$activeSharedLinksHash() => r'5b5b12d0204b7aa9184cb3a8c516b5c63299ebd7';

/// Provider for expired shared links

@ProviderFor(expiredSharedLinks)
final expiredSharedLinksProvider = ExpiredSharedLinksProvider._();

/// Provider for expired shared links

final class ExpiredSharedLinksProvider extends $FunctionalProvider<
    List<SharedLink>,
    List<SharedLink>,
    List<SharedLink>> with $Provider<List<SharedLink>> {
  /// Provider for expired shared links
  ExpiredSharedLinksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expiredSharedLinksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expiredSharedLinksHash();

  @$internal
  @override
  $ProviderElement<List<SharedLink>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<SharedLink> create(Ref ref) {
    return expiredSharedLinks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SharedLink> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SharedLink>>(value),
    );
  }
}

String _$expiredSharedLinksHash() =>
    r'2962f768ca6dfd53fa2793e7d5f4176c42fc4aca';

/// Provider for password-protected links

@ProviderFor(protectedSharedLinks)
final protectedSharedLinksProvider = ProtectedSharedLinksProvider._();

/// Provider for password-protected links

final class ProtectedSharedLinksProvider extends $FunctionalProvider<
    List<SharedLink>,
    List<SharedLink>,
    List<SharedLink>> with $Provider<List<SharedLink>> {
  /// Provider for password-protected links
  ProtectedSharedLinksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'protectedSharedLinksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$protectedSharedLinksHash();

  @$internal
  @override
  $ProviderElement<List<SharedLink>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<SharedLink> create(Ref ref) {
    return protectedSharedLinks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SharedLink> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SharedLink>>(value),
    );
  }
}

String _$protectedSharedLinksHash() =>
    r'b4ab42372eb00c89b2ffbe2fadd915207ed9554e';

/// Provider for public (no password) links

@ProviderFor(publicSharedLinks)
final publicSharedLinksProvider = PublicSharedLinksProvider._();

/// Provider for public (no password) links

final class PublicSharedLinksProvider extends $FunctionalProvider<
    List<SharedLink>,
    List<SharedLink>,
    List<SharedLink>> with $Provider<List<SharedLink>> {
  /// Provider for public (no password) links
  PublicSharedLinksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'publicSharedLinksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$publicSharedLinksHash();

  @$internal
  @override
  $ProviderElement<List<SharedLink>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<SharedLink> create(Ref ref) {
    return publicSharedLinks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SharedLink> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SharedLink>>(value),
    );
  }
}

String _$publicSharedLinksHash() => r'5c8e0125e5a3eeb0b2d0fd3f75cbc35933a3047d';

/// Provider for shared links count

@ProviderFor(sharedLinksCount)
final sharedLinksCountProvider = SharedLinksCountProvider._();

/// Provider for shared links count

final class SharedLinksCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider for shared links count
  SharedLinksCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedLinksCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedLinksCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return sharedLinksCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sharedLinksCountHash() => r'3c91aa12c8d0585f84f1b2c20898a64a7da54460';

/// Provider for active links count

@ProviderFor(activeLinksCount)
final activeLinksCountProvider = ActiveLinksCountProvider._();

/// Provider for active links count

final class ActiveLinksCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider for active links count
  ActiveLinksCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeLinksCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeLinksCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return activeLinksCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$activeLinksCountHash() => r'eb46e078c128d11fc9d40312abe931bd19ce6481';
