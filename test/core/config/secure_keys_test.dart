import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/config/secure_keys.dart';

void main() {
  group('SecureKeys', () {
    test('missingKeys returns list of missing keys', () {
      // In test environment, no keys are provided via --dart-define
      // and dotenv is not loaded, so keys should be empty.
      final missing = SecureKeys.missingKeys();

      // At minimum, the keys should be listed when not configured.
      expect(missing, isNotEmpty);
    });

    test('missingKeysMessage returns descriptive message', () {
      final message = SecureKeys.missingKeysMessage();
      expect(message, contains('Missing API keys'));
    });

    test('allKeysPresent reflects key availability', () {
      // In test environment without --dart-define or dotenv,
      // keys should not be present.
      expect(SecureKeys.allKeysPresent, isFalse);
    });

    test('hasGooglePlacesKey returns false when not configured', () {
      expect(SecureKeys.hasGooglePlacesKey, isFalse);
    });

    test('hasViatorKey returns false when not configured', () {
      expect(SecureKeys.hasViatorKey, isFalse);
    });

    test('googlePlacesApiKey returns empty string when not configured', () {
      expect(SecureKeys.googlePlacesApiKey, isEmpty);
    });

    test('viatorApiKey returns empty string when not configured', () {
      expect(SecureKeys.viatorApiKey, isEmpty);
    });
  });
}
