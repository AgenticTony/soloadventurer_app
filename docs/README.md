# Project Documentation

This directory contains comprehensive documentation for the SoloAdventurer project.

## Core Documentation

- [Project Plan](PROJECT_PLAN.md) - Main project planning document
- [Project Plan 2](PROJECT_PLAN2.md) - Updated project planning document
- [Architecture](ARCHITECTURE.md) - Core system architecture
- [Architecture Evolution](ARCHITECTURE_EVOLUTION.md) - Planned architectural changes
- [Project Roadmap](PROJECT_ROADMAP.md) - Project timeline and milestones

## Development Guidelines

- [Feature Development](FEATURE_DEVELOPMENT.md) - Guidelines for feature development
- [Sample Feature](SAMPLE_FEATURE.md) - Example feature implementation
- [Project Restructuring](PROJECT_RESTRUCTURING.md) - Clean architecture implementation
- [Riverpod Patterns](RIVERPOD_PATTERNS.md) - State management patterns
- [Riverpod Strategy](riverpod_strategy.md) - State management strategy
- [Testing Patterns](TESTING_PATTERNS.md) - Testing guidelines and patterns
- [Riverpod Testing](RIVERPOD_TESTING.md) - State management testing

## Implementation Details

- [Auth Architecture](AUTH_ARCHITECTURE.md) - Authentication system design
- [Travel Preferences Implementation](TRAVEL_PREFERENCES_IMPLEMENTATION.md) - Travel preferences feature
- [AI/ML Strategy](AI_ML_STRATEGY.md) - AI and ML integration plans
- [Monitoring Strategy](monitoring_strategy.md) - Application monitoring approach

## Project Management

- [Sprint Plan Phase 1](SPRINT_PLAN_PHASE1.md) - Initial sprint planning
- [Migration Plan](MIGRATION_PLAN.md) - System migration strategy
- [Migration Checklist](MIGRATION_CHECKLIST.md) - Migration tasks and checks
- [Cost Optimization](COST_OPTIMIZATION.md) - Resource optimization strategy
- [Daily Progress](DAILY_PROGRESS.md) - Daily development updates
- [Tomorrow's Plan](TOMORROWS_PLAN.md) - Next day planning
- [End of Day Checklist](END_OF_DAY_CHECKLIST.md) - Daily wrap-up tasks
- [Restructuring Progress](RESTRUCTURING_PROGRESS.md) - Architecture updates progress

## Document Status

✅ = Complete
🚧 = In Progress
📝 = Planned

| Document             | Status | Last Updated |
| -------------------- | ------ | ------------ |
| Project Plan         | ✅     | 2024-03-21   |
| Architecture         | ✅     | 2024-03-21   |
| Auth Architecture    | ✅     | 2024-03-21   |
| Riverpod Patterns    | ✅     | 2024-03-21   |
| Daily Progress       | 🚧     | 2024-03-21   |
| End of Day Checklist | ✅     | 2024-03-21   |
| Project Roadmap      | ✅     | 2024-03-21   |
| Sprint Plan Phase 1  | 🚧     | 2024-03-21   |
| Testing Patterns     | 📝     | -            |
| Monitoring Strategy  | 📝     | -            |

## How to Use This Documentation

### For New Developers

1. Start with the [Project Plan](./PROJECT_PLAN2.md) to understand the project goals
2. Review the [Architecture](./ARCHITECTURE.md) to understand the current structure
3. Check the [Project Roadmap](./PROJECT_ROADMAP.md) to see what's being worked on
4. Review [Tomorrow's Plan](./TOMORROWS_PLAN.md) to see what's being worked on next

### For Current Developers

1. Refer to the [Project Roadmap](./PROJECT_ROADMAP.md) for current sprint tasks
2. Check [Tomorrow's Plan](./TOMORROWS_PLAN.md) for immediate next steps
3. Use the [Project Restructuring](./PROJECT_RESTRUCTURING.md) as a guide for implementing clean architecture
4. Follow the [Riverpod Testing](./RIVERPOD_TESTING.md) guidelines for state management
5. Implement [Cost Optimization](./COST_OPTIMIZATION.md) practices for AWS infrastructure

### For Project Managers

1. Track progress using the [Project Roadmap](./PROJECT_ROADMAP.md)
2. Review [Tomorrow's Plan](./TOMORROWS_PLAN.md) for daily progress tracking
3. Review the [Architecture Evolution](./ARCHITECTURE_EVOLUTION.md) for long-term planning
4. Monitor implementation of the [Monitoring Strategy](./monitoring_strategy.md)

## Documentation Maintenance

All documentation should be kept up-to-date as the project evolves. When making significant changes:

1. Update the relevant documentation files
2. Add a changelog entry at the bottom of the modified file
3. Update this README if new documentation is added
4. Update [Tomorrow's Plan](./TOMORROWS_PLAN.md) at the end of each day

## Generating Tasks from Documentation

We have a script to generate GitHub issues from the roadmap:

```bash
# Generate tasks for the current sprint
dart scripts/generate_tasks.dart

# Generate tasks for a specific sprint
dart scripts/generate_tasks.dart 2
```

This will create issue templates in `.github/ISSUES/` that can be manually created in GitHub.
