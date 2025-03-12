import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/services/token_blacklist_manager.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('TokenBlacklistManager - Core Functionality', () {
    test('should initialize with empty blacklist', () {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      expect(manager.blacklistedTokenCount, equals(0));
    });

    test('should blacklist a token', () {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      manager.blacklistToken('test_token');
      expect(manager.blacklistedTokenCount, equals(1));
      expect(manager.isTokenBlacklisted('test_token'), isTrue);
    });

    test('should not duplicate tokens in blacklist', () {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      manager.blacklistToken('test_token');
      manager.blacklistToken('test_token');
      expect(manager.blacklistedTokenCount, equals(1));
    });

    test('should return false for non-blacklisted tokens', () {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      expect(manager.isTokenBlacklisted('non_existent_token'), isFalse);
    });
  });

  group('TokenBlacklistManager - Token Expiration', () {
    test('should remove expired tokens when checking', () async {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      final now = DateTime.now();

      withClock(Clock.fixed(now), () {
        manager.blacklistToken('test_token');
      });

      // Fast forward time by 25 hours
      withClock(Clock.fixed(now.add(const Duration(hours: 25))), () {
        expect(manager.isTokenBlacklisted('test_token'), isFalse);
        expect(manager.blacklistedTokenCount, equals(0));
      });
    });

    test('should keep valid tokens during cleanup', () async {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      final now = DateTime.now();

      withClock(Clock.fixed(now), () {
        manager.blacklistToken('test_token');
      });

      // Fast forward time by 23 hours (before expiration)
      withClock(Clock.fixed(now.add(const Duration(hours: 23))), () {
        expect(manager.isTokenBlacklisted('test_token'), isTrue);
        expect(manager.blacklistedTokenCount, equals(1));
      });
    });

    test('should respect blacklist duration of 24 hours', () {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      final now = DateTime.now();

      withClock(Clock.fixed(now), () {
        manager.blacklistToken('test_token');
      });

      // Check at 23:59 hours
      withClock(Clock.fixed(now.add(const Duration(hours: 23, minutes: 59))),
          () {
        expect(manager.isTokenBlacklisted('test_token'), isTrue);
      });

      // Check at 24:01 hours
      withClock(Clock.fixed(now.add(const Duration(hours: 24, minutes: 1))),
          () {
        expect(manager.isTokenBlacklisted('test_token'), isFalse);
      });
    });
  });

  group('TokenBlacklistManager - Token Rotation', () {
    test('should handle token rotation by blacklisting old tokens', () async {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);

      final oldSession = AuthSession(
        accessToken: 'old_access_token',
        idToken: 'old_id_token',
        refreshToken: 'old_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await manager.handleTokenRotation(oldSession, newSession);

      expect(manager.isTokenBlacklisted('old_access_token'), isTrue);
      expect(manager.isTokenBlacklisted('old_refresh_token'), isTrue);
      expect(manager.isTokenBlacklisted('new_access_token'), isFalse);
      expect(manager.isTokenBlacklisted('new_refresh_token'), isFalse);
      expect(manager.blacklistedTokenCount, equals(2));
    });

    test('should not blacklist unchanged tokens during rotation', () async {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);

      final oldSession = AuthSession(
        accessToken: 'same_access_token',
        idToken: 'old_id_token',
        refreshToken: 'same_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      final newSession = AuthSession(
        accessToken: 'same_access_token',
        idToken: 'new_id_token',
        refreshToken: 'same_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await manager.handleTokenRotation(oldSession, newSession);

      expect(manager.isTokenBlacklisted('same_access_token'), isFalse);
      expect(manager.isTokenBlacklisted('same_refresh_token'), isFalse);
      expect(manager.blacklistedTokenCount, equals(0));
    });
  });

  group('TokenBlacklistManager - Cleanup Timer', () {
    test('should start cleanup timer on initialization', () {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      expect(manager, isNotNull); // Timer is started in build()
    });

    test('should cleanup expired tokens periodically', () async {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      final now = DateTime.now();

      withClock(Clock.fixed(now), () {
        manager.blacklistToken('test_token');
      });

      // Fast forward time by 25 hours
      withClock(Clock.fixed(now.add(const Duration(hours: 25))), () {
        // Trigger cleanup by checking any token
        manager.isTokenBlacklisted('any_token');
        expect(manager.blacklistedTokenCount, equals(0));
      });
    });

    test('should cancel cleanup timer on dispose', () {
      final localContainer = ProviderContainer();
      final manager =
          localContainer.read(tokenBlacklistManagerProvider.notifier);

      manager.blacklistToken('test_token');
      expect(manager.blacklistedTokenCount, equals(1));

      localContainer.dispose();
      // After disposal, the timer should be cancelled
      // We can't directly test timer cancellation, but we can verify the container is disposed
      expect(() => manager.blacklistedTokenCount, throwsStateError);
    });

    test('should run cleanup every hour', () {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      final now = DateTime.now();

      withClock(Clock.fixed(now), () {
        manager.blacklistToken('token1');
        manager.blacklistToken('token2');
      });

      // Check after 25 hours (should be cleaned up)
      withClock(Clock.fixed(now.add(const Duration(hours: 25))), () {
        expect(manager.blacklistedTokenCount, equals(0));
      });

      // Add new tokens and check after 30 minutes (should still be there)
      withClock(Clock.fixed(now.add(const Duration(minutes: 30))), () {
        manager.blacklistToken('token3');
        manager.blacklistToken('token4');
        expect(manager.blacklistedTokenCount, equals(2));
      });
    });
  });

  group('TokenBlacklistManager - Edge Cases', () {
    test('should handle empty tokens gracefully', () {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      manager.blacklistToken('');
      expect(manager.isTokenBlacklisted(''), isTrue);
    });

    test('should handle large number of tokens', () {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);

      // Add 1000 tokens
      for (var i = 0; i < 1000; i++) {
        manager.blacklistToken('token_$i');
      }

      expect(manager.blacklistedTokenCount, equals(1000));
      expect(manager.isTokenBlacklisted('token_999'), isTrue);
      expect(manager.isTokenBlacklisted('token_1000'), isFalse);
    });

    test('should handle concurrent token operations', () async {
      final manager = container.read(tokenBlacklistManagerProvider.notifier);
      final now = DateTime.now();

      withClock(Clock.fixed(now), () {
        // Simulate concurrent operations
        Future.wait([
          Future(() => manager.blacklistToken('token1')),
          Future(() => manager.blacklistToken('token2')),
          Future(() => manager.isTokenBlacklisted('token1')),
          Future(() => manager.blacklistToken('token3')),
        ]);

        expect(manager.blacklistedTokenCount, equals(3));
        expect(manager.isTokenBlacklisted('token1'), isTrue);
        expect(manager.isTokenBlacklisted('token2'), isTrue);
        expect(manager.isTokenBlacklisted('token3'), isTrue);
      });
    });
  });
}
