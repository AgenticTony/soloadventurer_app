#!/bin/bash
set -e
echo "=== Provider Migration Script ==="

# Backup
BACKUP=".migration_backup_$(date +%Y%m%d_%H%M%S)"
echo "Creating backup in $BACKUP..."
cp -r lib "$BACKUP/"

echo "Phase 1: Fixing provider names..."
find lib -name "*.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" -exec sed -i '' 's/authStateProvider/authProvider/g' {} + 2>/dev/null || true
find lib -name "*.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" -exec sed -i '' 's/authNotifierProvider/authProvider/g' {} + 2>/dev/null || true
find lib -name "*.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" -exec sed -i '' 's/authNavigationNotifierProvider/authNavigationProvider/g' {} + 2>/dev/null || true
find lib -name "*.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" -exec sed -i '' 's/profileNotifierProvider/profileDomainNotifierProvider/g' {} + 2>/dev/null || true

echo "Phase 2: Fixing AsyncValue access..."
find lib -name "*.dart" -not -name "*.g.dart" -exec sed -i '' 's/authState\.isLoggedIn/authState.value?.isAuthenticated ?? false/g' {} + 2>/dev/null || true
find lib -name "*.dart" -not -name "*.g.dart" -exec sed -i '' 's/authState\.requiresEmailVerification/authState.value?.requiresEmailVerification ?? false/g' {} + 2>/dev/null || true
find lib -name "*.dart" -not -name "*.g.dart" -exec sed -i '' 's/authState\.requiresPasswordReset/authState.value?.requiresPasswordReset ?? false/g' {} + 2>/dev/null || true

echo "Phase 3: Fixing navigation methods..."
find lib -name "*.dart" -exec sed -i '' 's/\.navigateTo(AuthRoutes\.login)/.navigateToLogin()/g' {} + 2>/dev/null || true
find lib -name "*.dart" -exec sed -i '' 's/\.navigateTo(AuthRoutes\.signup)/.navigateToSignup()/g' {} + 2>/dev/null || true
find lib -name "*.dart" -exec sed -i '' 's/\.navigateTo(AuthRoutes\.home)/.navigateToHome()/g' {} + 2>/dev/null || true
find lib -name "*.dart" -exec sed -i '' 's/\.navigateTo(AuthRoutes\.forgotPassword)/.navigateToForgotPassword()/g' {} + 2>/dev/null || true

echo "Phase 4: Fixing const Failure..."
find lib -name "*.dart" -not -name "*.g.dart" -exec sed -i '' 's/const Failure\./Failure./g' {} + 2>/dev/null || true
find lib -name "*.dart" -not -name "*.g.dart" -exec sed -i '' 's/const Left(Failure/Left(Failure/g' {} + 2>/dev/null || true

echo "Phase 5: Regenerating code..."
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

echo "Phase 6: Checking results..."
ERROR_COUNT=$(flutter analyze 2>&1 | grep -c "error •" || true)
echo "Remaining errors: $ERROR_COUNT"
echo ""
echo "Backup saved in: $BACKUP"
echo "To rollback: rm -rf lib && cp -r $BACKUP/lib ."
