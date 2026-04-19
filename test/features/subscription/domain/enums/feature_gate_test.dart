import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/subscription/domain/enums/feature_gate.dart';
import 'package:soloadventurer/features/subscription/domain/enums/subscription_tier.dart';

void main() {
  group('FeatureGate', () {
    test('has all eleven gates', () {
      expect(FeatureGate.values.length, 11);
    });

    test('labels are non-empty', () {
      for (final gate in FeatureGate.values) {
        expect(gate.label, isNotEmpty,
            reason: '${gate.name} should have a label');
      }
    });

    test('descriptions are non-empty', () {
      for (final gate in FeatureGate.values) {
        expect(gate.description, isNotEmpty,
            reason: '${gate.name} should have a description');
      }
    });

    test('all gates have contextual copy', () {
      for (final gate in FeatureGate.values) {
        expect(gate.contextualCopy, isNotEmpty,
            reason: '${gate.name} should have contextual copy');
      }
    });

    test('all gates require Explorer tier', () {
      for (final gate in FeatureGate.values) {
        expect(gate.requiredTier, SubscriptionTier.explorer,
            reason: '${gate.name} should require Explorer tier');
      }
    });

    test('iconNames are non-empty', () {
      for (final gate in FeatureGate.values) {
        expect(gate.iconName, isNotEmpty);
      }
    });

    test('gates include original features', () {
      expect(FeatureGate.values, contains(FeatureGate.unlimitedMatches));
      expect(FeatureGate.values, contains(FeatureGate.passportMode));
      expect(FeatureGate.values, contains(FeatureGate.boost));
      expect(FeatureGate.values, contains(FeatureGate.readReceipts));
      expect(FeatureGate.values, contains(FeatureGate.superConnect));
    });

    test('gates include new Sprint 6.6 features', () {
      expect(FeatureGate.values, contains(FeatureGate.connectionRequests));
      expect(FeatureGate.values, contains(FeatureGate.verifiedFilter));
      expect(FeatureGate.values, contains(FeatureGate.guardianPro));
      expect(FeatureGate.values, contains(FeatureGate.idVerification));
      expect(FeatureGate.values, contains(FeatureGate.advancedFilters));
      expect(FeatureGate.values, contains(FeatureGate.dailyMessages));
    });

    test('contextual copy uses travel-appropriate language', () {
      expect(FeatureGate.connectionRequests.contextualCopy,
          contains('travel'));
      expect(FeatureGate.verifiedFilter.contextualCopy,
          contains('peace of mind'));
      expect(FeatureGate.dailyMessages.contextualCopy,
          contains('5 messages'));
    });

    test('contextual copy never uses generic upgrade language', () {
      for (final gate in FeatureGate.values) {
        expect(gate.contextualCopy, isNot(contains('Upgrade to unlock')));
      }
    });

    test('specific gates show lock icon', () {
      expect(FeatureGate.verifiedFilter.showsLockIcon, isTrue);
      expect(FeatureGate.connectionRequests.showsLockIcon, isTrue);
      expect(FeatureGate.dailyMessages.showsLockIcon, isTrue);
      expect(FeatureGate.readReceipts.showsLockIcon, isFalse);
      expect(FeatureGate.boost.showsLockIcon, isFalse);
    });

    test('idVerification contextual copy mentions Explorer', () {
      expect(FeatureGate.idVerification.contextualCopy,
          contains('Explorer'));
    });

    test('guardianPro contextual copy mentions contacts and location', () {
      expect(FeatureGate.guardianPro.contextualCopy, contains('contacts'));
      expect(FeatureGate.guardianPro.contextualCopy, contains('location'));
    });
  });
}
