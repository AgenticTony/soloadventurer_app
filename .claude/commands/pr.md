---
command: pr
description: Create PR following boring reliable pattern
---

## PR Creator - Boring Reliable Pattern

I'll create a pull request using a proven, repeatable workflow.

**The Boring Pattern:**
1. ✅ Run `/verify` - ensure quality
2. ✅ Run `/test` - all tests pass
3. ✅ Run `/analyze` - no issues
4. ✅ Update CHANGELOG.md
5. ✅ Commit with conventional format
6. ✅ Push to branch
7. ✅ Create PR with template

**Commit Format:**
```
feat(recommendations): add collaborative trip planning

- Add multi-user itinerary editing
- Implement real-time sync via Supabase
- Add conflict resolution for concurrent edits

Closes #123

Tests: ✅ All passing
Review: ready for review
```

**PR Template:**
```
## What
Brief description

## Why
Business reason

## How
Technical approach

## Testing
- Unit tests: ✅
- Integration tests: ✅
- Manual testing: [ ]

## Checklist
- [ ] Tests updated
- [ ] Docs updated
- [ ] CHANGELOG updated
```

Boring = Reliable = Ship faster 🚢
