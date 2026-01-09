import 'package:drift/drift.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';

/// Data Access Object for Users table
///
/// Provides type-safe database operations for user profile data.
/// Supports offline-first scenarios with sync-aware queries.
class UserDao extends DatabaseAccessor<AppDatabase> {
  /// Creates a new UserDao
  ///
  /// The [db] parameter is the AppDatabase instance.
  UserDao(super.db);

  // ==============================================================================
  // CRUD OPERATIONS
  // ==============================================================================

  /// Inserts a new user into the database
  ///
  /// The [user] parameter is a LocalUser object with user data.
  /// Returns the inserted user with the database-generated ID (if applicable).
  ///
  /// Throws [InvalidDataException] if the user data is invalid.
  Future<int> insertUser(UsersCompanion user) async {
    return await into(db.users).insert(user);
  }

  /// Inserts multiple users in a single transaction
  ///
  /// The [users] parameter is a list of UsersCompanion objects.
  /// Returns the count of users inserted.
  ///
  /// This is more efficient than inserting users one by one.
  Future<int> insertUsers(List<UsersCompanion> users) async {
    return await transaction(() async {
      var count = 0;
      for (final user in users) {
        await into(db.users).insert(user);
        count++;
      }
      return count;
    });
  }

  /// Updates an existing user
  ///
  /// The [user] parameter is a LocalUser object with updated data.
  /// Returns the number of rows affected (should be 1).
  ///
  /// Uses the user ID to identify which record to update.
  Future<bool> updateUser(LocalUser user) async {
    return await update(db.users).replace(user);
  }

  /// Updates multiple users in a single transaction
  ///
  /// The [users] parameter is a list of LocalUser objects.
  /// Returns the count of users updated.
  ///
  /// This is more efficient than updating users one by one.
  Future<int> updateUsers(List<LocalUser> users) async {
    return await transaction(() async {
      var count = 0;
      for (final user in users) {
        if (await update(db.users).replace(user)) {
          count++;
        }
      }
      return count;
    });
  }

  /// Deletes a user by ID
  ///
  /// The [id] parameter is the user ID to delete.
  /// Returns the number of rows affected (should be 1 or 0).
  Future<int> deleteUserById(String id) async {
    return await (delete(db.users)..where((u) => u.id.equals(id))).go();
  }

  /// Deletes multiple users by IDs
  ///
  /// The [ids] parameter is a list of user IDs to delete.
  /// Returns the count of users deleted.
  Future<int> deleteUsersByIds(List<String> ids) async {
    return await (delete(db.users)..where((u) => u.id.isIn(ids))).go();
  }

  // ==============================================================================
  // QUERY OPERATIONS
  // ==============================================================================

