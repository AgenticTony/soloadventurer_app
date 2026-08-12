import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/utils/error_mapping.dart';

void main() {
  group('ErrorMapping', () {
    test('log does not throw', () {
      expect(
        () => ErrorMapping.log('test_op', Exception('test error')),
        returnsNormally,
      );
    });

    test('logAndReturn returns the fallback value', () {
      final result = ErrorMapping.logAndReturn<int>(
        'test_op',
        Exception('test error'),
        fallback: () => 42,
      );
      expect(result, 42);
    });

    test('logAndReturn can return null', () {
      final result = ErrorMapping.logAndReturn<String?>(
        'test_op',
        Exception('test error'),
        fallback: () => null,
      );
      expect(result, isNull);
    });

    test('logAndRethrow throws the error', () {
      expect(
        () => ErrorMapping.logAndRethrow(
          'test_op',
          Exception('rethrown'),
          stackTrace: StackTrace.current,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('logWarning does not throw', () {
      expect(
        () => ErrorMapping.logWarning('test_op', 'minor issue'),
        returnsNormally,
      );
    });

    test('log accepts context map', () {
      expect(
        () => ErrorMapping.log(
          'test_op',
          Exception('test'),
          context: {'userId': '123', 'tripId': '456'},
        ),
        returnsNormally,
      );
    });
  });
}
