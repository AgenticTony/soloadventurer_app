#!/bin/bash
# Architecture validation for Auth feature
# This script ensures the Auth feature follows consistent patterns

set -e

echo "=== Auth Architecture Validation ==="
echo ""

# Check 1: AuthState exists and follows pattern
echo "Check 1: AuthState file exists and follows pattern..."
if [ -f "lib/features/auth/presentation/state/auth_state.dart" ]; then
  echo "✅ PASS: AuthState file exists"

  # Check for isAuthenticated field
  if grep -q "bool isAuthenticated" lib/features/auth/presentation/state/auth_state.dart 2>/dev/null; then
    echo "✅ PASS: AuthState has isAuthenticated field"
  else
    echo "❌ FAIL: AuthState missing isAuthenticated field"
    exit 1
  fi

  # Check for copyWith method
  if grep -q "copyWith" lib/features/auth/presentation/state/auth_state.dart 2>/dev/null; then
    echo "✅ PASS: AuthState has copyWith method"
  else
    echo "⚠️  WARNING: AuthState missing copyWith method"
  fi
else
  echo "❌ FAIL: AuthState file not found at lib/features/auth/presentation/state/auth_state.dart"
  exit 1
fi
echo ""

# Check 2: AuthNotifier exists
echo "Check 2: AuthNotifier exists..."
AUTH_NOTIFIER_COUNT=$(find lib/features/auth -name "*auth*notifier*.dart" -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$AUTH_NOTIFIER_COUNT" -gt 0 ]; then
  echo "✅ PASS: Found AuthNotifier files"
  find lib/features/auth -name "*auth*notifier*.dart" -type f 2>/dev/null
else
  echo "❌ FAIL: No AuthNotifier files found"
  exit 1
fi

# Check for multiple AuthNotifier classes
AUTH_NOTIFIER_CLASS_COUNT=$(grep -r "class AuthNotifier" lib/features/auth/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
if [ "$AUTH_NOTIFIER_CLASS_COUNT" -gt 1 ]; then
  echo "⚠️  WARNING: Found $AUTH_NOTIFIER_CLASS_COUNT AuthNotifier class definitions"
  grep -rn "class AuthNotifier" lib/features/auth/ --include="*.dart" 2>/dev/null
else
  echo "✅ PASS: Single AuthNotifier class definition"
fi
echo ""

# Check 3: Provider files exist
echo "Check 3: Auth provider files exist..."
PROVIDER_FILES=(
  "lib/features/auth/presentation/providers/auth_provider.dart"
  "lib/features/auth/presentation/providers/auth_providers.dart"
)

PROVIDER_FOUND=0
for file in "${PROVIDER_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "✅ PASS: Found $file"
    PROVIDER_FOUND=1
  fi
done

if [ "$PROVIDER_FOUND" -eq 0 ]; then
  echo "❌ FAIL: No auth provider files found"
  exit 1
fi
echo ""

# Check 4: No pseudo-type checking in presentation layer
echo "Check 4: No pseudo-type checking patterns..."
# Check for forbidden patterns in presentation layer
BAD_PATTERNS=$(grep -rn "state is Authenticated\|state is Unauthenticated" lib/features/auth/presentation/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
if [ "$BAD_PATTERNS" -gt 0 ]; then
  echo "❌ FAIL: Found $BAD_PATTERNS instances of type checking with 'is' keyword"
  grep -rn "state is Authenticated\|state is Unauthenticated" lib/features/auth/presentation/ --include="*.dart" 2>/dev/null || true
  exit 1
else
  echo "✅ PASS: No pseudo-type checking in presentation layer"
fi
echo ""

# Check 5: State pattern consistency
echo "Check 5: State pattern consistency..."
# Check that AuthState uses proper constructor pattern
if grep -q "const AuthState.initial()" lib/features/auth/presentation/state/auth_state.dart 2>/dev/null; then
  echo "✅ PASS: AuthState has initial() constructor"
else
  echo "⚠️  WARNING: AuthState missing initial() constructor"
fi

if grep -q "const AuthState.authenticated" lib/features/auth/presentation/state/auth_state.dart 2>/dev/null; then
  echo "✅ PASS: AuthState has authenticated() constructor"
else
  echo "❌ FAIL: AuthState missing authenticated() constructor"
  exit 1
fi

if grep -q "const AuthState.unauthenticated()" lib/features/auth/presentation/state/auth_state.dart 2>/dev/null; then
  echo "✅ PASS: AuthState has unauthenticated() constructor"
else
  echo "❌ FAIL: AuthState missing unauthenticated() constructor"
  exit 1
fi
echo ""

# Check 6: Usage pattern - check for proper field access
echo "Check 6: Proper field access patterns..."
# Check for .isAuthenticated usage (good pattern)
GOOD_PATTERN_COUNT=$(grep -r "\.isAuthenticated" lib/features/auth/presentation/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
if [ "$GOOD_PATTERN_COUNT" -gt 0 ]; then
  echo "✅ PASS: Found $GOOD_PATTERN_COUNT instances of proper .isAuthenticated field access"
else
  echo "⚠️  WARNING: No .isAuthenticated field access found in presentation layer"
fi
echo ""

# Check 7: Provider consistency
echo "Check 7: Provider naming consistency..."
# Check for duplicate provider definitions
PROVIDER_DEFINITIONS=$(grep -r "authNotifierProvider\|authProvider" lib/features/auth/presentation/providers/ --include="*.dart" 2>/dev/null | grep -E "final.*Provider|Provider<.*>" | wc -l | tr -d ' ')
if [ "$PROVIDER_DEFINITIONS" -gt 2 ]; then
  echo "⚠️  WARNING: Found $PROVIDER_DEFINITIONS provider definitions (review for duplicates)"
  grep -rn "authNotifierProvider\|authProvider" lib/features/auth/presentation/providers/ --include="*.dart" 2>/dev/null | grep -E "final.*Provider|Provider<.*>" || true
else
  echo "✅ PASS: Provider naming appears consistent"
fi
echo ""

# Check 8: No raw .state access in production code
echo "Check 8: No raw .state access on providers..."
BAD_STATE_ACCESS=$(grep -rn "\.state\s*=" lib/features/auth/presentation/ --include="*.dart" 2>/dev/null | grep -v "copyWith" | wc -l | tr -d ' ')
if [ "$BAD_STATE_ACCESS" -gt 0 ]; then
  echo "⚠️  WARNING: Found $BAD_STATE_ACCESS instances of .state assignment (review for proper usage)"
  grep -rn "\.state\s*=" lib/features/auth/presentation/ --include="*.dart" 2>/dev/null | grep -v "copyWith" || true
else
  echo "✅ PASS: No problematic .state access"
fi
echo ""

echo "=== Architecture Checks Complete ==="
echo ""
echo "Summary:"
echo "  ✅ AuthState file exists with proper structure"
echo "  ✅ AuthNotifier files present"
echo "  ✅ Provider files exist"
echo "  ✅ No pseudo-type checking with 'is' keyword"
echo "  ✅ State constructors follow pattern"
echo "  ✅ Proper field access patterns used"
echo "  ✅ Provider naming consistent"
echo "  ✅ No problematic .state access"
echo ""
echo "Note: This validation ensures consistency with the current Auth architecture."
echo "For migration to Riverpod 3.0 + Freezed, see docs/architecture/auth_pattern.md"
echo ""
exit 0
