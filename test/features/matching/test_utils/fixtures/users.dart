// User Test Fixtures

class UserFixture {
  final String id;
  final String email;
  final String firstName;
  final String gender;
  final String? ageRange;
  final String homeCountry;
  final bool womenOnlyMode;
  final DateTime? createdAt;

  UserFixture({
    required this.id,
    required this.email,
    required this.firstName,
    required this.gender,
    this.ageRange,
    required this.homeCountry,
    this.womenOnlyMode = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime(2026, 1, 1);

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'gender': gender,
    'age_range': ageRange,
    'home_country': homeCountry,
    'women_only_mode': womenOnlyMode,
    'created_at': createdAt?.toIso8601String(),
  };
}

/// Predefined user fixtures for testing
class Users {
  /// Alex - Female user without women-only mode
  static UserFixture get alex => UserFixture(
    id: 'user-alex',
    email: 'alex@test.com',
    firstName: 'Alex',
    gender: 'female',
    ageRange: '25-30',
    homeCountry: 'US',
    womenOnlyMode: false,
  );

  /// Marcus - Male user
  static UserFixture get marcus => UserFixture(
    id: 'user-marcus',
    email: 'marcus@test.com',
    firstName: 'Marcus',
    gender: 'male',
    ageRange: '30-35',
    homeCountry: 'DE',
  );

  /// Priya - Female user WITH women-only mode enabled
  static UserFixture get priya => UserFixture(
    id: 'user-priya',
    email: 'priya@test.com',
    firstName: 'Priya',
    gender: 'female',
    ageRange: '40-45',
    homeCountry: 'IN',
    womenOnlyMode: true,
  );

  /// Emma - Another female user for multiple match scenarios
  static UserFixture get emma => UserFixture(
    id: 'user-emma',
    email: 'emma@test.com',
    firstName: 'Emma',
    gender: 'female',
    ageRange: '25-30',
    homeCountry: 'UK',
    womenOnlyMode: false,
  );

  /// John - Another male user
  static UserFixture get john => UserFixture(
    id: 'user-john',
    email: 'john@test.com',
    firstName: 'John',
    gender: 'male',
    ageRange: '35-40',
    homeCountry: 'AU',
  );

  /// All user fixtures
  static List<UserFixture> get all => [alex, marcus, priya, emma, john];

  /// Female users only
  static List<UserFixture> get females => all.where((u) => u.gender == 'female').toList();

  /// Male users only
  static List<UserFixture> get males => all.where((u) => u.gender == 'male').toList();

  /// Users with women-only mode enabled
  static List<UserFixture> get womenOnlyEnabled => all.where((u) => u.womenOnlyMode).toList();
}

/// Generate test users programmatically
class UserGenerator {
  static int _counter = 0;

  static UserFixture generate({
    String? gender,
    bool womenOnlyMode = false,
    String? homeCountry,
  }) {
    final id = 'user-${DateTime.now().millisecondsSinceEpoch}-$_counter';
    return UserFixture(
      id: id,
      email: '$id@test.com',
      firstName: 'User$_counter',
      gender: gender ?? (_counter % 2 == 0 ? 'female' : 'male'),
      ageRange: '25-30',
      homeCountry: homeCountry ?? 'US',
      womenOnlyMode: womenOnlyMode,
    );
  }

  static List<UserFixture> generateBatch(int count, {
    String? gender,
    bool womenOnlyMode = false,
  }) {
    return List.generate(count, (_) => generate(
      gender: gender,
      womenOnlyMode: womenOnlyMode,
    ));
  }

  static void reset() => _counter = 0;
}
