#!/bin/bash

# Script to run tests and collect test results for SoloAdventurer app

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running tests for SoloAdventurer app...${NC}"
echo "==============================================="

# Create results directory if it doesn't exist
RESULTS_DIR="test_results"
mkdir -p $RESULTS_DIR

# Get current date for the report
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H-%M-%S")
REPORT_FILE="$RESULTS_DIR/test_report_$DATE-$TIME.txt"

# Write header to report file
echo "SoloAdventurer Test Report" > $REPORT_FILE
echo "Date: $DATE" >> $REPORT_FILE
echo "Time: $TIME" >> $REPORT_FILE
echo "===============================================" >> $REPORT_FILE

# Run Flutter analyzer and capture results
echo -e "\n${YELLOW}Running Flutter analyzer...${NC}"
echo -e "\nFlutter Analyzer Results:" >> $REPORT_FILE
flutter analyze > "$RESULTS_DIR/analyzer_output.txt" 2>&1
ANALYZER_EXIT_CODE=$?
cat "$RESULTS_DIR/analyzer_output.txt" | tee -a $REPORT_FILE

if [ $ANALYZER_EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}Analyzer completed successfully.${NC}"
  echo "Analyzer Status: PASS" >> $REPORT_FILE
else
  echo -e "${RED}Analyzer found issues.${NC}"
  echo "Analyzer Status: FAIL" >> $REPORT_FILE
fi

# Count linter warnings
LINTER_WARNINGS=$(grep -c "warning" "$RESULTS_DIR/analyzer_output.txt")
echo "Linter Warnings: $LINTER_WARNINGS" >> $REPORT_FILE

# Run unit tests and capture results
echo -e "\n${YELLOW}Running unit tests...${NC}"
echo -e "\nUnit Test Results:" >> $REPORT_FILE
flutter test --machine > "$RESULTS_DIR/unit_test_output.json" 2>&1
UNIT_TEST_EXIT_CODE=$?
flutter test | tee -a $REPORT_FILE

if [ $UNIT_TEST_EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}Unit tests passed.${NC}"
  echo "Unit Test Status: PASS" >> $REPORT_FILE
else
  echo -e "${RED}Unit tests failed.${NC}"
  echo "Unit Test Status: FAIL" >> $REPORT_FILE
fi

# Calculate test coverage (if lcov is installed)
if command -v lcov &> /dev/null && command -v genhtml &> /dev/null; then
  echo -e "\n${YELLOW}Calculating test coverage...${NC}"
  echo -e "\nTest Coverage:" >> $REPORT_FILE
  
  # Run tests with coverage
  flutter test --coverage
  
  # Generate coverage report
  genhtml coverage/lcov.info -o coverage/html
  
  # Extract coverage percentage
  COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $4}')
  echo "Test Coverage: $COVERAGE" | tee -a $REPORT_FILE
  echo "Coverage report generated at: coverage/html/index.html" | tee -a $REPORT_FILE
else
  echo -e "\n${YELLOW}Skipping coverage calculation. lcov not installed.${NC}"
  echo "Test Coverage: Not calculated (lcov not installed)" >> $REPORT_FILE
fi

# Summary
echo -e "\n${YELLOW}Test Summary:${NC}"
echo -e "\nTest Summary:" >> $REPORT_FILE
echo "Linter Warnings: $LINTER_WARNINGS" | tee -a $REPORT_FILE
if [ $UNIT_TEST_EXIT_CODE -eq 0 ]; then
  echo -e "Unit Tests: ${GREEN}PASS${NC}" | tee -a $REPORT_FILE
else
  echo -e "Unit Tests: ${RED}FAIL${NC}" | tee -a $REPORT_FILE
fi

echo -e "\nDetailed report saved to: $REPORT_FILE"
echo -e "${YELLOW}===============================================${NC}" 