import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soloadventurer/core/services/consent_gated_analytics_service.dart';
import 'analytics_provider.dart';

/// SharedPreferences key for the analytics opt-in flag (GDPR).
const String kAnalyticsConsentKey = 'analytics_consent_granted';

/// Injected in bootstrap (see `core_service_providers`). Overridden with the
/// real instance so this controller can persist consent synchronously.
final analyticsConsentPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'analyticsConsentPrefsProvider must be overridden in bootstrap',
  );
});

/// Reads the persisted analytics-consent flag. Defaults to **false** (opt-in).
bool readPersistedAnalyticsConsent(SharedPreferences prefs) =>
    prefs.getBool(kAnalyticsConsentKey) ?? false;

/// Controls the GDPR analytics opt-in. State is `true` when the user has
/// consented. Flipping it: persists the flag, tells the [ConsentGatedAnalyticsService]
/// gate (which blocks/allows events and toggles the SDK via its injected hook).
///
/// See `docs/analytics-v0.1.md` (Privacy / consent).
class AnalyticsConsentController extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(analyticsConsentPrefsProvider);
    return readPersistedAnalyticsConsent(prefs);
  }

  /// Grant or withdraw analytics consent.
  Future<void> setConsent(bool granted) async {
    final prefs = ref.read(analyticsConsentPrefsProvider);
    await prefs.setBool(kAnalyticsConsentKey, granted);

    final service = ref.read(analyticsServiceProvider);
    if (service is ConsentGatedAnalyticsService) {
      service.updateConsent(granted);
    }
    state = granted;
  }

  Future<void> grant() => setConsent(true);
  Future<void> withdraw() => setConsent(false);
}

final analyticsConsentControllerProvider =
    NotifierProvider<AnalyticsConsentController, bool>(
  AnalyticsConsentController.new,
);
