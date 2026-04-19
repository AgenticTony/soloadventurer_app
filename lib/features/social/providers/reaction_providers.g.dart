// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reactionRemoteDataSource)
const reactionRemoteDataSourceProvider = ReactionRemoteDataSourceProvider._();

final class ReactionRemoteDataSourceProvider extends $FunctionalProvider<
    ReactionRemoteDataSource,
    ReactionRemoteDataSource,
    ReactionRemoteDataSource> with $Provider<ReactionRemoteDataSource> {
  const ReactionRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reactionRemoteDataSourceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reactionRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ReactionRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReactionRemoteDataSource create(Ref ref) {
    return reactionRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReactionRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReactionRemoteDataSource>(value),
    );
  }
}

String _$reactionRemoteDataSourceHash() =>
    r'787f2b8ad9415599c9a7dbab8ceffc8ca491111b';

@ProviderFor(reactionRepository)
const reactionRepositoryProvider = ReactionRepositoryProvider._();

final class ReactionRepositoryProvider extends $FunctionalProvider<
    ReactionRepository,
    ReactionRepository,
    ReactionRepository> with $Provider<ReactionRepository> {
  const ReactionRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reactionRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReactionRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReactionRepository create(Ref ref) {
    return reactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReactionRepository>(value),
    );
  }
}

String _$reactionRepositoryHash() =>
    r'0df542b0704ff81cbd20e1b2454a1d12ec0e92f1';

@ProviderFor(toggleReactionUseCase)
const toggleReactionUseCaseProvider = ToggleReactionUseCaseProvider._();

final class ToggleReactionUseCaseProvider extends $FunctionalProvider<
    ToggleReactionUseCase,
    ToggleReactionUseCase,
    ToggleReactionUseCase> with $Provider<ToggleReactionUseCase> {
  const ToggleReactionUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'toggleReactionUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$toggleReactionUseCaseHash();

  @$internal
  @override
  $ProviderElement<ToggleReactionUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ToggleReactionUseCase create(Ref ref) {
    return toggleReactionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToggleReactionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToggleReactionUseCase>(value),
    );
  }
}

String _$toggleReactionUseCaseHash() =>
    r'bddd4dde4d38ef6094a907a7cdc2ee19ac8fca53';

@ProviderFor(getReactionsUseCase)
const getReactionsUseCaseProvider = GetReactionsUseCaseProvider._();

final class GetReactionsUseCaseProvider extends $FunctionalProvider<
    GetReactionsUseCase,
    GetReactionsUseCase,
    GetReactionsUseCase> with $Provider<GetReactionsUseCase> {
  const GetReactionsUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getReactionsUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getReactionsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetReactionsUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetReactionsUseCase create(Ref ref) {
    return getReactionsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetReactionsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetReactionsUseCase>(value),
    );
  }
}

String _$getReactionsUseCaseHash() =>
    r'cc0f9a1f75a25aefa7876321d1eee51cbe607562';

@ProviderFor(ReactionSummaryNotifier)
const reactionSummaryProvider = ReactionSummaryNotifierFamily._();

final class ReactionSummaryNotifierProvider
    extends $AsyncNotifierProvider<ReactionSummaryNotifier, ReactionSummary> {
  const ReactionSummaryNotifierProvider._(
      {required ReactionSummaryNotifierFamily super.from,
      required (
        String,
        ReactionTargetType,
      )
          super.argument})
      : super(
          retry: null,
          name: r'reactionSummaryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reactionSummaryNotifierHash();

  @override
  String toString() {
    return r'reactionSummaryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ReactionSummaryNotifier create() => ReactionSummaryNotifier();

  @override
  bool operator ==(Object other) {
    return other is ReactionSummaryNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reactionSummaryNotifierHash() =>
    r'5c71948be170f816162c8f840e6964d85cd602b7';

final class ReactionSummaryNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            ReactionSummaryNotifier,
            AsyncValue<ReactionSummary>,
            ReactionSummary,
            FutureOr<ReactionSummary>,
            (
              String,
              ReactionTargetType,
            )> {
  const ReactionSummaryNotifierFamily._()
      : super(
          retry: null,
          name: r'reactionSummaryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ReactionSummaryNotifierProvider call(
    String targetId,
    ReactionTargetType targetType,
  ) =>
      ReactionSummaryNotifierProvider._(argument: (
        targetId,
        targetType,
      ), from: this);

  @override
  String toString() => r'reactionSummaryProvider';
}

abstract class _$ReactionSummaryNotifier
    extends $AsyncNotifier<ReactionSummary> {
  late final _$args = ref.$arg as (
    String,
    ReactionTargetType,
  );
  String get targetId => _$args.$1;
  ReactionTargetType get targetType => _$args.$2;

  FutureOr<ReactionSummary> build(
    String targetId,
    ReactionTargetType targetType,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args.$1,
      _$args.$2,
    );
    final ref = this.ref as $Ref<AsyncValue<ReactionSummary>, ReactionSummary>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ReactionSummary>, ReactionSummary>,
        AsyncValue<ReactionSummary>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
