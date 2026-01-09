#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Provider Diagnostics ===${NC}"

echo -e "\n${BLUE}1. INCORRECT PROVIDER NAMES${NC}"

echo -n "   authStateProvider: "
COUNT=$(grep -rl "authStateProvider" lib/ --include="*.dart" 2>/dev/null | grep -v ".g.dart" | wc -l | tr -d ' ')
[ "$COUNT" -gt 0 ] && echo -e "${RED}$COUNT files${NC}" || echo -e "${GREEN}✓ none${NC}"

echo -n "   authNotifierProvider: "
COUNT=$(grep -rl "authNotifierProvider" lib/ --include="*.dart" 2>/dev/null | grep -v ".g.dart" | wc -l | tr -d ' ')
[ "$COUNT" -gt 0 ] && echo -e "${RED}$COUNT files${NC}" || echo -e "${GREEN}✓ none${NC}"

echo -n "   authNavigationNotifierProvider: "
COUNT=$(grep -rl "authNavigationNotifierProvider" lib/ --include="*.dart" 2>/dev/null | grep -v ".g.dart" | wc -l | tr -d ' ')
[ "$COUNT" -gt 0 ] && echo -e "${RED}$COUNT files${NC}" || echo -e "${GREEN}✓ none${NCho -n "   isLoadingProvider: "
COUNT=$(grep -rl "isLoadingProvider" lib/ --include="*.dart" 2>/dev/null | grep -v ".g.dart" | wc -l | tr -d ' ')
[ "$COUNT" -gt 0 ] && echo -e "${RED}$COUNT files${NC}" || echo -e "${GREEN}✓ none${NC}"

echo -e "\n${BLUE}2. ASYNCVALUE ACCESS ISSUES${NC}"

echo -n "   authState.user (should be .value?.user): "
COUNT=$(grep -rn "authState\.user[^?]" lib/ --include="*.dart" 2>/dev/null | grep -v ".g.dart" | grep -v "value?.user" | wc -l | tr -d ' ')
[ "$COUNT" -gt 0 ] && echo -e "${RED}$COUNT occurrences${NC}" || echo -e "${GREEN}✓ none${NC}"

echo -n "   authState.isLoggedIn: "
COUNT=$(grep -rn "authState\.isLoggedIn" lib/ --include="*.dart" 2>/dev/null | grep -v ".g.dart" | wc -l | tr -d ' ')
[ "$COUNT" -gt 0 ] && echo -e "${RED}$COUNT occurrences${NC}" || echo -e "${GREEN}✓ none${NC}"

echo -e "\n${BLUE}3. CONST FAILURE ISSUES${NC}"
echo -n "   const Failure.: "
COUNT=$(grep -rn "const Failure\." lib/ --include="*.dart" 2>/dev/null | grep -v ".g.dart" | wc -l | tr -d ' $COUNT" -gt 0 ] && echo -e "${RED}$COUNT occurrences${NC}" || echo -e "${GREEN}✓ none${NC}"

echo -e "\n${BLUE}4. NAVIGATION METHOD ISSUES${NC}"
echo -n "   navigateTo(AuthRoutes.*): "
COUNT=$(grep -rn "navigateTo(AuthRoutes\." lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
[ "$COUNT" -gt 0 ] && echo -e "${RED}$COUNT occurrences${NC}" || echo -e "${GREEN}✓ none${NC}"

echo -e "\n${BLUE}5. FLUTTER ANALYZE${NC}"
ERROR_COUNT=$(flutter analyze 2>&1 | grep -c "error •" || true)
WARNING_COUNT=$(flutter analyze 2>&1 | grep -c "warning •" || true)
echo -e "   Errors: ${RED}$ERROR_COUNT${NC}"
echo -e "   Warnings: ${YELLOW}$WARNING_COUNT${NC}"

echo -e "\n${BLUE}=== Diagnostic Complete ===${NC}"
