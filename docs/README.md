# SoloAdventurer Documentation

This directory contains all documentation for the SoloAdventurer application. Use this README as a starting point to navigate the documentation.

## Getting Started

If you're new to the project, start with these documents:

1. [Project Plan](PROJECT_PLAN.md) - Overview of the project goals and tech stack
2. [Architecture](ARCHITECTURE.md) - Current architecture documentation
3. [Project Roadmap](PROJECT_ROADMAP.md) - Timeline and implementation plan
4. [Tomorrow's Plan](TOMORROWS_PLAN.md) - Detailed plan for the next day's work

## Documentation Index

### Planning & Architecture

- [Project Plan](PROJECT_PLAN.md) - Overall project vision and tech stack
- [Architecture](ARCHITECTURE.md) - Current architecture documentation
- [Architecture Evolution](ARCHITECTURE_EVOLUTION.md) - Future architecture plans
- [Project Restructuring](PROJECT_RESTRUCTURING.md) - Clean architecture implementation plan
- [Project Roadmap](PROJECT_ROADMAP.md) - Timeline and implementation plan
- [Tomorrow's Plan](TOMORROWS_PLAN.md) - Detailed plan for the next day's work

### Development Practices

- [Riverpod Testing](RIVERPOD_TESTING.md) - State management testing strategy
- [Monitoring Strategy](MONITORING_STRATEGY.md) - Application monitoring approach
- [Cost Optimization](COST_OPTIMIZATION.md) - AWS cost reduction strategy

## How to Use This Documentation

### For New Developers

1. Start with the [Project Plan](PROJECT_PLAN.md) to understand the project goals
2. Review the [Architecture](ARCHITECTURE.md) to understand the current structure
3. Check the [Project Roadmap](PROJECT_ROADMAP.md) to see what's being worked on
4. Review [Tomorrow's Plan](TOMORROWS_PLAN.md) to see what's being worked on next

### For Current Developers

1. Refer to the [Project Roadmap](PROJECT_ROADMAP.md) for current sprint tasks
2. Check [Tomorrow's Plan](TOMORROWS_PLAN.md) for immediate next steps
3. Use the [Project Restructuring](PROJECT_RESTRUCTURING.md) as a guide for implementing clean architecture
4. Follow the [Riverpod Testing](RIVERPOD_TESTING.md) guidelines for state management
5. Implement [Cost Optimization](COST_OPTIMIZATION.md) practices for AWS infrastructure

### For Project Managers

1. Track progress using the [Project Roadmap](PROJECT_ROADMAP.md)
2. Review [Tomorrow's Plan](TOMORROWS_PLAN.md) for daily progress tracking
3. Review the [Architecture Evolution](ARCHITECTURE_EVOLUTION.md) for long-term planning
4. Monitor implementation of the [Monitoring Strategy](MONITORING_STRATEGY.md)

## Documentation Maintenance

All documentation should be kept up-to-date as the project evolves. When making significant changes:

1. Update the relevant documentation files
2. Add a changelog entry at the bottom of the modified file
3. Update this README if new documentation is added
4. Update [Tomorrow's Plan](TOMORROWS_PLAN.md) at the end of each day

## Generating Tasks from Documentation

We have a script to generate GitHub issues from the roadmap:

```bash
# Generate tasks for the current sprint
dart scripts/generate_tasks.dart

# Generate tasks for a specific sprint
dart scripts/generate_tasks.dart 2
```

This will create issue templates in `.github/ISSUES/` that can be manually created in GitHub.
