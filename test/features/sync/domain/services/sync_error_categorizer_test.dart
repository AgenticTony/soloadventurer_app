import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_error_categorizer.dart';

void main() {
  group('SyncErrorCategorizerImpl', () {
    late SyncErrorCategorizerImpl categorizer;

    setUp(() {
      categorizer = SyncErrorCategorizerImpl();
    });

    group('getUserMessage', () {
      test('should return user-friendly message for network error', () {
        final message = categorizer.getUserMessage(SyncErrorType.network);
        expect(
          message,
          'Network connection issue. Please check your internet connection.',
        );
      });

      test('should return user-friendly message for authentication error', () {
        final message =
            categorizer.getUserMessage(SyncErrorType.authentication);
        expect(message, 'Authentication failed. Please sign in again.');
      });

      test('should return user-friendly message for server error', () {
        final message = categorizer.getUserMessage(SyncErrorType.server);
        expect(message, 'Server error. Our team has been notified.');
      });

      test('should return user-friendly message for validation error', () {
        final message = categorizer.getUserMessage(SyncErrorType.validation);
        expect(
          message,
          'Invalid data. Some information couldn\'t be validated.',
        );
      });

      test('should return user-friendly message for conflict error', () {
        final message = categorizer.getUserMessage(SyncErrorType.conflict);
        expect(
          message,
          'Sync conflict detected. This data was modified elsewhere.',
        );
      });

      test('should return user-friendly message for timeout error', () {
        final message = categorizer.getUserMessage(SyncErrorType.timeout);
        expect(
          message,
          'Request timed out. The server took too long to respond.',
        );
      });

      test('should return user-friendly message for not found error', () {
        final message = categorizer.getUserMessage(SyncErrorType.notFound);
        expect(
          message,
          'Data not found. The item may have been deleted.',
        );
      });

      test('should return user-friendly message for rate limited error', () {
        final message = categorizer.getUserMessage(SyncErrorType.rateLimited);
        expect(
          message,
          'Too many requests. Please wait a moment before trying again.',
        );
      });

      test('should return user-friendly message for quota exceeded error', () {
        final message = categorizer.getUserMessage(SyncErrorType.quotaExceeded);
        expect(message, 'Storage quota exceeded. Please free up some space.');
      });

      test('should return user-friendly message for unknown error', () {
        final message = categorizer.getUserMessage(SyncErrorType.unknown);
        expect(message, 'An unexpected error occurred.');
      });
    });

    group('getSuggestion', () {
      test('should return actionable suggestion for network error', () {
        final suggestion = categorizer.getSuggestion(SyncErrorType.network);
        expect(
          suggestion,
          'Check your WiFi or mobile data connection and try again.',
        );
      });

      test('should return actionable suggestion for authentication error', () {
        final suggestion =
            categorizer.getSuggestion(SyncErrorType.authentication);
        expect(
          suggestion,
          'Your session may have expired. Please sign out and sign back in.',
        );
      });

      test('should return actionable suggestion for server error', () {
        final suggestion = categorizer.getSuggestion(SyncErrorType.server);
        expect(
          suggestion,
          'This is usually temporary. Please try again in a few minutes.',
        );
      });

      test('should return actionable suggestion for validation error', () {
        final suggestion = categorizer.getSuggestion(SyncErrorType.validation);
        expect(
          suggestion,
          'Please check your input and try again. Contact support if the issue persists.',
        );
      });

      test('should return actionable suggestion for conflict error', () {
        final suggestion = categorizer.getSuggestion(SyncErrorType.conflict);
        expect(
          suggestion,
          'Please review the changes and choose which version to keep.',
        );
      });

      test('should return actionable suggestion for timeout error', () {
        final suggestion = categorizer.getSuggestion(SyncErrorType.timeout);
        expect(
          suggestion,
          'The server may be busy. Your request will be retried automatically.',
        );
      });

      test('should return actionable suggestion for not found error', () {
        final suggestion = categorizer.getSuggestion(SyncErrorType.notFound);
        expect(
          suggestion,
          'Refresh your data to ensure you have the latest information.',
        );
      });

      test('should return actionable suggestion for rate limited error', () {
        final suggestion = categorizer.getSuggestion(SyncErrorType.rateLimited);
        expect(
          suggestion,
          'You\'re making requests too frequently. Please wait and try again later.',
        );
      });

      test('should return actionable suggestion for quota exceeded error', () {
        final suggestion =
            categorizer.getSuggestion(SyncErrorType.quotaExceeded);
        expect(
          suggestion,
          'Delete old trips or upgrade your account to increase storage.',
        );
      });

      test('should return actionable suggestion for unknown error', () {
        final suggestion = categorizer.getSuggestion(SyncErrorType.unknown);
        expect(
          suggestion,
          'Please try again. If the problem persists, contact support.',
        );
      });
    });

    group('isRetryable', () {
      test('network errors should be retryable', () {
        expect(categorizer.isRetryable(SyncErrorType.network), true);
      });

      test('authentication errors should not be retryable', () {
        expect(categorizer.isRetryable(SyncErrorType.authentication), false);
      });

      test('server errors should be retryable', () {
        expect(categorizer.isRetryable(SyncErrorType.server), true);
      });

      test('validation errors should not be retryable', () {
        expect(categorizer.isRetryable(SyncErrorType.validation), false);
      });

      test('conflict errors should not be retryable', () {
        expect(categorizer.isRetryable(SyncErrorType.conflict), false);
      });

      test('timeout errors should be retryable', () {
        expect(categorizer.isRetryable(SyncErrorType.timeout), true);
      });

      test('not found errors should not be retryable', () {
        expect(categorizer.isRetryable(SyncErrorType.notFound), false);
      });

      test('rate limited errors should be retryable', () {
        expect(categorizer.isRetryable(SyncErrorType.rateLimited), true);
      });

      test('quota exceeded errors should not be retryable', () {
        expect(categorizer.isRetryable(SyncErrorType.quotaExceeded), false);
      });

      test('unknown errors should be retryable', () {
        expect(categorizer.isRetryable(SyncErrorType.unknown), true);
      });
    });

    group('getSeverity', () {
      test('network errors should be medium severity', () {
        expect(
          categorizer.getSeverity(SyncErrorType.network),
          SyncErrorSeverity.medium,
        );
      });

      test('authentication errors should be high severity', () {
        expect(
          categorizer.getSeverity(SyncErrorType.authentication),
          SyncErrorSeverity.high,
        );
      });

      test('server errors should be medium severity', () {
        expect(
          categorizer.getSeverity(SyncErrorType.server),
          SyncErrorSeverity.medium,
        );
      });

      test('validation errors should be high severity', () {
        expect(
          categorizer.getSeverity(SyncErrorType.validation),
          SyncErrorSeverity.high,
        );
      });

      test('conflict errors should be medium severity', () {
        expect(
          categorizer.getSeverity(SyncErrorType.conflict),
          SyncErrorSeverity.medium,
        );
      });

      test('timeout errors should be low severity', () {
        expect(
          categorizer.getSeverity(SyncErrorType.timeout),
          SyncErrorSeverity.low,
        );
      });

      test('not found errors should be high severity', () {
        expect(
          categorizer.getSeverity(SyncErrorType.notFound),
          SyncErrorSeverity.high,
        );
      });

      test('rate limited errors should be medium severity', () {
        expect(
          categorizer.getSeverity(SyncErrorType.rateLimited),
          SyncErrorSeverity.medium,
        );
      });

      test('quota exceeded errors should be high severity', () {
        expect(
          categorizer.getSeverity(SyncErrorType.quotaExceeded),
          SyncErrorSeverity.high,
        );
      });

      test('unknown errors should be medium severity', () {
        expect(
          categorizer.getSeverity(SyncErrorType.unknown),
          SyncErrorSeverity.medium,
        );
      });
    });

    group('categorizeStatusCode', () {
      test('400 should categorize as validation error', () {
        final type = categorizer.categorizeStatusCode(400);
        expect(type, SyncErrorType.validation);
      });

      test('401 should categorize as authentication error', () {
        final type = categorizer.categorizeStatusCode(401);
        expect(type, SyncErrorType.authentication);
      });

      test('403 should categorize as authentication error', () {
        final type = categorizer.categorizeStatusCode(403);
        expect(type, SyncErrorType.authentication);
      });

      test('404 should categorize as not found error', () {
        final type = categorizer.categorizeStatusCode(404);
        expect(type, SyncErrorType.notFound);
      });

      test('409 should categorize as conflict error', () {
        final type = categorizer.categorizeStatusCode(409);
        expect(type, SyncErrorType.conflict);
      });

      test('422 should categorize as validation error', () {
        final type = categorizer.categorizeStatusCode(422);
        expect(type, SyncErrorType.validation);
      });

      test('429 should categorize as rate limited error', () {
        final type = categorizer.categorizeStatusCode(429);
        expect(type, SyncErrorType.rateLimited);
      });

      test('500 should categorize as server error', () {
        final type = categorizer.categorizeStatusCode(500);
        expect(type, SyncErrorType.server);
      });

      test('502 should categorize as server error', () {
        final type = categorizer.categorizeStatusCode(502);
        expect(type, SyncErrorType.server);
      });

      test('503 should categorize as server error', () {
        final type = categorizer.categorizeStatusCode(503);
        expect(type, SyncErrorType.server);
      });

      test('504 should categorize as server error', () {
        final type = categorizer.categorizeStatusCode(504);
        expect(type, SyncErrorType.server);
      });

      test('507 should categorize as quota exceeded error', () {
        final type = categorizer.categorizeStatusCode(507);
        expect(type, SyncErrorType.quotaExceeded);
      });

      test('other 4xx codes should categorize as validation error', () {
        final type = categorizer.categorizeStatusCode(418);
        expect(type, SyncErrorType.validation);
      });

      test('other 5xx codes should categorize as server error', () {
        final type = categorizer.categorizeStatusCode(599);
        expect(type, SyncErrorType.server);
      });

      test('unknown codes should categorize as unknown error', () {
        final type = categorizer.categorizeStatusCode(999);
        expect(type, SyncErrorType.unknown);
      });
    });

    group('createError', () {
      test('should create error with all fields', () {
        final error = categorizer.createError(
          type: SyncErrorType.network,
          technicalMessage: 'Connection failed',
          code: 'ERR_001',
          statusCode: 500,
          entityType: 'trip',
          entityId: 'trip_123',
          operationType: 'update',
          retryCount: 2,
          details: {'key': 'value'},
        );

        expect(error.type, SyncErrorType.network);
        expect(error.technicalMessage, 'Connection failed');
        expect(error.code, 'ERR_001');
        expect(error.statusCode, 500);
        expect(error.entityType, 'trip');
        expect(error.entityId, 'trip_123');
        expect(error.operationType, 'update');
        expect(error.retryCount, 2);
        expect(error.details, {'key': 'value'});
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.isRetryable, true);
      });

      test('should create error with minimal fields', () {
        final error = categorizer.createError(
          type: SyncErrorType.validation,
          technicalMessage: 'Invalid data',
        );

        expect(error.type, SyncErrorType.validation);
        expect(error.technicalMessage, 'Invalid data');
        expect(error.severity, SyncErrorSeverity.high);
        expect(error.isRetryable, false);
        expect(error.code, null);
        expect(error.statusCode, null);
      });

      test('should use appropriate user message and suggestion', () {
        final error = categorizer.createError(
          type: SyncErrorType.authentication,
          technicalMessage: 'Auth failed',
        );

        expect(
            error.userMessage, 'Authentication failed. Please sign in again.');
        expect(
          error.suggestion,
          'Your session may have expired. Please sign out and sign back in.',
        );
      });
    });

    group('Convenience Factory Methods', () {
      test('createNetworkError should create network error', () {
        final error = categorizer.createNetworkError(
          technicalMessage: 'Network failed',
          entityType: 'trip',
          retryCount: 3,
        );

        expect(error.type, SyncErrorType.network);
        expect(error.technicalMessage, 'Network failed');
        expect(error.entityType, 'trip');
        expect(error.retryCount, 3);
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.isRetryable, true);
      });

      test('createAuthenticationError should create auth error', () {
        final error = categorizer.createAuthenticationError(
          technicalMessage: 'Unauthorized',
          statusCode: 401,
          code: 'AUTH_001',
        );

        expect(error.type, SyncErrorType.authentication);
        expect(error.technicalMessage, 'Unauthorized');
        expect(error.statusCode, 401);
        expect(error.code, 'AUTH_001');
        expect(error.severity, SyncErrorSeverity.high);
        expect(error.isRetryable, false);
      });

      test('createServerError should create server error', () {
        final error = categorizer.createServerError(
          technicalMessage: 'Internal server error',
          statusCode: 500,
          retryCount: 1,
        );

        expect(error.type, SyncErrorType.server);
        expect(error.technicalMessage, 'Internal server error');
        expect(error.statusCode, 500);
        expect(error.retryCount, 1);
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.isRetryable, true);
      });

      test('createValidationError should create validation error', () {
        final validationErrors = {
          'email': ['Invalid email format']
        };
        final error = categorizer.createValidationError(
          technicalMessage: 'Validation failed',
          validationErrors: validationErrors,
          entityType: 'user',
        );

        expect(error.type, SyncErrorType.validation);
        expect(error.technicalMessage, 'Validation failed');
        expect(error.statusCode, 422);
        expect(error.details, validationErrors);
        expect(error.severity, SyncErrorSeverity.high);
        expect(error.isRetryable, false);
      });

      test('createConflictError should create conflict error', () {
        final error = categorizer.createConflictError(
          technicalMessage: 'Version conflict',
          entityType: 'trip',
          entityId: 'trip_123',
        );

        expect(error.type, SyncErrorType.conflict);
        expect(error.technicalMessage, 'Version conflict');
        expect(error.statusCode, 409);
        expect(error.entityType, 'trip');
        expect(error.entityId, 'trip_123');
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.isRetryable, false);
      });

      test('createTimeoutError should create timeout error', () {
        final error = categorizer.createTimeoutError(
          technicalMessage: 'Request timeout',
          operationType: 'sync',
          retryCount: 2,
        );

        expect(error.type, SyncErrorType.timeout);
        expect(error.technicalMessage, 'Request timeout');
        expect(error.operationType, 'sync');
        expect(error.retryCount, 2);
        expect(error.severity, SyncErrorSeverity.low);
        expect(error.isRetryable, true);
      });
    });

    group('categorizeError', () {
      test('should categorize Exception to SyncError', () {
        final exception = Exception('Network error');
        final error = categorizer.categorizeError(
          exception: exception,
          entityType: 'trip',
          operationType: 'create',
        );

        expect(error, isA<SyncError>());
        expect(error.entityType, 'trip');
        expect(error.operationType, 'create');
      });
    });
  });
}
