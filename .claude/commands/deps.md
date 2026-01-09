---
command: deps
description: Update dependencies safely
---

## Dependency Updater

I'll help you update Flutter dependencies safely.

**Process:**
1. Check outdated packages
2. Verify version compatibility
3. Update pubspec.yaml
4. Run `flutter pub get`
5. Run tests to verify
6. Rollback if issues found

**Features:**
- Major version updates (with warnings)
- Patch/minor updates (auto-apply)
- Dependency conflict resolution
- Breaking changes detection
- Changelog summaries

**Safety:**
- Shows what will change
- Runs tests before confirming
- Git commit before major updates
- Rollback if tests fail

**Usage:**
```
/deps              # Check for updates
/deps major        # Major updates (risky)
/deps patch        # Patch updates (safe)
/deps verify       # Verify current deps
```

Updates without the stress! 📦
