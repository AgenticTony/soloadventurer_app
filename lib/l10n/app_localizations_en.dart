// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appBarTitleNearbyTravelers => 'Nearby Travelers';

  @override
  String get fabAddTrip => 'Add Trip';

  @override
  String get noTripsTitle => 'Start Your Adventure';

  @override
  String get noTripsDescription =>
      'Add your first trip to discover fellow solo travelers nearby.';

  @override
  String get noTripsButton => 'Add Your First Trip';

  @override
  String get noMatchesTitle => 'No Travelers Found';

  @override
  String get noMatchesDescription =>
      'We couldn\'t find any travelers nearby with overlapping dates.\nTry adjusting your trip dates or expanding your search.';

  @override
  String get noMatchesButton => 'Adjust Preferences';

  @override
  String get unknownTraveler => 'Unknown Traveler';

  @override
  String get notAvailable => 'N/A';

  @override
  String get unknownLocation => 'Unknown';

  @override
  String get statusNew => 'New';

  @override
  String get unknownDestination => 'Unknown destination';

  @override
  String daysOverlap(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days overlap',
      one: '1 day overlap',
    );
    return '$_temp0';
  }

  @override
  String kmAway(String distance) {
    return '$distance km away';
  }

  @override
  String get matchTypeSameDestination => 'Same destination';

  @override
  String get matchTypeSharedInterests => 'Shared interests';

  @override
  String get matchTypePerfectMatch => 'Perfect match';

  @override
  String get matchTypeDefault => 'Match';

  @override
  String get errorTitle => 'Something Went Wrong';

  @override
  String get errorButtonRetry => 'Try Again';

  @override
  String get subClose => 'Close';

  @override
  String get subWelcomeTrial =>
      'Welcome to Explorer! Your 7-day trial has started.';

  @override
  String get subHeroHeadline => 'Travel with peace of mind';

  @override
  String get subHeroSubheadline =>
      'Connect with travelers who\'ve verified their government ID. Your badge shows you\'re the real deal.';

  @override
  String get subTestimonial =>
      '\"I only meet verified travelers — it\'s how I stay safe while exploring solo.\"';

  @override
  String get subTestimonialAttribution => '— Solo Traveler, Barcelona';

  @override
  String get subGuardianPreview =>
      'Plus — Guardian check-ins that watch your back during meetups';

  @override
  String get subWhatYouGet => 'What you get';

  @override
  String get subFeatureIdVerification => 'ID Verification';

  @override
  String get subFeatureIdVerificationDesc =>
      'Verify your government ID — show travelers you\'re the real deal';

  @override
  String get subFeatureGuardian => 'Guardian Check-Ins';

  @override
  String get subFeatureGuardianDesc =>
      'Advanced safety check-ins during meetups — multiple contacts, location sharing';

  @override
  String get subFeatureUnlimitedMessages => 'Unlimited connection messages';

  @override
  String get subFeatureMessagesFree => 'Free: 5/day';

  @override
  String get subFeatureSeeInterested => 'See travelers interested in you';

  @override
  String get subFeatureVerifiedFilter => 'ID Verified-only filter';

  @override
  String get subFeatureAdvancedFilters => 'Advanced filters';

  @override
  String get subFeatureAdvancedFiltersSub =>
      'Age, gender, language, travel dates';

  @override
  String get subFeaturePriority => 'Priority discovery';

  @override
  String get subFeatureReadReceipts => 'Read receipts';

  @override
  String get subComingSoon => 'COMING SOON';

  @override
  String get subNotifyMe => 'Notify me';

  @override
  String subNotifyMeConfirm(String tier) {
    return 'We\'ll notify you when $tier is available!';
  }

  @override
  String get subMonthly => 'Monthly';

  @override
  String get subAnnual => 'Annual';

  @override
  String get subCtaStartTrial => 'Get ID Verified · Start Free Trial';

  @override
  String subCtaPurchase(String price) {
    return 'Get ID Verified · $price';
  }

  @override
  String subTrialNote(String price) {
    return 'No credit card required. Then $price. Cancel anytime.';
  }

  @override
  String get subContinueFree => 'Continue with Free';

  @override
  String get subUpgradeToSee => 'Upgrade to see';

  @override
  String get subTravelersWantToConnectHeader =>
      'Travelers Interested in Connecting';

  @override
  String subTravelersWantToConnect(int count) {
    return '$count travelers want to connect';
  }

  @override
  String get subBlurredForFree => 'Blurred for free tier';

  @override
  String get subUnlock => 'Unlock';

  @override
  String get subUpgradeBanner =>
      'See who wants to travel with you — start your free trial';

  @override
  String get subStartFreeTrial => 'Start Free Trial';

  @override
  String get subWantToSeeWho => 'Want to see who?';

  @override
  String subUpgradeModalBody(String name) {
    return 'See who wants to travel with you — start your free trial to connect with $name and other interested travelers.';
  }

  @override
  String get subMaybeLater => 'Maybe Later';

  @override
  String get subManageTitle => 'Subscription';

  @override
  String get subFreeTrialActive => 'Free Trial Active';

  @override
  String get subPreviouslyVerified => 'Previously verified';

  @override
  String get subBilling => 'Billing';

  @override
  String get subStatus => 'Status';

  @override
  String get subStatusActive => 'Active';

  @override
  String get subStatusFree => 'Free tier';

  @override
  String get subNextRenewal => 'Next Renewal';

  @override
  String get subTrialEnds => 'Trial Ends';

  @override
  String get subTrialStarted => 'Trial Started';

  @override
  String get subBillingCycle => 'Billing Cycle';

  @override
  String get subAutoRenew => 'Auto-Renew';

  @override
  String get subOn => 'On';

  @override
  String get subOff => 'Off';

  @override
  String get subPlatform => 'Platform';

  @override
  String get subPrice => 'Price';

  @override
  String get subIncludedFeatures => 'Included Features';

  @override
  String get subChangePlan => 'Change Plan';

  @override
  String get subCancelSubscription => 'Cancel Subscription';

  @override
  String get subRestorePurchases => 'Restore Purchases';

  @override
  String get subPurchasesRestored => 'Purchases restored.';

  @override
  String get subGetVerifiedCta => 'Get ID Verified · Start Trial';

  @override
  String get subCancelTitle => 'Cancel Subscription?';

  @override
  String get subCancelBody =>
      'You\'ll keep your Explorer features until the end of your current billing period. After that, you\'ll be on the Free plan with \"Previously verified\" status.';

  @override
  String get subKeepSubscription => 'Keep Subscription';

  @override
  String get subContinueToCancel => 'Continue to Cancel';

  @override
  String get subExitSurveyTitle => 'Why are you cancelling?';

  @override
  String get subExitSurveyOptional => 'Optional — helps us improve.';

  @override
  String get subCancelReasonExpensive => 'Too expensive';

  @override
  String get subCancelReasonNotUsing => 'Not using it enough';

  @override
  String get subCancelReasonAlternative => 'Found a better alternative';

  @override
  String get subCancelReasonPrivacy => 'Concerned about privacy';

  @override
  String get subCancelReasonTechnical => 'Technical issues';

  @override
  String get subSkip => 'Skip';

  @override
  String get subConfirmCancel => 'Confirm Cancel';

  @override
  String get subCancelledConfirmation =>
      'Subscription cancelled. You\'ll keep access until end of billing period.';

  @override
  String get subTrustTitle => 'Trust & Verification';

  @override
  String get subSignalEmail => 'Email confirmed';

  @override
  String get subSignalPhoto => 'Photo checked';

  @override
  String get subSignalIdVerified => 'ID Verified';

  @override
  String get subPreviouslyVerifiedSignal => 'Previously verified';

  @override
  String get subProfileCompleteness => 'Profile completeness';

  @override
  String get subGetVerifiedCtaTitle => 'Get ID Verified';

  @override
  String get subExplorer => 'Explorer';

  @override
  String get subGetVerifiedCtaDesc =>
      'Verify your government ID — show travelers you\'re the real deal.';

  @override
  String get subNewTraveler => 'New traveler';

  @override
  String get subChatVerifiedBanner => 'This traveler is ID Verified';

  @override
  String get subChatSafetyReminder =>
      'Remember: meet in public places and trust your instincts';

  @override
  String get subGateMaybeLater => 'Maybe Later';

  @override
  String get subGateCta => 'Get ID Verified · Start Trial';

  @override
  String get subGateIncluded =>
      'Included with Explorer (\$9.99/mo or \$59.99/yr)';

  @override
  String subConnectedWith(String name) {
    return 'Connected with $name!';
  }
}
