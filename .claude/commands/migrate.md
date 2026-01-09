---
command: migrate
description: Run Supabase migrations
---

## Migration Runner

I'll help you manage Supabase database migrations.

**Actions:**
1. **List migrations** - Show all applied migrations
2. **Create migration** - Generate new migration file
3. **Apply migration** - Apply pending migrations
4. **Rollback** - Revert last migration (if supported)
5. **Status** - Show migration status

**Usage:**
```
/migrate              # Show status
/migrate list         # List all migrations
/migrate create       # Create new migration
/migrate apply        # Apply pending migrations
```

**Safety checks:**
- Backup warning for production
- Dry-run mode available
- Migration validation
- Rollback confirmation

Your data is safe! I'll confirm before any changes.
