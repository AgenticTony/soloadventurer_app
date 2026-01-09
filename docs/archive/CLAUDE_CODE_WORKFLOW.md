# Claude Code Power User Workflow
## Based on Boris Cherny's Best Practices

This guide documents the optimized workflow for SoloAdventurer using Claude Code, based on insights from Boris Cherny (Creator of Claude Code) and the power user community.

---

## 🚀 Quick Start

### 1. Your Custom Agents (4)
```
/code-simplifier  - Simplify code after implementation
/verify-app      - End-to-end testing before PR
/test-fixer      - Fix failing tests automatically
/review-pr       - Review code quality before merging
```

### 2. Your Skills (16)
```
/test      /gen      /analyze    /verify
/feature   /provider /pr         /worktree
/schema    /migrate  /deps       /clean
/doctor    /watch    /improve    /schema
```

### 3. Automation (Hooks)
- **PostToolUse Hook** - Auto-formats Dart code after edits
- **Pre-allowed Permissions** - No prompts for safe commands

---

## 📊 Boris's 13 Tips Applied to SoloAdventurer

### Tip 1: Multiple Claude Instances
> "Run 5+ Claude instances simultaneously"

**Your Setup:**
```bash
# Terminal 1: Main development
claude
"Implement auth feature using /feature"

# Terminal 2: Quality assurance
claude
"Run /watch continuously and alert on failures"

# Terminal 3: Code simplification
claude
"After each change, use /code-simplifier"

# Terminal 4: Testing
claude
"Run /verify-app after every commit"

# Terminal 5: Documentation
claude
"Update CHANGELOG and docs as needed"
```

---

### Tip 2: Verification Loops = 2-3x Quality
> "Give Claude a way to verify its work"

**Your Verification Stack:**
1. **Immediate** - PostToolUse hook formats code
2. **Post-change** - `/verify` skill runs tests
3. **Pre-commit** - `/verify-app` agent does E2E testing
4. **Pre-PR** - `/review-pr` agent checks quality

---

### Tip 3: Subagents for Common Workflows
> "Automate the most common workflows"

**Your Subagents:**
- **code-simplifier** - Cleans up after implementation
- **verify-app** - Thorough E2E testing
- **test-fixer** - Fixes broken tests
- **review-pr** - PR quality gate

---

### Tip 4: PostToolUse Hook for Formatting
> "Format Claude's code - handles the last 10%"

**Your Hook:** `.claude/hooks/post-tool-use.js`
- Runs `dart format` after every Write/Edit
- Runs `dart fix --apply` automatically
- Prevents CI formatting failures

**Result:** Code is always formatted! ✨

---

### Tip 5: Pre-allow Safe Permissions
> "Use /permissions to pre-allow common bash commands"

**Your Setup:** `.claude/settings.json`
```json
{
  "permissions": {
    "allow": [
      "Bash(*)",  // All bash commands pre-allowed
      "Read(./**)",
      "Write(./**)"
    ]
  }
}
```

**Shared with team** - Checked into version control! 🎯

---

### Tip 6: MCP Servers for External Tools
> "Slack, BigQuery, Sentry via MCP"

**Your MCP Servers:**
- **Dart MCP** - Flutter/Dart analysis
- **Supabase MCP** - Database operations
- **Context7** - Documentation
- **Ref** - Code search
- **Playwright** - Browser automation

**Configuration:** `~/.claude.json`

---

### Tip 7: Background Agents for Long Tasks
> "Use background agents for verification"

**Your Pattern:**
```dart
// After implementing feature
"Use /verify-app agent in background to test while I continue"
```

**Or use Stop Hook:**
```javascript
// .claude/hooks/stop.js
"Run /verify-app before stopping"
```

---

### Tip 8: Parallel Feature Development
> "Use git worktrees for isolation"

**Your Workflow:**
```bash
# Create isolated environment
/worktable recommendations

# Terminal 1: Main branch
Terminal 2: ../SA-recommendations (new feature)
Terminal 3: ../SA-auth (auth refactor)
```

---

### Tip 9: Continuous Testing
> "Watch for file changes and run tests"

**Your Setup:**
```bash
/watch  # Continuously run tests
```

**Never break code without knowing!** 🚨

---

### Tip 10: Boring Reliable Patterns
> "Boring setups usually win"

**Your PR Workflow:**
```bash
/pr  # Follows the same pattern every time:
    # 1. /verify
    # 2. /test
    # 3. /analyze
    # 4. Update CHANGELOG
    # 5. Commit with conventional format
    # 6. Push and create PR
```

---

### Tip 11: Recursive Improvement
> "Workflow that improves itself"

