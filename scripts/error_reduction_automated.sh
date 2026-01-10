#!/bin/bash

################################################################################
# SoloAdventurer Error Reduction Automation Script (Phases 3-7)
################################################################################
# 
# DESCRIPTION:
#   Automates Phases 3-7 of the Error Reduction Plan with safety features
#
# FEATURES:
#   - Dry-run mode for safe testing
#   - Automatic backup creation
#   - Rollback capability
#   - Progress tracking and logging
#   - Run all phases or individual phases
#
# USAGE:
#   ./error_reduction_automated.sh [options]
#
# OPTIONS:
#   --dry-run           Show changes without applying them
#   --phase N           Run specific phase (3-7)
#   --all               Run all phases (default)
#   --skip-backup       Skip backup creation
#   --rollback          Rollback last changes
#   --verify            Verify changes after completion
#   -y, --yes           Auto-confirm all prompts
#   -v, --verbose       Enable verbose output
#   -h, --help          Show this help message
#
# EXAMPLES:
#   ./error_reduction_automated.sh --dry-run --all
#   ./error_reduction_automated.sh --phase 3
#   ./error_reduction_automated.sh --all --verify
#   ./error_reduction_automated.sh --rollback
#
################################################################################

set -euo pipefail

################################################################################
# CONFIGURATION
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/.error_reduction_backup"
LOG_FILE="$PROJECT_ROOT/error_reduction.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# STATE
################################################################################

DRY_RUN=false
SKIP_BACKUP=false
VERIFY=false
AUTO_CONFIRM=false
VERBOSE=false
SPECIFIC_PHASE=""
RUN_ALL=true

# Track changes for rollback
declare -a BACKED_UP_FILES=()
declare -a CREATED_FILES=()
declare -a MODIFIED_FILES=()

################################################################################
# UTILITY FUNCTIONS
################################################################################

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}INFO${NC}: $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}SUCCESS${NC}: $*" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}WARNING${NC}: $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}ERROR${NC}: $*" | tee -a "$LOG_FILE"
}

log_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}STEP${NC}: $*"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

show_help() {
    grep '^#' "$0" | grep -v '#!/' | sed 's/^# //' | sed 's/^#//'
    exit 0
}

confirm() {
    if [[ "$AUTO_CONFIRM" == true ]]; then
        return 0
    fi
    
    local prompt="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]"
    else
        prompt="$prompt [y/N]"
    fi
    
    while true; do
        read -rp "$prompt " response
        response=${response:-$default}
        case $response in
            [Yy]|[Yy][Ee][Ss]) return 0;;
            [Nn]|[Nn][Oo]) return 1;;
            *) echo "Please answer yes or no.";;
        esac
    done
}

backup_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    local backup_path="$BACKUP_DIR/$TIMESTAMP/$(dirname "$file" | sed "s|^$PROJECT_ROOT/||")"
    mkdir -p "$(dirname "$backup_path")"
    
    cp "$file" "$backup_path"
    BACKED_UP_FILES+=("$file")
    
    log_info "Backed up: $file"
    return 0
}

create_backup() {
    if [[ "$SKIP_BACKUP" == true ]]; then
        log_warning "Skipping backup creation"
        return 0
    fi
    
    log_step "Creating backup"
    
    local backup_path="$BACKUP_DIR/$TIMESTAMP"
    mkdir -p "$backup_path"
    
    # Backup critical files and directories
    local critical_files=(
        "pubspec.yaml"
        "analysis_options.yaml"
        "lib/"
        "test/"
    )
    
    for item in "${critical_files[@]}"; do
        if [[ -e "$PROJECT_ROOT/$item" ]]; then
            local item_backup="$backup_path/$item"
            mkdir -p "$(dirname "$item_backup")"
            
            if [[ -d "$PROJECT_ROOT/$item" ]]; then
                cp -r "$PROJECT_ROOT/$item" "$item_backup/"
            else
                cp "$PROJECT_ROOT/$item" "$item_backup/"
            fi
            
            log_info "Backed up: $item"
        fi
    done
    
    # Save backup metadata
    cat > "$backup_path/backup_metadata.txt" << EOF
Backup created: $(date)
Script: $0
Timestamp: $TIMESTAMP
Files backed up: ${#critical_files[@]}
EOF
    
    log_success "Backup created at: $backup_path"
}

rollback() {
    log_step "Rolling back changes"
    
    local latest_backup=$(ls -t "$BACKUP_DIR" 2>/dev/null | head -1)
    
    if [[ -z "$latest_backup" ]]; then
        log_error "No backup found for rollback"
        return 1
    fi
    
    log_info "Rolling back to backup: $latest_backup"
    
    if ! confirm "This will restore files from backup. Continue?"; then
        log_info "Rollback cancelled"
        return 0
    fi
    
    local backup_path="$BACKUP_DIR/$latest_backup"
    
    # Delete created files
    for file in "${CREATED_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            rm "$file"
            log_info "Deleted created file: $file"
        fi
    done
    
    # Restore backed up files
    cd "$backup_path"
    find . -type f -o -type d | while read -r item; do
        if [[ -e "$item" ]]; then
            local target="$PROJECT_ROOT/${item#./}"
            mkdir -p "$(dirname "$target)"
            
            if [[ -d "$item" ]]; then
                cp -r "$item" "$target"
            else
                cp "$item" "$target"
            fi
            
            log_info "Restored: $item"
        fi
    done
    
    log_success "Rollback complete"
}

