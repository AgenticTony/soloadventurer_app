---
command: gen
description: Run build_runner code generation
---

## Code Generation

I'll regenerate all your freezed, Riverpod, and drift code.

**Running:** `dart run build_runner build --delete-conflicting-outputs`

This generates:
- Freezed immutable classes
- Riverpod providers
- JSON serialization code
- Drift database classes
- Mock classes for testing

This takes ~30-60 seconds. Go get coffee! ☕

After completion, I'll show you:
- Number of files generated
- Any errors that occurred
- Next steps if issues found