**Your Setup:**
```bash
/improve  # Analyzes and improves our workflow
```

The workflow gets better over time! 📈

---

### Tip 12: Verification is Everything
> "Most important tip - verify work = 2-3x quality"

**Your Verification Stack:**
1. **Code simplifier** - Cleans up implementation
2. **Test fixer** - Ensures tests pass
3. **Verify app** - E2E testing
4. **Review PR** - Quality gate
5. **Continuous watch** - Never break code

---

### Tip 13: Use All Your Tools
> "Claude uses all tools - Slack, BigQuery, Sentry"

**Your Tools:**
- **Supabase MCP** - Query database, run migrations
- **Dart MCP** - Analyze code, fix errors
- **Playwright MCP** - Test UI, automate browser
- **Git MCP** - Manage repositories

---

## 🎯 Daily Workflow Example

### Morning Setup (5 terminals)
```bash
# Terminal 1: Main development
claude

# Terminal 2: Quality assurance
claude
"Run /watch continuously"

# Terminal 3: Code review
claude
"After each change, run /code-simplifier"

# Terminal 4: Testing
claude
"Run /verify-app after commits"

# Terminal 5: Background tasks
claude
"Handle long-running tasks in background"
```

### Implementing a Feature
```bash
# 1. Create feature structure
/feature recommendations

# 2. Implement the feature
[Write code...]

# 3. Automatic formatting kicks in (PostToolUse hook)

# 4. Verify implementation
/verify

# 5. Run tests
/test

# 6. Simplify code
/code-simplifier

# 7. E2E verification
/verify-app

# 8. Create PR
/pr
```

---

## 📁 Project Structure

```
.claude/
├── agents/              # Specialized AI assistants
│   ├── code-simplifier.md
│   ├── verify-app.md
│   ├── test-fixer.md
│   └── review-pr.md
├── hooks/               # Automation
│   └── post-tool-use.js
├── skills/              # Custom slash commands
│   ├── flutter-test.md
│   ├── codegen.md
│   ├── analyze.md
│   ├── verify.md
│   └── ... (12 more)
└── settings.json        # Permissions & config
```

---

## 🔧 Configuration Files

### `.claude/settings.json`
- Pre-allowed permissions
- Hook configuration
- Enabled skills

### `~/.claude.json`
- Global MCP servers
- Dart MCP configuration
- Supabase MCP configuration

### `.env`
- Supabase credentials
- API keys
- Environment-specific config

---

## 📈 Metrics & Quality

### Code Quality Gates
```
✅ All tests passing (/test)
✅ Zero analyzer issues (/analyze)
✅ Code simplified (/code-simplifier)
✅ E2E verified (/verify-app)
✅ PR reviewed (/review-pr)
```

### Continuous Monitoring
```
📊 Test coverage: >70%
📊 Analyzer issues: 0
📊 Code formatting: Automatic
📊 E2E tests: Passing
```

---

## 🎓 Key Learnings

1. **Parallelization** - Multiple Claude instances = 10x speed
2. **Verification** - Self-checking = 2-3x quality
3. **Automation** - Hooks handle the last 10%
4. **Subagents** - Specialized AI for specific tasks
5. **MCP Servers** - Connect to all your tools
6. **Boring patterns** - Reliable workflows win
7. **Git worktrees** - Isolated parallel development
8. **Continuous testing** - Never break code unknowingly
9. **Recursive improvement** - Workflow improves itself
10. **Team sharing** - Check configs into version control

---

## 🚀 Getting Started

1. **Try the agents:**
   ```
   Use the code-simplifier agent to clean up auth module
   Use the verify-app agent to test the recommendations feature
   ```

2. **Try the skills:**
   ```
   /test       # Run tests
   /gen        # Generate code
   /verify     # Verify implementation
   /pr         # Create PR
   ```

3. **Watch the automation:**
   - Write some code
   - Notice it auto-formats (PostToolUse hook)
   - Run `/code-simplifier` to clean it up
   - Run `/verify-app` to test it

---

## 📚 Additional Resources

- [Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Hooks Documentation](https://code.claude.com/docs/en/hooks)
- [Slash Commands](https://code.claude.com/docs/en/slash-commands)
- [MCP Servers](https://code.claude.com/docs/en/mcp)

---

## 🎯 Summary

You now have:
- ✅ 4 specialized subagents
- ✅ 16 custom skills
- ✅ Automatic code formatting
- ✅ Pre-allowed permissions
- ✅ 5 MCP servers configured
- ✅ Verification loops in place
- ✅ Quality gates established

**Result:** 2-3x better code quality with 10x development speed! 🚀

---

*Last updated: January 8, 2026*
*Based on Claude Code 2.1.1*
