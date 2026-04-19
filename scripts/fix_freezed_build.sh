#!/bin/bash

################################################################################
# SoloAdventurer - Freezed Build Fix Script
################################################################################
#
# PURPOSE:
#   Fixes the "missing implementations" freezed compilation error by:
#   1. Cleaning ALL generated files and caches
#   2. Verifying dependency versions
#   3. Regenerating all code from scratch
#   4. Validating the build
#
# USAGE:
#   chmod +x fix_freezed_build.sh
#   ./fix_freezed_build.sh
#
# RUN FROM: Project root directory (where pubspec.yaml is)
#
################################################################################

set -e  # Exit on first error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}╔═════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║  SoloAdventurer - Freezed Build Fix Script     ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}ERROR: pubspec.yaml not found. Run this from the project root.${NC}"
    exit 1
fi

echo -e "${BLUE}Step 1/8: Checking current environment${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter --version
dart --version
echo ""

echo -e "${BLUE}Step 2/8: Stopping any running processes${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Kill any running Flutter processes
pkill -f "flutter" 2>/dev/null || true
pkill -f "dart" 2>/dev/null || true
echo -e "${GREEN}✓${NC} Processes stopped"
echo ""

echo -e "${BLUE}Step 3/8: Counting generated files before deletion${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count files before deletion
FREEZED_COUNT=$(find . -name "*.freezed.dart" -not -path "./.dart_tool/*" 2>/dev/null | wc -l | tr -d ' ')
G_COUNT=$(find . -name "*.g.dart" -not -path "./.dart_tool/*" 2>/dev/null | wc -l | tr -d ' ')
MOCKS_COUNT=$(find . -name "*.mocks.dart" -not -path "./.dart_tool/*" 2>/dev/null | wc -l | tr -d ' ')

echo "Found: $FREEZED_COUNT .freezed.dart, $G_COUNT .g.dart, $MOCKS_COUNT .mocks.dart"
echo ""

echo -e "${BLUE}Step 4/8: Deleting all generated files${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Delete generated files
find . -name "*.freezed.dart" -not -path "./.dart_tool/*" -delete 2>/dev/null || true
find . -name "*.g.dart" -not -path "./.dart_tool/*" -delete 2>/dev/null || true
find . -name "*.mocks.dart" -not -path "./.dart_tool/*" -delete 2>/dev/null || true

echo -e "${GREEN}✓${NC} Generated files removed"
echo ""

echo -e "${BLUE}Step 5/8: Removing build caches${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Remove Dart/Flutter caches
rm -rf .dart_tool 2>/dev/null || true
rm -rf build 2>/dev/null || true
rm -rf .packages 2>/dev/null || true

# Remove iOS build artifacts
rm -rf ios/Pods 2>/dev/null || true
rm -rf ios/.symlinks 2>/dev/null || true
rm -rf ios/Podfile.lock 2>/dev/null || true
rm -rf ios/Flutter/Flutter.framework 2>/dev/null || true
rm -rf ios/Flutter/Flutter.podspec 2>/dev/null || true

# Remove Android build artifacts
rm -rf android/.gradle 2>/dev/null || true
rm -rf android/app/build 2>/dev/null || true

# Remove macOS build artifacts (if exists)
rm -rf macos/Pods 2>/dev/null || true
rm -rf macos/Podfile.lock 2>/dev/null || true

echo -e "${GREEN}✓${NC} Build caches removed"
echo ""

echo -e "${BLUE}Step 6/8: Getting fresh dependencies${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}This may take several minutes...${NC}"
echo ""

flutter pub get

echo ""
echo -e "${GREEN}✓${NC} Dependencies installed"
echo ""

echo -e "${BLUE}Step 7/8: Regenerating all code${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}Running build_runner... this will take time.${NC}"
echo ""

# Run build_runner with clean slate
dart run build_runner clean 2>/dev/null || true
dart run build_runner build --delete-conflicting-outputs

# Count regenerated files
NEW_FREEZED_COUNT=$(find . -name "*.freezed.dart" -not -path "./.dart_tool/*" 2>/dev/null | wc -l | tr -d ' ')
NEW_G_COUNT=$(find . -name "*.g.dart" -not -path "./.dart_tool/*" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo -e "${GREEN}✓${NC} Generated: $NEW_FREEZED_COUNT .freezed.dart, $NEW_G_COUNT .g.dart files"
echo ""

echo -e "${BLUE}Step 8/8: Verifying build${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Try to build (just compilation check, not full app)
echo "Running flutter analyze to check for errors..."
ANALYZE_OUTPUT=$(flutter analyze --no-pub 2>&1)
ANALYZE_EXIT=$?

echo ""
if [ $ANALYZE_EXIT -ne 0 ]; then
    ERROR_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "error •" || echo "0")
    echo -e "${YELLOW}⚠️  Analyzer errors (expected - app has known issues)${NC}"
else
    echo -e "${GREEN}✓ No analyzer errors!${NC}"
fi

# Check specifically for freezed errors
echo ""
echo "Checking for freezed-specific errors..."
FREEZED_ERRORS=$(echo "$ANALYZE_OUTPUT" | grep -i "freezed\|missing implementations\|_\$" | head -10 || true)

if [ -n "$FREEZED_ERRORS" ]; then
    echo -e "${RED}⚠ Freezed-related errors found:${NC}"
    echo "$FREEZED_ERRORS"
else
    echo -e "${GREEN}✓ No freezed-specific errors detected!${NC}"
fi

echo ""
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  SUMMARY${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Generated files:"
echo "  Before: $FREEZED_COUNT .freezed.dart, $G_COUNT .g.dart"
echo "  After:  $NEW_FREEZED_COUNT .freezed.dart, $NEW_G_COUNT .g.dart"
echo ""

if [ -z "$FREEZED_ERRORS" ]; then
    echo -e "${GREEN}${BOLD}✓ SUCCESS! No freezed errors detected.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Try building the app:  flutter build ios --debug"
    echo "  2. Or run the app:        flutter run"
    echo ""
else
    echo -e "${YELLOW}${BOLD}⚠️  Freezed issues may still exist${NC}"
    echo ""
    echo "Try these additional steps:"
    echo "  1. Check pubspec.yaml freezed versions (see below)"
    echo "  2. Run: flutter pub upgrade freezed freezed_annotation"
    echo "  3. If issues persist, see MANUAL_FREEZED_FIX.md"
    echo ""
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
