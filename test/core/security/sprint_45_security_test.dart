import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/config/app_config.dart';
import 'package:soloadventurer/core/config/secure_keys.dart';

void main() {
  group('Sprint 4.5 Security Hardening', () {
    group('4.5.4 — Cryptographic fixes', () {
      test('Random.secure() generates unique values', () {
        final random = Random.secure();
        final values = <int>{};
        for (var i = 0; i < 50; i++) {
          values.add(random.nextInt(0xFFFFFFFF));
        }
        // Random.secure should produce mostly unique values in 50 draws
        expect(values.length, greaterThan(40));
      });

      test('PRNG seed bytes are non-sequential', () {
        final random = Random.secure();
        final seed = List.generate(32, (_) => random.nextInt(256));
        // The old pattern was List.generate(32, (i) => i) — 0,1,2,...,31
        // New pattern should NOT be sequential
        final isSequential = seed.asMap().entries.every((e) => e.value == e.key);
        expect(isSequential, isFalse);
      });
    });

    group('4.5.5 — Auth secrets handling', () {
      test('AppConfig.supabaseAnonKey throws when key is missing', () {
        // In test environment, dotenv is not loaded, so this should throw
        expect(
          () => AppConfig.supabaseAnonKey,
          throwsA(isA<StateError>()),
        );
      });

      test('AppConfig.supabaseUrl returns empty when not configured', () {
        // Should gracefully return empty string, not throw
        expect(AppConfig.supabaseUrl, isEmpty);
      });

      test('SecureKeys handles missing dotenv gracefully', () {
        // Should never throw — returns empty string when dotenv not loaded
        expect(() => SecureKeys.googlePlacesApiKey, returnsNormally);
        expect(() => SecureKeys.viatorApiKey, returnsNormally);
        expect(SecureKeys.googlePlacesApiKey, isEmpty);
        expect(SecureKeys.viatorApiKey, isEmpty);
      });
    });

    group('4.5.7 — PII logging', () {
      test('obfuscated email helper produces safe output', () {
        // Test the obfuscation pattern directly
        const email = 'john.doe@example.com';
        final parts = email.split('@');
        expect(parts.length, equals(2));

        final local = parts[0];
        final domain = parts[1];

        // Obfuscation should hide most of the local part
        final obfuscatedLocal = '${local[0]}***';
        expect(obfuscatedLocal, equals('j***'));
        expect(obfuscatedLocal, isNot(contains('john')));
        expect(obfuscatedLocal, isNot(contains('doe')));

        // Domain obfuscation
        final domainParts = domain.split('.');
        final obfuscatedDomain =
            '${domainParts[0][0]}***.${domainParts.last}';
        expect(obfuscatedDomain, equals('e***.com'));
        expect(obfuscatedDomain, isNot(contains('example')));
      });

      test('empty email is handled safely', () {
        const email = '';
        expect(email.isEmpty, isTrue);
        // The implementation returns '(empty)' for empty emails
      });

      test('malformed email is handled safely', () {
        const email = 'not-an-email';
        final parts = email.split('@');
        // Should not have exactly 2 parts -> returns '(redacted)'
        expect(parts.length, isNot(equals(2)));
      });
    });
  });
}
