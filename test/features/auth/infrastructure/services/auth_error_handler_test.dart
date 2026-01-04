import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/auth_error_handler.dart';

void main() {
  group('AuthErrorHandler', () {
    late AuthErrorHandler errorHandler;

    setUp(() {
      errorHandler = const AuthErrorHandler(enableDetailedLogging: false);
    });

    group('Error Categorization', () {
      test('categorizes network errors correctly', () {
        final networkError = AuthException(
          'Network connection failed',
          code: 'NETWORK_ERROR',
        );

        final errorInfo = errorHandler.handleError(networkError);

        expect(errorInfo.category, AuthErrorCategory.network);
        expect(errorInfo.errorCode, 'NETWORK_ERROR');
        expect(errorInfo.isRetryable, isTrue);
      });

      test('categorizes credential errors correctly', () {
        final credentialError = AuthException(
          'Invalid credentials',
          code: 'INVALID_CREDENTIALS',
        );

        final errorInfo = errorHandler.handleError(credentialError);

        expect(errorInfo.category, AuthErrorCategory.credentials);
        expect(errorInfo.errorCode, 'INVALID_CREDENTIALS');
        expect(errorInfo.isRetryable, isTrue);
      });

      test('categorizes token expiration errors correctly', () {
        final expiredError = AuthException(
          'Token has expired',
          code: 'TOKEN_EXPIRED',
        );

        final errorInfo = errorHandler.handleError(expiredError);

        expect(errorInfo.category, AuthErrorCategory.expired);
        expect(errorInfo.errorCode, 'TOKEN_EXPIRED');
        expect(errorInfo.isRetryable, isTrue);
      });

      test('categorizes rate limit errors correctly', () {
        final rateLimitError = AuthException(
          'Too many requests',
          code: 'RATE_LIMIT_EXCEEDED',
        );

        final errorInfo = errorHandler.handleError(rateLimitError);

        expect(errorInfo.category, AuthErrorCategory.rateLimit);
        expect(errorInfo.errorCode, 'RATE_LIMIT_EXCEEDED');
        expect(errorInfo.isRetryable, isFalse);
      });

      test('categorizes server errors correctly', () {
        final serverError = AuthException(
          'Internal server error',
          code: 'INTERNAL_ERROR',
        );

        final errorInfo = errorHandler.handleError(serverError);

        expect(errorInfo.category, AuthErrorCategory.server);
        expect(errorInfo.errorCode, 'INTERNAL_ERROR');
        expect(errorInfo.isRetryable, isTrue);
      });

      test('categorizes validation errors correctly', () {
        final validationError = AuthException(
          'Invalid password',
          code: 'INVALID_PASSWORD',
        );

        final errorInfo = errorHandler.handleError(validationError);

        expect(errorInfo.category, AuthErrorCategory.validation);
        expect(errorInfo.errorCode, 'INVALID_PASSWORD');
        expect(errorInfo.isRetryable, isTrue);
      });
    });

    group('User-Friendly Messages', () {
      test('provides clear message for user not found', () {
        final error = AuthException(
          'User not found',
          code: 'USER_NOT_FOUND',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.userMessage,
          contains('No account found'),
        );
        expect(
          errorInfo.recovery.primaryAction,
          contains('Check your email and password'),
        );
      });

      test('provides clear message for invalid credentials', () {
        final error = AuthException(
          'Invalid credentials',
          code: 'INVALID_CREDENTIALS',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.userMessage,
          contains('Incorrect email or password'),
        );
      });

      test('provides clear message for email not verified', () {
        final error = AuthException(
          'Email not verified',
          code: 'EMAIL_NOT_VERIFIED',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.userMessage,
          contains('verify your email'),
        );
        expect(
          errorInfo.recovery.primaryAction,
          contains('verification link'),
        );
      });

      test('provides clear message for password reset required', () {
        final error = AuthException(
          'Password reset required',
          code: 'PASSWORD_RESET_REQUIRED',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.userMessage,
          contains('reset your password'),
        );
        expect(
          errorInfo.recovery.primaryAction,
          contains('Forgot Password'),
        );
      });

      test('provides clear message for expired token', () {
        final error = AuthException(
          'Token expired',
          code: 'TOKEN_EXPIRED',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.userMessage,
          contains('session has expired'),
        );
        expect(
          errorInfo.recovery.primaryAction,
          contains('sign in again'),
        );
      });

      test('provides clear message for rate limit exceeded', () {
        final error = AuthException(
          'Rate limit exceeded',
          code: 'RATE_LIMIT_EXCEEDED',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.userMessage,
          contains('Too many attempts'),
        );
        expect(
          errorInfo.recovery.primaryAction,
          contains('wait'),
        );
        expect(errorInfo.isRetryable, isFalse);
      });

      test('provides clear message for invalid password', () {
        final error = AuthException(
          'Password does not meet requirements',
          code: 'INVALID_PASSWORD',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.userMessage,
          allOf(
            contains('Password'),
            contains('requirements'),
            contains('8 characters'),
          ),
        );
      });

      test('provides clear message for invalid code', () {
        final error = AuthException(
          'Invalid verification code',
          code: 'INVALID_CODE',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.userMessage,
          contains('Invalid verification code'),
        );
        expect(
          errorInfo.recovery.primaryAction,
          contains('correct verification code'),
        );
      });

      test('provides clear message for expired code', () {
        final error = AuthException(
          'Code expired',
          code: 'EXPIRED_CODE',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.userMessage,
          contains('expired'),
        );
        expect(
          errorInfo.recovery.primaryAction,
          contains('request a new code'),
        );
      });

      test('provides clear message for email already exists', () {
        final error = AuthException(
          'Email already exists',
          code: 'EMAIL_EXISTS',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.userMessage,
          contains('already exists'),
        );
        expect(
          errorInfo.recovery.primaryAction,
          contains('Sign in'),
        );
      });
    });

    group('Recovery Actions', () {
      test('provides network recovery actions', () {
        final error = AuthException(
          'Network failed',
          code: 'NETWORK_ERROR',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.recovery.primaryAction,
          contains('internet connection'),
        );
        expect(errorInfo.recovery.canRetry, isTrue);
        expect(errorInfo.recovery.retryDelay, isNotNull);
      });

      test('provides credential recovery actions', () {
        final error = AuthException(
          'Wrong password',
          code: 'INVALID_CREDENTIALS',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.recovery.primaryAction,
          contains('Check your email and password'),
        );
        expect(
          errorInfo.recovery.secondaryAction,
          contains('Reset your password'),
        );
        expect(errorInfo.recovery.canRetry, isTrue);
      });

      test('provides reauthentication recovery actions', () {
        final error = AuthException(
          'Session expired',
          code: 'SESSION_EXPIRED',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.recovery.primaryAction,
          contains('sign in again'),
        );
        expect(errorInfo.recovery.canRetry, isTrue);
      });

      test('provides rate limit recovery actions with wait time', () {
        final error = AuthException(
          'Too many attempts',
          code: 'TOO_MANY_REQUESTS',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.recovery.primaryAction,
          contains('wait'),
        );
        expect(errorInfo.recovery.canRetry, isFalse);
        expect(errorInfo.recovery.retryDelay, isNotNull);
      });

      test('provides server error recovery actions', () {
        final error = AuthException(
          'Server error',
          code: 'INTERNAL_ERROR',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(
          errorInfo.recovery.primaryAction,
          contains('try again later'),
        );
        expect(
          errorInfo.recovery.secondaryAction,
          contains('contact support'),
        );
        expect(errorInfo.recovery.canRetry, isTrue);
      });
    });

    group('Exception Type Handling', () {
      test('handles AuthException correctly', () {
        final error = AuthException(
          'Auth failed',
          code: 'INVALID_CREDENTIALS',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.credentials);
        expect(errorInfo.errorCode, 'INVALID_CREDENTIALS');
        expect(errorInfo.technicalDetails, isNotNull);
      });

      test('handles NetworkTimeoutException correctly', () {
        final error = const NetworkTimeoutException(
          message: 'Request timed out',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.network);
        expect(
          errorInfo.userMessage,
          contains('timed out'),
        );
        expect(errorInfo.isRetryable, isTrue);
      });

      test('handles NetworkConnectivityException correctly', () {
        final error = const NetworkConnectivityException(
          message: 'No internet',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.network);
        expect(
          errorInfo.userMessage,
          contains('internet connection'),
        );
        expect(errorInfo.isRetryable, isTrue);
      });

      test('handles generic ServerException correctly', () {
        final error = const ServerException(
          message: 'Server error',
          code: 'SERVER_ERROR',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.server);
        expect(
          errorInfo.userMessage,
          contains('server error'),
        );
        expect(errorInfo.isRetryable, isTrue);
      });

      test('handles unknown exceptions correctly', () {
        final error = Exception('Unknown error');

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.unknown);
        expect(
          errorInfo.userMessage,
          contains('unexpected error'),
        );
        expect(errorInfo.isRetryable, isTrue);
      });

      test('handles UnauthorizedException correctly', () {
        final error = const UnauthorizedException(
          message: 'Unauthorized',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.credentials);
        expect(
          errorInfo.userMessage,
          contains('not authorized'),
        );
      });

      test('handles NotFoundException correctly', () {
        final error = const NotFoundException(
          message: 'Not found',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.server);
        expect(
          errorInfo.userMessage,
          contains('not found'),
        );
      });
    });

    group('Convenience Methods', () {
      test('isRetryable returns true for retryable errors', () {
        final networkError = AuthException(
          'Network failed',
          code: 'NETWORK_ERROR',
        );

        expect(errorHandler.isRetryable(networkError), isTrue);
      });

      test('isRetryable returns false for non-retryable errors', () {
        final rateLimitError = AuthException(
          'Rate limit exceeded',
          code: 'RATE_LIMIT_EXCEEDED',
        );

        expect(errorHandler.isRetryable(rateLimitError), isFalse);
      });

      test('shouldRefreshToken returns true for token errors', () {
        final expiredError = AuthException(
          'Token expired',
          code: 'TOKEN_EXPIRED',
        );

        expect(errorHandler.shouldRefreshToken(expiredError), isTrue);
      });

      test('shouldRefreshToken returns false for other errors', () {
        final credentialError = AuthException(
          'Invalid credentials',
          code: 'INVALID_CREDENTIALS',
        );

        expect(errorHandler.shouldRefreshToken(credentialError), isFalse);
      });

      test('isCredentialError returns true for credential errors', () {
        final error = AuthException(
          'Wrong password',
          code: 'INVALID_CREDENTIALS',
        );

        expect(errorHandler.isCredentialError(error), isTrue);
      });

      test('isCredentialError returns false for other errors', () {
        final error = AuthException(
          'Network failed',
          code: 'NETWORK_ERROR',
        );

        expect(errorHandler.isCredentialError(error), isFalse);
      });

      test('isNetworkError returns true for network errors', () {
        final error = AuthException(
          'Network failed',
          code: 'NETWORK_ERROR',
        );

        expect(errorHandler.isNetworkError(error), isTrue);
      });

      test('isNetworkError returns false for other errors', () {
        final error = AuthException(
          'Wrong password',
          code: 'INVALID_CREDENTIALS',
        );

        expect(errorHandler.isNetworkError(error), isFalse);
      });
    });

    group('Edge Cases', () {
      test('handles exception with null error code', () {
        final error = AuthException('Some error');

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.unknown);
        expect(errorInfo.userMessage, isNotEmpty);
        expect(errorInfo.isRetryable, isTrue);
      });

      test('handles exception with lowercase error code', () {
        final error = AuthException(
          'Network failed',
          code: 'network_error',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.network);
        expect(errorInfo.errorCode, 'NETWORK_ERROR');
      });

      test('handles exception with mixed case error code', () {
        final error = AuthException(
          'Invalid credentials',
          code: 'Invalid_Credentials',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.credentials);
        expect(errorInfo.errorCode, 'INVALID_CREDENTIALS');
      });

      test('infers category from message for unknown codes', () {
        final error = AuthException(
          'Network connection failed',
          code: 'UNKNOWN_CODE',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.network);
        expect(errorInfo.isRetryable, isTrue);
      });

      test('provides fallback for completely unknown errors', () {
        final error = AuthException(
          'Something went wrong',
          code: 'XYZ123',
        );

        final errorInfo = errorHandler.handleError(error);

        expect(errorInfo.category, AuthErrorCategory.unknown);
        expect(errorInfo.userMessage, contains('unexpected error'));
        expect(errorInfo.isRetryable, isTrue);
      });
    });

    group('AuthErrorRecovery', () {
      test('formats duration correctly for hours', () {
        final recovery = AuthErrorRecovery.waitAndRetry(
          waitTime: const Duration(hours: 2),
        );

        expect(
          recovery.primaryAction,
          contains('2 hours'),
        );
      });

      test('formats duration correctly for minutes', () {
        final recovery = AuthErrorRecovery.waitAndRetry(
          waitTime: const Duration(minutes: 15),
        );

        expect(
          recovery.primaryAction,
          contains('15 minutes'),
        );
      });

      test('formats duration correctly for seconds', () {
        final recovery = AuthErrorRecovery.waitAndRetry(
          waitTime: const Duration(seconds: 30),
        );

        expect(
          recovery.primaryAction,
          contains('30 seconds'),
        );
      });

      test('formats duration correctly for singular unit', () {
        final recovery = AuthErrorRecovery.waitAndRetry(
          waitTime: const Duration(hours: 1),
        );

        expect(
          recovery.primaryAction,
          contains('1 hour'),
        );
        expect(
          recovery.primaryAction,
          isNot(contains('1 hours')),
        );
      });

      test('toString combines primary and secondary actions', () {
        final recovery = const AuthErrorRecovery(
          primaryAction: 'Do this',
          secondaryAction: 'Or do that',
        );

        final result = recovery.toString();

        expect(result, contains('Do this'));
        expect(result, contains('Or do that'));
      });
    });

    group('AuthErrorInfo', () {
      test('toString contains key information', () {
        final errorInfo = AuthErrorInfo(
          category: AuthErrorCategory.network,
          userMessage: 'Network error',
          recovery: AuthErrorRecovery.retryNetwork(),
          errorCode: 'NET_001',
          isRetryable: true,
        );

        final result = errorInfo.toString();

        expect(result, contains('AuthErrorInfo'));
        expect(result, contains('network'));
        expect(result, contains('Network error'));
        expect(result, contains('NET_001'));
        expect(result, contains('isRetryable: true'));
      });
    });
  });
}
