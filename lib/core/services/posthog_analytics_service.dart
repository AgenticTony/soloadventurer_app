import 'package:posthog_flutter/posthog_flutter.dart';

import 'analytics_service.dart';

/// PostHog-backed [AnalyticsService] (product analytics — funnels, cohorts,
/// north-star). See `docs/analytics-v0.1.md`.
///
/// GDPR: this service assumes the SDK was initialized with `config.optOut = true`
/// (see [PostHogAnalyticsService.setup]) so **nothing is collected until the user
/// opts in**. Consent is enforced in two layers: the SDK opt-out flag, and the
/// [ConsentGatedAnalyticsService] decorator that wraps this service. Callers use
/// the wrapped decorator, never this class directly, so events cannot leak.
class PostHogAnalyticsService implements AnalyticsService {
  const PostHogAnalyticsService();

  /// Initialize the PostHog SDK. Call once in bootstrap, before the app runs.
  ///
  /// Starts **opted-out** (`config.optOut = true`); [ConsentGate.grant] flips it
  /// on once the user consents. Returns false (and skips setup) when [apiKey] is
  /// empty so the app runs cleanly without analytics configured.
  static Future<bool> setup({
    required String apiKey,
    required String host,
  }) async {
    if (apiKey.isEmpty) return false;
    final config = PostHogConfig(apiKey)
      ..host = host
      ..optOut = true // GDPR: collect nothing until the user opts in
      ..captureApplicationLifecycleEvents = true
      // No PII in events: strip known sensitive keys before send.
      ..beforeSend = [
        (event) {
          const sensitive = ['email', 'phone', 'full_name', 'name', 'password'];
          for (final key in sensitive) {
            event.properties?.remove(key);
          }
          return event;
        },
      ];
    await Posthog().setup(config);
    return true;
  }

  /// Toggle SDK-level collection to match consent. Injected into
  /// [ConsentGatedAnalyticsService] at the composition root.
  static Future<void> setOptedIn(bool optedIn) =>
      optedIn ? Posthog().enable() : Posthog().disable();

  @override
  void track(String eventName, {Map<String, dynamic>? properties}) {
    Posthog().capture(
      eventName: eventName,
      properties: _clean(properties),
    );
  }

  @override
  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    Posthog().capture(
      eventName: AnalyticsEvents.screenView,
      properties: {
        AnalyticsEvents.screenName: screenName,
        ...?_clean(properties),
      },
    );
  }

  @override
  void identify({required String userId, Map<String, dynamic>? traits}) {
    Posthog().identify(
      userId: userId,
      userProperties: _clean(traits),
    );
  }

  @override
  void reset() => Posthog().reset();

  @override
  void setUserProperty(String key, dynamic value) {
    // PostHog sets person properties via capture with $set; use a lightweight
    // no-op event carrying the property.
    Posthog().capture(
      eventName: r'$set',
      userProperties: {key: _asObject(value)},
    );
  }

  @override
  Future<void> flush() => Posthog().flush();

  /// PostHog's Dart API takes `Map<String, Object>` (non-null values); drop
  /// nulls and coerce so a stray null can't throw at the SDK boundary.
  Map<String, Object>? _clean(Map<String, dynamic>? props) {
    if (props == null) return null;
    final out = <String, Object>{};
    props.forEach((k, v) {
      if (v != null) out[k] = _asObject(v);
    });
    return out;
  }

  Object _asObject(dynamic v) => v is Object ? v : v.toString();
}
