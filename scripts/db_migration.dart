import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';

/// A utility script for managing database migrations for the SoloAdventurer app.
/// This script helps create, apply, and track database migrations.

class Migration {
  final String name;
  final String filename;
  final DateTime createdAt;
  bool applied;

  Migration({
    required this.name,
    required this.filename,
    required this.createdAt,
    this.applied = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'filename': filename,
      'createdAt': createdAt.toIso8601String(),
      'applied': applied,
    };
  }

  factory Migration.fromJson(Map<String, dynamic> json) {
    return Migration(
      name: json['name'],
      filename: json['filename'],
      createdAt: DateTime.parse(json['createdAt']),
      applied: json['applied'],
    );
  }

  @override
  String toString() {
    return '${applied ? "[✓]" : "[ ]"} $filename - $name (${createdAt.toIso8601String()})';
  }
}

class MigrationManager {
  final String migrationsDir;
  final String trackingFile;
  List<Migration> migrations = [];

  MigrationManager({
    this.migrationsDir = 'migrations',
    this.trackingFile = 'migrations/migration_history.json',
  }) {
    _ensureDirectoryExists();
    _loadMigrations();
  }

  void _ensureDirectoryExists() {
    final dir = Directory(migrationsDir);
    if (!dir.existsSync()) {
      print('Creating migrations directory: $migrationsDir');
      dir.createSync(recursive: true);
    }

    final trackingDir = Directory(path.dirname(trackingFile));
    if (!trackingDir.existsSync()) {
      trackingDir.createSync(recursive: true);
    }
  }

  void _loadMigrations() {
    final file = File(trackingFile);
    if (!file.existsSync()) {
      migrations = [];
      return;
    }

    try {
      final content = file.readAsStringSync();
      final List<dynamic> jsonList = json.decode(content);
      migrations = jsonList.map((item) => Migration.fromJson(item)).toList();
      migrations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      print('Error loading migrations: $e');
      migrations = [];
    }
  }

  void _saveMigrations() {
    final file = File(trackingFile);
    final jsonList = migrations.map((m) => m.toJson()).toList();
    file.writeAsStringSync(json.encode(jsonList));
  }

