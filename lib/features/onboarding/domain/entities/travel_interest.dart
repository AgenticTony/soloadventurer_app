/// Travel interest categories for solo travelers
///
/// These interests are used during onboarding to personalize
/// the generated itinerary with relevant activities and destinations.
enum TravelInterest {
  /// Food & Cuisine experiences
  food('🍽️', 'Food & Cuisine'),

  /// Culture & History exploration
  culture('🏛️', 'Culture & History'),

  /// Art & Museums visits
  art('🎨', 'Art & Museums'),

  /// Adventure & Outdoor activities
  adventure('🥾', 'Adventure & Outdoors'),

  /// Wellness & Relaxation experiences
  wellness('📿', 'Wellness & Relaxation'),

  /// Nightlife & Entertainment
  nightlife('🌙', 'Nightlife & Entertainment'),

  /// Nature & Scenery exploration
  nature('🌲', 'Nature & Scenery'),

  /// Shopping & Markets
  shopping('🛍️', 'Shopping & Markets'),

  /// Photography opportunities
  photography('📸', 'Photography'),

  /// Local cultural experiences
  localExperience('👥', 'Local Experiences');

  /// Emoji icon representing this interest
  final String emoji;

  /// Human-readable label for this interest
  final String label;

  /// Creates a TravelInterest with an emoji and label
  const TravelInterest(this.emoji, this.label);

  /// Returns a display-friendly string with emoji and label
  String get displayName => '$emoji $label';
}
