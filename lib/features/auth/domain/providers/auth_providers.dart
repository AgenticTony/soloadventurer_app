/// Barrel file for Auth providers
///
/// This file re-exports all auth-related providers from their actual locations
/// to maintain backward compatibility with existing imports.
library;

// Auth Repository
export 'package:soloadventurer/app/providers/auth_service_providers.dart'
    show
        authRepositoryProvider,
        AuthRepository;

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
    show
        authNotifierProvider,
        authProvider,
        AuthNotifier;

// Token Management
export 'package:soloadventurer/features/auth/presentation/providers/token_manager_provider.dart'
    show tokenManagerProvider;

// Navigation
export 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart'
    show authNavigationProvider;
