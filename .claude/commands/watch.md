---
command: watch
description: Watch mode for continuous testing
---

## Continuous Test Watcher

I'll run tests continuously as you code.

**Usage:**
```
/watch                    # Watch all tests
/watch unit              # Unit tests only
/watch integration       # Integration tests only
/watch feature <name>     # Specific feature tests
```

**What I do:**
1. Watch for file changes
2. Run affected tests automatically
3. Show results in real-time
4. Alert on failures immediately

**Example output:**
```
👀 Watching for changes...

✅ test/features/auth/* - All passing (12 tests)
⚠️  test/features/profile/* - 1 failure
   └── profile_repository_test.dart:45

💡 Fix the issue, I'll re-test automatically when saved!
```

**Never break tests without knowing!**

Perfect for TDD and rapid iteration! ⚡
