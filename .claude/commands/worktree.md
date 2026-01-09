---
command: worktree
description: Create isolated worktree for feature development
---

## Git Worktree Manager

I'll create isolated development environments for parallel work.

**Usage:**
```
/worktree <feature_name>
```

**Example:**
```
/worktable recommendations
```

**Creates:**
```
../SA-recommendations/    # Isolated environment
├── All your files
├── Separate git branch
└── Independent Claude session
```

**Benefits:**
- Work on multiple features simultaneously
- No merge conflicts until ready
- Each Claude instance has isolated context
- Easy to discard if experiment fails

**Parallel Workflow:**
```
Terminal 1: Main branch (fixes)
Terminal 2: ../SA-auth (auth feature)
Terminal 3: ../SA-recs (recommendations)
Terminal 4: ../SA-travel (travel feature)
```

All running Claude simultaneously! 🚀
