// Connection/Match Test Fixtures
class ConnectionFixture {
  final String id;
  final String userAId;
  final String userBId;
  final String matchReason;
  final int overlapDays;
  final double distanceKm;
  final DateTime createdAt;

  ConnectionFixture({
    required this.id,
    required this.userAId,
    required this.userBId,
    this.matchReason = 'geographic_overlap',
    this.overlapDays = 0,
    this.distanceKm = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime(2026, 4, 1);

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_a_id': userAId,
    'user_b_id': userBId,
    'match_reason': matchReason,
    'overlap_days': overlapDays,
    'distance_km': distanceKm,
    'created_at': createdAt.toIso8601String(),
  };

  /// Create reverse connection (B → A)
  ConnectionFixture get reversed => ConnectionFixture(
    id: 'conn-$userBId-$userAId',
    userAId: userBId,
    userBId: userAId,
    matchReason: matchReason,
    overlapDays: overlapDays,
    distanceKm: distanceKm,
    createdAt: createdAt,
  );
}

/// Predefined connection fixtures for testing
class Connections {
  /// Alex ↔ Marcus match (4 days overlap, same city)
  static ConnectionFixture get alexMarcus => ConnectionFixture(
    id: 'conn-alex-marcus',
    userAId: 'user-alex',
    userBId: 'user-marcus',
    overlapDays: 4,
    distanceKm: 0.0,
  );

  /// Alex ↔ Emma match (6 days overlap, same city, perfect match)
  static ConnectionFixture get alexEmma => ConnectionFixture(
    id: 'conn-alex-emma',
    userAId: 'user-alex',
    userBId: 'user-emma',
    overlapDays: 6,
    distanceKm: 0.0,
  );

  /// Priya ↔ Alex match (6 days overlap, but 394km away)
  /// Only visible if radius > 50km
  static ConnectionFixture get priyaAlex => ConnectionFixture(
    id: 'conn-priya-alex',
    userAId: 'user-priya',
    userBId: 'user-alex',
    overlapDays: 6,
    distanceKm: 394.0,
  );

  /// Priya ↔ Emma match (both female, Priya has women-only mode)
  static ConnectionFixture get priyaEmma => ConnectionFixture(
    id: 'conn-priya-emma',
    userAId: 'user-priya',
    userBId: 'user-emma',
    overlapDays: 6,
    distanceKm: 0.0,
  );

  /// All connection fixtures
  static List<ConnectionFixture> get all => [
    alexMarcus,
    alexEmma,
    priyaAlex,
    priyaEmma,
  ];

  /// Connections visible to a specific user
  static List<ConnectionFixture> visibleTo(String userId) =>
    all.where((c) => c.userAId == userId || c.userBId == userId).toList();

  /// Connections respecting women-only mode
  static List<ConnectionFixture> visibleToWithWomenOnly(String userId) {
    // Priya has women-only mode, so she should only see female users
    if (userId == 'user-priya') {
      return all.where((c) {
        final otherId = c.userAId == userId ? c.userBId : c.userAId;
        return otherId != 'user-marcus'; // Exclude Marcus (male)
      }).toList();
    }
    return visibleTo(userId);
  }
}

/// Generate test connections programmatically
class ConnectionGenerator {
  static int _counter = 0;

  static ConnectionFixture generate({
    String? userAId,
    String? userBId,
    int overlapDays = 3,
    double distanceKm = 0.0,
  }) {
    final id = 'conn-${DateTime.now().millisecondsSinceEpoch}-$_counter';
    return ConnectionFixture(
      id: id,
      userAId: userAId ?? 'user-a-$id',
      userBId: userBId ?? 'user-b-$id',
      overlapDays: overlapDays,
      distanceKm: distanceKm,
    );
  }

  static List<ConnectionFixture> generateBatch(int count, {
    String? baseUserAId,
    required List<String> targetUserIds,
  }) {
    return List.generate(count, (i) => generate(
      userAId: baseUserAId,
      userBId: targetUserIds[i % targetUserIds.length],
      overlapDays: (i % 6) + 1,
      distanceKm: i * 10.0,
    ));
  }

  static void reset() => _counter = 0;
}
