// Mock Supabase Client Helpers
// Utilities for mocking Supabase in tests

/// Mock Supabase Client Configuration
class MockSupabaseConfig {
  /// Local development URL
  static const String localUrl = 'http://localhost:54321';
  
  /// Test project URL (can be a real test project or local)
  static const String testUrl = String.fromEnvironment(
    'SUPABASE_TEST_URL',
    defaultValue: localUrl,
  );
  
  /// Test anon key
  static const String testAnonKey = String.fromEnvironment(
    'SUPABASE_TEST_ANON_KEY',
    defaultValue: 'test-anon-key',
  );
  
  /// Test service role key (for admin operations)
  static const String testServiceRoleKey = String.fromEnvironment(
    'SUPABASE_TEST_SERVICE_ROLE_KEY',
    defaultValue: 'test-service-role-key',
  );
  
  /// Whether to use real Supabase (for integration tests) or mocks (for unit tests)
  static const bool useRealSupabase = bool.fromEnvironment(
    'USE_REAL_SUPABASE',
    defaultValue: false,
  );
}

/// Mock response builder for Supabase queries
class MockSupabaseResponseBuilder {
  /// Build a successful query response
  static Map<String, dynamic> successResponse({
    List<Map<String, dynamic>>? data,
    int? count,
  }) => {
    'data': data ?? [],
    'error': null,
    'count': count ?? (data?.length ?? 0),
    'status': 200,
  };

  /// Build an error response
  static Map<String, dynamic> errorResponse({
    String? message,
    int? status,
    String? code,
  }) => {
    'data': null,
    'error': {
      'message': message ?? 'An error occurred',
      'code': code ?? 'UNKNOWN_ERROR',
    },
    'status': status ?? 400,
  };

  /// Build a single row response
  static Map<String, dynamic> singleRowResponse(Map<String, dynamic>? row) =>
    successResponse(data: row != null ? [row] : [], count: row != null ? 1 : 0);

  /// Build an empty response
  static Map<String, dynamic> emptyResponse() => successResponse(data: []);
}

/// Mock RPC (Remote Procedure Call) responses
class MockRpcResponses {
  /// Mock get_matches RPC response
  static List<Map<String, dynamic>> getMatches({
    List<Map<String, dynamic>>? matches,
  }) => matches ?? [];

  /// Mock create_trip RPC response
  static Map<String, dynamic> createTrip({
    required String id,
    required String destination,
  }) => {
    'id': id,
    'destination': destination,
    'status': 'created',
  };

  /// Mock validate_trip RPC response
  static Map<String, dynamic> validateTrip({
    bool valid = true,
    String? error,
  }) => {
    'valid': valid,
    'error': error,
  };

  /// Mock geocode RPC response
  static Map<String, dynamic> geocode({
    double? lat,
    double? lng,
    String? error,
  }) => {
    'latitude': lat,
    'longitude': lng,
    'error': error,
  };
}

/// Mock Supabase Auth responses
class MockAuthResponses {
  /// Mock successful sign up
  static Map<String, dynamic> signUp({
    required String userId,
    required String email,
  }) => {
    'user': {
      'id': userId,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    },
    'session': {
      'access_token': 'mock-access-token',
      'refresh_token': 'mock-refresh-token',
      'expires_at': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
    },
  };

  /// Mock successful sign in
  static Map<String, dynamic> signIn({
    required String userId,
    required String email,
  }) => signUp(userId: userId, email: email);

  /// Mock sign out
  static Map<String, dynamic> signOut() => {'success': true};

  /// Mock auth error
  static Map<String, dynamic> authError({
    String message = 'Invalid credentials',
  }) => {
    'error': {
      'message': message,
      'status': 401,
    },
    'user': null,
    'session': null,
  };
}

/// Mock RLS (Row Level Security) test helpers
class MockRlsTestHelper {
  /// Assert that a query is blocked by RLS
  static Map<String, dynamic> rlsBlocked() => MockSupabaseResponseBuilder.errorResponse(
    message: 'new row violates row-level security policy',
    code: 'PGRST301',
    status: 403,
  );

  /// Assert that a query passes RLS
  static Map<String, dynamic> rlsPassed({
    List<Map<String, dynamic>>? data,
  }) => MockSupabaseResponseBuilder.successResponse(data: data);
}

/// Mock Realtime channel responses
class MockRealtimeResponses {
  /// Mock presence state
  static Map<String, dynamic> presenceState({
    required String userId,
    bool online = true,
  }) => {
    'user_id': userId,
    'online': online,
    'last_seen': DateTime.now().toIso8601String(),
  };

  /// Mock broadcast message
  static Map<String, dynamic> broadcastMessage({
    required String from,
    required String to,
    required String content,
  }) => {
    'type': 'broadcast',
    'event': 'message',
    'payload': {
      'from': from,
      'to': to,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    },
  };

  /// Mock postgres change event
  static Map<String, dynamic> postgresChange({
    required String table,
    required String eventType, // INSERT, UPDATE, DELETE
    required Map<String, dynamic> record,
  }) => {
    'type': 'postgres_changes',
    'table': table,
    'eventType': eventType,
    'new': record,
    'old': eventType == 'DELETE' ? record : null,
  };
}

/// Mock PostGIS/spatial query responses
class MockSpatialResponses {
  /// Mock spatial match result
  static Map<String, dynamic> spatialMatch({
    required String userId,
    required String destination,
    required double distanceKm,
    required int overlapDays,
  }) => {
    'user_id': userId,
    'destination': destination,
    'distance_km': distanceKm,
    'overlap_days': overlapDays,
    'location': 'POINT(0 0)', // Would be actual coordinates
  };

  /// Mock geocode result
  static Map<String, dynamic> geocodeResult({
    required String address,
    required double lat,
    required double lng,
  }) => {
    'address': address,
    'latitude': lat,
    'longitude': lng,
    'location': 'POINT($lng $lat)',
  };
}

/// Test data seeding helpers
class TestDataSeeder {
  /// Generate SQL to seed test users
  static String seedUsers(List<Map<String, dynamic>> users) {
    final values = users.map((u) => '''(
      '${u['id']}',
      '${u['email']}',
      '${u['first_name']}',
      '${u['gender']}',
      '${u['age_range'] ?? '25-30'}',
      '${u['home_country']}',
      ${u['women_only_mode'] ?? false}
    )''').join(',\n    ');
    
    return '''
INSERT INTO users (id, email, first_name, gender, age_range, home_country, women_only_mode)
VALUES
    $values;
''';
  }

  /// Generate SQL to seed test trips
  static String seedTrips(List<Map<String, dynamic>> trips) {
    final values = trips.map((t) => '''(
      '${t['id']}',
      '${t['user_id']}',
      '${t['destination']}',
      ST_SetSRID(ST_GeomFromText('${t['location']}'), 4326),
      '${t['start_date']}',
      '${t['end_date']}',
      ${t['is_active'] ?? true}
    )''').join(',\n    ');
    
    return '''
INSERT INTO trips (id, user_id, destination, location, start_date, end_date, is_active)
VALUES
    $values;
''';
  }

  /// Generate SQL to clear test data
  static String clearTestData() => '''
DELETE FROM messages WHERE id LIKE 'msg-%' OR id LIKE 'test-%';
DELETE FROM matches WHERE id LIKE 'conn-%' OR id LIKE 'test-%';
DELETE FROM trips WHERE id LIKE 'trip-%' OR id LIKE 'test-%';
DELETE FROM users WHERE id LIKE 'user-%' OR id LIKE 'test-%';
''';
}