  String _generateFilename(String name) {
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.Z]'), '');
    final safeName =
        name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
    return '${timestamp}_$safeName.sql';
  }

  void createMigration(String name) {
    final filename = _generateFilename(name);
    final filepath = path.join(migrationsDir, filename);

    // Create migration file with template
    final file = File(filepath);
    file.writeAsStringSync('''
-- Migration: $name
-- Created at: ${DateTime.now().toIso8601String()}

-- Up Migration
-- SQL statements for applying the migration

-- Down Migration
-- SQL statements for rolling back the migration

''');

    // Add to tracking
    final migration = Migration(
      name: name,
      filename: filename,
      createdAt: DateTime.now(),
      applied: false,
    );

    migrations.add(migration);
    _saveMigrations();

    print('Created migration: $filepath');
  }

  void listMigrations() {
    if (migrations.isEmpty) {
      print('No migrations found.');
      return;
    }

    print('Migrations:');
    for (var i = 0; i < migrations.length; i++) {
      print('${i + 1}. ${migrations[i]}');
    }
  }

  void applyMigration(int index) {
    if (index < 0 || index >= migrations.length) {
      print('Invalid migration index: $index');
      return;
    }

    final migration = migrations[index];
    if (migration.applied) {
      print('Migration already applied: ${migration.filename}');
      return;
    }

    final filepath = path.join(migrationsDir, migration.filename);
    final file = File(filepath);
    if (!file.existsSync()) {
      print('Migration file not found: $filepath');
      return;
    }

    print('Applying migration: ${migration.filename}');

    // In a real implementation, this would execute the SQL in the migration file
    // For this example, we'll just mark it as applied
    migration.applied = true;
    _saveMigrations();

    print('Migration applied successfully.');
  }

  void applyAllMigrations() {
    final unapplied = migrations.where((m) => !m.applied).toList();

    if (unapplied.isEmpty) {
      print('No migrations to apply.');
      return;
    }

    print('Applying ${unapplied.length} migrations...');

    for (var migration in unapplied) {
      final filepath = path.join(migrationsDir, migration.filename);
      final file = File(filepath);

      if (!file.existsSync()) {
        print('Migration file not found: $filepath');
        continue;
      }

      print('Applying migration: ${migration.filename}');

      // In a real implementation, this would execute the SQL in the migration file
      // For this example, we'll just mark it as applied
      migration.applied = true;
    }

    _saveMigrations();
    print('All migrations applied successfully.');
  }

  void rollbackMigration(int index) {
    if (index < 0 || index >= migrations.length) {
      print('Invalid migration index: $index');
      return;
    }

    final migration = migrations[index];
    if (!migration.applied) {
      print('Migration not applied: ${migration.filename}');
      return;
    }

    final filepath = path.join(migrationsDir, migration.filename);
    final file = File(filepath);
    if (!file.existsSync()) {
      print('Migration file not found: $filepath');
      return;
    }

    print('Rolling back migration: ${migration.filename}');

    // In a real implementation, this would execute the down SQL in the migration file
    // For this example, we'll just mark it as not applied
    migration.applied = false;
    _saveMigrations();

    print('Migration rolled back successfully.');
  }

  void rollbackLastMigration() {
    final applied = migrations.where((m) => m.applied).toList();

    if (applied.isEmpty) {
      print('No migrations to roll back.');
      return;
    }

    // Sort by creation date descending to get the last applied migration
    applied.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final lastMigration = applied.first;

    print('Rolling back migration: ${lastMigration.filename}');

    // In a real implementation, this would execute the down SQL in the migration file
    // For this example, we'll just mark it as not applied
    lastMigration.applied = false;
    _saveMigrations();

    print('Last migration rolled back successfully.');
  }

  void generateSchemaSnapshot(String outputPath) {
    final appliedMigrations = migrations.where((m) => m.applied).toList();

    if (appliedMigrations.isEmpty) {
      print('No applied migrations to generate schema from.');
      return;
    }

    // In a real implementation, this would combine all migrations to create a schema snapshot
    final output = File(outputPath);
    final buffer = StringBuffer();

    buffer.writeln(
        '-- Schema snapshot generated on ${DateTime.now().toIso8601String()}');
    buffer
        .writeln('-- Based on ${appliedMigrations.length} applied migrations');
    buffer.writeln();

    for (var migration in appliedMigrations) {
      buffer.writeln('-- Including migration: ${migration.filename}');
      final migrationFile = File(path.join(migrationsDir, migration.filename));
      if (migrationFile.existsSync()) {
        final content = migrationFile.readAsStringSync();
        // In a real implementation, we would extract and apply only the "up" part
        buffer.writeln(content);
        buffer.writeln();
      }
    }

    output.writeAsStringSync(buffer.toString());
    print('Schema snapshot generated: $outputPath');
  }
}

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addCommand(
        'create',
        ArgParser()
          ..addOption('name', abbr: 'n', help: 'Name of the migration'))
    ..addCommand('list')
    ..addCommand(
        'apply',
        ArgParser()
          ..addOption('index',
              abbr: 'i', help: 'Index of the migration to apply')
          ..addFlag('all', abbr: 'a', help: 'Apply all pending migrations'))
    ..addCommand(
        'rollback',
        ArgParser()
          ..addOption('index',
              abbr: 'i', help: 'Index of the migration to roll back')
          ..addFlag('last',
              abbr: 'l', help: 'Roll back the last applied migration'))
    ..addCommand(
        'snapshot',
        ArgParser()
          ..addOption('output',
              abbr: 'o', help: 'Output file path for the schema snapshot'))
    ..addOption('dir', abbr: 'd', help: 'Migrations directory')
    ..addOption('tracking', abbr: 't', help: 'Tracking file path')
    ..addFlag('help', abbr: 'h', help: 'Show this help');

  try {
    final results = parser.parse(arguments);

    if (results['help'] == true || results.command == null) {
      _printUsage(parser);
      return;
    }

    final manager = MigrationManager(
      migrationsDir: results['dir'] ?? 'migrations',
      trackingFile: results['tracking'] ?? 'migrations/migration_history.json',
    );

    final command = results.command!;

    switch (command.name) {
      case 'create':
        final name = command['name'];
        if (name == null || name.isEmpty) {
          print('Error: Migration name is required');
          print('Usage: dart db_migration.dart create --name <migration_name>');
          return;
        }
        manager.createMigration(name);
        break;

      case 'list':
        manager.listMigrations();
        break;

      case 'apply':
        if (command['all'] == true) {
          manager.applyAllMigrations();
        } else {
          final indexStr = command['index'];
          if (indexStr == null) {
            print('Error: Migration index is required');
            print('Usage: dart db_migration.dart apply --index <index>');
            return;
          }
          final index = int.tryParse(indexStr);
          if (index == null) {
            print('Error: Invalid index: $indexStr');
            return;
          }
          manager.applyMigration(index - 1); // Convert to 0-based index
        }
        break;

      case 'rollback':
        if (command['last'] == true) {
          manager.rollbackLastMigration();
        } else {
          final indexStr = command['index'];
          if (indexStr == null) {
            print('Error: Migration index is required');
            print('Usage: dart db_migration.dart rollback --index <index>');
            return;
          }
          final index = int.tryParse(indexStr);
          if (index == null) {
            print('Error: Invalid index: $indexStr');
            return;
          }
          manager.rollbackMigration(index - 1); // Convert to 0-based index
        }
        break;

      case 'snapshot':
        final output = command['output'];
        if (output == null || output.isEmpty) {
          print('Error: Output file path is required');
          print('Usage: dart db_migration.dart snapshot --output <file_path>');
          return;
        }
        manager.generateSchemaSnapshot(output);
        break;

      default:
        print('Unknown command: ${command.name}');
        _printUsage(parser);
    }
  } catch (e) {
    print('Error: $e');
    _printUsage(parser);
  }
}

void _printUsage(ArgParser parser) {
  print('SoloAdventurer Database Migration Tool');
  print('');
  print('Usage:');
  print('  dart db_migration.dart <command> [options]');
  print('');
  print('Commands:');
  print('  create    Create a new migration');
  print('  list      List all migrations');
  print('  apply     Apply migrations');
  print('  rollback  Roll back migrations');
  print('  snapshot  Generate a schema snapshot');
  print('');
  print('Options:');
  print(parser.usage);
}
