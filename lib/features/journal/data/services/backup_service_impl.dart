import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart'; // For SyncStatus enum
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/services/backup_service.dart';

/// Implementation of [BackupService] using local file system
class BackupServiceImpl implements BackupService {
  final JournalRepository _journalRepository;
  final TripRepository _tripRepository;
  final TagRepository _tagRepository;

  final StreamController<BackupProgress> _backupProgressController =
      StreamController<BackupProgress>.broadcast();
  final StreamController<RestoreProgress> _restoreProgressController =
      StreamController<RestoreProgress>.broadcast();

  bool _isOperating = false;
  bool _isCancelled = false;

  BackupServiceImpl({
    required JournalRepository journalRepository,
    required TripRepository tripRepository,
    required TagRepository tagRepository,
  })  : _journalRepository = journalRepository,
        _tripRepository = tripRepository,
        _tagRepository = tagRepository;

  @override
  bool get isOperating => _isOperating;

  @override
  Stream<BackupProgress>? get backupProgressStream =>
      _backupProgressController.stream;

  @override
  Stream<RestoreProgress>? get restoreProgressStream =>
      _restoreProgressController.stream;

  @override
  Future<BackupResult> createBackup({
    required BackupConfig config,
    BackupProgressCallback? onProgress,
    String? outputPath,
  }) async {
    final startedAt = DateTime.now();

    try {
      // Validate configuration
      if (!config.isValid) {
        throw BackupException.backupCreationFailed(
          'Invalid backup configuration',
        );
      }

      _isOperating = true;
      _isCancelled = false;

      onProgress?.call(const BackupProgress(
        stage: BackupStage.initializing,
        progress: 0.0,
      ));
      _backupProgressController.add(const BackupProgress(
        stage: BackupStage.initializing,
        progress: 0.0,
      ));

      // Get backup directory
      final backupDir = await getBackupDirectory();
      await Directory(backupDir).create(recursive: true);

      // Generate backup filename
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = config.customFilename ?? 'backup_$timestamp';
      final backupPath = outputPath ?? path.join(backupDir, '$filename.zip');

      onProgress?.call(const BackupProgress(
        stage: BackupStage.gatheringData,
        progress: 0.1,
      ));
      _backupProgressController.add(const BackupProgress(
        stage: BackupStage.gatheringData,
        progress: 0.1,
      ));

      // Gather all data
      final entries = await _journalRepository.getEntries();
      final trips = await _tripRepository.getTrips();
      final tags = (await _tagRepository.getTags()).fold((l) => <Tag>[], (r) => r);

      final totalItems = entries.length + trips.length + tags.length;
      int processedItems = 0;

      // Create backup data structure
      final backupData = <String, dynamic>{
        'version': await _getAppVersion(),
        'createdAt': DateTime.now().toIso8601String(),
        'entries': entries.map((e) => _entryToJson(e)).toList(),
        'trips': trips.map((t) => _tripToJson(t)).toList(),
        'tags': tags.map((t) => _tagToJson(t)).toList(),
        'entryCount': entries.length,
        'tripCount': trips.length,
        'tagCount': tags.length,
        'mediaCount': 0,
        'isEncrypted': config.encrypt,
      };

      processedItems = entries.length + trips.length + tags.length;

      onProgress?.call(BackupProgress(
        stage: BackupStage.gatheringData,
        progress: 0.3,
        processedItems: processedItems,
        totalItems: totalItems,
      ));
      _backupProgressController.add(BackupProgress(
        stage: BackupStage.gatheringData,
        progress: 0.3,
        processedItems: processedItems,
        totalItems: totalItems,
      ));

      // Gather media if requested
      List<int>? mediaData;
      int mediaCount = 0;

      if (config.includeMedia) {
        onProgress?.call(const BackupProgress(
          stage: BackupStage.gatheringData,
          progress: 0.5,
          currentItem: 'Gathering media files...',
        ));

        final mediaArchive = Archive();
        final allMedia = <MediaItem>[];

        for (final entry in entries) {
          final entryMedia = await _journalRepository.getMediaForEntry(entry.id);
          allMedia.addAll(entryMedia);
        }

        backupData['mediaCount'] = allMedia.length;
        backupData['media'] = allMedia.map((m) => _mediaToJson(m)).toList();

        // Add media files to archive
        for (final media in allMedia) {
          if (_isCancelled) {
            throw const BackupException(
              message: 'Backup cancelled',
              code: BackupErrorCode.cancelled,
            );
          }

          try {
            final mediaFile = File(media.storagePath);
            if (await mediaFile.exists()) {
              final bytes = await mediaFile.readAsBytes();
              final archiveFile =
                  ArchiveFile(media.storagePath, bytes.length, bytes);
              mediaArchive.addFile(archiveFile);
              mediaCount++;

              onProgress?.call(BackupProgress(
                stage: BackupStage.gatheringData,
                progress: 0.5 + (0.2 * mediaCount / allMedia.length),
                currentItem: 'Adding media: ${media.originalFilename ?? media.id}',
                processedItems: processedItems + mediaCount,
                totalItems: totalItems + allMedia.length,
              ));
            }
          } catch (e) {
            // Continue even if media file is missing
            continue;
          }
        }

        mediaData = ZipEncoder().encode(mediaArchive);
      }

      onProgress?.call(const BackupProgress(
        stage: BackupStage.compressingData,
        progress: 0.7,
      ));
      _backupProgressController.add(const BackupProgress(
        stage: BackupStage.compressingData,
        progress: 0.7,
      ));

      // Create archive
      final archive = Archive();

      // Add metadata file
      final metadataJson = _encodeJson(backupData);
      final metadataBytes = utf8.encode(metadataJson);
      archive.addFile(
          ArchiveFile('metadata.json', metadataBytes.length, metadataBytes));

      // Add media archive if any
      if (mediaData != null) {
        archive.addFile(ArchiveFile('media.zip', mediaData.length, mediaData));
      }

      // Compress archive
      final zipData =
          ZipEncoder().encode(archive, level: config.compressionLevel);

      onProgress?.call(const BackupProgress(
        stage: BackupStage.compressingData,
        progress: 0.8,
      ));
      _backupProgressController.add(const BackupProgress(
        stage: BackupStage.compressingData,
        progress: 0.8,
      ));

      // Encrypt if requested
      List<int> finalData = zipData;
      if (config.encrypt && config.encryptionPassword != null) {
        onProgress?.call(const BackupProgress(
          stage: BackupStage.encryptingData,
          progress: 0.9,
        ));
        _backupProgressController.add(const BackupProgress(
          stage: BackupStage.encryptingData,
          progress: 0.9,
        ));

        finalData = await _encryptData(zipData, config.encryptionPassword!);
      }

      // Calculate checksum
      final checksum = sha256.convert(finalData).toString();

      onProgress?.call(const BackupProgress(
        stage: BackupStage.finalizing,
        progress: 0.95,
      ));
      _backupProgressController.add(const BackupProgress(
        stage: BackupStage.finalizing,
        progress: 0.95,
      ));

      // Write to file
      final backupFile = File(backupPath);
      await backupFile.writeAsBytes(finalData);

      final duration = DateTime.now().difference(startedAt);

      onProgress?.call(BackupProgress(
        stage: BackupStage.completed,
        progress: 1.0,
        processedItems: processedItems + mediaCount,
        totalItems: totalItems + mediaCount,
      ));
      _backupProgressController.add(BackupProgress(
        stage: BackupStage.completed,
        progress: 1.0,
        processedItems: processedItems + mediaCount,
        totalItems: totalItems + mediaCount,
      ));

      // Verify integrity if requested
      if (config.verifyIntegrity) {
        final isValid = await validateBackup(backupPath);
        if (!isValid) {
          await backupFile.delete();
          throw BackupException.checksumMismatch();
        }
      }

      return BackupResult(
        success: true,
        backupPath: backupPath,
        entryCount: entries.length,
        tripCount: trips.length,
        tagCount: tags.length,
        mediaCount: mediaCount,
        fileSize: finalData.length,
        isEncrypted: config.encrypt,
        duration: duration,
        checksum: checksum,
      );
    } catch (e) {
      onProgress?.call(const BackupProgress(
        stage: BackupStage.failed,
        progress: 0.0,
      ));
      _backupProgressController.add(const BackupProgress(
        stage: BackupStage.failed,
        progress: 0.0,
      ));

      if (e is BackupException) {
        rethrow;
      }
      throw BackupException.backupCreationFailed(
        'Failed to create backup: ${e.toString()}',
        e,
      );
    } finally {
      _isOperating = false;
    }
  }

