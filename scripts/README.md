# SoloAdventurer Utility Scripts

This directory contains utility scripts for the SoloAdventurer app development process. These scripts help with testing, performance measurement, database management, and user feedback analysis.

## Available Scripts

### 1. Performance Measurement (`measure_performance.dart`)

A Dart utility for measuring and tracking performance metrics within the app.

**Features:**

- Start and stop measurements for specific operations
- Calculate average durations
- Print summaries of recorded metrics
- Measure execution time of both synchronous and asynchronous functions

**Usage Example:**

```dart
import 'package:soloadventurer/scripts/measure_performance.dart';

// Initialize the performance metrics
final metrics = PerformanceMetrics();

// Measure a specific operation
metrics.startMeasurement('database_query');
// ... perform database query
metrics.stopMeasurement('database_query');

// Measure a function execution
final result = await metrics.measureFunction('api_call', () async {
  // ... perform API call
  return response;
});

// Print a summary of all metrics
metrics.printSummary();
```

### 2. Test Runner (`run_tests.sh`)

A shell script to run tests and collect test results for the SoloAdventurer app.

**Features:**

- Runs Flutter analyzer to check for code issues
- Executes unit tests and captures results
- Calculates test coverage (if lcov is installed)
- Generates detailed test reports with timestamps
- Provides a summary of test results

**Usage:**

```bash
# Make sure the script is executable
chmod +x scripts/run_tests.sh

# Run the script
./scripts/run_tests.sh
```

### 3. Feedback Analyzer (`analyze_feedback.py`)

A Python script to analyze user feedback data from CSV files and generate reports.

**Features:**

- Loads feedback data from CSV files
- Generates statistical summaries of feedback
- Extracts common terms from feedback text
- Analyzes time trends in feedback metrics
- Creates visualizations of rating and category distributions
- Can generate sample data for testing

**Usage:**

```bash
# Make sure the script is executable
chmod +x scripts/analyze_feedback.py

# Generate sample data and analyze it
./scripts/analyze_feedback.py --sample

# Analyze existing feedback data
./scripts/analyze_feedback.py --input feedback_data.csv

# Get help
./scripts/analyze_feedback.py --help
```

### 4. Database Migration Tool (`db_migration.dart`)

A Dart utility for managing database migrations for the SoloAdventurer app.

**Features:**

- Create new migrations with templates
- List all migrations and their status
- Apply pending migrations
- Roll back applied migrations
- Generate schema snapshots

**Usage:**

```bash
# Create a new migration
dart scripts/db_migration.dart create --name add_user_preferences

# List all migrations
dart scripts/db_migration.dart list

# Apply all pending migrations
dart scripts/db_migration.dart apply --all

# Roll back the last applied migration
dart scripts/db_migration.dart rollback --last

# Generate a schema snapshot
dart scripts/db_migration.dart snapshot --output schema.sql

# Get help
dart scripts/db_migration.dart --help
```

### 5. Auth Architecture Validator (`validate_auth_architecture.sh`)

A shell script to validate the Auth feature's architecture and ensure it follows consistent patterns.

**Features:**

- Validates AuthState structure and required fields
- Checks for proper AuthNotifier implementations
- Ensures provider files exist and follow naming conventions
- Detects forbidden patterns (pseudo-type checking with 'is' keyword)
- Verifies state constructor patterns
- Checks for proper field access patterns
- Identifies duplicate AuthNotifier classes
- Validates no problematic .state access

**Usage:**

```bash
# Make sure the script is executable
chmod +x scripts/validate_auth_architecture.sh

# Run the validation
./scripts/validate_auth_architecture.sh
```

**Exit Codes:**

- `0`: All checks passed
- `1`: Critical checks failed (state file missing, no providers, forbidden patterns)
- Script will exit immediately on critical failures

**What It Checks:**

1. ✅ AuthState file exists with proper structure
2. ✅ AuthNotifier files present
3. ✅ Provider files exist
4. ✅ No pseudo-type checking with 'is' keyword
5. ✅ State constructors follow pattern
6. ✅ Proper field access patterns used
7. ✅ Provider naming consistent
8. ✅ No problematic .state access

**Integration with CI:**

Add to your CI pipeline:

```yaml
- name: Validate Auth Architecture
  run: ./scripts/validate_auth_architecture.sh
```

## Dependencies

- **measure_performance.dart**: No external dependencies
- **run_tests.sh**: Requires bash shell
- **analyze_feedback.py**: Requires Python 3 with pandas and matplotlib
- **db_migration.dart**: Requires Dart with path and args packages
- **validate_auth_architecture.sh**: Requires bash shell and grep

## Adding New Scripts

When adding new utility scripts to this directory:

1. Make sure to document the script's purpose and usage in this README
2. Add appropriate error handling and help documentation
3. Make shell and Python scripts executable with `chmod +x`
4. Follow the existing naming conventions
