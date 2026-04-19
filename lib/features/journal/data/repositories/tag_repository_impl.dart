import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/tag_model.dart';
import 'package:soloadventurer/features/journal/domain/entities/tag.dart';
import 'package:soloadventurer/features/journal/domain/repositories/tag_repository.dart';

/// Implementation of [TagRepository]
class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource remoteDataSource;

  TagRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Tag>> createTag(Tag tag) async {
    try {
      final tagModel = TagModel.fromEntity(tag);
      final createdTag = await remoteDataSource.createTag(tagModel);
      return Right(createdTag.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tag>> getTag(String tagId) async {
    try {
      final tag = await remoteDataSource.getTag(tagId);
      return Right(tag.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> getTags() async {
    try {
      final tags = await remoteDataSource.getTags();
      return Right(tags.map((t) => t.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> getTagsForEntry(String entryId) async {
    try {
      final tags = await remoteDataSource.getTagsForEntry(entryId);
      return Right(tags.map((t) => t.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tag>> updateTag(Tag tag) async {
    try {
      final tagModel = TagModel.fromEntity(tag);
      final updatedTag = await remoteDataSource.updateTag(tagModel);
      return Right(updatedTag.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTag(String tagId) async {
    try {
      await remoteDataSource.deleteTag(tagId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTagToEntry(
    String entryId,
    String tagId,
  ) async {
    try {
      await remoteDataSource.addTagToEntry(entryId, tagId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeTagFromEntry(
    String entryId,
    String tagId,
  ) async {
    try {
      await remoteDataSource.removeTagFromEntry(entryId, tagId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTagsForEntry(
    String entryId,
    List<String> tagIds,
  ) async {
    try {
      await remoteDataSource.updateTagsForEntry(entryId, tagIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> getPopularTags({int limit = 20}) async {
    try {
      final tags = await remoteDataSource.getPopularTags(limit: limit);
      return Right(tags.map((t) => t.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> searchTags(String query) async {
    try {
      final tags = await remoteDataSource.searchTags(query);
      return Right(tags.map((t) => t.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