  @override
  Future<RestoreResult> restoreBackup({
    required String backupPath,
    required RestoreConfig config,
    RestoreProgressCallback? onProgress,
  }) async {
    final startedAt = DateTime.now();
    String? preRestoreBackupPath;

    try {
      _isOperating = true;
      _isCancelled = false;

      onProgress?.call(const RestoreProgress(
        stage: RestoreStage.initializing,
        progress: 0.0,
      ));
      _restoreProgressController.add(const RestoreProgress(
        stage: RestoreStage.initializing,
        progress: 0.0,
      ));

      // Validate backup file exists
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw BackupException.invalidBackupFile(
            'Backup file not found: $backupPath');
      }

      // Create pre-restore backup if requested
      if (config.backupBeforeRestore) {
        onProgress?.call(const RestoreProgress(
          stage: RestoreStage.initializing,
          progress: 0.05,
          currentItem: 'Creating pre-restore backup...',
        ));

        try {
          final preBackupResult = await createBackup(
            config: BackupConfig(
              includeMedia: config.restoreMedia,
              encrypt: false,
              verifyIntegrity: false,
            ),
          );
          preRestoreBackupPath = preBackupResult.backupPath;
        } catch (e) {
          // Continue even if pre-restore backup fails
          // but log the error
        }
      }

      onProgress?.call(const RestoreProgress(
        stage: RestoreStage.validatingBackup,
        progress: 0.1,
      ));
      _restoreProgressController.add(const RestoreProgress(
        stage: RestoreStage.validatingBackup,
        progress: 0.1,
      ));

      // Validate backup if requested
      if (config.verifyBeforeRestore) {
        final isValid = await validateBackup(
          backupPath,
          password: config.encryptionPassword,
        );
        if (!isValid) {
          throw BackupException.checksumMismatch();
        }
      }

      // Read backup file
      List<int> backupData = await backupFile.readAsBytes();

      onProgress?.call(const RestoreProgress(
        stage: RestoreStage.decryptingData,
        progress: 0.2,
      ));
      _restoreProgressController.add(const RestoreProgress(
        stage: RestoreStage.decryptingData,
        progress: 0.2,
      ));

      // Decrypt if needed
      if (config.encryptionPassword != null) {
        backupData = await _decryptData(backupData, config.encryptionPassword!);
      }

      onProgress?.call(const RestoreProgress(
        stage: RestoreStage.extractingData,
        progress: 0.3,
      ));
      _restoreProgressController.add(const RestoreProgress(
        stage: RestoreStage.extractingData,
        progress: 0.3,
      ));

      // Extract archive
      final archive = ZipDecoder().decodeBytes(backupData);

      // Get metadata
      final metadataFile = archive.files.firstWhere(
        (f) => f.name == 'metadata.json',
        orElse: () => throw BackupException.invalidBackupFile(
          'Backup file is missing metadata.json',
        ),
      );

      final metadataJson =
          String.fromCharCodes(metadataFile.content as List<int>);
      final metadata = _decodeJson(metadataJson) as Map<String, dynamic>;

      // Check if entities should be restored
      final shouldRestoreEntries = config.entitiesToRestore == null ||
          config.entitiesToRestore!.contains(RestoreEntityType.journalEntries);
      final shouldRestoreTrips = config.entitiesToRestore == null ||
          config.entitiesToRestore!.contains(RestoreEntityType.trips);
      final shouldRestoreTags = config.entitiesToRestore == null ||
          config.entitiesToRestore!.contains(RestoreEntityType.tags);

      onProgress?.call(const RestoreProgress(
        stage: RestoreStage.restoringData,
        progress: 0.4,
      ));
      _restoreProgressController.add(const RestoreProgress(
        stage: RestoreStage.restoringData,
        progress: 0.4,
      ));

      int entriesRestored = 0;
      int tripsRestored = 0;
      int tagsRestored = 0;
      int mediaRestored = 0;
      int conflictCount = 0;
      int skippedCount = 0;

      final entryIds = <String>[];
      final tripIds = <String>[];
      final tagIds = <String>[];
      final conflictIds = <String>[];

      // Restore entries
      if (shouldRestoreEntries) {
        final entriesData = metadata['entries'] as List;
        final totalEntries = entriesData.length;

        for (int i = 0; i < entriesData.length; i++) {
          if (_isCancelled) {
            throw const BackupException(
              message: 'Restore cancelled',
              code: BackupErrorCode.cancelled,
            );
          }

          try {
            final entryJson = entriesData[i] as Map<String, dynamic>;
            final entry = _jsonToEntry(entryJson);

            // Handle conflict resolution
            JournalEntry? existingEntry;
                try {
                  existingEntry = await _journalRepository.getEntry(entry.id);
                } catch (_) {
                  existingEntry = null;
                }

            if (existingEntry != null) {
              conflictCount++;

              bool shouldRestore = false;
              switch (config.conflictResolution) {
                case ConflictResolution.keepNewest:
                  shouldRestore =
                      entry.updatedAt.isAfter(existingEntry.updatedAt);
                  break;
                case ConflictResolution.keepBackup:
                  shouldRestore = true;
                  break;
                case ConflictResolution.keepExisting:
                  shouldRestore = false;
                  break;
                case ConflictResolution.keepBoth:
                  // Would need to create duplicate with new ID
                  // For now, treat as keepExisting
                  shouldRestore = false;
                  break;
                case ConflictResolution.manual:
                  // In manual mode, skip conflicts
                  shouldRestore = false;
                  break;
              }

              if (shouldRestore) {
                await _journalRepository.updateEntry(entry);
                entryIds.add(entry.id);
                entriesRestored++;
              } else {
                skippedCount++;
              }

              if (shouldRestore) {
                conflictIds.add(entry.id);
              }
            } else {
              await _journalRepository.createEntry(entry);
              entryIds.add(entry.id);
              entriesRestored++;
            }

            onProgress?.call(RestoreProgress(
              stage: RestoreStage.restoringData,
              progress: 0.4 + (0.3 * (i + 1) / totalEntries),
              currentItem: 'Restoring entry ${i + 1}/$totalEntries',
              processedItems: i + 1,
              totalItems: totalEntries,
            ));
          } catch (e) {
            // Continue even if individual entry fails
            continue;
          }
        }
      }

      // Restore trips
      if (shouldRestoreTrips) {
        final tripsData = metadata['trips'] as List;
        final totalTrips = tripsData.length;

        for (int i = 0; i < tripsData.length; i++) {
          if (_isCancelled) {
            throw const BackupException(
              message: 'Restore cancelled',
              code: BackupErrorCode.cancelled,
            );
          }

          try {
            final tripJson = tripsData[i] as Map<String, dynamic>;
            final trip = _jsonToTrip(tripJson);

            Trip? existingTrip;
            try {
              existingTrip = await _tripRepository.getTrip(trip.id);
            } catch (_) {
              existingTrip = null;
            }

            if (existingTrip == null) {
              await _tripRepository.createTrip(trip);
              tripIds.add(trip.id);
              tripsRestored++;
            } else {
              skippedCount++;
            }

            onProgress?.call(RestoreProgress(
              stage: RestoreStage.restoringData,
              progress: 0.7 + (0.15 * (i + 1) / totalTrips),
              currentItem: 'Restoring trip ${i + 1}/$totalTrips',
              processedItems: i + 1,
              totalItems: totalTrips,
            ));
          } catch (e) {
            continue;
          }
        }
      }

      // Restore tags
      if (shouldRestoreTags) {
        final tagsData = metadata['tags'] as List;
        final totalTags = tagsData.length;

        for (int i = 0; i < tagsData.length; i++) {
          if (_isCancelled) {
            throw const BackupException(
              message: 'Restore cancelled',
              code: BackupErrorCode.cancelled,
            );
          }

          try {
            final tagJson = tagsData[i] as Map<String, dynamic>;
            final tag = _jsonToTag(tagJson);

            Tag? existingTag;
            try {
              existingTag = (await _tagRepository.getTag(tag.id)).fold(
                (l) => null,
                (r) => r,
              );
            } catch (_) {
              existingTag = null;
            }

            if (existingTag == null) {
              await _tagRepository.createTag(tag);
              tagIds.add(tag.id);
              tagsRestored++;
            } else {
              skippedCount++;
            }

            onProgress?.call(RestoreProgress(
              stage: RestoreStage.restoringData,
              progress: 0.85 + (0.1 * (i + 1) / totalTags),
              currentItem: 'Restoring tag ${i + 1}/$totalTags',
              processedItems: i + 1,
              totalItems: totalTags,
            ));
          } catch (e) {
            continue;
          }
        }
      }

      onProgress?.call(const RestoreProgress(
        stage: RestoreStage.finalizing,
        progress: 0.98,
      ));
      _restoreProgressController.add(const RestoreProgress(
        stage: RestoreStage.finalizing,
        progress: 0.98,
      ));

      final duration = DateTime.now().difference(startedAt);

      onProgress?.call(const RestoreProgress(
        stage: RestoreStage.completed,
        progress: 1.0,
      ));
      _restoreProgressController.add(const RestoreProgress(
        stage: RestoreStage.completed,
        progress: 1.0,
      ));

      return RestoreResult(
        success: true,
        entriesRestored: entriesRestored,
        tripsRestored: tripsRestored,
        tagsRestored: tagsRestored,
        mediaRestored: mediaRestored,
        conflictCount: conflictCount,
        skippedCount: skippedCount,
        preRestoreBackupPath: preRestoreBackupPath,
        duration: duration,
        details: RestoreDetails(
          entryIds: entryIds,
          tripIds: tripIds,
          tagIds: tagIds,
          conflictIds: conflictIds,
        ),
      );
    } catch (e) {
      onProgress?.call(const RestoreProgress(
        stage: RestoreStage.failed,
        progress: 0.0,
      ));
      _restoreProgressController.add(const RestoreProgress(
        stage: RestoreStage.failed,
        progress: 0.0,
      ));

      if (e is BackupException) {
        rethrow;
      }
      throw BackupException.restoreFailed(
        'Failed to restore backup: ${e.toString()}',
        e,
      );
    } finally {
      _isOperating = false;
    }
  }

  @override
  Future<BackupInfo> getBackupInfo(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw BackupException.invalidBackupFile('Backup file not found');
      }

      List<int> backupData = await backupFile.readAsBytes();
      final fileSize = backupData.length;

      // Try to decrypt if encrypted
      // We'll need to attempt decryption or read metadata
      // For now, assume unencrypted for info

      try {
        final archive = ZipDecoder().decodeBytes(backupData);

        final metadataFile = archive.files.firstWhere(
          (f) => f.name == 'metadata.json',
        );

        final metadataJson =
            String.fromCharCodes(metadataFile.content as List<int>);
        final metadata = _decodeJson(metadataJson) as Map<String, dynamic>;

        return BackupInfo(
          path: backupPath,
          createdAt: DateTime.parse(metadata['createdAt'] as String),
          entryCount: metadata['entryCount'] as int? ?? 0,
          tripCount: metadata['tripCount'] as int? ?? 0,
          tagCount: metadata['tagCount'] as int? ?? 0,
          mediaCount: metadata['mediaCount'] as int? ?? 0,
          fileSize: fileSize,
          isEncrypted: metadata['isEncrypted'] as bool? ?? false,
          appVersion: metadata['version'] as String?,
          checksum: metadata['checksum'] as String?,
        );
      } catch (e) {
        // If we can't decode, it might be encrypted
        return BackupInfo(
          path: backupPath,
          createdAt: await backupFile.lastModified(),
          entryCount: 0,
          tripCount: 0,
          tagCount: 0,
          mediaCount: 0,
          fileSize: fileSize,
          isEncrypted: true,
        );
      }
    } catch (e) {
      throw BackupException.invalidBackupFile(
        'Failed to read backup info: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> validateBackup(String backupPath, {String? password}) async {
    try {
      final info = await getBackupInfo(backupPath);

      // If encrypted and no password provided, can't validate
      if (info.isEncrypted && password == null) {
        return false;
      }

      final backupFile = File(backupPath);
      List<int> backupData = await backupFile.readAsBytes();

      // Decrypt if needed
      if (info.isEncrypted && password != null) {
        backupData = await _decryptData(backupData, password);
      }

      // Decode and verify structure
      final archive = ZipDecoder().decodeBytes(backupData);
      final hasMetadata = archive.files.any((f) => f.name == 'metadata.json');

      if (!hasMetadata) {
        return false;
      }

      // Verify checksum if present
      if (info.checksum != null) {
        final computedChecksum = sha256.convert(backupData).toString();
        return computedChecksum == info.checksum;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<BackupInfo>> getAvailableBackups() async {
    try {
      final backupDir = await getBackupDirectory();
      final dir = Directory(backupDir);

      if (!await dir.exists()) {
        return [];
      }

      final backups = <BackupInfo>[];
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.zip')) {
          try {
            final info = await getBackupInfo(entity.path);
            backups.add(info);
          } catch (e) {
            // Skip invalid backup files
            continue;
          }
        }
      }

      // Sort by creation date, newest first
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> getBackupDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'backups');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'backups');
    }
  }

  @override
  Future<int> estimateBackupSize({bool includeMedia = true}) async {
    try {
      int totalSize = 0;

      // Estimate data size (rough estimate)
      final entries = await _journalRepository.getEntries();
      final trips = await _tripRepository.getTrips();
      final tags = (await _tagRepository.getTags()).fold((l) => <Tag>[], (r) => r);

      // Rough estimate: 1KB per entry, 500 bytes per trip/tag
      totalSize += entries.length * 1024;
      totalSize += trips.length * 500;
      totalSize += tags.length * 500;

      // Add media size if requested
      if (includeMedia) {
        for (final entry in entries) {
          try {
            final entryMedia = await _journalRepository.getMediaForEntry(entry.id);
            for (final media in entryMedia) {
              try {
                final file = File(media.storagePath);
                if (await file.exists()) {
                  totalSize += await file.length();
                }
              } catch (e) {
                // Skip missing files
              }
            }
          } catch (e) {
            // Skip if media retrieval fails
          }
        }
      }

      // Add compression overhead estimate (20%)
      return (totalSize * 1.2).toInt();
    } catch (e) {
      // Return conservative estimate if calculation fails
      return 100 * 1024 * 1024; // 100 MB
    }
  }

  @override
  Future<void> cancelOperation() async {
    _isCancelled = true;
  }

  // Helper methods

  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return 'unknown';
    }
  }

  String _encodeJson(Map<String, dynamic> data) {
    return json.encode(data);
  }

  dynamic _decodeJson(String jsonString) {
    return json.decode(jsonString);
  }

  Map<String, dynamic> _entryToJson(JournalEntry entry) {
    return {
      'id': entry.id,
      'userId': entry.userId,
      'tripId': entry.tripId,
      'title': entry.title,
      'content': entry.content,
      'mood': entry.mood,
      'locationName': entry.locationName,
      'latitude': entry.latitude,
      'longitude': entry.longitude,
      'locationAccuracy': entry.locationAccuracy,
      'entryDate': entry.entryDate.toIso8601String(),
      'weatherData': entry.weatherData?.toString(),
      'isFavorite': entry.isFavorite,
      'syncStatus': entry.syncStatus.toString(),
      'lastSyncedAt': entry.lastSyncedAt?.toIso8601String(),
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt.toIso8601String(),
    };
  }

  JournalEntry _jsonToEntry(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tripId: json['tripId'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String?,
      locationName: json['locationName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationAccuracy: (json['locationAccuracy'] as num?)?.toDouble(),
      entryDate: DateTime.parse(json['entryDate'] as String),
      weatherData: json['weatherData'] as Map<String, dynamic>?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString() == json['syncStatus'],
        orElse: () => SyncStatus.synced,
      ),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _tripToJson(Trip trip) {
    return {
      'id': trip.id,
      'userId': trip.userId,
      'name': trip.name,
      'description': trip.description,
      'startDate': trip.startDate.toIso8601String(),
      'endDate': trip.endDate?.toIso8601String(),
      'coverImageUrl': trip.coverImageUrl,
      'syncStatus': trip.syncStatus.toString(),
      'createdAt': trip.createdAt.toIso8601String(),
      'updatedAt': trip.updatedAt.toIso8601String(),
    };
  }

  Trip _jsonToTrip(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      coverImageUrl: json['coverImageUrl'] as String?,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString() == json['syncStatus'],
        orElse: () => SyncStatus.synced,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _tagToJson(Tag tag) {
    return {
      'id': tag.id,
      'userId': tag.userId,
      'name': tag.name,
      'color': tag.color,
      'icon': tag.icon,
      'usageCount': tag.usageCount,
      'syncStatus': tag.syncStatus.toString(),
      'createdAt': tag.createdAt.toIso8601String(),
    };
  }

  Tag _jsonToTag(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      usageCount: json['usageCount'] as int? ?? 0,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString() == json['syncStatus'],
        orElse: () => SyncStatus.synced,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> _mediaToJson(MediaItem media) {
    return {
      'id': media.id,
      'journalEntryId': media.journalEntryId,
      'mediaType': media.mediaType.toString(),
      'storagePath': media.storagePath,
      'originalFilename': media.originalFilename,
      'mimeType': media.mimeType,
      'fileSize': media.fileSize,
      'width': media.width,
      'height': media.height,
      'duration': media.duration,
      'thumbnailPath': media.thumbnailPath,
      'uploadStatus': media.uploadStatus.toString(),
      'uploadProgress': media.uploadProgress,
      'isCover': media.isCover,
      'orderIndex': media.orderIndex,
      'createdAt': media.createdAt.toIso8601String(),
      'updatedAt': media.updatedAt.toIso8601String(),
    };
  }

  Future<List<int>> _encryptData(List<int> data, String password) async {
    try {
      final key = encrypt.Key.fromUtf8(password.padRight(32).substring(0, 32));
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      final encrypted = encrypter.encryptBytes(Uint8List.fromList(data), iv: iv);
      return [...iv.bytes, ...encrypted.bytes];
    } catch (e) {
      throw BackupException.encryptionFailed('Failed to encrypt backup', e);
    }
  }

  Future<List<int>> _decryptData(List<int> data, String password) async {
    try {
      if (data.length < 16) {
        throw BackupException.decryptionFailed('Invalid encrypted data');
      }

      final key = encrypt.Key.fromUtf8(password.padRight(32).substring(0, 32));
      final iv = encrypt.IV(Uint8List.fromList(data.sublist(0, 16)));
      final encryptedData = data.sublist(16);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      final decrypted = encrypter.decryptBytes(
        encrypt.Encrypted(Uint8List.fromList(encryptedData)),
        iv: iv,
      );
      return decrypted;
    } catch (e) {
      throw BackupException.decryptionFailed(
        'Failed to decrypt backup. Wrong password?',
        e,
      );
    }
  }

  void dispose() {
    _backupProgressController.close();
    _restoreProgressController.close();
  }
}
