---
command: clean
description: Clean build artifacts and caches
---

## Project Cleaner

I'll clean all build artifacts and caches to free space and fix weird build issues.

**Cleans:**
- Flutter build cache (`build/`)
- iOS Pods (`ios/Pods/`, `Podfile.lock`)
- Android Gradle cache (`.gradle/`, `build/`)
- Dart `.dart_tool/`
- Test coverage files
- Temporary files
- IDE cache files

**After cleaning:**
- Runs `flutter clean`
- Runs `flutter pub get`
- Shows space freed
- Ready for fresh build

**Usage:**
```
/clean             # Full clean
/clean light       # Quick clean (build/ only)
/clean pods        # iOS pods only
/clean gradle      # Android cache only
```

**Space savings:** Typically 500MB - 2GB

Perfect for:
- Fixing weird build errors
- Freeing disk space
- Before git commits
- CI/CD preparation
