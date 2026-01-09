🎓 Interactive Claude Code Tutorial

  Learn by Doing!

  Let me walk you through everything step by step. We'll start simple and build up.

  ---
  PART 1: The Basics (Start Here) 🚀

  Lesson 1: Your First Skill 📝

  Let's try the doctor skill - it checks your project's health.

  Type this:
  /doctor

  What happens:
  1. I'll run flutter doctor
  2. Check dependencies
  3. Analyze code quality
  4. Check test coverage
  5. Show Supabase connection status

  You'll see:
  🏥 SoloAdventurer Health Check

  Flutter Environment: ✅ Healthy
  Dependencies: ✅ Up to date
  Code Quality: ⚠️ 5 issues
  Test Coverage: 68%
  Supabase: ✅ Connected

  Recommendations:
  1. Fix 5 analyzer issues
  2. Improve test coverage

  ---
  Lesson 2: Running Tests 🧪

  Let's run your tests:

  Type this:
  /test

  What happens:
  1. Runs flutter test --coverage
  2. Shows test results
  3. Highlights failures
  4. Shows coverage report

  You'll see:
  Running tests...

  ✅ test/features/auth/* - All passing (12 tests)
  ⚠️  test/features/profile/* - 2 failures

  Test Coverage: 68%

  ---
  Lesson 3: Code Generation 🔧

  Let's generate some code:

  Type this:
  /gen

  What happens:
  1. Runs dart run build_runner build --delete-conflicting-outputs
  2. Generates freezed classes
  3. Generates Riverpod providers
  4. Generates JSON serialization

  Takes ~30 seconds - go get coffee! ☕

  ---
  PART 2: Fixing Issues 🔨

  Lesson 4: Analyzing & Fixing 🔍

  Let's check for code issues:

  Type this:
  /analyze

  What happens:
  1. Runs flutter analyze
  2. Runs dart fix --apply
  3. Shows fixed issues
  4. Lists remaining problems

  You'll see:
  🔍 Analyzing code...

  Found 15 issues:
  - 10 can be auto-fixed
  - 5 need manual attention

  Auto-fixing...
  ✅ Fixed: 10 issues

  Remaining issues:
  1. lib/auth/service.dart:45 - Missing return type
  2. lib/profile/data/repository.dart:78 - Unnecessary cast
  ...

  ---
  PART 3: Using Agents 🤖

  Lesson 5: Code Simplifier ✨

  This is where the magic happens! Let's use a specialized AI agent.

  Type this:
  Use the code-simplifier agent to clean up the auth module

  What happens:
  1. I spawn a specialized AI agent
  2. It reads your auth code
  3. Finds complex/duplicate code
  4. Simplifies it
  5. Runs tests to verify
  6. Returns a report

  You'll see:
  📝 Simplified: lib/auth/service.dart:42

  Before:
  function login(user, pass, remember) {
    if (user != null) {
      if (pass != null) {
        if (remember) {
          // 20 lines of nested code
        }
      }
    }
  }

  After:
  function login(user, pass, remember) {
    if (!user || !pass) return;
    if (!remember) return;
    // Simplified logic
  }

  Benefit: Reduced nesting, improved readability

  ✅ Simplification complete
  - Removed 50 lines of duplicate code
  - Extracted 3 functions
  - Improved 12 variable names

  Tests: ✅ Passing

  ---
  Lesson 6: Test Fixer 🧪

  Let's say tests are failing. Use the test-fixer agent:

  Type this:
  Use the test-fixer agent to fix the failing auth tests

  What happens:
  1. Agent analyzes the test failure
  2. Identifies root cause
  3. Fixes the issue
  4. Verifies the fix

  ---
  Lesson 7: Verification Loop 🔄

  This is Boris's #1 tip - verification = 2-3x quality!

  Type this:
  /verify

  What happens:
  1. I run multiple verification passes:
    - Code review
    - Test coverage
    - Type safety
    - Build check
    - Integration test
    - Self-correction
    - Re-verify

  You'll see:
  🔄 Verification Loop...

  Pass 1: Code Review
  ✅ Code is clean

  Pass 2: Test Coverage
  ⚠️  Missing edge case tests

  Pass 3: Type Safety
  ✅ All types correct

  Pass 4: Build
  ✅ Build successful

  Pass 5: Integration Test
  ✅ All integrations working

  Pass 6: Self-Correction
  Added 3 test cases for edge cases

  Pass 7: Re-verify
  ✅ All checks passing

  Result: 🎉 Verified and improved!

  ---
  PART 4: Feature Development 🏗️

  Lesson 8: Creating a New Feature 🆕

  Let's create a notifications feature:

  Type this:
  /feature notifications

  What happens:
  1. I create the full feature structure
  2. Follows your Clean Architecture
  3. Includes example files
  4. Creates test structure

  You'll get:
  lib/features/notifications/
  ├── domain/
  │   ├── entities/
  │   ├── repositories/
  │   └── services/
  ├── data/
  │   ├── models/
  │   ├── datasources/
  │   └── repositories/
  ├── presentation/
  │   ├── providers/
  │   ├── screens/
  │   └── widgets/
  └── infrastructure/
      └── services/

  ---
  Lesson 9: Creating a Provider 📦

  Let's create a Riverpod provider:

  Type this:
  /provider notifications notifier

  What happens:
  1. I create a notifier with AsyncValue
  2. Follows your Riverpod patterns
  3. Includes proper error handling
  4. Adds tests

  ---
  PART 5: Database Operations 🗄️

  Lesson 10: Viewing Database Schema 👀

  Type this:
  /schema

  What happens:
  1. I query your Supabase database
  2. Show all tables
  3. Show columns and types
  4. Show relationships

  You'll see:
  📊 Database Schema

  Table: users
  ├── id: uuid (PK)
  ├── email: text (unique)
  ├── created_at: timestamp
  └── profiles (1:1)

  Table: profiles
  ├── id: uuid (PK, FK → users.id)
  ├── display_name: text
  └── bio: text?

  Table: trips
  ├── id: uuid (PK)
  ├── user_id: uuid (FK → users.id)
  ├── destination: text
  └── start_date: date

  ---
  Lesson 11: Running Migrations 🔄

  Type this:
  /migrate

  What happens:
  1. I show migration status
  2. List pending migrations
  3. Apply them safely
  4. Verify success

  ---
  PART 6: Pull Requests 📋

  Lesson 12: Creating a PR 🎯

  Type this:
  /pr

  What happens:
  1. Run /verify - ensure quality
  2. Run /test - all tests pass
  3. Run /analyze - no issues
  4. Update CHANGELOG.md
  5. Commit with conventional format
  6. Push to branch
  7. Create PR with template

  Automated PR workflow! ✨

  ---
  PART 7: Advanced Automation ⚡

  Lesson 13: Auto-Formatting 🎨

  Try this: Edit a Dart file

  Type this:
  echo "class Test{Test(){}}" > test.dart

  What happens:
  1. PostToolUse hook triggers automatically
  2. Runs dart format
  3. Runs dart fix --apply
  4. File is formatted!

  You'll see:
  🎨 Formatting: test.dart
  ✅ Formatted: test.dart

  No manual formatting needed! ✨

  ---
  Lesson 14: Continuous Testing 📺

  Type this:
  /watch

  What happens:
  1. I watch for file changes
  2. Run tests automatically
  3. Show results in real-time
  4. Alert on failures

  Perfect for TDD! 🧪

  ---
  Lesson 15: Parallel Development 🚀

  Open multiple terminal windows:

  Terminal 1:
  claude
  "Implement the auth feature using /feature"

  Terminal 2:
  claude
  "Run /watch continuously for tests"

  Terminal 3:
  claude
  "After each change, use /code-simplifier"

  All working in parallel! ⚡

  ---
  PART 8: Quality Gates 🚦

  Lesson 16: End-to-End Verification 🎯

  Type this:
  Use the verify-app agent to test the recommendations feature

  What happens:
  1. Comprehensive testing:
    - Unit tests
    - Integration tests
    - Build verification
    - Manual test checklist
    - Code quality check
  2. Detailed report with issues found
  3. Recommendations for fixes

  ---
  Lesson 17: Code Review 👀

  Type this:
  Use the review-pr agent to review my recent changes

  What happens:
  1. Thorough code review
  2. Security checks
  3. Performance analysis
  4. Best practices verification
  5. Categorized issues (critical/warning/suggestion)

  ---
  PART 9: Workflow Improver 📈

  Lesson 18: Self-Improving Workflow 🔄

  Type this:
  /improve

  What happens:
  1. I analyze our workflow
  2. Find friction points
  3. Identify patterns
  4. Create new skills to automate
  5. Update existing skills

  The workflow improves itself! ♾️

  ---
  PART 10: Git Worktrees 🌳

  Lesson 19: Isolated Development 🏝️

  Type this:
  /worktree recommendations

  What happens:
  1. Create isolated environment
  2. Separate git branch
  3. Independent Claude session
  4. No merge conflicts until ready

  Perfect for parallel features! ⚡

  ---
  🎓 Quick Reference Card

  ┌─────────────────────────────────────┐
  │     SOLOADVENTURER SKILLS          │
  ├─────────────────────────────────────┤
  │ /test      - Run tests              │
  │ /gen       - Generate code          │
  │ /analyze   - Fix issues             │
  │ /verify    - Verify implementation  │
  │ /doctor    - Health check           │
  │ /clean     - Clean artifacts        │
  │ /feature   - Create feature         │
  │ /provider  - Create provider        │
  │ /schema    - View database          │
  │ /migrate   - Run migrations         │
  │ /deps      - Update dependencies    │
  │ /pr        - Create PR              │
  │ /watch     - Continuous testing     │
  │ /improve   - Improve workflow       │
  │ /worktree  - Git worktree           │
  └─────────────────────────────────────┘

  ┌─────────────────────────────────────┐
  │        AGENTS (Specialized AI)      │
  ├─────────────────────────────────────┤
  │ code-simplifier  - Clean up code    │
  │ verify-app      - E2E testing       │
  │ test-fixer      - Fix tests         │
  │ review-pr       - Review code       │
  └─────────────────────────────────────┘

  ---
  🚀 Start Now!

  Try this right now:

  /doctor

  Then tell me what you see!

  I'll guide you through each step based on what happens. We'll learn by doing! 🎉

  ---
  Next Steps:
  1. Run /doctor - Check your project health
  2. Run /test - See your test results
  3. Try Use the code-simplifier agent - See AI in action
  4. Read .claude/README.md - Quick reference
  5. Read docs/CLAUDE_CODE_WORKFLOW.md - Full guide

  Let's get started! Type /doctor and tell me what happens! 🚀