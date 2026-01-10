// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing journal entry detail state
/// MIGRATION: StateNotifier → Notifier pattern with family parameter
/// - entryId is passed as a parameter to the build() method (family provider)
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
/// Usage: ref.watch(journalEntryDetailProvider(entryId))

@ProviderFor(JournalEntryDetail)
final journalEntryDetailProvider = JournalEntryDetailFamily._();

/// Notifier for managing journal entry detail state
/// MIGRATION: StateNotifier → Notifier pattern with family parameter
/// - entryId is passed as a parameter to the build() method (family provider)
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
/// Usage: ref.watch(journalEntryDetailProvider(entryId))
final class JournalEntryDetailProvider
    extends $NotifierProvider<JournalEntryDetail, JournalEntryDetailState> {
  /// Notifier for managing journal entry detail state
  /// MIGRATION: StateNotifier → Notifier pattern with family parameter
  /// - entryId is passed as a parameter to the build() method (family provider)
  /// - Dependencies accessed via ref.watch() in methods
  /// - Automatic provider generation via @riverpod annotation
  /// Usage: ref.watch(journalEntryDetailProvider(entryId))
  JournalEntryDetailProvider._(
      {required JournalEntryDetailFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'journalEntryDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalEntryDetailHash();

  @override
  String toString() {
    return r'journalEntryDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  JournalEntryDetail create() => JournalEntryDetail();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalEntryDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalEntryDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JournalEntryDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$journalEntryDetailHash() =>
    r'30ff4a98bd4ec9e075a581fb6faf741c3e73d37b';

/// Notifier for managing journal entry detail state
/// MIGRATION: StateNotifier → Notifier pattern with family parameter
/// - entryId is passed as a parameter to the build() method (family provider)
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
/// Usage: ref.watch(journalEntryDetailProvider(entryId))

final class JournalEntryDetailFamily extends $Family
    with
        $ClassFamilyOverride<JournalEntryDetail, JournalEntryDetailState,
            JournalEntryDetailState, JournalEntryDetailState, String> {
  JournalEntryDetailFamily._()
      : super(
          retry: null,
          name: r'journalEntryDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Notifier for managing journal entry detail state
  /// MIGRATION: StateNotifier → Notifier pattern with family parameter
  /// - entryId is passed as a parameter to the build() method (family provider)
  /// - Dependencies accessed via ref.watch() in methods
  /// - Automatic provider generation via @riverpod annotation
  /// Usage: ref.watch(journalEntryDetailProvider(entryId))

  JournalEntryDetailProvider call(
    String entryId,
  ) =>
      JournalEntryDetailProvider._(argument: entryId, from: this);

  @override
  String toString() => r'journalEntryDetailProvider';
}

/// Notifier for managing journal entry detail state
/// MIGRATION: StateNotifier → Notifier pattern with family parameter
/// - entryId is passed as a parameter to the build() method (family provider)
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
/// Usage: ref.watch(journalEntryDetailProvider(entryId))

abstract class _$JournalEntryDetail extends $Notifier<JournalEntryDetailState> {
  late final _$args = ref.$arg as String;
  String get entryId => _$args;

  JournalEntryDetailState build(
    String entryId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<JournalEntryDetailState, JournalEntryDetailState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<JournalEntryDetailState, JournalEntryDetailState>,
        JournalEntryDetailState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
