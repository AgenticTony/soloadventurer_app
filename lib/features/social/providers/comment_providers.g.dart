// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(commentRemoteDataSource)
const commentRemoteDataSourceProvider = CommentRemoteDataSourceProvider._();

final class CommentRemoteDataSourceProvider extends $FunctionalProvider<
    CommentRemoteDataSource,
    CommentRemoteDataSource,
    CommentRemoteDataSource> with $Provider<CommentRemoteDataSource> {
  const CommentRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'commentRemoteDataSourceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<CommentRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CommentRemoteDataSource create(Ref ref) {
    return commentRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentRemoteDataSource>(value),
    );
  }
}

String _$commentRemoteDataSourceHash() =>
    r'9da5e4f56597ede647a8bdc84e5920a95bb2630e';

@ProviderFor(commentRepository)
const commentRepositoryProvider = CommentRepositoryProvider._();

final class CommentRepositoryProvider extends $FunctionalProvider<
    CommentRepository,
    CommentRepository,
    CommentRepository> with $Provider<CommentRepository> {
  const CommentRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'commentRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentRepositoryHash();

  @$internal
  @override
  $ProviderElement<CommentRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CommentRepository create(Ref ref) {
    return commentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentRepository>(value),
    );
  }
}

String _$commentRepositoryHash() => r'e1c9f4c4502d618aca1e66ed3793f9800c513e03';

@ProviderFor(getCommentsUseCase)
const getCommentsUseCaseProvider = GetCommentsUseCaseProvider._();

final class GetCommentsUseCaseProvider extends $FunctionalProvider<
    GetCommentsUseCase,
    GetCommentsUseCase,
    GetCommentsUseCase> with $Provider<GetCommentsUseCase> {
  const GetCommentsUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getCommentsUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getCommentsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCommentsUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetCommentsUseCase create(Ref ref) {
    return getCommentsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCommentsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCommentsUseCase>(value),
    );
  }
}

String _$getCommentsUseCaseHash() =>
    r'5a43ff775e7eaa471ab2acf8f7ec4ea5d00b39e8';

@ProviderFor(addCommentUseCase)
const addCommentUseCaseProvider = AddCommentUseCaseProvider._();

final class AddCommentUseCaseProvider extends $FunctionalProvider<
    AddCommentUseCase,
    AddCommentUseCase,
    AddCommentUseCase> with $Provider<AddCommentUseCase> {
  const AddCommentUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'addCommentUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addCommentUseCaseHash();

  @$internal
  @override
  $ProviderElement<AddCommentUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AddCommentUseCase create(Ref ref) {
    return addCommentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddCommentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddCommentUseCase>(value),
    );
  }
}

String _$addCommentUseCaseHash() => r'b097ebdc193f55a5d634feb17c79f24876224653';

@ProviderFor(deleteCommentUseCase)
const deleteCommentUseCaseProvider = DeleteCommentUseCaseProvider._();

final class DeleteCommentUseCaseProvider extends $FunctionalProvider<
    DeleteCommentUseCase,
    DeleteCommentUseCase,
    DeleteCommentUseCase> with $Provider<DeleteCommentUseCase> {
  const DeleteCommentUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deleteCommentUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deleteCommentUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteCommentUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteCommentUseCase create(Ref ref) {
    return deleteCommentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteCommentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteCommentUseCase>(value),
    );
  }
}

String _$deleteCommentUseCaseHash() =>
    r'f8781135e7a70321920ec1becac4fa1aaad057db';

@ProviderFor(CommentsNotifier)
const commentsProvider = CommentsNotifierFamily._();

final class CommentsNotifierProvider
    extends $AsyncNotifierProvider<CommentsNotifier, List<Comment>> {
  const CommentsNotifierProvider._(
      {required CommentsNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'commentsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentsNotifierHash();

  @override
  String toString() {
    return r'commentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommentsNotifier create() => CommentsNotifier();

  @override
  bool operator ==(Object other) {
    return other is CommentsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentsNotifierHash() => r'84be7979a5a5b59b514b169f73d98221430d595c';

final class CommentsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<CommentsNotifier, AsyncValue<List<Comment>>,
            List<Comment>, FutureOr<List<Comment>>, String> {
  const CommentsNotifierFamily._()
      : super(
          retry: null,
          name: r'commentsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CommentsNotifierProvider call(
    String journalId,
  ) =>
      CommentsNotifierProvider._(argument: journalId, from: this);

  @override
  String toString() => r'commentsProvider';
}

abstract class _$CommentsNotifier extends $AsyncNotifier<List<Comment>> {
  late final _$args = ref.$arg as String;
  String get journalId => _$args;

  FutureOr<List<Comment>> build(
    String journalId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<AsyncValue<List<Comment>>, List<Comment>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Comment>>, List<Comment>>,
        AsyncValue<List<Comment>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
