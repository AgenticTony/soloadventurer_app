
/// Analytics event names
abstract class AnalyticsEvents {
  // Screen views
  static const String screenView = 'screen_view';
  static const String screenName = 'screen_name';

  // Auth events
  static const String signUp = 'sign_up';
  static const String login = 'login';
  static const String signOut = 'sign_out';

  // Matching events
  static const String viewMatches = 'view_matches';
  static const String createTrip = 'create_trip';
  static const String sendConnectionRequest = 'send_connection_request';
  static const String acceptConnection = 'accept_connection';
  static const String declineConnection = 'decline_connection';

  // Chat events
  static const String openChat = 'open_chat';
  static const String sendMessage = 'send_message';
  static const String receiveMessage = 'receive_message';

  // Profile events
  static const String editProfile = 'edit_profile';
  static const String uploadPhoto = 'upload_photo';

  // Journal events
  static const String createJournalEntry = 'create_journal_entry';
  static const String viewJournalEntry = 'view_journal_entry';
  static const String shareJournalEntry = 'share_journal_entry';

  // Safety events
  static const String triggerSOS = 'trigger_sos';
  static const String checkIn = 'check_in';
  static const String shareLocation = 'share_location';

  // Destination events
  static const String searchDestination = 'search_destination';
  static const String selectActivity = 'select_activity';
  static const String tapAffiliateLink = 'tap_affiliate_link';

  // Monetization events
  static const String paywallViewed = 'paywall_viewed';
  static const String paywallCtaTapped = 'paywall_cta_tapped';
  static const String trialStarted = 'trial_started';
  static const String trialEnded = 'trial_ended';
  static const String trialConverted = 'trial_converted';
  static const String subscriptionStarted = 'subscription_started';
  static const String subscriptionCancelled = 'subscription_cancelled';
  static const String subscriptionRenewed = 'subscription_renewed';
  static const String featureGateBlocked = 'feature_gate_blocked';
  static const String connectionRequestsViewed = 'connection_requests_viewed';
  static const String verifiedFilterToggled = 'verified_filter_toggled';
  static const String dailyMessageCapReached = 'daily_message_cap_reached';
  static const String notifyMeTapped = 'notify_me_tapped';
}

/// Abstract analytics service interface
///
/// Implementations can be swapped (PostHog, Firebase Analytics, etc.)
/// without changing consumer code.
abstract class AnalyticsService {
  /// Track a named event with optional properties
  void track(String eventName, {Map<String, dynamic>? properties});

  /// Track a screen view
  void trackScreenView(String screenName, {Map<String, dynamic>? properties});

  /// Identify a user
  void identify({required String userId, Map<String, dynamic>? traits});

  /// Reset user identity (on logout)
  void reset();

  /// Set a user property
  void setUserProperty(String key, dynamic value);

  /// Flush any queued events
  Future<void> flush();
}

/// Debug-only analytics service that logs events to console
class DebugAnalyticsService implements AnalyticsService {
  bool _enabled = true;

  void setEnabled(bool enabled) => _enabled = enabled;

  @override
  void track(String eventName, {Map<String, dynamic>? properties}) {
    if (!_enabled) return;
  }

  @override
  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    if (!_enabled) return;
  }

  @override
  void identify({required String userId, Map<String, dynamic>? traits}) {
    if (!_enabled) return;
  }

  @override
  void reset() {
    if (!_enabled) return;
  }

  @override
  void setUserProperty(String key, dynamic value) {
    if (!_enabled) return;
  }

  @override
  Future<void> flush() async {
    if (!_enabled) return;
  }
}

/// In-memory analytics service for testing
///
/// Records all events so tests can verify correct tracking.
class TestAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> events = [];
  String? _userId;
  final Map<String, dynamic> _userProperties = {};

  String? get userId => _userId;
  Map<String, dynamic> get userProperties => Map.unmodifiable(_userProperties);

  /// Check if an event was tracked
  bool hasEvent(String eventName) =>
      events.any((e) => e.name == eventName);

  /// Get all events with a given name
  List<AnalyticsEvent> getEvents(String eventName) =>
      events.where((e) => e.name == eventName).toList();

  /// Get the last tracked event
  AnalyticsEvent? get lastEvent =>
      events.isNotEmpty ? events.last : null;

  /// Clear all recorded events
  void clear() {
    events.clear();
    _userId = null;
    _userProperties.clear();
  }

  @override
  void track(String eventName, {Map<String, dynamic>? properties}) {
    events.add(AnalyticsEvent(
      name: eventName,
      properties: properties ?? {},
    ));
  }

  @override
  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    events.add(AnalyticsEvent(
      name: AnalyticsEvents.screenView,
      properties: {AnalyticsEvents.screenName: screenName, ...?properties},
    ));
  }

  @override
  void identify({required String userId, Map<String, dynamic>? traits}) {
    _userId = userId;
    if (traits != null) {
      _userProperties.addAll(traits);
    }
  }

  @override
  void reset() {
    _userId = null;
    _userProperties.clear();
  }

  @override
  void setUserProperty(String key, dynamic value) {
    _userProperties[key] = value;
  }

  @override
  Future<void> flush() async {}
}

/// Recorded analytics event
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> properties;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    required this.properties,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'AnalyticsEvent($name, $properties)';
}
