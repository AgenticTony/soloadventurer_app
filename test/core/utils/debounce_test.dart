import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_adventurer/core/utils/debounce.dart';

void main() {
  group('Debouncer', () {
    late Debouncer<String> debouncer;

    setUp(() {
      debouncer = Debouncer<String>(
        duration: const Duration(milliseconds: 100),
      );
    });

    tearDown(() {
      debouncer.dispose();
    });

    test('should execute action after debounce duration', () async {
      var executed = false;
      String? result;

      debouncer.debounce(
        input: 'test',
        action: () async {
          executed = true;
          return 'result';
        },
        onCompleteOverride: (debounceResult) {
          result = debounceResult.value;
        },
      );

      // Should not execute immediately
      expect(executed, false);
      expect(result, isNull);

      // Wait for debounce duration
      await Future.delayed(const Duration(milliseconds: 150));

      // Should have executed
      expect(executed, true);
      expect(result, 'result');
    });

    test('should reset timer on new input before duration completes', () async {
      var executionCount = 0;
      String? lastInput;

      debouncer.debounce(
        input: 'first',
        action: () async {
          executionCount++;
          lastInput = 'first';
          return 'result1';
        },
      );

      await Future.delayed(const Duration(milliseconds: 50));

      // New input before first completes
      debouncer.debounce(
        input: 'second',
        action: () async {
          executionCount++;
          lastInput = 'second';
          return 'result2';
        },
      );

      // Wait for debounce duration from second call
      await Future.delayed(const Duration(milliseconds: 150));

      // Should only execute once with second input
      expect(executionCount, 1);
      expect(lastInput, 'second');
    });

    test('should provide correct DebounceResult', () async {
      DebounceResult<String>? capturedResult;

      debouncer.debounce(
        input: 'test-input',
        action: () async => 'test-result',
        onCompleteOverride: (result) {
          capturedResult = result;
        },
      );

      await Future.delayed(const Duration(milliseconds: 150));

      expect(capturedResult, isNotNull);
      expect(capturedResult!.executed, true);
      expect(capturedResult!.value, 'test-result');
      expect(capturedResult!.input, 'test-input');
      expect(capturedResult!.timestamp, isNotNull);
    });

    test('should handle errors in action', () async {
      DebounceResult<String>? capturedResult;

      debouncer.debounce(
        input: 'test',
        action: () async {
          throw Exception('Test error');
        },
        onCompleteOverride: (result) {
          capturedResult = result;
        },
      );

      await Future.delayed(const Duration(milliseconds: 150));

      expect(capturedResult, isNotNull);
      expect(capturedResult!.executed, true);
      expect(capturedResult!.value, isNull);
    });

    test('should track call and execution counts', () async {
      // Multiple rapid calls
      for (int i = 0; i < 5; i++) {
        debouncer.debounce(
          input: 'call-$i',
          action: () async => 'result-$i',
        );
      }

      // Should have 5 calls
      expect(debouncer.callCount, 5);
      expect(debouncer.executionCount, 0);

      // Wait for execution
      await Future.delayed(const Duration(milliseconds: 150));

      // Should have 1 execution (last one)
      expect(debouncer.executionCount, 1);
    });

    test('should track last input and time', () async {
      debouncer.debounce(
        input: 'test-input',
        action: () async => 'result',
      );

      expect(debouncer.lastInput, 'test-input');
      expect(debouncer.lastInputTime, isNotNull);

      await Future.delayed(const Duration(milliseconds: 150));
    });

    test('should indicate pending status correctly', () async {
      debouncer.debounce(
        input: 'test',
        action: () async => 'result',
      );

      expect(debouncer.isPending, true);

      await Future.delayed(const Duration(milliseconds: 150));

      expect(debouncer.isPending, false);
    });

    test('should cancel pending operation', () async {
      var executed = false;

      debouncer.debounce(
        input: 'test',
        action: () async {
          executed = true;
          return 'result';
        },
      );

      expect(debouncer.isPending, true);

      // Cancel before execution
      final cancelled = debouncer.cancel();

      expect(cancelled, true);
      expect(debouncer.isPending, false);

      await Future.delayed(const Duration(milliseconds: 150));

      // Should not have executed
      expect(executed, false);
    });

    test('should return false when cancel with nothing pending', () {
      final cancelled = debouncer.cancel();
      expect(cancelled, false);
    });

    test('should reset state', () async {
      debouncer.debounce(
        input: 'test',
        action: () async => 'result',
      );

      await Future.delayed(const Duration(milliseconds: 150));

      expect(debouncer.callCount, 1);
      expect(debouncer.executionCount, 1);
      expect(debouncer.lastInput, 'test');

      debouncer.reset();

      expect(debouncer.callCount, 0);
      expect(debouncer.executionCount, 0);
      expect(debouncer.lastInput, isNull);
      expect(debouncer.lastInputTime, isNull);
    });

    test('should call onDebounceStart callback', () async {
      var debounceStartCalled = false;

      final debouncer = Debouncer<String>(
        duration: const Duration(milliseconds: 100),
        onDebounceStart: () {
          debounceStartCalled = true;
        },
      );

      debouncer.debounce(
        input: 'test',
        action: () async => 'result',
      );

      expect(debounceStartCalled, true);

      await Future.delayed(const Duration(milliseconds: 150));

      debouncer.dispose();
    });

    test('should use custom onComplete callback', () async {
      var customCallbackCalled = false;
      var defaultCallbackCalled = false;

      final debouncer = Debouncer<String>(
        duration: const Duration(milliseconds: 100),
        onComplete: (_) {
          defaultCallbackCalled = true;
        },
      );

      debouncer.debounce(
        input: 'test',
        action: () async => 'result',
        onCompleteOverride: (_) {
          customCallbackCalled = true;
        },
      );

      await Future.delayed(const Duration(milliseconds: 150));

      expect(customCallbackCalled, true);
      expect(defaultCallbackCalled, false);

      debouncer.dispose();
    });
  });

  group('SimpleDebouncer', () {
    late SimpleDebouncer debouncer;

    setUp(() {
      debouncer = SimpleDebouncer(
        duration: const Duration(milliseconds: 100),
      );
    });

    tearDown(() {
      debouncer.dispose();
    });

    test('should execute synchronous action after debounce', () async {
      var executed = false;

      debouncer.debounce(() {
        executed = true;
      });

      expect(executed, false);

      await Future.delayed(const Duration(milliseconds: 150));

      expect(executed, true);
    });

    test('should cancel pending operation', () async {
      var executed = false;

      debouncer.debounce(() {
        executed = true;
      });

      expect(debouncer.cancel(), true);

      await Future.delayed(const Duration(milliseconds: 150));

      expect(executed, false);
    });

    test('should call onDebounceStart and onDebounceComplete callbacks', () async {
      var startCalled = false;
      var completeCalled = false;

      final debouncer = SimpleDebouncer(
        duration: const Duration(milliseconds: 100),
        onDebounceStart: () {
          startCalled = true;
        },
        onDebounceComplete: () {
          completeCalled = true;
        },
      );

      debouncer.debounce(() {});

      expect(startCalled, true);
      expect(completeCalled, false);

      await Future.delayed(const Duration(milliseconds: 150));

      expect(completeCalled, true);

      debouncer.dispose();
    });

    test('should reset state', () async {
      debouncer.debounce(() {});

      await Future.delayed(const Duration(milliseconds: 150));

      debouncer.reset();

      expect(debouncer.isPending, false);

      debouncer.dispose();
    });
  });

  group('DebounceResult', () {
    test('should create result with all fields', () {
      final timestamp = DateTime.now();
      final result = DebounceResult<String>(
        value: 'test-value',
        executed: true,
        timestamp: timestamp,
        input: 'test-input',
      );

      expect(result.value, 'test-value');
      expect(result.executed, true);
      expect(result.timestamp, timestamp);
      expect(result.input, 'test-input');
    });

    test('should create result with null value', () {
      final result = DebounceResult<String>(
        value: null,
        executed: true,
        timestamp: DateTime.now(),
        input: 'test-input',
      );

      expect(result.value, isNull);
      expect(result.executed, true);
    });

    test('should format toString correctly', () {
      final result = DebounceResult<String>(
        value: 'value',
        executed: true,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        input: 'input',
      );

      final string = result.toString();

      expect(string, contains('input: input'));
      expect(string, contains('executed: true'));
      expect(string, contains('value: value'));
    });
  });
}