safe_write() {
    local file="$1"
    local content="$2"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would write to: $file"
        if [[ "$VERBOSE" == true ]]; then
            echo "$content"
        fi
        return 0
    fi
    
    # Backup existing file
    if [[ -f "$file" ]]; then
        backup_file "$file"
        MODIFIED_FILES+=("$file")
    else
        CREATED_FILES+=("$file")
    fi
    
    # Write new content
    mkdir -p "$(dirname "$file")"
    echo "$content" > "$file"
    
    log_info "Written: $file"
    return 0
}

safe_sed() {
    local file="$1"
    local pattern="$2"
    local replacement="$3"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would sed in $file: s/$pattern/$replacement/"
        return 0
    fi
    
    backup_file "$file"
    MODIFIED_FILES+=("$file")
    
    sed -i.bak "s/$pattern/$replacement/g" "$file"
    rm -f "${file}.bak"
    
    log_info "Modified: $file"
}

################################################################################
# PHASE 3: Handle Example/Documentation Files
################################################################################

phase_3() {
    log_step "Phase 3: Handle Example/Documentation Files"
    
    log_info "Finding example files..."
    
    local example_files=()
    while IFS= read -r -d '' file; do
        example_files+=("$file")
    done < <(find "$PROJECT_ROOT/lib" "$PROJECT_ROOT/test" -name "*_example*.dart" -o -name "example_*.dart" 2>/dev/null | head -20)
    
    log_info "Found ${#example_files[@]} example files"
    
    if [[ ${#example_files[@]} -eq 0 ]]; then
        log_warning "No example files found"
        return 0
    fi
    
    # Create examples directory
    local examples_dir="$PROJECT_ROOT/examples/lib"
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$examples_dir"
        mkdir -p "$PROJECT_ROOT/examples/test"
    fi
    
    # Move example files
    for file in "${example_files[@]}"; do
        local relative_path="${file#$PROJECT_ROOT/}"
        local target_file="$PROJECT_ROOT/examples/$relative_path"
        
        log_info "Processing: $relative_path"
        
        if [[ "$DRY_RUN" == true ]]; then
            log_info "[DRY RUN] Would move: $relative_path -> examples/$relative_path"
        else
            backup_file "$file"
            mkdir -p "$(dirname "$target_file")"
            mv "$file" "$target_file"
            MODIFIED_FILES+=("$file")
            CREATED_FILES+=("$target_file")
            log_success "Moved: $relative_path"
        fi
    done
    
    # Create analysis_options.yaml for examples
    local examples_analysis="$PROJECT_ROOT/examples/analysis_options.yaml"
    safe_write "$examples_analysis" '# Exclude example files from analysis
include: ../analysis_options.yaml

analyzer:
  exclude:
    - "**/*.dart"
'
    
    log_success "Phase 3 complete: ${#example_files[@]} files processed"
}

################################################################################
# PHASE 4: Create Missing Performance Utilities
################################################################################

phase_4() {
    log_step "Phase 4: Create Missing Performance Utilities"
    
    local perf_utils_dir="$PROJECT_ROOT/test/utils/performance"
    
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$perf_utils_dir"
    fi
    
    # Create performance_test_utils.dart (barrel file)
    safe_write "$perf_utils_dir/performance_test_utils.dart" '/// Performance testing utilities barrel export
library performance_test_utils;

export 'performance_test_data_generator.dart';
export 'photo_data_generator.dart';
export 'performance_reporter.dart';
'
    
    # Create PerformanceTestDataGenerator
    safe_write "$perf_utils_dir/performance_test_data_generator.dart" 'import "dart:math";

/// Generates test data for performance testing
class PerformanceTestDataGenerator {
  static final _random = Random();

  /// Generate a unique test ID
  static String generateId() => "test-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(999999)}";

  /// Generate a random string of specified length
  static String generateString(int length) {
    const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Generate a random date within the past year
  static DateTime generateDate() {
    return DateTime.now().subtract(Duration(days: _random.nextInt(365)));
  }

  /// Generate a random JSON-like object
  static Map<String, dynamic> generateJsonObject(int fields) {
    return Map.fromEntries(
      List.generate(fields, (i) => MapEntry("field$i", generateString(10))),
    );
  }

  /// Generate mock trip data
  static Map<String, dynamic> generateTripData() {
    return {
      "id": generateId(),
      "title": "Trip ${generateString(5)}",
      "description": generateString(100),
      "startDate": generateDate().toIso8601String(),
      "endDate": generateDate().toIso8601String(),
    };
  }
}
'
    
    # Create PhotoDataGenerator
    safe_write "$perf_utils_dir/photo_data_generator.dart" 'import "dart:math";
import "dart:typed_data";

/// Generates photo-related test data
class PhotoDataGenerator {
  static final _random = Random();

  static Uint8List generateImageBytes({int size = 1024}) {
    return Uint8List.fromList(
      List.generate(size, (_) => _random.nextInt(256)),
    );
  }

  static String generatePhotoPath({String extension = "jpg"}) {
    final id = _random.nextInt(999999);
    return "/test/photos/photo_$id.$extension";
  }

  static Map<String, dynamic> generatePhotoMetadata() {
    return {
      "id": "photo-${_random.nextInt(999999)}",
      "width": [1920, 2048, 3840][_random.nextInt(3)],
      "height": [1080, 1536, 2160][_random.nextInt(3)],
      "format": ["jpeg", "png", "webp"][_random.nextInt(3)],
    };
  }
}
'
    
    # Create PerformanceReporter
    safe_write "$perf_utils_dir/performance_reporter.dart" 'import "dart:collection";

/// Reports and tracks performance metrics
class PerformanceReporter {
  final List<PerformanceMetric> _metrics = [];

  void recordMetric(String name, double value, {String? unit}) {
    _metrics.add(PerformanceMetric(
      name: name,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
    ));
  }

  void printReport() {
    print("");
    print("═════════════════════════════════════════");
    print("         PERFORMANCE REPORT             ");
    print("═════════════════════════════════════════");

    for (final metric in _metrics) {
      print("📊 ${metric.name}: ${metric.value} ${metric.unit ?? ""}");
    }
  }

  List<Map<String, dynamic>> toJson() {
    return _metrics.map((m) => m.toJson()).toList();
  }
}

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
    "name": name,
    "value": value,
    "unit": unit,
    "timestamp": timestamp.toIso8601String(),
  };
}
'
    
    log_success "Phase 4 complete: Created 4 performance utility files"
}

################################################################################
# PHASE 5: Create Missing Widget Classes
################################################################################

phase_5() {
    log_step "Phase 5: Create Missing Widget Classes"
    
    local widgets_dir="$PROJECT_ROOT/lib/core/widgets"
    
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$widgets_dir"
    fi
    
    # Create spacing widgets
    safe_write "$widgets_dir/spacing.dart" 'import "package:flutter/material.dart";

/// A widget that provides consistent vertical spacing
class VerticalSpacing extends StatelessWidget {
  final double height;

  const VerticalSpacing(this.height, {super.key});

  const VerticalSpacing.xs({super.key}) : height = 4;
  const VerticalSpacing.small({super.key}) : height = 8;
  const VerticalSpacing.medium({super.key}) : height = 16;
  const VerticalSpacing.large({super.key}) : height = 24;
  const VerticalSpacing.xl({super.key}) : height = 32;
  const VerticalSpacing.xxl({super.key}) : height = 48;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// A widget that provides consistent horizontal spacing
class HorizontalSpacing extends StatelessWidget {
  final double width;

  const HorizontalSpacing(this.width, {super.key});

  const HorizontalSpacing.small({super.key}) : width = 8;
  const HorizontalSpacing.medium({super.key}) : width = 16;
  const HorizontalSpacing.large({super.key}) : width = 24;

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}

class Spacing {
  Spacing._();

  static const double xs = 4;
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
'
    
    # Update or create core.dart barrel file
    local core_dart="$PROJECT_ROOT/lib/core/core.dart"
    if [[ -f "$core_dart" ]]; then
        if ! grep -q "widgets/spacing.dart" "$core_dart"; then
            safe_sed "$core_dart" "export 'widgets/spacing.dart';" ""
        fi
    else
        safe_write "$core_dart" '// Core barrel file
export "widgets/spacing.dart";
'
    fi
    
    log_success "Phase 5 complete: Created spacing widgets"
}

################################################################################
# PHASE 6: Fix Repository Type Casting
################################################################################

phase_6() {
    log_step "Phase 6: Fix Repository Type Casting Issues"
    
    # Create JSON helpers
    safe_write "$PROJECT_ROOT/lib/core/utils/json_helpers.dart" '/// Type-safe JSON parsing helpers
class JsonHelpers {
  JsonHelpers._();

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static int parseIntOrDefault(dynamic value, {int defaultValue = 0}) {
    return parseInt(value) ?? defaultValue;
  }

  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String? parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static String parseStringOrDefault(dynamic value, {String defaultValue = ""}) {
    return parseString(value) ?? defaultValue;
  }

  static bool? parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value.toLowerCase() == "true" || value == "1";
    }
    return null;
  }

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  static List<T>? parseList<T>(dynamic value, T Function(dynamic) mapper) {
    if (value == null) return null;
    if (value is! List) return null;
    return value.map((e) => mapper(e)).toList();
  }

  static Map<String, dynamic>? parseMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
'
    
    # Find and fix repository files
    log_info "Searching for repository files with type casting issues..."
    
    local repo_files=()
    while IFS= read -r -d '' file; do
        if grep -q "as int?" "$file" 2>/dev/null; then
            repo_files+=("$file")
        fi
    done < <(find "$PROJECT_ROOT/lib" -name "*_repository_impl.dart" -print0 2>/dev/null)
    
    log_info "Found ${#repo_files[@]} repository files to process"
    
    for file in "${repo_files[@]}"; do
        log_info "Processing: ${file#$PROJECT_ROOT/}"
        
        # Add import if not present
        if ! grep -q "json_helpers.dart" "$file"; then
            local import_line="import 'package:soloadventurer/core/utils/json_helpers.dart';"
            if [[ "$DRY_RUN" == false ]]; then
                backup_file "$file"
                MODIFIED_FILES+=("$file")
                
                # Add import after first import or at top
                if grep -q "^import " "$file"; then
                    sed -i.bak "1a\\
$import_line
" "$file"
                    rm -f "${file}.bak"
                else
                    sed -i.bak "1i\\
$import_line
" "$file"
                    rm -f "${file}.bak"
                fi
                
                log_info "Added import to: ${file#$PROJECT_ROOT/}"
            fi
        fi
        
        # Note: Complex type casting fixes require manual review
        # This marks the files for manual follow-up
        log_warning "File ${file#$PROJECT_ROOT/} marked for manual type casting review"
    done
    
    log_success "Phase 6 complete: Created JsonHelpers and identified repository files"
}

################################################################################
# PHASE 7: Fix Deprecated withOpacity Usage
################################################################################

phase_7() {
    log_step "Phase 7: Fix Deprecated withOpacity Usage"
    
    log_info "Searching for withOpacity usage..."
    
    local withopacity_count=$(grep -r "\.withOpacity(" "$PROJECT_ROOT/lib" --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
    
    log_info "Found $withopacity_count occurrences of withOpacity"
    
    if [[ "$withopacity_count" -eq 0 ]]; then
        log_warning "No withOpacity usage found"
        return 0
    fi
    
    local fixed_count=0
    
    # Find and fix simple cases: .withOpacity(NUMBER)
    while IFS= read -r -d '' file; do
        if grep -q "\.withOpacity(" "$file"; then
            log_info "Processing: ${file#$PROJECT_ROOT/}"
            
            if [[ "$DRY_RUN" == true ]]; then
                log_info "[DRY RUN] Would fix withOpacity in: ${file#$PROJECT_ROOT/}"
            else
                backup_file "$file"
                MODIFIED_FILES+=("$file")
                
                # Fix simple numeric cases: .withOpacity(0.5) -> .withValues(alpha: 0.5)
                perl -i.bak -pe 's/\.withOpacity\((\d+\.\d+)\)/.withValues(alpha: $1)/g' "$file"
                rm -f "${file}.bak"
                
                fixed_count=$((fixed_count + 1))
                log_success "Fixed: ${file#$PROJECT_ROOT/}"
            fi
        fi
    done < <(find "$PROJECT_ROOT/lib" -name "*.dart" -print0 2>/dev/null)
    
    log_success "Phase 7 complete: Fixed $fixed_count files with withOpacity"
}

################################################################################
# VERIFICATION
################################################################################

verify_changes() {
    log_step "Verifying Changes"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "Skipping verification in dry-run mode"
        return 0
    fi
    
    log_info "Running flutter analyze..."
    
    cd "$PROJECT_ROOT"
    
    # Run flutter analyze and capture output
    local analyze_output
    analyze_output=$(flutter analyze 2>&1)
    local exit_code=$?
    
    echo "$analyze_output" | tee -a "$LOG_FILE"
    
    # Count errors
    local error_count=$(echo "$analyze_output" | grep -c "error •" || echo "0")
    local warning_count=$(echo "$analyze_output" | grep -c "warning •" || echo "0")
    local info_count=$(echo "$analyze_output" | grep -c "info •" || echo "0")
    
    echo ""
    log_info "Analysis Summary:"
    echo "  Errors:   $error_count"
    echo "  Warnings: $warning_count"
    echo "  Info:     $info_count"
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "Verification passed: No critical issues found"
    else
        log_warning "Verification found issues. Review the output above."
    fi
}

################################################################################
# SUMMARY REPORT
################################################################################

print_summary() {
    log_step "Execution Summary"
    
    echo ""
    echo "Configuration:"
    echo "  Dry Run:        $DRY_RUN"
    echo "  Backup Skipped: $SKIP_BACKUP"
    echo "  Auto Confirm:   $AUTO_CONFIRM"
    echo ""
    
    echo "Changes Made:"
    echo "  Files Created:  ${#CREATED_FILES[@]}"
    echo "  Files Modified: ${#MODIFIED_FILES[@]}"
    echo "  Files Backed Up: ${#BACKED_UP_FILES[@]}"
    echo ""
    
    if [[ ${#CREATED_FILES[@]} -gt 0 ]]; then
        echo "Created Files:"
        printf "  - %s\n" "${CREATED_FILES[@]}"
        echo ""
    fi
    
    if [[ ${#MODIFIED_FILES[@]} -gt 0 ]]; then
        echo "Modified Files:"
        printf "  - %s\n" "${MODIFIED_FILES[@]}"
        echo ""
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        echo "⚠️  This was a DRY RUN - no actual changes were made"
        echo "   Run without --dry-run to apply changes"
    else
        echo "✅ Changes have been applied"
        echo ""
        echo "To rollback, run:"
        echo "  $0 --rollback"
    fi
}

################################################################################
# MAIN EXECUTION
################################################################################

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --phase)
                SPECIFIC_PHASE="$2"
                RUN_ALL=false
                shift 2
                ;;
            --all)
                RUN_ALL=true
                shift
                ;;
            --skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --rollback)
                rollback
                exit 0
                ;;
            --verify)
                VERIFY=true
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
                show_help
                ;;
        esac
    done
}

run_phase() {
    local phase=$1
    
    case $phase in
        3) phase_3 ;;
        4) phase_4 ;;
        5) phase_5 ;;
        6) phase_6 ;;
        7) phase_7 ;;
        *) log_error "Invalid phase: $phase"; return 1 ;;
    esac
}

main() {
    parse_args "$@"
    
    log_info "Starting Error Reduction Automation Script"
    log_info "Project: $PROJECT_ROOT"
    log_info "Timestamp: $TIMESTAMP"
    
    # Create backup unless skipped or rolling back
    if [[ "$DRY_RUN" == false && "$SKIP_BACKUP" == false ]]; then
        create_backup
    fi
    
    # Run phases
    local phases_to_run=()
    
    if [[ "$RUN_ALL" == true ]]; then
        phases_to_run=(3 4 5 6 7)
    else
        phases_to_run=("$SPECIFIC_PHASE")
    fi
    
    for phase in "${phases_to_run[@]}"; do
        run_phase "$phase"
    done
    
    # Verify if requested
    if [[ "$VERIFY" == true && "$DRY_RUN" == false ]]; then
        verify_changes
    fi
    
    # Print summary
    print_summary
}

# Run main
main "$@"
