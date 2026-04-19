// Activity Test Fixtures

class ActivityFixture {
  final String id;
  final String name;
  final String category;
  final bool isLocationSpecific;
  final String? locationConstraint; // PostGIS or null for global

  const ActivityFixture({
    required this.id,
    required this.name,
    required this.category,
    this.isLocationSpecific = false,
    this.locationConstraint,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'is_location_specific': isLocationSpecific,
    'location_constraint': locationConstraint,
  };
}

/// Predefined activity fixtures
class Activities {
  // Social Activities
  static ActivityFixture get coffee => ActivityFixture(
    id: 'act-coffee',
    name: 'Coffee',
    category: 'social',
  );

  static ActivityFixture get meal => ActivityFixture(
    id: 'act-meal',
    name: 'Meal',
    category: 'social',
  );

  static ActivityFixture get drinks => ActivityFixture(
    id: 'act-drinks',
    name: 'Drinks',
    category: 'social',
  );

  // Exploration Activities
  static ActivityFixture get sightseeing => ActivityFixture(
    id: 'act-sightseeing',
    name: 'Sightseeing',
    category: 'exploration',
  );

  static ActivityFixture get walkingTour => ActivityFixture(
    id: 'act-walking-tour',
    name: 'Walking Tour',
    category: 'exploration',
  );

  static ActivityFixture get museum => ActivityFixture(
    id: 'act-museum',
    name: 'Museum',
    category: 'exploration',
  );

  // Outdoor Activities
  static ActivityFixture get hiking => ActivityFixture(
    id: 'act-hiking',
    name: 'Hiking',
    category: 'outdoor',
    isLocationSpecific: true,
    locationConstraint: 'nature_areas', // Would need spatial data
  );

  static ActivityFixture get beach => ActivityFixture(
    id: 'act-beach',
    name: 'Beach',
    category: 'outdoor',
    isLocationSpecific: true,
    locationConstraint: 'coastal_areas',
  );

  static ActivityFixture get cycling => ActivityFixture(
    id: 'act-cycling',
    name: 'Cycling',
    category: 'outdoor',
  );

  // Nightlife
  static ActivityFixture get nightlife => ActivityFixture(
    id: 'act-nightlife',
    name: 'Nightlife',
    category: 'entertainment',
  );

  // Food Experiences
  static ActivityFixture get foodTour => ActivityFixture(
    id: 'act-food-tour',
    name: 'Food Tour',
    category: 'food',
  );

  static ActivityFixture get cooking => ActivityFixture(
    id: 'act-cooking',
    name: 'Cooking Class',
    category: 'food',
  );

  /// All activity fixtures
  static List<ActivityFixture> get all => [
    coffee, meal, drinks,
    sightseeing, walkingTour, museum,
    hiking, beach, cycling,
    nightlife, foodTour, cooking,
  ];

  /// Activities by category
  static List<ActivityFixture> byCategory(String category) =>
    all.where((a) => a.category == category).toList();

  /// Location-independent activities (available everywhere)
  static List<ActivityFixture> get global =>
    all.where((a) => !a.isLocationSpecific).toList();

  /// Location-specific activities (only available in certain areas)
  static List<ActivityFixture> get locationSpecific =>
    all.where((a) => a.isLocationSpecific).toList();

  /// Activities available in Paris (all except beach/hiking)
  static List<ActivityFixture> get inParis =>
    all.where((a) => a.id != 'act-beach' && a.id != 'act-hiking').toList();

  /// Activities available in coastal areas
  static List<ActivityFixture> get inCoastalArea =>
    all; // Beach is available

  /// Activities available in mountain/nature areas
  static List<ActivityFixture> get inMountainArea =>
    all.where((a) => a.id != 'act-beach').toList();
}

/// Activity interest fixtures for users
class UserActivityInterestFixture {
  final String userId;
  final String activityId;
  final int priority; // 1-5, higher = more interested

  const UserActivityInterestFixture({
    required this.userId,
    required this.activityId,
    this.priority = 3,
  });

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'activity_id': activityId,
    'priority': priority,
  };
}

/// Predefined user activity interests
class UserActivityInterests {
  /// Alex likes coffee, museums, and walking tours
  static List<UserActivityInterestFixture> get alex => [
    UserActivityInterestFixture(
      userId: 'user-alex',
      activityId: 'act-coffee',
      priority: 5,
    ),
    UserActivityInterestFixture(
      userId: 'user-alex',
      activityId: 'act-museum',
      priority: 4,
    ),
    UserActivityInterestFixture(
      userId: 'user-alex',
      activityId: 'act-walking-tour',
      priority: 4,
    ),
  ];

  /// Marcus likes hiking, food tours, and nightlife
  static List<UserActivityInterestFixture> get marcus => [
    UserActivityInterestFixture(
      userId: 'user-marcus',
      activityId: 'act-hiking',
      priority: 5,
    ),
    UserActivityInterestFixture(
      userId: 'user-marcus',
      activityId: 'act-food-tour',
      priority: 4,
    ),
    UserActivityInterestFixture(
      userId: 'user-marcus',
      activityId: 'act-nightlife',
      priority: 3,
    ),
  ];

  /// Priya likes meals, museums, and cooking classes
  static List<UserActivityInterestFixture> get priya => [
    UserActivityInterestFixture(
      userId: 'user-priya',
      activityId: 'act-meal',
      priority: 5,
    ),
    UserActivityInterestFixture(
      userId: 'user-priya',
      activityId: 'act-museum',
      priority: 5,
    ),
    UserActivityInterestFixture(
      userId: 'user-priya',
      activityId: 'act-cooking',
      priority: 4,
    ),
  ];

  /// All user activity interests
  static List<UserActivityInterestFixture> get all => [
    ...alex,
    ...marcus,
    ...priya,
  ];

  /// Interests for a specific user
  static List<UserActivityInterestFixture> forUser(String userId) =>
    all.where((i) => i.userId == userId).toList();

  /// Shared interests between two users
  static List<String> sharedInterests(String userAId, String userBId) {
    final aInterests = forUser(userAId).map((i) => i.activityId).toSet();
    final bInterests = forUser(userBId).map((i) => i.activityId).toSet();
    return aInterests.intersection(bInterests).toList();
  }
}
