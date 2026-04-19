# SoloAdventurer QA Documentation

This directory contains all quality assurance documentation and testing utilities for the SoloAdventurer matching feature.

## Directory Structure

```
qa/
├── README.md                    # This file
├── WEEK1_TEST_PLAN.md           # Week 1 test plan with test cases
├── TEST_FRAMEWORK_SETUP.md      # Test framework architecture and setup
├── run_all_tests.sh             # Script to run all tests
├── reports/                     # Test execution reports (generated)
├── benchmarks/                  # Performance benchmark scripts
│   └── run_benchmark.sql
└── test_utils/                  # Test utilities and fixtures
    ├── fixtures.dart            # Central fixture exports
    ├── fixtures/
    │   ├── users.dart           # User test fixtures
    │   ├── trips.dart           # Trip test fixtures
    │   ├── connections.dart     # Connection/message fixtures
    │   └── activities.dart      # Activity test fixtures
    ├── mock_supabase_client.dart # Supabase mock helpers
    ├── test_data_generator.dart  # Programmatic data generation
    └── test_helpers.dart        # Test assertion utilities
```

## Quick Start

### Running Tests

```bash
# Run all tests
./run_all_tests.sh

# Run specific test suite
./run_all_tests.sh --unit
./run_all_tests.sh --widget
./run_all_tests.sh --coverage

# Show help
./run_all_tests.sh --help
```

### Test Plan Overview

The **Week 1 Test Plan** covers:

- **Matching Algorithm Tests**: 10 spatial query tests
- **Performance Tests**: 7 benchmark tests (100K trips)
- **Women-Only Mode Tests**: 5 functional + 5 security tests
- **RLS Policy Tests**: 16 tests
- **Edge Function Tests**: 16 tests
- **P0 Feature Tests**: Trip Entry + Matching

**Total: 57+ test cases**

### Test Categories

| Category | Tests | Priority |
|----------|-------|----------|
| Matching Algorithm | 10 | P0 |
| Matching Performance | 7 | P0 |
| Women-Only Mode | 10 | P0 (Security Critical) |
| RLS Policies | 16 | P0 |
| Edge Functions | 16 | P0 |
| Feature: Trip Entry | 11 | P0 |
| Feature: Matching | 11 | P0 |

### Using Test Fixtures

```dart
import 'package:soloadventurer/qa/test_utils/fixtures.dart';

void main() {
  test('user fixture example', () {
    // Use predefined fixtures
    expect(Users.alex.gender, equals('female'));
    expect(Users.marcus.gender, equals('male'));
    expect(Users.priya.womenOnlyMode, isTrue);
    
    // Use trip fixtures
    expect(Trips.parisAlex.overlapsWith(Trips.parisMarcus), isTrue);
    expect(Trips.parisAlex.overlapsWith(Trips.parisNoOverlap), isFalse);
  });
}
```

### Using Test Data Generators

```dart
import 'package:soloadventurer/qa/test_utils/test_data_generator.dart';

void main() {
  test('generate test data', () {
    // Generate random user
    final user = TestDataGenerator.user();
    
    // Generate random trip
    final trip = TestDataGenerator.trip();
    
    // Generate benchmark data
    final benchmarkTrips = TestDataGenerator.benchmarkTrips(count: 100000);
    expect(benchmarkTrips.length, equals(100000));
  });
}
```

### Using Mock Supabase

```dart
import 'package:soloadventurer/qa/test_utils/mock_supabase_client.dart';

void main() {
  test('mock supabase response', () {
    // Build mock responses
    final success = MockSupabaseResponseBuilder.successResponse(
      data: [{'id': '1', 'name': 'Test'}],
    );
    
    final error = MockSupabaseResponseBuilder.errorResponse(
      message: 'Not found',
    );
    
    // Mock RPC responses
    final matches = MockRpcResponses.getMatches(
      matches: [{'user_id': 'user-1'}],
    );
  });
}
```

## Week 1 Focus Areas

### 1. Matching Algorithm (P0)
- Spatial queries with PostGIS
- Date overlap calculations
- Distance-based filtering
- Sorting by relevance

### 2. Women-Only Mode (P0 - Security Critical)
- RLS policy enforcement
- Gender-based filtering
- Security bypass prevention
- CTO sign-off required

### 3. Performance (P0)
- 100K trip benchmark
- p95 latency < 2 seconds
- Spatial index verification
- Concurrent query testing

### 4. RLS Policies (P0)
- User can only see own data
- Matches visible to authorized users
- Women-only mode RLS enforcement

## Pass/Fail Criteria

| Metric | Target |
|--------|--------|
| Test Execution Rate | 100% |
| Pass Rate (P0 tests) | 100% |
| Pass Rate (All tests) | >95% |
| P0 Bugs Open | 0 |
| P1 Bugs Open | 0 |
| Benchmark p95 Latency | <2s |

## Reports

Test reports are saved to `qa/reports/` with timestamps:

- `Flutter_Analyze_YYYYMMDD_HHMMSS.txt`
- `Unit_Tests_YYYYMMDD_HHMMSS.txt`
- `Widget_Tests_YYYYMMDD_HHMMSS.txt`

## Next Steps

After Week 1, the test framework will be extended to cover:

- **Week 5-6**: Real-time messaging tests
- **Week 7**: Activity suggestion tests
- **Week 8-9**: Women-only mode + Onfido integration tests
- **Week 10-11**: Safety feature tests (SOS, Check-ins)
- **Week 12**: Offline sync tests

## Contact

- **QA Lead**: qa-lead
- **Security Lead**: security-lead (for safety feature sign-off)
- **CTO**: cto (for final approval)
