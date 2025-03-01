# Project Restructuring Progress

## Completed Tasks

### Core Infrastructure

- [x] Created the `lib/core` directory
- [x] Created subdirectories for API, errors, utils, and storage
- [x] Moved API client to `lib/core/api/client`
- [x] Moved interceptors to `lib/core/api/interceptors`
- [x] Moved error handling to `lib/core/errors`
- [x] Created `lib/core/utils/constants.dart`
- [x] Created `lib/core/errors/failures.dart`
- [x] Moved secure storage to `lib/core/storage`

### Feature Restructuring

- [x] Restructured the auth feature:
  - [x] Renamed `sources` to `datasources`
  - [x] Created `models` directory with `user_entity.dart`
  - [x] Updated imports to use the new structure

## In Progress

- [ ] Update the remaining features to follow the same structure
- [ ] Move theme-related code to `lib/shared/theme`
- [ ] Update the service locator to register all dependencies with proper abstractions

## Next Steps

- [ ] Implement proper provider structure that aligns with clean architecture
- [ ] Update tests to match the new structure
- [ ] Create a parallel test directory structure that mirrors the lib directory

## Issues Encountered

- Added the `get_it` package which was missing from the dependencies

## Notes

- The app directory already had the expected structure with `di`, `router`, etc.
- The auth feature already had a good separation of concerns with data, domain, and presentation layers
