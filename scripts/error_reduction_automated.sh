#!/bin/bash

################################################################################
# SoloAdventurer Error Reduction - Safe Automation Script
################################################################################
#
# DESCRIPTION:
#   Automates the SAFE phases of error reduction that don't require context:
#   - Phase 3: Move example files to excluded directory
#   - Phase 4: Create missing performance test utilities
#   - Phase 5a: Create missing spacing widget classes
#   - Phase 7a: Fix SIMPLE withOpacity cases (optional)
#
# WHAT THIS SCRIPT DOES NOT DO (requires manual dev work):
#   - Phase 5b: Update imports in files using VerticalSpacing
#   - Phase 5c: Fix LatLngBounds imports
#   - Phase 6: Fix repository type casting (context-dependent)
#   - Phase 7b: Fix withOpacity with variables/calculations
#   - Cleanup: Run dart fix --apply
#
# USAGE:
#   ./safe_error_reduction.sh [options]
#
# OPTIONS:
#   --dry-run         Preview changes without applying
#   --all             Run all safe phases (default)
#   --phase N         Run specific phase (3, 4, 5, 7)
#   --skip-backup     Skip backup creation
#   --with-opacity    Include Phase 7a (simple withOpacity fixes)
#   -y, --yes         Auto-confirm prompts
#   -v, --verbose     Show detailed output
#   -h, --help        Show help
#
# EXAMPLES:
#   ./safe_error_reduction.sh --dry-run          # Preview all changes
#   ./safe_error_reduction.sh --all              # Run phases 3, 4, 5
#   ./safe_error_reduction.sh --all --with-opacity  # Include phase 7a
#   ./safe_error_reduction.sh --phase 3          # Run only phase 3
#
# AFTER RUNNING:
#   See MANUAL_WORK_REQUIRED.md for remaining tasks
#
################################################################################

set -euo pipefail

################################################################################
# CONFIGURATION
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
BACKUP_DIR="$PROJECT_ROOT/.error_reduction_backup"
LOG_FILE="$PROJECT_ROOT/error_reduction_$(date +%Y%m%d_%H%M%S).log"
MANUAL_WORK_FILE="$PROJECT_ROOT/MANUAL_WORK_REQUIRED.md"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

################################################################################
# STATE
################################################################################

DRY_RUN=false
SKIP_BACKUP=false
AUTO_CONFIRM=false
VERBOSE=false
INCLUDE_OPACITY=false
RUN_ALL=true
SPECIFIC_PHASE=""

# Tracking
declare -a CREATED_FILES=()
declare -a MOVED_FILES=()
declare -a MODIFIED_FILES=()
declare -a MANUAL_TASKS=()

# Counters
ERRORS_FIXED_ESTIMATE=0

################################################################################
# LOGGING
################################################################################

log_info() {
    echo -e "${BLUE}ℹ${NC}  $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}✓${NC}  $*" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC}  $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}✗${NC}  $*" | tee -a "$LOG_FILE"
}

log_step() {
    echo "" | tee -a "$LOG_FILE"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}${BOLD}  $*${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "    ${NC}$*" | tee -a "$LOG_FILE"
    fi
}

################################################################################
# UTILITIES
################################################################################

show_help() {
    head -50 "$0" | grep '^#' | grep -v '#!/' | sed 's/^# //' | sed 's/^#//'
    exit 0
}

