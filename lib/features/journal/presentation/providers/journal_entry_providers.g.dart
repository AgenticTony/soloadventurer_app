// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing journal entry creation state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(JournalEntryCreation)
const journalEntryCreationProvider = JournalEntryCreationProvider._();

/// Notifier for managing journal entry creation state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class JournalEntryCreationProvider
    extends $NotifierProvider<JournalEntryCreation, JournalEntryCreationState> {
  /// Notifier for managing journal entry creation state
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  const JournalEntryCreationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalEntryCreationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalEntryCreationHash();

  @$internal
  @override
  JournalEntryCreation create() => JournalEntryCreation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalEntryCreationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalEntryCreationState>(value),
    );
  }
}

String _$journalEntryCreationHash() =>
    r'bb0b0783e848bf67f4ac84511cf320875d68067a';

/// Notifier for managing journal entry creation state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$JournalEntryCreation
    extends $Notifier<JournalEntryCreationState> {
  JournalEntryCreationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<JournalEntryCreationState, JournalEntryCreationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<JournalEntryCreationState, JournalEntryCreationState>,
        JournalEntryCreationState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider for Journal Repository
/// This should be overridden in the DI layer to provide the actual implementation

@ProviderFor(journalRepository)
const journalRepositoryProvider = JournalRepositoryProvider._();

/// Provider for Journal Repository
/// This should be overridden in the DI layer to provide the actual implementation

final class JournalRepositoryProvider extends $FunctionalProvider<
    JournalRepository,
    JournalRepository,
    JournalRepository> with $Provider<JournalRepository> {
  /// Provider for Journal Repository
  /// This should be overridden in the DI layer to provide the actual implementation
  const JournalRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalRepositoryHash();

  @$internal
  @override
  $ProviderElement<JournalRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JournalRepository create(Ref ref) {
    return journalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalRepository>(value),
    );
  }
}

String _$journalRepositoryHash() => r'1b421ae1bc677dc4c875687c7aef757180446e2f';

/// Provider for save button state

@ProviderFor(journalEntrySaveButton)
const journalEntrySaveButtonProvider = JournalEntrySaveButtonProvider._();

/// Provider for save button state

final class JournalEntrySaveButtonProvider extends $FunctionalProvider<
    SaveButtonState,
    SaveButtonState,
    SaveButtonState> with $Provider<SaveButtonState> {
  /// Provider for save button state
  const JournalEntrySaveButtonProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalEntrySaveButtonProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalEntrySaveButtonHash();

  @$internal
  @override
  $ProviderElement<SaveButtonState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaveButtonState create(Ref ref) {
    return journalEntrySaveButton(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveButtonState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveButtonState>(value),
    );
  }
}

String _$journalEntrySaveButtonHash() =>
    r'4001dcdc9915252a73d6e187ad986b3e974d9046';
