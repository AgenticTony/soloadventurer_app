library;

import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/failures/failures.dart';

void main() {
  group('Failure factory constructors', () {
    test('should create ServerFailure', () {
      final failure = Failure.server(
        message: 'Internal server error',
        statusCode: 500,
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Internal server error');
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('should create NetworkFailure', () {
      final failure = Failure.network(
        message: 'No connection',
        error: Exception('Network error'),
      );

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'No connection');
      expect((failure as NetworkFailure).error, isA<Exception>());
    });

    test('should create CacheFailure', () {
      final failure = Failure.cache(
        message: 'Cache error',
      );

      expect(failure, isA<CacheFailure>());
      expect(failure.message, 'Cache error');
    });

    test('should create AuthFailure', () {
      final failure = Failure.auth(
        message: 'Unauthorized',
      );

      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Unauthorized');
    });

    test('should create ValidationFailure', () {
      final fieldErrors = {'email': 'Invalid email format'};
      final failure = Failure.validation(
        message: 'Validation failed',
        fieldErrors: fieldErrors,
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Validation failed');
      expect((failure as ValidationFailure).fieldErrors, fieldErrors);
    });

    test('should create NotFoundFailure', () {
      final failure = Failure.notFound(
        message: 'User not found',
        resourceType: 'User',
      );

      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, 'User not found');
      expect((failure as NotFoundFailure).resourceType, 'User');
    });

    test('should create PermissionDeniedFailure', () {
      final failure = Failure.permissionDenied(
        message: 'Access denied',
        permission: 'admin',
      );

      expect(failure, isA<PermissionDeniedFailure>());
      expect(failure.message, 'Access denied');
      expect((failure as PermissionDeniedFailure).permission, 'admin');
    });

    test('should create UnknownFailure with default message', () {
      final failure = Failure.unknown();

      expect(failure, isA<UnknownFailure>());
      expect(failure.message, 'An unknown error occurred');
    });

    test('should create UnknownFailure with custom message', () {
      final failure = Failure.unknown(
        message: 'Custom unknown error',
      );

      expect(failure, isA<UnknownFailure>());
      expect(failure.message, 'Custom unknown error');
    });
  });

  group('FailureExtensions - requiresLogout', () {
    test('should return true for AuthFailure', () {
      final failure = Failure.auth(message: 'Token expired');
      expect(failure.requiresLogout, isTrue);
    });

    test('should return false for ServerFailure', () {
      final failure = Failure.server(message: 'Server error');
      expect(failure.requiresLogout, isFalse);
    });

    test('should return false for NetworkFailure', () {
      final failure = Failure.network(message: 'No connection');
      expect(failure.requiresLogout, isFalse);
    });

    test('should return false for CacheFailure', () {
      final failure = Failure.cache(message: 'Cache error');
      expect(failure.requiresLogout, isFalse);
    });

    test('should return false for ValidationFailure', () {
      final failure = Failure.validation(message: 'Invalid input');
      expect(failure.requiresLogout, isFalse);
    });

    test('should return false for NotFoundFailure', () {
      final failure = Failure.notFound(message: 'Not found');
      expect(failure.requiresLogout, isFalse);
    });

    test('should return false for PermissionDeniedFailure', () {
      final failure = Failure.permissionDenied(message: 'Access denied');
      expect(failure.requiresLogout, isFalse);
    });

    test('should return false for UnknownFailure', () {
      final failure = Failure.unknown();
      expect(failure.requiresLogout, isFalse);
    });
  });

  group('FailureExtensions - isRecoverable', () {
    test('should return true for NetworkFailure', () {
      final failure = Failure.network(message: 'No connection');
      expect(failure.isRecoverable, isTrue);
    });

    test('should return true for CacheFailure', () {
      final failure = Failure.cache(message: 'Cache error');
      expect(failure.isRecoverable, isTrue);
    });

    test('should return true for ServerFailure with 5xx status code', () {
      final failure = Failure.server(
        message: 'Internal server error',
        statusCode: 500,
      );
      expect(failure.isRecoverable, isTrue);
    });

    test('should return true for ServerFailure with 503 status code', () {
      final failure = Failure.server(
        message: 'Service unavailable',
        statusCode: 503,
      );
      expect(failure.isRecoverable, isTrue);
    });

    test('should return false for ServerFailure with 4xx status code', () {
      final failure = Failure.server(
        message: 'Bad request',
        statusCode: 400,
      );
      expect(failure.isRecoverable, isFalse);
    });

    test('should return false for ServerFailure with 401 status code', () {
      final failure = Failure.server(
        message: 'Unauthorized',
        statusCode: 401,
      );
      expect(failure.isRecoverable, isFalse);
    });

    test('should return false for ServerFailure without status code', () {
      final failure = Failure.server(message: 'Server error');
      expect(failure.isRecoverable, isFalse);
    });

    test('should return false for AuthFailure', () {
      final failure = Failure.auth(message: 'Token expired');
      expect(failure.isRecoverable, isFalse);
    });

    test('should return false for ValidationFailure', () {
      final failure = Failure.validation(message: 'Invalid input');
      expect(failure.isRecoverable, isFalse);
    });

    test('should return false for NotFoundFailure', () {
      final failure = Failure.notFound(message: 'Not found');
      expect(failure.isRecoverable, isFalse);
    });

    test('should return false for PermissionDeniedFailure', () {
      final failure = Failure.permissionDenied(message: 'Access denied');
      expect(failure.isRecoverable, isFalse);
    });

    test('should return false for UnknownFailure', () {
      final failure = Failure.unknown();
      expect(failure.isRecoverable, isFalse);
    });
  });

  group('FailureExtensions - userMessage', () {
    test('should return user-friendly message for NetworkFailure', () {
      final failure = Failure.network(message: 'DNS resolution failed');
      expect(
        failure.userMessage,
        'Please check your internet connection and try again.',
      );
    });

    test('should return user-friendly message for CacheFailure', () {
      final failure = Failure.cache(message: 'Database error');
      expect(
        failure.userMessage,
        'There was a problem loading your data. Please try again.',
      );
    });

    test('should return user-friendly message for AuthFailure', () {
      final failure = Failure.auth(message: 'Token expired');
      expect(
        failure.userMessage,
        'Your session has expired. Please log in again.',
      );
    });

    test('should return original message for ValidationFailure', () {
      final failure = Failure.validation(
        message: 'Email is required',
        fieldErrors: {'email': 'Required'},
      );
      expect(failure.userMessage, 'Email is required');
    });

    test('should return user-friendly message for NotFoundFailure', () {
      final failure = Failure.notFound(
        message: 'User not found',
        resourceType: 'User',
      );
      expect(
        failure.userMessage,
        'The requested information could not be found.',
      );
    });

    test('should return user-friendly message for PermissionDeniedFailure', () {
      final failure = Failure.permissionDenied(
        message: 'Admin access required',
        permission: 'admin',
      );
      expect(
        failure.userMessage,
        'You do not have permission to perform this action.',
      );
    });

    test('should return 5xx message for ServerFailure with 5xx code', () {
      final failure = Failure.server(
        message: 'Internal server error',
        statusCode: 500,
      );
      expect(
        failure.userMessage,
        'The server is experiencing issues. Please try again later.',
      );
    });

    test('should return generic server message for ServerFailure with 4xx code',
        () {
      final failure = Failure.server(
        message: 'Bad request',
        statusCode: 400,
      );
      expect(
        failure.userMessage,
        'There was a problem communicating with the server.',
      );
    });

    test('should return generic server message for ServerFailure without code',
        () {
      final failure = Failure.server(message: 'Server error');
      expect(
        failure.userMessage,
        'There was a problem communicating with the server.',
      );
    });

    test('should return user-friendly message for UnknownFailure', () {
      final failure = Failure.unknown(message: 'Something broke');
      expect(
        failure.userMessage,
        'An unexpected error occurred. Please try again.',
      );
    });
  });

  group('Failure pattern matching', () {
    test('should support exhaustive switch with all failure types', () {
      final failures = [
        Failure.server(message: 'Server error'),
        Failure.network(message: 'Network error'),
        Failure.cache(message: 'Cache error'),
        Failure.auth(message: 'Auth error'),
        Failure.validation(message: 'Validation error'),
        Failure.notFound(message: 'Not found'),
        Failure.permissionDenied(message: 'Permission denied'),
        Failure.unknown(message: 'Unknown error'),
      ];

      for (final failure in failures) {
        final description = switch (failure) {
          ServerFailure() => 'Server error',
          NetworkFailure() => 'Network error',
          CacheFailure() => 'Cache error',
          AuthFailure() => 'Auth error',
          ValidationFailure() => 'Validation error',
          NotFoundFailure() => 'Not found',
          PermissionDeniedFailure() => 'Permission denied',
          UnknownFailure() => 'Unknown error',
        };
        expect(description, isNotEmpty);
      }
    });

    test('should support pattern matching with guards', () {
      final failure = Failure.server(
        message: 'Internal server error',
        statusCode: 500,
      );

      final isServerError = switch (failure) {
        ServerFailure(statusCode: final code)
            when code != null && code >= 500 =>
          true,
        _ => false,
      };

      expect(isServerError, isTrue);
    });
  });

  group('Result type', () {
    test('should create Ok result', () {
      final Result<String> result = Result.ok('success');

      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect((result as Ok<String>).value, 'success');
    });

    test('should create Err result', () {
      final failure = Failure.network(message: 'Network error');
      final Result<String> result = Result.err(failure);

      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
      expect((result as Err<String>).error, failure);
    });

    test('should support pattern matching on Result', () {
      final Result<int> okResult = Result.ok(42);
      final Result<int> errResult = Result.err(Failure.unknown());

      final okValue = switch (okResult) {
        Ok(value: final v) => v,
        Err() => -1,
      };
      expect(okValue, 42);

      final errValue = switch (errResult) {
        Ok(value: final v) => v,
        Err() => -1,
      };
      expect(errValue, -1);
    });

    test('valueOrNull should return value for Ok', () {
      final Result<String> result = Result.ok('hello');
      expect(result.valueOrNull, 'hello');
    });

    test('valueOrNull should return null for Err', () {
      final Result<String> result = Result.err(Failure.unknown());
      expect(result.valueOrNull, isNull);
    });

    test('errorOrNull should return null for Ok', () {
      final Result<String> result = Result.ok('hello');
      expect(result.errorOrNull, isNull);
    });

    test('errorOrNull should return error for Err', () {
      final failure = Failure.network(message: 'Network error');
      final Result<String> result = Result.err(failure);
      expect(result.errorOrNull, failure);
    });

    test('map should transform Ok value', () {
      final Result<int> result = Result.ok(5);
      final Result<int> mapped = result.map((value) => value * 2);

      expect(mapped.isOk, isTrue);
      expect((mapped as Ok<int>).value, 10);
    });

    test('map should not transform Err', () {
      final failure = Failure.unknown();
      final Result<int> result = Result.err(failure);
      final Result<int> mapped = result.map((value) => value * 2);

      expect(mapped.isErr, isTrue);
      expect((mapped as Err<int>).error, failure);
    });

    test('orElse should return Ok value unchanged', () {
      final Result<int> result = Result.ok(42);
      final Result<int> orElsed = result.orElse((error) => 0);

      expect(orElsed.isOk, isTrue);
      expect((orElsed as Ok<int>).value, 42);
    });

    test('orElse should return provided value for Err', () {
      final Result<int> result = Result.err(Failure.unknown());
      final Result<int> orElsed = result.orElse((error) => 99);

      expect(orElsed.isOk, isTrue);
      expect((orElsed as Ok<int>).value, 99);
    });
  });

  group('Result toString', () {
    test('Ok toString should include type and value', () {
      final Result<String> result = Result.ok('test');
      expect(result.toString(), 'Ok<String>(test)');
    });

    test('Err toString should include type and failure message', () {
      final failure = Failure.network(message: 'Connection failed');
      final Result<String> result = Result.err(failure);
      expect(result.toString(), 'Err<String>(Connection failed)');
    });
  });

  group('Failure toString', () {
    test('toString should return message', () {
      final failure = Failure.network(message: 'Network error');
      expect(failure.toString(), 'Network error');
    });
  });
}
