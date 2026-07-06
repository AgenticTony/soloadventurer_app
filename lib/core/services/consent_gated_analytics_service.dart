import 'analytics_service.dart';

/// Wraps an [AnalyticsService] and **drops every call until the user has
/// opted in** (GDPR — see `docs/analytics-v0.1.md`).
///
/// This is defense-in-depth: the PostHog SDK is also initialized opted-out, but
/// the gate guarantees no event, screen view, or identify call reaches the inner
/// service while consent is absent — independent of SDK state, and unit-testable
/// with a [TestAnalyticsService] inner.
///
/// Consent starts **false** unless a persisted value is passed in. Flip it with
/// [updateConsent]; a withdrawal also calls [reset] on the inner service so any
/// established identity is cleared.
class ConsentGatedAnalyticsService implements AnalyticsService {
  ConsentGatedAnalyticsService(
    this._inner, {
    bool consentGranted = false,
    void Function(bool granted)? onConsentChanged,
  })  : _consentGranted = consentGranted,
        _onConsentChanged = onConsentChanged;

  final AnalyticsService _inner;

  /// Called when consent flips — the composition root injects the SDK toggle
  /// here (e.g. `Posthog().enable()/disable()`), keeping this gate provider-
  /// agnostic and unit-testable with a [TestAnalyticsService].
  final void Function(bool granted)? _onConsentChanged;

  bool _consentGranted;

  bool get consentGranted => _consentGranted;

  /// Update consent. On withdrawal, clears identity via the inner service's
  /// [reset]. Persistence is the consent controller's job (see
  /// `analytics_consent_provider.dart`); the SDK opt-in/out toggle runs through
  /// the injected [_onConsentChanged].
  void updateConsent(bool granted) {
    if (granted == _consentGranted) return;
    _consentGranted = granted;
    if (!granted) {
      _inner.reset();
    }
    _onConsentChanged?.call(granted);
  }

  @override
  void track(String eventName, {Map<String, dynamic>? properties}) {
    if (!_consentGranted) return;
    _inner.track(eventName, properties: properties);
  }

  @override
  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    if (!_consentGranted) return;
    _inner.trackScreenView(screenName, properties: properties);
  }

  @override
  void identify({required String userId, Map<String, dynamic>? traits}) {
    if (!_consentGranted) return;
    _inner.identify(userId: userId, traits: traits);
  }

  @override
  void reset() {
    // Always allowed — clearing identity must work regardless of consent.
    _inner.reset();
  }

  @override
  void setUserProperty(String key, dynamic value) {
    if (!_consentGranted) return;
    _inner.setUserProperty(key, value);
  }

  @override
  Future<void> flush() async {
    if (!_consentGranted) return;
    await _inner.flush();
  }
}
