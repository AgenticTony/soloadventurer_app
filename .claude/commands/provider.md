---
command: provider
description: Create Riverpod provider scaffold
---

## Riverpod Provider Creator

I'll help you create a new Riverpod provider following your project's architecture.

**Usage:**
```
/provider <feature_name> <provider_type>
```

**Provider types:**
- `notifier` - StateNotifier with AsyncValue
- `repository` - Repository pattern
- `service` - Service layer
- `usecase` - Use case pattern

**Example:**
```
/provider recommendations notifier
```

**Creates:**
```
lib/features/recommendations/
├── domain/
│   └── providers/
│       └── recommendations_provider.dart
├── data/
│   └── repositories/
│       └── recommendations_repository_impl.dart
└── presentation/
    └── providers/
        └── recommendation_state.dart
```

Follows your Clean Architecture + Riverpod patterns!