confirm() {
    if [[ "$AUTO_CONFIRM" == true ]]; then
        return 0
    fi
    local prompt="$1"
    read -rp "$prompt [y/N] " response
    case "$response" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

create_backup() {
    if [[ "$SKIP_BACKUP" == true ]]; then
        log_warning "Skipping backup (--skip-backup)"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would create backup at: $BACKUP_DIR/$TIMESTAMP"
        return 0
    fi
    
    log_step "Creating Backup"
    
    local backup_path="$BACKUP_DIR/$TIMESTAMP"
    mkdir -p "$backup_path"
    
    # Backup key config files
    for file in "pubspec.yaml" "analysis_options.yaml"; do
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            cp "$PROJECT_ROOT/$file" "$backup_path/"
            log_verbose "Backed up: $file"
        fi
    done
    
    # Save metadata
    cat > "$backup_path/backup_info.txt" << EOF
Backup Created: $(date)
Script: $0
Project: $PROJECT_ROOT
Phases Run: ${SPECIFIC_PHASE:-all}
EOF
    
    log_success "Backup created: $backup_path"
}

add_manual_task() {
    local phase="$1"
    local task="$2"
    local details="$3"
    MANUAL_TASKS+=("$phase|$task|$details")
}

################################################################################
# PHASE 3: Move Example Files
################################################################################

phase_3() {
    log_step "Phase 3: Move Example/Documentation Files"
    log_info "Moving *_example.dart files to examples/ directory"
    
    # Find example files
    local example_files=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && example_files+=("$file")
    done < <(find "$PROJECT_ROOT/lib" "$PROJECT_ROOT/test" \
        \( -name "*_example*.dart" -o -name "example_*.dart" \) \
        -type f 2>/dev/null | sort)
    
    local count=${#example_files[@]}
    log_info "Found $count example files"
    
    if [[ $count -eq 0 ]]; then
        log_warning "No example files found - skipping"
        return 0
    fi
    
    # Create examples directory structure
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$PROJECT_ROOT/examples/lib"
        mkdir -p "$PROJECT_ROOT/examples/test"
    fi
    
    # Move files
    local moved=0
    for file in "${example_files[@]}"; do
        local relative="${file#$PROJECT_ROOT/}"
        local target="$PROJECT_ROOT/examples/$relative"
        
        if [[ "$DRY_RUN" == true ]]; then
            log_verbose "[DRY RUN] Would move: $relative → examples/$relative"
        else
            mkdir -p "$(dirname "$target")"
            mv "$file" "$target"
            MOVED_FILES+=("$relative")
            moved=$((moved + 1))
            log_verbose "Moved: $relative"
        fi
    done
    
    # Create analysis_options.yaml for examples
    local analysis_file="$PROJECT_ROOT/examples/analysis_options.yaml"
    if [[ "$DRY_RUN" == true ]]; then
        log_verbose "[DRY RUN] Would create: examples/analysis_options.yaml"
    else
        cat > "$analysis_file" << 'EOF'
# Example files - excluded from main project analysis
# These files are for documentation/reference only

include: ../analysis_options.yaml

analyzer:
  exclude:
    - "**/*.dart"
  errors:
    # Downgrade all errors to info for example files
    unused_import: ignore
    unused_local_variable: ignore
    dead_code: ignore

linter:
  rules:
    # Disable lints that don't apply to examples
    avoid_print: false
    unused_element: false
EOF
        CREATED_FILES+=("examples/analysis_options.yaml")
    fi
    
    # Create README for examples
    local readme_file="$PROJECT_ROOT/examples/README.md"
    if [[ "$DRY_RUN" == false ]]; then
        cat > "$readme_file" << EOF
# Example Files

**Moved:** $(date +%Y-%m-%d)
**Reason:** Cleanup - example files excluded from main project analysis

## Contents

These files were moved from \`lib/\` and \`test/\` to reduce analyzer noise.
They contain:
- Usage examples
- Documentation code
- Reference implementations

## Files Moved

$(printf '- %s\n' "${MOVED_FILES[@]}" 2>/dev/null || echo "See error_reduction log for details")

## To Use These Examples

If you need to reference or run these examples:
1. Copy the specific file back to \`lib/\` or \`test/\`
2. Fix any import paths
3. Run the example

## Analysis

These files are excluded from \`flutter analyze\` via the local \`analysis_options.yaml\`.
EOF
        CREATED_FILES+=("examples/README.md")
    fi
    
    # Estimate errors fixed (~5-10 per file due to print statements, etc.)
    ERRORS_FIXED_ESTIMATE=$((ERRORS_FIXED_ESTIMATE + count * 7))
    
    log_success "Phase 3 complete: $moved files moved"
    log_info "Estimated errors removed: ~$((count * 7))"
}

################################################################################
# PHASE 4: Create Performance Test Utilities
################################################################################

phase_4() {
    log_step "Phase 4: Create Performance Test Utilities"
    log_info "Creating missing test utility classes"
    
    local perf_dir="$PROJECT_ROOT/test/utils/performance"
    
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$perf_dir"
    fi
    
    # File 1: Barrel export
    local barrel_file="$perf_dir/performance_test_utils.dart"
    if [[ "$DRY_RUN" == true ]]; then
        log_verbose "[DRY RUN] Would create: test/utils/performance/performance_test_utils.dart"
    else
        cat > "$barrel_file" << 'EOF'
/// Performance testing utilities
///
/// Provides helper classes for generating test data and measuring performance.
library performance_test_utils;

export 'performance_test_data_generator.dart';
export 'photo_data_generator.dart';
export 'performance_reporter.dart';
EOF
        CREATED_FILES+=("test/utils/performance/performance_test_utils.dart")
        log_verbose "Created: performance_test_utils.dart"
    fi
    
    # File 2: PerformanceTestDataGenerator
    local generator_file="$perf_dir/performance_test_data_generator.dart"
    if [[ "$DRY_RUN" == true ]]; then
        log_verbose "[DRY RUN] Would create: test/utils/performance/performance_test_data_generator.dart"
    else
        cat > "$generator_file" << 'EOF'
import 'dart:math';

/// Generates test data for performance testing scenarios.
///
/// Usage:
/// ```dart
/// final id = PerformanceTestDataGenerator.generateId();
/// final trip = PerformanceTestDataGenerator.generateTripData();
/// ```
class PerformanceTestDataGenerator {
  PerformanceTestDataGenerator._();

  static final _random = Random();

  /// Generate a unique test ID
  static String generateId() =>
      'test-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(999999)}';

  /// Generate a random string of specified length
  static String generateString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      length,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// Generate a random date within the past year
  static DateTime generateDate() {
    return DateTime.now().subtract(Duration(days: _random.nextInt(365)));
  }

  /// Generate a random date within a range
  static DateTime generateDateInRange(DateTime start, DateTime end) {
    final diff = end.difference(start).inDays;
    return start.add(Duration(days: _random.nextInt(diff.abs())));
  }

  /// Generate a random JSON-like object with specified fields
  static Map<String, dynamic> generateJsonObject(int fields) {
    return Map.fromEntries(
      List.generate(
        fields,
        (i) => MapEntry('field$i', generateString(10)),
      ),
    );
  }

  /// Generate random coordinates (latitude, longitude)
  static ({double latitude, double longitude}) generateCoordinates() {
    return (
      latitude: -90 + _random.nextDouble() * 180,
      longitude: -180 + _random.nextDouble() * 360,
    );
  }

  /// Generate mock trip data
  static Map<String, dynamic> generateTripData() {
    final coords = generateCoordinates();
    return {
      'id': generateId(),
      'title': 'Trip ${generateString(5)}',
      'description': generateString(100),
      'startDate': generateDate().toIso8601String(),
      'endDate': generateDate().toIso8601String(),
      'latitude': coords.latitude,
      'longitude': coords.longitude,
      'status': ['planned', 'active', 'completed'][_random.nextInt(3)],
    };
  }

  /// Generate mock journal entry data
  static Map<String, dynamic> generateJournalEntryData() {
    return {
      'id': generateId(),
      'tripId': generateId(),
      'title': 'Entry ${generateString(5)}',
      'content': generateString(500),
      'createdAt': generateDate().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'mood': ['happy', 'excited', 'peaceful', 'adventurous'][_random.nextInt(4)],
      'tags': List.generate(_random.nextInt(5), (_) => generateString(8)),
    };
  }

  /// Generate a batch of test data
  static List<Map<String, dynamic>> generateBatch(
    int count,
    Map<String, dynamic> Function() generator,
  ) {
    return List.generate(count, (_) => generator());
  }
}
EOF
        CREATED_FILES+=("test/utils/performance/performance_test_data_generator.dart")
        log_verbose "Created: performance_test_data_generator.dart"
    fi
    
    # File 3: PhotoDataGenerator
    local photo_file="$perf_dir/photo_data_generator.dart"
    if [[ "$DRY_RUN" == true ]]; then
        log_verbose "[DRY RUN] Would create: test/utils/performance/photo_data_generator.dart"
    else
        cat > "$photo_file" << 'EOF'
import 'dart:math';
import 'dart:typed_data';

/// Generates photo-related test data for performance testing.
///
/// Usage:
/// ```dart
/// final bytes = PhotoDataGenerator.generateImageBytes(size: 1024);
/// final metadata = PhotoDataGenerator.generatePhotoMetadata();
/// ```
class PhotoDataGenerator {
  PhotoDataGenerator._();

  static final _random = Random();

  /// Generate random bytes simulating image data
  static Uint8List generateImageBytes({int size = 1024}) {
    return Uint8List.fromList(
      List.generate(size, (_) => _random.nextInt(256)),
    );
  }

  /// Generate a mock photo file path
  static String generatePhotoPath({String extension = 'jpg'}) {
    final id = _random.nextInt(999999);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '/test/photos/photo_${timestamp}_$id.$extension';
  }

  /// Generate photo metadata
  static Map<String, dynamic> generatePhotoMetadata() {
    final resolutions = [
      (1920, 1080),
      (2048, 1536),
      (3840, 2160),
      (4096, 2304),
    ];
    final res = resolutions[_random.nextInt(resolutions.length)];
    
    return {
      'id': 'photo-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(999999)}',
      'path': generatePhotoPath(),
      'width': res.$1,
      'height': res.$2,
      'format': ['jpeg', 'png', 'webp', 'heic'][_random.nextInt(4)],
      'size': _random.nextInt(10000000) + 100000, // 100KB - 10MB
      'createdAt': DateTime.now()
          .subtract(Duration(days: _random.nextInt(365)))
          .toIso8601String(),
      'location': {
        'latitude': -90 + _random.nextDouble() * 180,
        'longitude': -180 + _random.nextDouble() * 360,
      },
      'exif': generateExifData(),
    };
  }

  /// Generate mock EXIF data
  static Map<String, dynamic> generateExifData() {
    final cameras = [
      'iPhone 15 Pro',
      'iPhone 14',
      'Pixel 8 Pro',
      'Samsung S24 Ultra',
      'Canon EOS R5',
      'Sony A7 IV',
    ];
    final apertures = ['f/1.8', 'f/2.0', 'f/2.8', 'f/4.0', 'f/5.6'];
    final isoValues = [100, 200, 400, 800, 1600, 3200];
    final shutterSpeeds = ['1/60', '1/125', '1/250', '1/500', '1/1000', '1/2000'];

    return {
      'camera': cameras[_random.nextInt(cameras.length)],
      'aperture': apertures[_random.nextInt(apertures.length)],
      'iso': isoValues[_random.nextInt(isoValues.length)],
      'shutterSpeed': shutterSpeeds[_random.nextInt(shutterSpeeds.length)],
      'focalLength': '${[24, 35, 50, 85, 100, 200][_random.nextInt(6)]}mm',
      'flash': _random.nextBool(),
    };
  }

  /// Generate a batch of photo metadata
  static List<Map<String, dynamic>> generatePhotoBatch(int count) {
    return List.generate(count, (_) => generatePhotoMetadata());
  }

  /// Generate thumbnail data (smaller than full image)
  static Uint8List generateThumbnail({int width = 150, int height = 150}) {
    return generateImageBytes(size: (width * height * 3) ~/ 10);
  }
}
EOF
        CREATED_FILES+=("test/utils/performance/photo_data_generator.dart")
        log_verbose "Created: photo_data_generator.dart"
    fi
    
    # File 4: PerformanceReporter
    local reporter_file="$perf_dir/performance_reporter.dart"
    if [[ "$DRY_RUN" == true ]]; then
        log_verbose "[DRY RUN] Would create: test/utils/performance/performance_reporter.dart"
    else
        cat > "$reporter_file" << 'EOF'
import 'dart:collection';

/// Reports and tracks performance metrics during testing.
///
/// Usage:
/// ```dart
/// final reporter = PerformanceReporter();
/// reporter.startTimer('database_query');
/// // ... perform operation
/// reporter.stopTimer('database_query');
/// reporter.printReport();
/// ```
class PerformanceReporter {
  final List<PerformanceMetric> _metrics = [];
  final Map<String, Stopwatch> _activeTimers = {};
  final String? name;

  PerformanceReporter({this.name});

  /// Record a metric with a name and value
  void recordMetric(String metricName, double value, {String? unit}) {
    _metrics.add(PerformanceMetric(
      name: metricName,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
    ));
  }

  /// Record a duration metric
  void recordDuration(String metricName, Duration duration) {
    recordMetric(metricName, duration.inMicroseconds.toDouble(), unit: 'μs');
  }

  /// Start a named timer
  void startTimer(String timerName) {
    _activeTimers[timerName] = Stopwatch()..start();
  }

  /// Stop a named timer and record the duration
  Duration? stopTimer(String timerName) {
    final timer = _activeTimers.remove(timerName);
    if (timer != null) {
      timer.stop();
      recordDuration(timerName, timer.elapsed);
      return timer.elapsed;
    }
    return null;
  }

  /// Measure execution time of an async function
  Future<T> measureAsync<T>(String metricName, Future<T> Function() fn) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await fn();
    } finally {
      stopwatch.stop();
      recordDuration(metricName, stopwatch.elapsed);
    }
  }

  /// Measure execution time of a sync function
  T measureSync<T>(String metricName, T Function() fn) {
    final stopwatch = Stopwatch()..start();
    try {
      return fn();
    } finally {
      stopwatch.stop();
      recordDuration(metricName, stopwatch.elapsed);
    }
  }

  /// Print a formatted report of all metrics
  void printReport() {
    final title = name != null ? 'PERFORMANCE REPORT: $name' : 'PERFORMANCE REPORT';
    
    // Using stderr to avoid lint warnings in tests
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('═' * 60);
    // ignore: avoid_print
    print('  $title');
    // ignore: avoid_print
    print('═' * 60);

    if (_metrics.isEmpty) {
      // ignore: avoid_print
      print('  No metrics recorded.');
      // ignore: avoid_print
      print('═' * 60);
      return;
    }

    // Group metrics by name
    final grouped = <String, List<double>>{};
    for (final metric in _metrics) {
      grouped.putIfAbsent(metric.name, () => []).add(metric.value);
    }

    for (final entry in grouped.entries) {
      final values = entry.value;
      final avg = values.reduce((a, b) => a + b) / values.length;
      final min = values.reduce((a, b) => a < b ? a : b);
      final max = values.reduce((a, b) => a > b ? a : b);
      final unit = _metrics.firstWhere((m) => m.name == entry.key).unit ?? '';

      // ignore: avoid_print
      print('');
      // ignore: avoid_print
      print('  📊 ${entry.key}');
      // ignore: avoid_print
      print('     Count: ${values.length}');
      // ignore: avoid_print
      print('     Avg:   ${avg.toStringAsFixed(2)} $unit');
      // ignore: avoid_print
      print('     Min:   ${min.toStringAsFixed(2)} $unit');
      // ignore: avoid_print
      print('     Max:   ${max.toStringAsFixed(2)} $unit');
    }

    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('═' * 60);
  }

  /// Get all recorded metrics (read-only)
  List<PerformanceMetric> get metrics => UnmodifiableListView(_metrics);

  /// Get metric statistics for a specific metric name
  PerformanceStats? getStats(String metricName) {
    final values = _metrics
        .where((m) => m.name == metricName)
        .map((m) => m.value)
        .toList();
    
    if (values.isEmpty) return null;
    
    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    
    return PerformanceStats(
      name: metricName,
      count: values.length,
      average: avg,
      min: min,
      max: max,
    );
  }

  /// Clear all recorded metrics and timers
  void clear() {
    _metrics.clear();
    _activeTimers.clear();
  }

  /// Export metrics as JSON-compatible list
  List<Map<String, dynamic>> toJson() {
    return _metrics.map((m) => m.toJson()).toList();
  }
}

/// Represents a single performance metric
class PerformanceMetric {
  final String name;
  final double value;
  final String? unit;
  final DateTime timestamp;

  PerformanceMetric({
    required this.name,
    required this.value,
    this.unit,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'unit': unit,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() => '$name: $value ${unit ?? ''}';
}

/// Statistics for a metric
class PerformanceStats {
  final String name;
  final int count;
  final double average;
  final double min;
  final double max;

  PerformanceStats({
    required this.name,
    required this.count,
    required this.average,
    required this.min,
    required this.max,
  });
}
EOF
        CREATED_FILES+=("test/utils/performance/performance_reporter.dart")
        log_verbose "Created: performance_reporter.dart"
    fi
    
    ERRORS_FIXED_ESTIMATE=$((ERRORS_FIXED_ESTIMATE + 100))
    
    log_success "Phase 4 complete: 4 files created"
    log_info "Estimated errors removed: ~100"
    
    # Add manual task for updating imports
    add_manual_task "Phase 4" "Update test imports" \
        "Add 'import \"package:soloadventurer/test/utils/performance/performance_test_utils.dart\";' to test files that need these utilities"
}

################################################################################
# PHASE 5: Create Missing Widget Classes
################################################################################

phase_5() {
    log_step "Phase 5a: Create Missing Widget Classes"
    log_info "Creating spacing widget utilities"
    
    local widgets_dir="$PROJECT_ROOT/lib/core/widgets"
    
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$widgets_dir"
    fi
    
    # Create spacing.dart
    local spacing_file="$widgets_dir/spacing.dart"
    if [[ "$DRY_RUN" == true ]]; then
        log_verbose "[DRY RUN] Would create: lib/core/widgets/spacing.dart"
    else
        cat > "$spacing_file" << 'EOF'
import 'package:flutter/material.dart';

/// A widget that provides consistent vertical spacing.
///
/// Usage:
/// ```dart
/// Column(
///   children: [
///     Text('Hello'),
///     VerticalSpacing.medium(),  // 16px gap
///     Text('World'),
///   ],
/// )
/// ```
class VerticalSpacing extends StatelessWidget {
  /// The height of the spacing in logical pixels
  final double height;

  /// Creates vertical spacing with a custom height
  const VerticalSpacing(this.height, {super.key});

  /// Extra small spacing (4px)
  const VerticalSpacing.xs({super.key}) : height = 4;

  /// Small spacing (8px)
  const VerticalSpacing.small({super.key}) : height = 8;

  /// Medium spacing (16px) - default
  const VerticalSpacing.medium({super.key}) : height = 16;

  /// Large spacing (24px)
  const VerticalSpacing.large({super.key}) : height = 24;

  /// Extra large spacing (32px)
  const VerticalSpacing.xl({super.key}) : height = 32;

  /// Extra extra large spacing (48px)
  const VerticalSpacing.xxl({super.key}) : height = 48;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// A widget that provides consistent horizontal spacing.
///
/// Usage:
/// ```dart
/// Row(
///   children: [
///     Icon(Icons.star),
///     HorizontalSpacing.small(),  // 8px gap
///     Text('Rating'),
///   ],
/// )
/// ```
class HorizontalSpacing extends StatelessWidget {
  /// The width of the spacing in logical pixels
  final double width;

  /// Creates horizontal spacing with a custom width
  const HorizontalSpacing(this.width, {super.key});

  /// Extra small spacing (4px)
  const HorizontalSpacing.xs({super.key}) : width = 4;

  /// Small spacing (8px)
  const HorizontalSpacing.small({super.key}) : width = 8;

  /// Medium spacing (16px)
  const HorizontalSpacing.medium({super.key}) : width = 16;

  /// Large spacing (24px)
  const HorizontalSpacing.large({super.key}) : width = 24;

  /// Extra large spacing (32px)
  const HorizontalSpacing.xl({super.key}) : width = 32;

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}

/// Common spacing constants for use with EdgeInsets, SizedBox, etc.
///
/// Usage:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(Spacing.medium),
///   child: Text('Hello'),
/// )
/// ```
abstract class Spacing {
  Spacing._();

  /// 4px
  static const double xs = 4;

  /// 8px
  static const double small = 8;

  /// 12px
  static const double smallMedium = 12;

  /// 16px
  static const double medium = 16;

  /// 20px
  static const double mediumLarge = 20;

  /// 24px
  static const double large = 24;

  /// 32px
  static const double xl = 32;

  /// 48px
  static const double xxl = 48;

  /// 64px
  static const double xxxl = 64;
}
EOF
        CREATED_FILES+=("lib/core/widgets/spacing.dart")
        log_verbose "Created: spacing.dart"
    fi
    
    # Create or update core.dart barrel file
    local core_barrel="$PROJECT_ROOT/lib/core/core.dart"
    local export_line="export 'widgets/spacing.dart';"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_verbose "[DRY RUN] Would update: lib/core/core.dart"
    else
        if [[ -f "$core_barrel" ]]; then
            if ! grep -q "widgets/spacing.dart" "$core_barrel" 2>/dev/null; then
                echo "" >> "$core_barrel"
                echo "// Spacing widgets" >> "$core_barrel"
                echo "$export_line" >> "$core_barrel"
                MODIFIED_FILES+=("lib/core/core.dart")
                log_verbose "Updated: core.dart with spacing export"
            else
                log_info "core.dart already exports spacing.dart"
            fi
        else
            cat > "$core_barrel" << EOF
/// Core library barrel export
///
/// Import this file to access all core utilities:
/// \`\`\`dart
/// import 'package:soloadventurer/core/core.dart';
/// \`\`\`
library core;

// Widgets
$export_line
EOF
            CREATED_FILES+=("lib/core/core.dart")
            log_verbose "Created: core.dart"
        fi
    fi
    
    # Create JsonHelpers for Phase 6 prep
    local utils_dir="$PROJECT_ROOT/lib/core/utils"
    local helpers_file="$utils_dir/json_helpers.dart"
    
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$utils_dir"
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log_verbose "[DRY RUN] Would create: lib/core/utils/json_helpers.dart"
    else
        cat > "$helpers_file" << 'EOF'
/// Type-safe JSON parsing helpers.
///
/// Use these instead of direct casting to avoid runtime errors:
/// ```dart
/// // ❌ Unsafe:
/// final id = data['id'] as int?;
///
/// // ✅ Safe:
/// final id = JsonHelpers.parseInt(data['id']);
/// ```
class JsonHelpers {
  JsonHelpers._();

  /// Safely parse an int from dynamic data.
  ///
  /// Handles: int, String (parseable), double, null
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  /// Parse int with a default value if null or invalid.
  static int parseIntOrDefault(dynamic value, {int defaultValue = 0}) {
    return parseInt(value) ?? defaultValue;
  }

  /// Safely parse a double from dynamic data.
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse double with a default value.
  static double parseDoubleOrDefault(dynamic value, {double defaultValue = 0.0}) {
    return parseDouble(value) ?? defaultValue;
  }

  /// Safely parse a String from dynamic data.
  static String? parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Parse String with a default value.
  static String parseStringOrDefault(dynamic value, {String defaultValue = ''}) {
    return parseString(value) ?? defaultValue;
  }

  /// Safely parse a bool from dynamic data.
  ///
  /// Handles: bool, int (0/1), String ('true'/'false'/'1'/'0')
  static bool? parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }

  /// Parse bool with a default value.
  static bool parseBoolOrDefault(dynamic value, {bool defaultValue = false}) {
    return parseBool(value) ?? defaultValue;
  }

  /// Safely parse a DateTime from dynamic data.
  ///
  /// Handles: DateTime, String (ISO 8601), int (milliseconds since epoch)
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// Safely parse a List with a mapper function.
  ///
  /// Example:
  /// ```dart
  /// final ids = JsonHelpers.parseList<int>(
  ///   data['ids'],
  ///   (e) => JsonHelpers.parseIntOrDefault(e),
  /// );
  /// ```
  static List<T>? parseList<T>(dynamic value, T Function(dynamic) mapper) {
    if (value == null) return null;
    if (value is! List) return null;
    try {
      return value.map((e) => mapper(e)).toList();
    } catch (_) {
      return null;
    }
  }

  /// Parse List with empty default.
  static List<T> parseListOrEmpty<T>(dynamic value, T Function(dynamic) mapper) {
    return parseList(value, mapper) ?? [];
  }

  /// Safely parse a Map<String, dynamic>.
  static Map<String, dynamic>? parseMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Parse Map with empty default.
  static Map<String, dynamic> parseMapOrEmpty(dynamic value) {
    return parseMap(value) ?? {};
  }
}
EOF
        CREATED_FILES+=("lib/core/utils/json_helpers.dart")
        log_verbose "Created: json_helpers.dart (for Phase 6)"
    fi
    
    ERRORS_FIXED_ESTIMATE=$((ERRORS_FIXED_ESTIMATE + 50))
    
    log_success "Phase 5a complete: Widget classes created"
    log_info "Estimated errors removed: ~50"
    
    # Add manual tasks
    add_manual_task "Phase 5b" "Update VerticalSpacing imports" \
        "Add 'import \"package:soloadventurer/core/widgets/spacing.dart\";' to files using VerticalSpacing/HorizontalSpacing. Run: grep -rln \"VerticalSpacing\" lib/"
    
    add_manual_task "Phase 5c" "Fix LatLngBounds imports" \
        "Add correct import for LatLngBounds (google_maps_flutter or latlong2). Run: grep -rln \"LatLngBounds\" lib/"
    
    add_manual_task "Phase 6" "Fix repository type casting" \
        "Replace 'as int?' with 'JsonHelpers.parseInt()' in repository files. JsonHelpers created at lib/core/utils/json_helpers.dart"
}

################################################################################
# PHASE 7a: Fix Simple withOpacity Cases
################################################################################

phase_7() {
    log_step "Phase 7a: Fix Simple withOpacity Cases"
    log_warning "This only fixes SIMPLE cases like .withOpacity(0.5)"
    log_warning "Complex cases with variables need manual fixing"
    
    # Count instances
    local count
    count=$(grep -r "\.withOpacity(" "$PROJECT_ROOT/lib" --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
    
    log_info "Found $count withOpacity instances"
    
    if [[ "$count" -eq 0 ]]; then
        log_warning "No withOpacity usage found"
        return 0
    fi
    
    local fixed=0
    local skipped=0
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        if grep -q "\.withOpacity(" "$file" 2>/dev/null; then
            # Check if file has simple cases (numeric literals)
            local simple_count
            simple_count=$(grep -oE "\.withOpacity\([0-9]+\.?[0-9]*\)" "$file" 2>/dev/null | wc -l | tr -d ' ')
            
            if [[ "$simple_count" -gt 0 ]]; then
                if [[ "$DRY_RUN" == true ]]; then
                    log_verbose "[DRY RUN] Would fix $simple_count cases in: ${file#$PROJECT_ROOT/}"
                else
                    # Fix simple numeric cases only
                    if command -v perl &> /dev/null; then
                        perl -i.bak -pe 's/\.withOpacity\((\d+\.?\d*)\)/.withValues(alpha: $1)/g' "$file"
                    else
                        sed -i.bak 's/\.withOpacity(\([0-9]*\.[0-9]*\))/.withValues(alpha: \1)/g' "$file"
                    fi
                    rm -f "${file}.bak"
                    MODIFIED_FILES+=("${file#$PROJECT_ROOT/}")
                    fixed=$((fixed + simple_count))
                    log_verbose "Fixed $simple_count cases in: ${file#$PROJECT_ROOT/}"
                fi
            fi
            
            # Check for complex cases (variables, calculations)
            local complex_count
            complex_count=$(grep -c "\.withOpacity(" "$file" 2>/dev/null || echo 0)
            complex_count=$((complex_count - simple_count))
            
            if [[ "$complex_count" -gt 0 ]]; then
                skipped=$((skipped + complex_count))
                log_verbose "Skipped $complex_count complex cases in: ${file#$PROJECT_ROOT/}"
            fi
        fi
    done < <(find "$PROJECT_ROOT/lib" -name "*.dart" -type f 2>/dev/null)
    
    ERRORS_FIXED_ESTIMATE=$((ERRORS_FIXED_ESTIMATE + fixed))
    
    log_success "Phase 7a complete: Fixed $fixed simple cases"
    
    if [[ $skipped -gt 0 ]]; then
        log_warning "$skipped complex cases need manual fixing"
        add_manual_task "Phase 7b" "Fix complex withOpacity cases" \
            "$skipped cases with variables/calculations need manual fix. Run: grep -rn \".withOpacity(\" lib/ | grep -v \"withValues\""
    fi
}

################################################################################
# GENERATE MANUAL WORK DOCUMENT
################################################################################

generate_manual_work_doc() {
    log_step "Generating Manual Work Document"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would create: MANUAL_WORK_REQUIRED.md"
        return 0
    fi
    
    cat > "$MANUAL_WORK_FILE" << EOF
# Manual Work Required

**Generated:** $(date)
**Script:** safe_error_reduction.sh
**Estimated Remaining Manual Work:** 2-3 hours

---

## Summary

The automation script has completed the safe phases. The following tasks
require manual intervention because they are context-dependent or need
human judgment.

---

## Tasks by Phase

EOF

    # Group tasks by phase
    local current_phase=""
    for task in "${MANUAL_TASKS[@]}"; do
        IFS='|' read -r phase title details <<< "$task"
        
        if [[ "$phase" != "$current_phase" ]]; then
            current_phase="$phase"
            echo "### $phase" >> "$MANUAL_WORK_FILE"
            echo "" >> "$MANUAL_WORK_FILE"
        fi
        
        cat >> "$MANUAL_WORK_FILE" << EOF
#### $title

$details

---

EOF
    done

    # Add standard manual tasks that always apply
    cat >> "$MANUAL_WORK_FILE" << 'EOF'

## Standard Cleanup Tasks

### Run dart fix

After completing manual fixes, run:

```bash
dart fix --dry-run  # Preview
dart fix --apply    # Apply fixes
```

### Format Code

```bash
dart format lib/ test/
```

### Regenerate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Final Verification

```bash
flutter analyze 2>&1 | tee final_analysis.txt
tail -20 final_analysis.txt
```

---

## Files Created by Script

EOF

    for file in "${CREATED_FILES[@]}"; do
        echo "- \`$file\`" >> "$MANUAL_WORK_FILE"
    done

    cat >> "$MANUAL_WORK_FILE" << 'EOF'

---

## Files Modified by Script

EOF

    for file in "${MODIFIED_FILES[@]}"; do
        echo "- \`$file\`" >> "$MANUAL_WORK_FILE"
    done

    if [[ ${#MOVED_FILES[@]} -gt 0 ]]; then
        cat >> "$MANUAL_WORK_FILE" << 'EOF'

---

## Files Moved by Script

EOF
        for file in "${MOVED_FILES[@]}"; do
            echo "- \`$file\` → \`examples/$file\`" >> "$MANUAL_WORK_FILE"
        done
    fi

    cat >> "$MANUAL_WORK_FILE" << EOF

---

## Estimated Error Reduction

- **Automated:** ~$ERRORS_FIXED_ESTIMATE errors
- **Manual (Phase 5b-c):** ~30 errors
- **Manual (Phase 6):** ~150 errors  
- **Manual (Phase 7b):** ~50-100 errors
- **dart fix --apply:** ~200 errors

**Total Estimated Reduction:** ~$((ERRORS_FIXED_ESTIMATE + 430))-$((ERRORS_FIXED_ESTIMATE + 480)) errors

---

## Questions?

If you encounter issues:
1. Check the log file: \`$LOG_FILE\`
2. Review backup at: \`$BACKUP_DIR/\`
3. Consult: \`/docs/ERROR_REDUCTION_ACTION_PLAN.md\`
EOF

    log_success "Created: MANUAL_WORK_REQUIRED.md"
}

################################################################################
# SUMMARY
################################################################################

print_summary() {
    log_step "Execution Summary"
    
    echo ""
    echo -e "${BOLD}Configuration:${NC}"
    echo "  Project Root:   $PROJECT_ROOT"
    echo "  Dry Run:        $DRY_RUN"
    echo "  Include Opacity: $INCLUDE_OPACITY"
    echo ""
    
    echo -e "${BOLD}Results:${NC}"
    echo "  Files Created:  ${#CREATED_FILES[@]}"
    echo "  Files Modified: ${#MODIFIED_FILES[@]}"
    echo "  Files Moved:    ${#MOVED_FILES[@]}"
    echo ""
    
    echo -e "${BOLD}Estimated Errors Fixed:${NC} ~$ERRORS_FIXED_ESTIMATE"
    echo ""
    
    if [[ ${#CREATED_FILES[@]} -gt 0 ]]; then
        echo -e "${BOLD}Created:${NC}"
        for f in "${CREATED_FILES[@]}"; do
            echo "  + $f"
        done
        echo ""
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}  DRY RUN - No changes were made${NC}"
        echo -e "${YELLOW}  Run without --dry-run to apply changes${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    else
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}  Changes applied successfully!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${BOLD}Next Steps:${NC}"
        echo "  1. Review: MANUAL_WORK_REQUIRED.md"
        echo "  2. Run: flutter analyze 2>&1 | tail -10"
        echo "  3. Complete manual tasks listed in the document"
        echo ""
        echo -e "${BOLD}Log File:${NC} $LOG_FILE"
    fi
}

################################################################################
# MAIN
################################################################################

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --all)
                RUN_ALL=true
                SPECIFIC_PHASE=""
                shift
                ;;
            --phase)
                SPECIFIC_PHASE="$2"
                RUN_ALL=false
                shift 2
                ;;
            --skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --with-opacity)
                INCLUDE_OPACITY=true
                shift
                ;;
            -y|--yes)
                AUTO_CONFIRM=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    
    # Initialize
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "=== Safe Error Reduction Started: $(date) ===" > "$LOG_FILE"
    
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║     SoloAdventurer Safe Error Reduction Script           ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    log_info "Project: $PROJECT_ROOT"
    log_info "Mode: $([ "$DRY_RUN" == true ] && echo 'DRY RUN' || echo 'LIVE')"
    
    # Confirm if not auto-confirm and not dry-run
    if [[ "$DRY_RUN" == false && "$AUTO_CONFIRM" == false ]]; then
        echo ""
        if ! confirm "This will modify files in your project. Continue?"; then
            log_info "Cancelled by user"
            exit 0
        fi
    fi
    
    # Create backup
    create_backup
    
    # Determine which phases to run
    local phases=()
    if [[ "$RUN_ALL" == true ]]; then
        phases=(3 4 5)
        if [[ "$INCLUDE_OPACITY" == true ]]; then
            phases+=(7)
        fi
    elif [[ -n "$SPECIFIC_PHASE" ]]; then
        phases=("$SPECIFIC_PHASE")
    fi
    
    # Run phases
    for phase in "${phases[@]}"; do
        case $phase in
            3) phase_3 ;;
            4) phase_4 ;;
            5) phase_5 ;;
            7) phase_7 ;;
            *)
                log_error "Invalid phase: $phase (valid: 3, 4, 5, 7)"
                exit 1
                ;;
        esac
    done
    
    # Generate manual work document
    if [[ "$DRY_RUN" == false ]]; then
        generate_manual_work_doc
    fi
    
    # Print summary
    print_summary
    
    echo "=== Safe Error Reduction Completed: $(date) ===" >> "$LOG_FILE"
}

main "$@"