  /// Gets a user by ID
  ///
  /// The [id] parameter is the user ID to retrieve.
  /// Returns the user if found, null otherwise.
  Future<LocalUser?> getUserById(String id) {
    return (select(db.users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  /// Gets a user by username
  ///
  /// The [username] parameter is the username to search for.
  /// Returns the user if found, null otherwise.
  Future<LocalUser?> getUserByUsername(String username) {
    return (select(db.users)..where((u) => u.username.equals(username)))
        .getSingleOrNull();
  }

  /// Gets a user by email
  ///
  /// The [email] parameter is the email to search for.
  /// Returns the user if found, null otherwise.
  Future<LocalUser?> getUserByEmail(String email) {
    return (select(db.users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  /// Gets all users in the database
  ///
  /// Returns a list of all users.
  Future<List<LocalUser>> getAllUsers() {
    return (select(db.users)..orderBy([(u) => OrderingTerm.asc(u.username)]))
        .get();
  }

  /// Gets users with pagination
  ///
  /// The [limit] parameter is the maximum number of users to return.
  /// The [offset] parameter is the number of users to skip.
  /// Returns a list of users.
  Future<List<LocalUser>> getUsersPaginated({int limit = 20, int offset = 0}) {
    return (select(db.users)
          ..limit(limit, offset: offset)
          ..orderBy([(u) => OrderingTerm.asc(u.username)]))
        .get();
  }

  /// Searches users by username, display name, or email
  ///
  /// The [searchTerm] parameter is the search query.
  /// Returns a list of users matching the search term.
  Future<List<LocalUser>> searchUsers(String searchTerm) {
    return (select(db.users)
          ..where((u) =>
              u.username.contains(searchTerm) |
              u.displayName.contains(searchTerm) |
              u.email.contains(searchTerm))
          ..orderBy([(u) => OrderingTerm.asc(u.username)]))
        .get();
  }

  /// Gets users by public profile status
  ///
  /// The [isPublic] parameter indicates whether to get public or private profiles.
  /// Returns a list of users matching the public status.
  Future<List<LocalUser>> getUsersByPublicStatus(bool isPublic) {
    return (select(db.users)
          ..where((u) => u.isPublic.equals(isPublic))
          ..orderBy([(u) => OrderingTerm.asc(u.username)]))
        .get();
  }

  /// Counts all users
  ///
  /// Returns the count of users in the database.
  Future<int> countAllUsers() async {
    final query = selectOnly(db.users)..addColumns([db.users.id.count()]);

    final result = await query.getSingle();
    return result.read(db.users.id.count()) ?? 0;
  }

  /// Checks if a user exists by ID
  ///
  /// The [id] parameter is the user ID to check.
  /// Returns true if the user exists, false otherwise.
  Future<bool> userExists(String id) async {
    final query = selectOnly(db.users)
      ..addColumns([db.users.id.count()])
      ..where(db.users.id.equals(id));

    final result = await query.getSingle();
    final count = result.read(db.users.id.count()) ?? 0;
    return count > 0;
  }

  /// Checks if a username is already taken
  ///
  /// The [username] parameter is the username to check.
  /// Returns true if the username exists, false otherwise.
  Future<bool> usernameExists(String username) async {
    final query = selectOnly(db.users)
      ..addColumns([db.users.id.count()])
      ..where(db.users.username.equals(username));

    final result = await query.getSingle();
    final count = result.read(db.users.id.count()) ?? 0;
    return count > 0;
  }

  /// Checks if an email is already taken
  ///
  /// The [email] parameter is the email to check.
  /// Returns true if the email exists, false otherwise.
  Future<bool> emailExists(String email) async {
    final query = selectOnly(db.users)
      ..addColumns([db.users.id.count()])
      ..where(db.users.email.equals(email));

    final result = await query.getSingle();
    final count = result.read(db.users.id.count()) ?? 0;
    return count > 0;
  }

  // ==============================================================================
  // SYNC-AWARE QUERIES
  // ==============================================================================

  /// Gets all users that are not synced
  ///
  /// Returns a list of users where isSynced is false.
  ///
  /// These users need to be synced to the server.
  Future<List<LocalUser>> getUnsyncedUsers() {
    return (select(db.users)
          ..where((u) => u.isSynced.equals(false))
          ..orderBy([(u) => OrderingTerm.asc(u.createdAt)]))
        .get();
  }

  /// Gets all users with pending changes
  ///
  /// Returns a list of users where hasPendingChanges is true.
  ///
  /// These users have local modifications that need to be synced.
  Future<List<LocalUser>> getUsersWithPendingChanges() {
    return (select(db.users)
          ..where((u) => u.hasPendingChanges.equals(true))
          ..orderBy([(u) => OrderingTerm.asc(u.updatedAt)]))
        .get();
  }

  /// Gets all users that need sync (unsynced or with pending changes)
  ///
  /// Returns a list of users that need to be synced to the server.
  Future<List<LocalUser>> getUsersNeedingSync() {
    return (select(db.users)
          ..where((u) =>
              u.isSynced.equals(false) | u.hasPendingChanges.equals(true))
          ..orderBy([(u) => OrderingTerm.asc(u.updatedAt)]))
        .get();
  }

  /// Gets users by their sync status
  ///
  /// The [synced] parameter indicates whether to get synced or unsynced users.
  /// Returns a list of users matching the sync status.
  Future<List<LocalUser>> getUsersBySyncStatus(bool synced) {
    return (select(db.users)
          ..where((u) => u.isSynced.equals(synced))
          ..orderBy([(u) => OrderingTerm.asc(u.createdAt)]))
        .get();
  }

  /// Updates sync status for a user
  ///
  /// The [id] parameter is the user ID.
  /// The [isSynced] parameter indicates the new sync status.
  /// Returns the number of rows affected.
  Future<int> updateUserSyncStatus(String id, bool isSynced) {
    return (update(db.users)..where((u) => u.id.equals(id)))
        .write(UsersCompanion(isSynced: Value(isSynced)));
  }

  /// Updates pending changes flag for a user
  ///
  /// The [id] parameter is the user ID.
  /// The [hasPendingChanges] parameter indicates whether there are pending changes.
  /// Returns the number of rows affected.
  Future<int> updateUserPendingChanges(String id, bool hasPendingChanges) {
    return (update(db.users)..where((u) => u.id.equals(id)))
        .write(UsersCompanion(hasPendingChanges: Value(hasPendingChanges)));
  }

  /// Marks a user as synced
  ///
  /// The [id] parameter is the user ID.
  /// The [lastSyncedAt] parameter is the timestamp of the sync.
  /// Returns the number of rows affected.
  Future<int> markUserAsSynced(String id, DateTime lastSyncedAt) {
    return (update(db.users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(
        isSynced: const Value(true),
        hasPendingChanges: const Value(false),
        lastSyncedAt: Value(lastSyncedAt),
      ),
    );
  }

  /// Marks multiple users as synced in a transaction
  ///
  /// The [ids] parameter is a list of user IDs.
  /// The [lastSyncedAt] parameter is the timestamp of the sync.
  /// Returns the count of users updated.
  Future<int> markUsersAsSynced(List<String> ids, DateTime lastSyncedAt) {
    return (update(db.users)..where((u) => u.id.isIn(ids))).write(
      UsersCompanion(
        isSynced: const Value(true),
        hasPendingChanges: const Value(false),
        lastSyncedAt: Value(lastSyncedAt),
      ),
    );
  }

  /// Updates version for a user (after conflict resolution)
  ///
  /// The [id] parameter is the user ID.
  /// The [version] parameter is the new version number.
  /// Returns the number of rows affected.
  Future<int> updateUserVersion(String id, int version) {
    return (update(db.users)..where((u) => u.id.equals(id)))
        .write(UsersCompanion(version: Value(version)));
  }

  /// Gets all users updated after a given timestamp
  ///
  /// The [timestamp] parameter is the timestamp to compare against.
  /// Returns a list of users updated after the timestamp.
  ///
  /// Useful for incremental sync operations.
  Future<List<LocalUser>> getUsersUpdatedAfter(DateTime timestamp) {
    return (select(db.users)
          ..where((u) => u.updatedAt.isBiggerThanValue(timestamp))
          ..orderBy([(u) => OrderingTerm.asc(u.updatedAt)]))
        .get();
  }

  // ==============================================================================
  // FIELD UPDATE OPERATIONS
  // ==============================================================================

  /// Updates user's last login timestamp
  ///
  /// The [id] parameter is the user ID.
  /// The [lastLoginAt] parameter is the last login timestamp.
  /// Returns the number of rows affected.
  Future<int> updateLastLogin(String id, DateTime lastLoginAt) {
    return (update(db.users)..where((u) => u.id.equals(id)))
        .write(UsersCompanion(lastLoginAt: Value(lastLoginAt)));
  }

  /// Updates user profile fields
  ///
  /// The [id] parameter is the user ID.
  /// The [fields] parameter is a map of field names to values.
  /// Returns the number of rows affected.
  Future<int> updateProfileFields(
      String id, Map<String, dynamic> fields) async {
    // Update each field individually if present
    final updates = <String, dynamic>{};

    if (fields['username'] != null) {
      updates['username'] = fields['username'] as String;
    }
    if (fields['displayName'] != null) {
      updates['displayName'] = fields['displayName'] as String;
    }
    if (fields['bio'] != null) {
      updates['bio'] = fields['bio'] as String;
    }
    if (fields['avatarUrl'] != null) {
      updates['avatarUrl'] = fields['avatarUrl'] as String?;
    }
    if (fields['isPublic'] != null) {
      updates['isPublic'] = fields['isPublic'] as bool;
    }
    if (fields['interests'] != null) {
      updates['interests'] = fields['interests'] as String;
    }
    if (fields['preferences'] != null) {
      updates['preferences'] = fields['preferences'] as String;
    }

    if (updates.isEmpty) return 0;

    // Build companion with only the fields that need updating
    final companion = UsersCompanion(
      username: fields['username'] != null
          ? Value(fields['username'] as String)
          : const Value.absent(),
      displayName: fields['displayName'] != null
          ? Value(fields['displayName'] as String)
          : const Value.absent(),
      bio: fields['bio'] != null
          ? Value(fields['bio'] as String)
          : const Value.absent(),
      avatarUrl: fields['avatarUrl'] != null
          ? Value(fields['avatarUrl'] as String?)
          : const Value.absent(),
      isPublic: fields['isPublic'] != null
          ? Value(fields['isPublic'] as bool)
          : const Value.absent(),
      interests: fields['interests'] != null
          ? Value(fields['interests'] as String)
          : const Value.absent(),
      preferences: fields['preferences'] != null
          ? Value(fields['preferences'] as String)
          : const Value.absent(),
    );

    return await (update(db.users)..where((u) => u.id.equals(id)))
        .write(companion);
  }

  /// Updates user avatar URL
  ///
  /// The [id] parameter is the user ID.
  /// The [avatarUrl] parameter is the new avatar URL.
  /// Returns the number of rows affected.
  Future<int> updateAvatar(String id, String? avatarUrl) {
    return (update(db.users)..where((u) => u.id.equals(id)))
        .write(UsersCompanion(avatarUrl: Value(avatarUrl)));
  }

  /// Updates user preferences
  ///
  /// The [id] parameter is the user ID.
  /// The [preferences] parameter is the preferences map as JSON string.
  /// Returns the number of rows affected.
  Future<int> updatePreferences(String id, String preferences) {
    return (update(db.users)..where((u) => u.id.equals(id)))
        .write(UsersCompanion(
      preferences: Value(preferences),
      hasPendingChanges: const Value(true),
    ));
  }

  /// Updates user interests
  ///
  /// The [id] parameter is the user ID.
  /// The [interests] parameter is the interests list as JSON string.
  /// Returns the number of rows affected.
  Future<int> updateInterests(String id, String interests) {
    return (update(db.users)..where((u) => u.id.equals(id)))
        .write(UsersCompanion(
      interests: Value(interests),
      hasPendingChanges: const Value(true),
    ));
  }

  /// Toggles user profile visibility
  ///
  /// The [id] parameter is the user ID.
  /// The [isPublic] parameter indicates whether the profile should be public.
  /// Returns the number of rows affected.
  Future<int> toggleProfileVisibility(String id, bool isPublic) {
    return (update(db.users)..where((u) => u.id.equals(id)))
        .write(UsersCompanion(
      isPublic: Value(isPublic),
      hasPendingChanges: const Value(true),
    ));
  }

  // ==============================================================================
  // BATCH OPERATIONS
  // ==============================================================================

  /// Deletes all users
  ///
  /// Returns the count of users deleted.
  ///
  /// **WARNING**: This is a destructive operation. Use with caution.
  Future<int> deleteAllUsers() async {
    return await delete(db.users).go();
  }
}
