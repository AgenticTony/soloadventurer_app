import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/services/analytics_service.dart';
import 'package:soloadventurer/core/services/consent_gated_analytics_service.dart';

void main() {
  group('Story 0.3 — ConsentGatedAnalyticsService (GDPR opt-in)', () {
    late TestAnalyticsService inner;
    late ConsentGatedAnalyticsService gate;

    setUp(() {
      inner = TestAnalyticsService();
      gate = ConsentGatedAnalyticsService(inner);
    });

    test('starts without consent by default', () {
      expect(gate.consentGranted, isFalse);
    });

    test('drops every event while consent is absent', () {
      gate.track('sign_up');
      gate.trackScreenView('home');
      gate.identify(userId: 'u1');
      gate.setUserProperty('plan', 'pro');

      expect(inner.events, isEmpty);
      expect(inner.userId, isNull);
      expect(inner.userProperties, isEmpty);
    });

    test('forwards events once consent is granted', () {
      gate.updateConsent(true);

      gate.track('sign_up', properties: {'method': 'email'});
      gate.trackScreenView('home');
      gate.identify(userId: 'u1', traits: {'city': 'Seoul'});

      expect(inner.hasEvent('sign_up'), isTrue);
      expect(inner.getEvents('sign_up').first.properties['method'], 'email');
      expect(inner.hasEvent(AnalyticsEvents.screenView), isTrue);
      expect(inner.userId, 'u1');
      expect(inner.userProperties['city'], 'Seoul');
    });

    test('withdrawing consent resets identity and blocks further events', () {
      gate.updateConsent(true);
      gate.identify(userId: 'u1');
      gate.track('sign_up');
      expect(inner.userId, 'u1');

      gate.updateConsent(false);
      expect(inner.userId, isNull, reason: 'withdrawal must clear identity');

      inner.clear();
      gate.track('login');
      expect(inner.events, isEmpty, reason: 'no events after withdrawal');
    });

    test('honours persisted consent passed at construction', () {
      final preConsented =
          ConsentGatedAnalyticsService(inner, consentGranted: true);
      preConsented.track('app_open');
      expect(inner.hasEvent('app_open'), isTrue);
    });

    test('invokes onConsentChanged only on actual transitions', () {
      final toggles = <bool>[];
      final g = ConsentGatedAnalyticsService(
        inner,
        onConsentChanged: toggles.add,
      );

      g.updateConsent(true);
      g.updateConsent(true); // no-op, same state
      g.updateConsent(false);

      expect(toggles, [true, false]);
    });

    test('reset is always allowed regardless of consent', () {
      gate.identify(userId: 'u1'); // blocked (no consent) — inner stays clean
      gate.reset();
      expect(inner.userId, isNull);
    });
  });
}
