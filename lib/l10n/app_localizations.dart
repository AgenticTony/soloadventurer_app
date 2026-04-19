import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Title shown in the app bar on the matches screen
  ///
  /// In en, this message translates to:
  /// **'Nearby Travelers'**
  String get appBarTitleNearbyTravelers;

  /// Floating action button label for adding a trip
  ///
  /// In en, this message translates to:
  /// **'Add Trip'**
  String get fabAddTrip;

  /// Title shown when user has no trips
  ///
  /// In en, this message translates to:
  /// **'Start Your Adventure'**
  String get noTripsTitle;

  /// Description shown when user has no trips
  ///
  /// In en, this message translates to:
  /// **'Add your first trip to discover fellow solo travelers nearby.'**
  String get noTripsDescription;

  /// Button label to add first trip
  ///
  /// In en, this message translates to:
  /// **'Add Your First Trip'**
  String get noTripsButton;

  /// Title shown when no travelers are found
  ///
  /// In en, this message translates to:
  /// **'No Travelers Found'**
  String get noMatchesTitle;

  /// Description shown when no travelers are found
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any travelers nearby with overlapping dates.\nTry adjusting your trip dates or expanding your search.'**
  String get noMatchesDescription;

  /// Button label to adjust search preferences
  ///
  /// In en, this message translates to:
  /// **'Adjust Preferences'**
  String get noMatchesButton;

  /// Fallback text for traveler name when not available
  ///
  /// In en, this message translates to:
  /// **'Unknown Traveler'**
  String get unknownTraveler;

  /// Text shown when a value is not available
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// Fallback text for location when not available
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownLocation;

  /// Status badge for new matches
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// Fallback text for destination when not available
  ///
  /// In en, this message translates to:
  /// **'Unknown destination'**
  String get unknownDestination;

  /// Text showing number of days overlap with another traveler
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day overlap} other{{count} days overlap}}'**
  String daysOverlap(int count);

  /// Text showing distance in kilometers
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(String distance);

  /// Match type label for geographic overlap
  ///
  /// In en, this message translates to:
  /// **'Same destination'**
  String get matchTypeSameDestination;

  /// Match type label for activity match
  ///
  /// In en, this message translates to:
  /// **'Shared interests'**
  String get matchTypeSharedInterests;

  /// Match type label for combined match
  ///
  /// In en, this message translates to:
  /// **'Perfect match'**
  String get matchTypePerfectMatch;

  /// Default match type label
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get matchTypeDefault;

  /// Title shown when an error occurs
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get errorTitle;

  /// Button label to retry after an error
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get errorButtonRetry;

  /// Tooltip for close button on paywall
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get subClose;

  /// Snack bar message after starting free trial
  ///
  /// In en, this message translates to:
  /// **'Welcome to Explorer! Your 7-day trial has started.'**
  String get subWelcomeTrial;

  /// Paywall hero section headline
  ///
  /// In en, this message translates to:
  /// **'Travel with peace of mind'**
  String get subHeroHeadline;

  /// Paywall hero section subheadline
  ///
  /// In en, this message translates to:
  /// **'Connect with travelers who\'ve verified their government ID. Your badge shows you\'re the real deal.'**
  String get subHeroSubheadline;

  /// Testimonial quote on paywall
  ///
  /// In en, this message translates to:
  /// **'\"I only meet verified travelers — it\'s how I stay safe while exploring solo.\"'**
  String get subTestimonial;

  /// Attribution for testimonial quote
  ///
  /// In en, this message translates to:
  /// **'— Solo Traveler, Barcelona'**
  String get subTestimonialAttribution;

  /// Guardian preview chip text on paywall
  ///
  /// In en, this message translates to:
  /// **'Plus — Guardian check-ins that watch your back during meetups'**
  String get subGuardianPreview;

  /// Feature comparison section heading
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get subWhatYouGet;

  /// Feature row title for ID Verification
  ///
  /// In en, this message translates to:
  /// **'ID Verification'**
  String get subFeatureIdVerification;

  /// Feature row description for ID Verification
  ///
  /// In en, this message translates to:
  /// **'Verify your government ID — show travelers you\'re the real deal'**
  String get subFeatureIdVerificationDesc;

  /// Feature row title for Guardian Check-Ins
  ///
  /// In en, this message translates to:
  /// **'Guardian Check-Ins'**
  String get subFeatureGuardian;

  /// Feature row description for Guardian Check-Ins
  ///
  /// In en, this message translates to:
  /// **'Advanced safety check-ins during meetups — multiple contacts, location sharing'**
  String get subFeatureGuardianDesc;

  /// Feature row title for unlimited messages
  ///
  /// In en, this message translates to:
  /// **'Unlimited connection messages'**
  String get subFeatureUnlimitedMessages;

  /// Subtitle showing free tier message limit
  ///
  /// In en, this message translates to:
  /// **'Free: 5/day'**
  String get subFeatureMessagesFree;

  /// Feature row title for seeing interested travelers
  ///
  /// In en, this message translates to:
  /// **'See travelers interested in you'**
  String get subFeatureSeeInterested;

  /// Feature row title for verified-only filter
  ///
  /// In en, this message translates to:
  /// **'ID Verified-only filter'**
  String get subFeatureVerifiedFilter;

  /// Feature row title for advanced filters
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get subFeatureAdvancedFilters;

  /// Subtitle listing advanced filter types
  ///
  /// In en, this message translates to:
  /// **'Age, gender, language, travel dates'**
  String get subFeatureAdvancedFiltersSub;

  /// Feature row title for priority discovery
  ///
  /// In en, this message translates to:
  /// **'Priority discovery'**
  String get subFeaturePriority;

  /// Feature row title for read receipts
  ///
  /// In en, this message translates to:
  /// **'Read receipts'**
  String get subFeatureReadReceipts;

  /// Label for coming soon tiers section
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get subComingSoon;

  /// Button to request notification when tier is available
  ///
  /// In en, this message translates to:
  /// **'Notify me'**
  String get subNotifyMe;

  /// Snack bar confirming notify me request
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when {tier} is available!'**
  String subNotifyMeConfirm(String tier);

  /// Billing cycle option label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subMonthly;

  /// Billing cycle option label
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get subAnnual;

  /// CTA button text when eligible for trial
  ///
  /// In en, this message translates to:
  /// **'Get ID Verified · Start Free Trial'**
  String get subCtaStartTrial;

  /// CTA button text for direct purchase
  ///
  /// In en, this message translates to:
  /// **'Get ID Verified · {price}'**
  String subCtaPurchase(String price);

  /// Note below CTA about trial terms
  ///
  /// In en, this message translates to:
  /// **'No credit card required. Then {price}. Cancel anytime.'**
  String subTrialNote(String price);

  /// Link to dismiss paywall and stay on free tier
  ///
  /// In en, this message translates to:
  /// **'Continue with Free'**
  String get subContinueFree;

  /// Overlay text on blurred connection request cards
  ///
  /// In en, this message translates to:
  /// **'Upgrade to see'**
  String get subUpgradeToSee;

  /// App bar title for connection requests screen
  ///
  /// In en, this message translates to:
  /// **'Travelers Interested in Connecting'**
  String get subTravelersWantToConnectHeader;

  /// Header showing count of connection requests
  ///
  /// In en, this message translates to:
  /// **'{count} travelers want to connect'**
  String subTravelersWantToConnect(int count);

  /// Label explaining blurred cards for free users
  ///
  /// In en, this message translates to:
  /// **'Blurred for free tier'**
  String get subBlurredForFree;

  /// Button in app bar to unlock connection requests
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get subUnlock;

  /// Banner text encouraging upgrade to see connection requests
  ///
  /// In en, this message translates to:
  /// **'See who wants to travel with you — start your free trial'**
  String get subUpgradeBanner;

  /// Button text to start free trial
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get subStartFreeTrial;

  /// Dialog title when tapping blurred card
  ///
  /// In en, this message translates to:
  /// **'Want to see who?'**
  String get subWantToSeeWho;

  /// Dialog body text for blurred card tap
  ///
  /// In en, this message translates to:
  /// **'See who wants to travel with you — start your free trial to connect with {name} and other interested travelers.'**
  String subUpgradeModalBody(String name);

  /// Dismiss button in upgrade dialogs
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get subMaybeLater;

  /// App bar title for subscription management screen
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subManageTitle;

  /// Badge text when trial is active
  ///
  /// In en, this message translates to:
  /// **'Free Trial Active'**
  String get subFreeTrialActive;

  /// Badge text for cancelled subscriber
  ///
  /// In en, this message translates to:
  /// **'Previously verified'**
  String get subPreviouslyVerified;

  /// Section title for billing info
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get subBilling;

  /// Label for subscription status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get subStatus;

  /// Status value when subscription is active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subStatusActive;

  /// Status value when on free tier
  ///
  /// In en, this message translates to:
  /// **'Free tier'**
  String get subStatusFree;

  /// Label for next renewal date
  ///
  /// In en, this message translates to:
  /// **'Next Renewal'**
  String get subNextRenewal;

  /// Label for trial end date
  ///
  /// In en, this message translates to:
  /// **'Trial Ends'**
  String get subTrialEnds;

  /// Label for trial start date
  ///
  /// In en, this message translates to:
  /// **'Trial Started'**
  String get subTrialStarted;

  /// Label for billing cycle selection
  ///
  /// In en, this message translates to:
  /// **'Billing Cycle'**
  String get subBillingCycle;

  /// Label for auto-renew status
  ///
  /// In en, this message translates to:
  /// **'Auto-Renew'**
  String get subAutoRenew;

  /// Value for enabled auto-renew
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get subOn;

  /// Value for disabled auto-renew
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get subOff;

  /// Label for purchase platform
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get subPlatform;

  /// Label for current price
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get subPrice;

  /// Section title for feature list
  ///
  /// In en, this message translates to:
  /// **'Included Features'**
  String get subIncludedFeatures;

  /// Button to change subscription plan
  ///
  /// In en, this message translates to:
  /// **'Change Plan'**
  String get subChangePlan;

  /// Button to cancel subscription
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get subCancelSubscription;

  /// Button to restore previous purchases
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get subRestorePurchases;

  /// Snack bar confirming purchase restore
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get subPurchasesRestored;

  /// CTA button for free users on management screen
  ///
  /// In en, this message translates to:
  /// **'Get ID Verified · Start Trial'**
  String get subGetVerifiedCta;

  /// Dialog title for cancellation confirmation
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription?'**
  String get subCancelTitle;

  /// Dialog body explaining cancellation consequences
  ///
  /// In en, this message translates to:
  /// **'You\'ll keep your Explorer features until the end of your current billing period. After that, you\'ll be on the Free plan with \"Previously verified\" status.'**
  String get subCancelBody;

  /// Button to keep subscription instead of cancelling
  ///
  /// In en, this message translates to:
  /// **'Keep Subscription'**
  String get subKeepSubscription;

  /// Button to proceed with cancellation
  ///
  /// In en, this message translates to:
  /// **'Continue to Cancel'**
  String get subContinueToCancel;

  /// Title of optional exit survey
  ///
  /// In en, this message translates to:
  /// **'Why are you cancelling?'**
  String get subExitSurveyTitle;

  /// Subtitle explaining survey is optional
  ///
  /// In en, this message translates to:
  /// **'Optional — helps us improve.'**
  String get subExitSurveyOptional;

  /// Exit survey reason
  ///
  /// In en, this message translates to:
  /// **'Too expensive'**
  String get subCancelReasonExpensive;

  /// Exit survey reason
  ///
  /// In en, this message translates to:
  /// **'Not using it enough'**
  String get subCancelReasonNotUsing;

  /// Exit survey reason
  ///
  /// In en, this message translates to:
  /// **'Found a better alternative'**
  String get subCancelReasonAlternative;

  /// Exit survey reason
  ///
  /// In en, this message translates to:
  /// **'Concerned about privacy'**
  String get subCancelReasonPrivacy;

  /// Exit survey reason
  ///
  /// In en, this message translates to:
  /// **'Technical issues'**
  String get subCancelReasonTechnical;

  /// Button to skip exit survey
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get subSkip;

  /// Button to confirm cancellation
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancel'**
  String get subConfirmCancel;

  /// Snack bar after confirming cancellation
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled. You\'ll keep access until end of billing period.'**
  String get subCancelledConfirmation;

  /// Section title for trust display
  ///
  /// In en, this message translates to:
  /// **'Trust & Verification'**
  String get subTrustTitle;

  /// Trust signal for email confirmation
  ///
  /// In en, this message translates to:
  /// **'Email confirmed'**
  String get subSignalEmail;

  /// Trust signal for photo/liveness check
  ///
  /// In en, this message translates to:
  /// **'Photo checked'**
  String get subSignalPhoto;

  /// Trust signal for government ID verification
  ///
  /// In en, this message translates to:
  /// **'ID Verified'**
  String get subSignalIdVerified;

  /// Text shown when user was previously verified
  ///
  /// In en, this message translates to:
  /// **'Previously verified'**
  String get subPreviouslyVerifiedSignal;

  /// Label for profile completeness bar
  ///
  /// In en, this message translates to:
  /// **'Profile completeness'**
  String get subProfileCompleteness;

  /// CTA card title on trust display
  ///
  /// In en, this message translates to:
  /// **'Get ID Verified'**
  String get subGetVerifiedCtaTitle;

  /// Tier label shown in CTA card
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get subExplorer;

  /// CTA card description
  ///
  /// In en, this message translates to:
  /// **'Verify your government ID — show travelers you\'re the real deal.'**
  String get subGetVerifiedCtaDesc;

  /// Label for accounts less than 7 days old
  ///
  /// In en, this message translates to:
  /// **'New traveler'**
  String get subNewTraveler;

  /// Banner shown in chat with verified user
  ///
  /// In en, this message translates to:
  /// **'This traveler is ID Verified'**
  String get subChatVerifiedBanner;

  /// Neutral safety reminder shown in all chats
  ///
  /// In en, this message translates to:
  /// **'Remember: meet in public places and trust your instincts'**
  String get subChatSafetyReminder;

  /// Dismiss button in feature gate modal
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get subGateMaybeLater;

  /// CTA button in feature gate modal
  ///
  /// In en, this message translates to:
  /// **'Get ID Verified · Start Trial'**
  String get subGateCta;

  /// Info text in feature gate modal
  ///
  /// In en, this message translates to:
  /// **'Included with Explorer (\$9.99/mo or \$59.99/yr)'**
  String get subGateIncluded;

  /// Snack bar after connecting with a traveler
  ///
  /// In en, this message translates to:
  /// **'Connected with {name}!'**
  String subConnectedWith(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
