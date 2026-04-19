/// Barrel file for Auth providers
///
/// This file re-exports all auth-related providers from their actual locations
/// to maintain backward compatibility with existing imports.
library;

// Auth Repository
export 'package:soloadventurer/app/providers/auth_service_providers.dart'
    show authRepositoryProvider;

// Auth Use Cases
export 'package:soloadventurer/app/providers/auth_service_providers.dart'
    show
        getCurrentUserUseCaseProvider,
        isSignedInUseCaseProvider,
        loginUseCaseProvider,
        signUpUseCaseProvider,
        signOutUseCaseProvider,
        forgotPasswordUseCaseProvider,
        confirmPasswordResetUseCaseProvider,
        verifyEmailUseCaseProvider,
        resendVerificationEmailUseCaseProvider;

// Auth State Management
export 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart'
    show authProvider, AuthNotifier;

// Token Management (Domain service with FeatureAvailability state)
export 'package:soloadventurer/features/auth/domain/services/token_manager.dart'
    show tokenManagerProvider, TokenManager, FeatureAvailability, FeatureAvailabilityX;

// Navigation
export 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart'
    show authNavigationProvider;
