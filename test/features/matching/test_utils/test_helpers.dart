// Test Helpers
// Common utilities for test setup and assertions

/// Test assertion helpers
class TestAssertions {
  /// Assert that a list is sorted
  static bool isSorted<T extends Comparable>(List<T> list, {bool ascending = true}) {
    if (list.length <= 1) return true;
    
    for (int i = 0; i < list.length - 1; i++) {
      final shouldAscend = list[i].compareTo(list[i + 1]) <= 0;
      if (ascending && !shouldAscend) return false;
      if (!ascending && shouldAscend) return false;
    }
    return true;
  }

  /// Assert that a list contains unique elements
  static bool hasUniqueElements<T>(List<T> list) {
    return list.toSet().length == list.length;
  }

  /// Assert that all elements satisfy a condition
  static bool allSatisfy<T>(List<T> list, bool Function(T) condition) {
    return list.every(condition);
  }

  /// Assert that no elements satisfy a condition
  static bool noneSatisfy<T>(List<T> list, bool Function(T) condition) {
    return list.every((e) => !condition(e));
  }

  /// Assert dates are in valid trip range (start <= end)
  static bool isValidDateRange(DateTime start, DateTime end) {
    return !start.isAfter(end);
  }

  /// Assert trip duration is within limits
  static bool isValidTripDuration(DateTime start, DateTime end, {
    int minDays = 1,
    int maxDays = 90,
  }) {
    final days = end.difference(start).inDays + 1;
    return days >= minDays && days <= maxDays;
  }
}

/// Test wait helpers for async operations
class TestWait {
  /// Wait until condition is true or timeout
  static Future<void> until(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final startTime = DateTime.now();
    
    while (DateTime.now().difference(startTime) < timeout) {
      if (condition()) return;
      await Future.delayed(interval);
    }
    
    throw AssertionError('Condition not met within $timeout');
  }

  /// Wait for a duration
  static Future<void> forDuration(Duration duration) async {
    await Future.delayed(duration);
  }

  /// Wait until a future completes
  static Future<T> forFuture<T>(Future<T> future, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return await future.timeout(timeout);
  }
}

/// Test comparison helpers
class TestComparisons {
  /// Check if two lists have same elements (order-independent)
  static bool haveSameElements<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    final aSet = a.toSet();
    final bSet = b.toSet();
    return aSet.length == bSet.length && aSet.containsAll(bSet);
  }

  /// Check if two maps are equal
  static bool mapsEqual<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  /// Check if list a contains all elements of list b
  static bool containsAll<T>(List<T> a, List<T> b) {
    return a.toSet().containsAll(b.toSet());
  }
}

/// Test data validators
class TestValidators {
  /// Validate user data
  static bool isValidUser(Map<String, dynamic> user) {
    return user.containsKey('id') &&
        user.containsKey('email') &&
        user['email'].toString().contains('@') &&
        user.containsKey('first_name') &&
        user.containsKey('gender') &&
        ['male', 'female', 'non-binary'].contains(user['gender']);
  }

  /// Validate trip data
  static bool isValidTrip(Map<String, dynamic> trip) {
    return trip.containsKey('id') &&
        trip.containsKey('user_id') &&
        trip.containsKey('destination') &&
        trip.containsKey('start_date') &&
        trip.containsKey('end_date') &&
        trip.containsKey('is_active');
  }

  /// Validate match data
  static bool isValidMatch(Map<String, dynamic> match) {
    return match.containsKey('id') &&
        match.containsKey('user_a_id') &&
        match.containsKey('user_b_id') &&
        match['user_a_id'] != match['user_b_id'];
  }

  /// Validate message data
  static bool isValidMessage(Map<String, dynamic> message) {
    return message.containsKey('id') &&
        message.containsKey('sender_id') &&
        message.containsKey('receiver_id') &&
        message.containsKey('content') &&
        message['content'].toString().isNotEmpty;
  }
}

/// Test matcher helpers for custom assertions
class TestMatchers {
  /// Matcher for dates within a range
  static bool isDateWithin(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  /// Matcher for numeric values within tolerance
  static bool isWithinTolerance(num value, num expected, num tolerance) {
    return (value - expected).abs() <= tolerance;
  }

  /// Matcher for valid UUID format
  static bool isValidUuid(String uuid) {
    final regex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return regex.hasMatch(uuid);
  }

  /// Matcher for valid email format
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(email);
  }

  /// Matcher for valid PostGIS POINT format
  static bool isValidPostgisPoint(String point) {
    final regex = RegExp(r'^POINT\(-?\d+\.?\d* -?\d+\.?\d*\)$');
    return regex.hasMatch(point);
  }
}

/// Test logger for debugging
class TestLogger {
  static bool enabled = false;
  
  static void log(String message) {
    if (enabled) {
      // ignore: avoid_print
      debugPrint('[TEST] $message');
    }
  }
  
  static void debugPrint(String msg) {
    // Helper method to avoid linter warning
  }
  
  static void logTestStart(String testName) {
    log('Starting: $testName');
  }
  
  static void logTestEnd(String testName, {bool passed = true}) {
    log('${passed ? "✓" : "✗"} $testName');
  }
  
  static void logData(String label, dynamic data) {
    log('$label: $data');
  }
}
