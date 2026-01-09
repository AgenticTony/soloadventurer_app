# SoloAdventurer - Claude Code Setup
## Quick Reference for the Team

---

## 🎯 What We Have

### Custom Agents (4 specialized AI assistants)
```
/code-simplifier  - Cleans up code after implementation
/verify-app      - End-to-end testing before PR
/test-fixer      - Fixes failing tests automatically
/review-pr       - Reviews code before merging
```

### Custom Slash Commands (16)
```
Development:
  /test      - Run Flutter tests
  /gen       - Generate code (freezed/Riverpod/drift)
  /analyze   - Fix code issues
  /verify    - Self-verification loop

Project Management:
  /feature   - Create new feature structure
  /provider  - Create Riverpod provider
  /pr        - Create pull request
  /worktree  - Create git worktree

Database & Config:
  /schema    - View Supabase database
  /migrate   - Run migrations
  /deps      - Update dependencies
  /clean     - Clean build artifacts

Quality & Monitoring:
  /doctor    - Project health check
  /watch     - Continuous testing
  /improve   - Improve workflow
```

### Automation
- **PostToolUse Hook** - Auto-formats Dart code after edits
- **Pre-allowed Permissions** - No prompts for safe commands

### MCP Servers (5)
- **Dart MCP** - Flutter/Dart analysis
- **Supabase MCP** - Database operations
- **Context7** - Documentation
- **Ref** - Code search
- **Playwright** - Browser automation

---

## 🚀 Quick Start

### For Developers

1. **Clone the repo**
   ```bash
   git clone <repo>
   cd SoloAdventurer_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Start Claude Code**
   ```bash
   claude
   ```

4. **Try a command**
   ```
   /test     # Run tests
   /doctor   # Check project health
   ```

### For Feature Development

```bash
# 1. Create feature structure
/feature <feature_name>

# 2. Implement the feature
[Code...]

# 3. Code auto-formats (hook)

# 4. Generate code
/gen

# 5. Verify
/verify

# 6. Test
/test

# 7. Create PR
/pr
```

---

## 📁 Configuration Files

### Project-Level
```
.claude/
├── agents/              # Custom AI assistants
├── commands/            # Custom slash commands
├── hooks/               # Automation scripts
└── settings.json        # Permissions & config
```

### Global
```
~/.claude/
├── agents/              # Global agents
└── settings.json        # Global settings
```

---

## 🔧 Common Tasks

### Running Tests
```bash
/test                    # All tests
/test unit              # Unit tests only
/test integration       # Integration tests
```

### Code Generation
```bash
/gen                    # Regenerate all code
```

### Fixing Issues
```bash
/analyze                # Fix analyzer issues
/code-simplifier        # Simplify code
/test-fixer            # Fix failing tests
```

### Creating PR
```bash
/pr                     # Full PR workflow
```

---

## 📊 Quality Gates

Before merging:
- ✅ `/test` - All tests passing
- ✅ `/analyze` - Zero issues
- ✅ `/verify-app` - E2E verified
- ✅ `/review-pr` - Code reviewed

---

## 🎓 Best Practices

1. **Use agents for specialized tasks**
   ```
   Use the code-simplifier agent to clean up
   Use the verify-app agent to test
   ```

2. **Let automation handle formatting**
   - Code auto-formats after edits
   - No manual formatting needed

3. **Run verification frequently**
   ```
   /verify after changes
   /test before committing
   ```

4. **Use worktrees for features**
   ```
   /worktree <feature_name>
   ```

---

## 🐛 Troubleshooting

### Tests Failing
```bash
/test-fixer            # Auto-fix failing tests
```

### Code Quality Issues
```bash
/code-simplifier        # Simplify code
/analyze               # Fix issues
```

### Build Issues
```bash
/clean                  # Clean artifacts
/gen                   # Regenerate code
```

### Health Check
```bash
/doctor                 # Full project checkup
```

---

## 📚 Documentation

- [Full Workflow Guide](../docs/CLAUDE_CODE_WORKFLOW.md)
- [Claude Code Docs](https://code.claude.com/docs/en/sub-agents)

---

## 🤝 Contributing

### Adding New Commands
1. Create `.claude/commands/<command_name>.md`
2. Follow the existing format
3. Test with `/<command_name>`

### Adding New Agents
1. Create `.claude/agents/<agent_name>.md`
2. Define tools and permissions
3. Test with `Use the <agent_name> agent`

---

## 🎯 Key Benefits

- **2-3x better code quality** - Verification loops
- **10x development speed** - Parallel Claude instances
- **Automatic formatting** - No manual work
- **Specialized agents** - Expert AI assistants
- **Continuous testing** - Never break code

---

*Happy coding! 🚀*

*Questions? Check `docs/CLAUDE_CODE_WORKFLOW.md`*
