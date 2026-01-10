import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart'; // For SyncStatus enum
import 'package:sqflite/sqflite.dart';
import 'package:soloadventurer/core/errors/exceptions.dart' as app_exceptions;
import 'package:soloadventurer/features/journal/data/datasources/database_helper.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/tag_model.dart';
import 'package:soloadventurer/features/journal/domain/entities/tag.dart';

/// SQLite implementation of [TagLocalDataSource]
class TagLocalDataSourceImpl implements TagLocalDataSource {
  final DatabaseHelper _databaseHelper;

  TagLocalDataSourceImpl({
    required DatabaseHelper databaseHelper,
  }) : _databaseHelper = databaseHelper;

  @override
  Future<TagModel> createTag(TagModel tag) async {
    try {
      final db = await _databaseHelper.database;

      await db.insert(
        DatabaseHelper.tableTags,
        _tagToMap(tag),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return tag;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to create tag: $e',
      );
    }
  }

  @override
  Future<TagModel> updateTag(TagModel tag) async {
    try {
      final db = await _databaseHelper.database;

      final count = await db.update(
        DatabaseHelper.tableTags,
        _tagToMap(tag),
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [tag.id],
      );

      if (count == 0) {
        throw const NotFoundException(
          message: 'Tag not found',
        );
      }

      return tag;
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update tag: $e',
      );
    }
  }

  @override
  Future<TagModel?> getTag(String tagId) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableTags,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [tagId],
      );

      if (maps.isEmpty) return null;

      return _mapToTag(maps.first);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get tag: $e',
      );
    }
  }

  @override
  Future<List<TagModel>> getTags() async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableTags,
        orderBy: '${DatabaseHelper.colUsageCount} DESC',
      );

      return maps.map(_mapToTag).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get tags: $e',
      );
    }
  }

  @override
  Future<List<TagModel>> getTagsBySyncStatus(String syncStatus) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableTags,
        where: '${DatabaseHelper.colSyncStatus} = ?',
        whereArgs: [syncStatus],
        orderBy: '${DatabaseHelper.colUsageCount} DESC',
      );

      return maps.map(_mapToTag).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get tags by sync status: $e',
      );
    }
  }

  @override
  Future<TagModel> updateSyncStatus(String tagId, String syncStatus) async {
    try {
      final tag = await getTag(tagId);
      if (tag == null) {
        throw const NotFoundException(
          message: 'Tag not found',
        );
      }

      final updatedTag = tag.copyWith(
        syncStatus: SyncStatusExtension.fromString(syncStatus),
        lastSyncedAt: DateTime.now(),
      );

      return await updateTag(updatedTag);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update sync status: $e',
      );
    }
  }

  @override
  Future<void> deleteTag(String tagId) async {
    try {
      final db = await _databaseHelper.database;

      await db.delete(
        DatabaseHelper.tableTags,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [tagId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to delete tag: $e',
      );
    }
  }

  @override
  Future<TagModel> incrementUsageCount(String tagId) async {
    try {
      final tag = await getTag(tagId);
      if (tag == null) {
        throw const NotFoundException(
          message: 'Tag not found',
        );
      }

      final updatedTag = tag.copyWith(
        usageCount: tag.usageCount + 1,
      );

      return await updateTag(updatedTag);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to increment usage count: $e',
      );
    }
  }

  @override
  Future<TagModel> decrementUsageCount(String tagId) async {
    try {
      final tag = await getTag(tagId);
      if (tag == null) {
        throw const NotFoundException(
          message: 'Tag not found',
        );
      }

      final newCount = tag.usageCount > 0 ? tag.usageCount - 1 : 0;
      final updatedTag = tag.copyWith(
        usageCount: newCount,
      );

      return await updateTag(updatedTag);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to decrement usage count: $e',
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(DatabaseHelper.tableTags);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to clear all tags: $e',
      );
    }
  }

  /// Converts a [TagModel] to a map for database storage
  Map<String, dynamic> _tagToMap(TagModel tag) {
    return {
      DatabaseHelper.colId: tag.id,
      DatabaseHelper.colUserId: tag.userId,
      DatabaseHelper.colName: tag.name,
      DatabaseHelper.colTagColor: tag.color,
      DatabaseHelper.colTagIcon: tag.icon,
      DatabaseHelper.colUsageCount: tag.usageCount,
      DatabaseHelper.colCreatedAt: tag.createdAt.toIso8601String(),
    };
  }

  /// Converts a database map to a [TagModel]
  TagModel _mapToTag(Map<String, dynamic> map) {
    return TagModel(
      id: map[DatabaseHelper.colId] as String,
      userId: map[DatabaseHelper.colUserId] as String,
      name: map[DatabaseHelper.colName] as String,
      color: map[DatabaseHelper.colTagColor] as String?,
      icon: map[DatabaseHelper.colTagIcon] as String?,
      usageCount: map[DatabaseHelper.colUsageCount] as int,
      createdAt: DateTime.parse(map[DatabaseHelper.colCreatedAt] as String),
    );
  }
}
