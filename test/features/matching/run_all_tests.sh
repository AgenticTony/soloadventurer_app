#!/bin/bash
# =============================================================================
# SoloAdventurer Test Suite Runner
# =============================================================================
# 
# This script runs the complete test suite for the SoloAdventurer matching
# feature and reports a summary of results.
#
# Usage:
#   ./run_all_tests.sh           # Run all tests
#   ./run_all_tests.sh --unit    # Run only unit tests
#   ./run_all_tests.sh --widget  # Run only widget tests
#   ./run_all_tests.sh --help    # Show help
#
# Requirements:
#   - Flutter SDK installed
#   - Project dependencies installed (flutter pub get)
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$SCRIPT_DIR/reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0
SKIPPED_SUITES=0

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

print_section() {
    echo ""
    echo -e "${YELLOW}>>> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

run_test_suite() {
    local name=$1
    local command=$2
    local report_file="$REPORT_DIR/${name// /_}_$TIMESTAMP.txt"
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    echo ""
    echo "Running: $name"
    echo "-----------------------------------------"
    
    # Create reports directory
    mkdir -p "$REPORT_DIR"
    
    # Run test and capture output
    if eval $command 2>&1 | tee "$report_file"; then
        print_success "$name passed"
        PASSED_SUITES=$((PASSED_SUITES + 1))
        return 0
    else
        print_error "$name failed"
        FAILED_SUITES=$((FAILED_SUITES + 1))
        return 1
    fi
}

show_help() {
    echo "SoloAdventurer Test Suite Runner"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --unit        Run only unit tests"
    echo "  --widget      Run only widget tests"
    echo "  --integration Run integration tests"
    echo "  --analyze     Run only static analysis"
    echo "  --coverage    Generate coverage report"
    echo "  --benchmark   Run performance benchmarks"
    echo "  --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 --unit             # Run only unit tests"
    echo "  $0 --coverage         # Run tests with coverage"
    exit 0
}

# =============================================================================
# Pre-flight Checks
# =============================================================================

check_flutter() {
    print_section "Checking Flutter installation..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found. Please install Flutter SDK."
        exit 1
    fi
    
    FLUTTER_VERSION=$(flutter --version | head -1)
    print_success "Flutter found: $FLUTTER_VERSION"
}

check_dependencies() {
    print_section "Checking dependencies..."
    
    cd "$PROJECT_ROOT"
    
    if [ ! -d "lib" ]; then
        print_warning "lib/ directory not found. This is expected for initial setup."
        print_warning "Skipping dependency check."
        return 0
    fi
    
    if [ ! -f "pubspec.lock" ]; then
        print_warning "Dependencies not installed. Running flutter pub get..."
        flutter pub get
    fi
    
    print_success "Dependencies checked"
}

# =============================================================================
# Test Suite Functions
# =============================================================================

run_analyze() {
    print_section "Running Static Analysis..."
    
    cd "$PROJECT_ROOT"
    
    if [ -d "lib" ]; then
        run_test_suite "Flutter Analyze" "flutter analyze"
    else
        print_warning "Skipping analyze - lib/ directory not found"
        SKIPPED_SUITES=$((SKIPPED_SUITES + 1))
    fi
}

run_unit_tests() {
    print_section "Running Unit Tests..."
    
    cd "$PROJECT_ROOT"
    
    if [ -d "test/unit" ]; then
        run_test_suite "Unit Tests" "flutter test test/unit/ --reporter compact"
    else
        print_warning "Skipping unit tests - test/unit/ directory not found"
        print_info "This is expected for initial framework setup."
        SKIPPED_SUITES=$((SKIPPED_SUITES + 1))
    fi
}

run_widget_tests() {
    print_section "Running Widget Tests..."
    
    cd "$PROJECT_ROOT"
    
    if [ -d "test/widget" ]; then
        run_test_suite "Widget Tests" "flutter test test/widget/ --reporter compact"
    else
        print_warning "Skipping widget tests - test/widget/ directory not found"
        SKIPPED_SUITES=$((SKIPPED_SUITES + 1))
    fi
}

run_integration_tests() {
    print_section "Running Integration Tests..."
    
    cd "$PROJECT_ROOT"
    
    if [ -d "integration_test" ]; then
        print_warning "Integration tests require a running emulator/simulator."
        print_warning "Skipping. To run manually: flutter test integration_test/"
        SKIPPED_SUITES=$((SKIPPED_SUITES + 1))
    else
        print_warning "Skipping integration tests - integration_test/ directory not found"
        SKIPPED_SUITES=$((SKIPPED_SUITES + 1))
    fi
}

run_coverage() {
    print_section "Generating Coverage Report..."
    
    cd "$PROJECT_ROOT"
    
    if [ -d "test" ]; then
        # Run tests with coverage
        flutter test --coverage 2>/dev/null || true
        
        if [ -f "coverage/lcov.info" ]; then
            if command -v genhtml &> /dev/null; then
                genhtml coverage/lcov.info -o coverage/html 2>/dev/null
                print_success "Coverage report generated: coverage/html/index.html"
            else
                print_warning "genhtml not installed. Install with: brew install lcov"
                print_info "Coverage data available at: coverage/lcov.info"
            fi
        else
            print_warning "Coverage data not generated"
        fi
    else
        print_warning "Skipping coverage - test/ directory not found"
    fi
}

run_benchmark() {
    print_section "Running Performance Benchmarks..."
    
    # Check if benchmark SQL script exists
    BENCHMARK_SQL="$SCRIPT_DIR/benchmarks/run_benchmark.sql"
    
    if [ -f "$BENCHMARK_SQL" ]; then
        print_info "To run database benchmarks:"
        print_info "  psql -f $BENCHMARK_SQL"
        SKIPPED_SUITES=$((SKIPPED_SUITES + 1))
    else
        print_warning "Benchmark scripts not found"
        SKIPPED_SUITES=$((SKIPPED_SUITES + 1))
    fi
}

run_all() {
    print_header "SoloAdventurer Test Suite"
    echo "Timestamp: $TIMESTAMP"
    echo "Project: $PROJECT_ROOT"
    
    # Pre-flight checks
    check_flutter
    check_dependencies
    
    # Run all test suites
    run_analyze
    run_unit_tests
    run_widget_tests
    run_integration_tests
    run_coverage
    
    # Print summary
    print_summary
}

# =============================================================================
# Summary Report
# =============================================================================

print_summary() {
    print_header "Test Summary"
    
    echo ""
    echo "Suites Run:    $TOTAL_SUITES"
    echo -e "${GREEN}Passed:        $PASSED_SUITES${NC}"
    echo -e "${RED}Failed:        $FAILED_SUITES${NC}"
    echo -e "${YELLOW}Skipped:       $SKIPPED_SUITES${NC}"
    echo ""
    echo "Reports saved to: $REPORT_DIR"
    echo ""
    
    if [ $FAILED_SUITES -gt 0 ]; then
        echo -e "${RED}=========================================${NC}"
        echo -e "${RED}  TESTS FAILED - Please fix before merge${NC}"
        echo -e "${RED}=========================================${NC}"
        exit 1
    else
        echo -e "${GREEN}=========================================${NC}"
        echo -e "${GREEN}  ALL TESTS PASSED ✓${NC}"
        echo -e "${GREEN}=========================================${NC}"
        exit 0
    fi
}

# =============================================================================
# Main Script
# =============================================================================

# Parse arguments
case "${1:-}" in
    --help|-h)
        show_help
        ;;
    --unit)
        check_flutter
        check_dependencies
        run_unit_tests
        print_summary
        ;;
    --widget)
        check_flutter
        check_dependencies
        run_widget_tests
        print_summary
        ;;
    --integration)
        check_flutter
        check_dependencies
        run_integration_tests
        print_summary
        ;;
    --analyze)
        check_flutter
        check_dependencies
        run_analyze
        print_summary
        ;;
    --coverage)
        check_flutter
        check_dependencies
        run_coverage
        print_summary
        ;;
    --benchmark)
        run_benchmark
        print_summary
        ;;
    *)
        run_all
        ;;
esac
