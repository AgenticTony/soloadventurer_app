---
command: schema
description: View Supabase database schema
---

## Database Schema Viewer

I'll show you your Supabase database structure.

**Fetching schema:**
- All tables and columns
- Relationships and foreign keys
- Indexes and constraints
- RLS policies

**Displaying:**
```
Table: users
├── id: uuid (PK)
├── email: text (unique)
├── created_at: timestamp
└── profiles (1:1)

Table: profiles
├── id: uuid (PK, FK)
├── user_id: uuid (FK)
└── ...
```

Use this to:
- Understand data model
- Plan migrations
- Debug queries
- Design new features
