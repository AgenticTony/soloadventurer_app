---
command: feature
description: Scaffold new feature structure
---

## Feature Scaffolder

I'll create a new feature following your Clean Architecture pattern.

**Usage:**
```
/feature <feature_name>
```

**Example:**
```
/feature notifications
```

**Creates:**
```
lib/features/notifications/
├── domain/
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── services/          # Domain services
├── data/
│   ├── models/            # Data models
│   ├── datasources/       # Data sources (API, DB)
│   └── repositories/      # Repository implementations
├── presentation/
│   ├── providers/         # Riverpod providers
│   ├── screens/           # UI screens
│   └── widgets/           # Reusable widgets
└── infrastructure/
    └── services/          # External services
```

**Includes:**
- Example files with proper patterns
- Test files structure
- Export barrel files
- Route configuration template

All following your SoloAdventurer architecture! 🏗️
